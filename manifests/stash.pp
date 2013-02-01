class atlassian::stash inherits atlassian::base {
  # Change version number in order to install a more recent stash version
  # Remember to verify that the response.varfile.erb template has the correct contents
  $stashVersion = "2.0.3"

  $stashInstallDir = "${atlassianDir}/stash"

  @atlassian::base::atlassianuser { 'stash': home => $stashInstallDir }
  realize(Atlassian::Base::Atlassianuser[stash])

  $appDir = "${stashInstallDir}/atlassian-${name}-${stashVersion}"

  exec { 'atlassian-installer-exec':
    path    => '/usr/bin:/usr/sbin:/bin',
    unless  => "test -d ${appDir}",
    command => "tar -zxf /tmp/atlassian-stash-${stashVersion}.tar.gz",
    cwd     => $stashInstallDir,
    user    => 'stash',
    timeout => 7200, # 2h
    notify  => [File["current-version-link"], File['current-data-link']],
  }

  file { 'current-version-link':
    path   => "${stashInstallDir}/current",
    ensure => link,
    target => $appDir,
  }

  file { 'data-dir':
    ensure => directory,
    path   => '/data/stash-data',
    owner  => 'stash',
    group  => 'stash',
  }

  file { 'current-data-link':
    path    => "${stashInstallDir}/stash-data",
    ensure  => link,
    target  => '/data/stash-data',
    require => File['data-dir'],
  }

}
