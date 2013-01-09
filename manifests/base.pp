class atlassian::base {
  $variant = $architecture ? {
    amd64   => 'x64',
    x86_64  => 'x64',
    default => 'x32',
  }
  $atlassianDir = "/opt/atlassian"

  file { 'atlassian-dir':
    ensure => "directory",
    path   => "${atlassianDir}",
  }

  define atlassianuser ($home) {
    group { "${name}": ensure => present, }

    user { "${name}":
      ensure     => present,
      comment    => "${name} user",
      gid        => "${name}",
      shell      => "/bin/bash",
      require    => Group["$name"],
      managehome => true,
      home       => "${home}",
    }

  }

  define atlassianinstance ($installerFileName, $installDir, $version) {
    File {
      owner => "${name}",
      group => "${name}",
    }

    wget::fetch { "installer":
      source      => "http://www.atlassian.com/software/${name}/downloads/binary/${installerFileName}",
      destination => "/tmp/${installerFileName}",
      timeout     => 7200, # 2h
    }

    file { 'executable-installer':
      ensure  => 'present',
      path    => "/tmp/${installerFileName}",
      mode    => 755,
      require => Wget::Fetch["installer"],
    }

    file { 'response-file':
      path    => "${installDir}/.response.varfile",
      content => template('jira/${name}-response.varfile.erb'),
    }

    exec { 'atlassian-installer-exec':
      path    => "/usr/bin:/usr/sbin:/bin",
      unless  => "test -d ${installDir}/atlassian-${name}-${version}",
      command => "/tmp/${installerFileName} -q -varfile ${installDir}/.response.varfile",
      cwd     => "${installDir}/",
      user    => "${name}",
      timeout => 7200, # 2h
      require => [File['executable-installer'], File['response-file']],
      notify  => File["current-link"],
    }

    file { 'current-link':
      path    => "${installDir}/current",
      ensure  => link,
      target  => "${installDir}/atlassian-${name}-${version}",
    }

  }

}