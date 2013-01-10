class atlassian::base {
  $atlassianDir = "/opt/atlassian"

  file { 'atlassian-dir':
    ensure => 'directory',
    path   => $atlassianDir,
    mode    => 744,    
  }

  define atlassianuser ($home) {
    group { $name: ensure => present, }

    user { $name:
      ensure     => present,
      comment    => "${name} user",
      gid        => $name,
      shell      => '/bin/bash',
      require    => Group[$name],
      managehome => true,
      home       => $home,
    }

  }

  define atlassianinstance ($installDir, $version, $dataDir, $httpPort = 8080, $rmiPort = 8005) {
    $variant = $architecture ? {
      i386    => 'x32',
      default => 'x64',
    }
    $appDir = "${installDir}/atlassian-${name}-${version}"
    $installerFileName = "atlassian-${name}-${version}-${variant}.bin"

    File {
      owner => $name,
      group => $name,
    }

    wget::fetch { 'installer':
      source      => "http://www.atlassian.com/software/${name}/downloads/binary/${installerFileName}",
      destination => "${installDir}/${installerFileName}",
      timeout     => 7200, # 2h
    }

    file { 'executable-installer':
      ensure  => 'present',
      path    => "/tmp/${installerFileName}",
      mode    => 755,
      require => [Wget::Fetch["installer"], User[$name]],
    }

    file { 'response-file':
      path    => "${installDir}/.response.varfile",
      content => template("atlassian/${name}-response.varfile.erb"),
      require => User[$name],
    }

    exec { 'atlassian-installer-exec':
      path    => '/usr/bin:/usr/sbin:/bin',
      unless  => "test -d ${appDir}",
      command => "${installDir}/${installerFileName} -q -varfile ${installDir}/.response.varfile",
      cwd     => $installDir,
      user    => $name,
      timeout => 7200, # 2h
      require => [File['executable-installer'], File['response-file']],
      notify  => [File["current-version-link"], File['current-data-link']],
    }

    file { 'current-version-link':
      path   => "${installDir}/current-${name}",
      ensure => link,
      target => $appDir,
    }

    file { 'current-data-link':
      path   => "${installDir}/current-data",
      ensure => link,
      target => $dataDir,
    }
  }

}