class atlassian::stash inherits atlassian::base {
  # Change version number in order to install a more recent stash version
  # Remember to verify that the response.varfile.erb template has the correct contents
  $stashVersion = "2.4.1"

  $stashInstallDir = "${atlassianDir}/stash"
  $serverProxyName = 'git.aktia.bank'

  @atlassian::base::atlassianuser { 'stash': home => $stashInstallDir }
  realize(Atlassian::Base::Atlassianuser[stash])

  $appDir = "${stashInstallDir}/atlassian-stash-${stashVersion}"

  exec { 'atlassian-installer-exec':
    path    => '/usr/bin:/usr/sbin:/bin',
    unless  => "test -d ${appDir}",
    command => "tar -zxvf /tmp/atlassian-stash-${stashVersion}.tar.gz",
    cwd     => $stashInstallDir,
    user    => 'stash',
    timeout => 7200, # 2h
    notify  => [
      File["current-version-link"],
      File['current-data-link'],
      File['mysql-driver'],
      Line['stash-home'],
      Line['java-home']],
  }

  file { 'current-version-link':
    path   => "${stashInstallDir}/current",
    ensure => link,
    target => $appDir,
  }

  # TODO utf8 alter DATABASE stashdb CHARACTER SET utf8 COLLATE utf8_bin;
  file { 'mysql-driver':
    path   => "${appDir}/lib/mysql-connector-java-5.1.23-bin.jar",
    owner  => 'stash',
    group  => 'stash',
    source => "puppet:///modules/atlassian/mysql-connector-java-5.1.23-bin.jar",
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

  line { 'stash-home':
    file => "${stashInstallDir}/current/bin/setenv.sh",
    line => "export STASH_HOME=${stashInstallDir}/stash-data"
  }

  # TODO externalize java home path
  line { 'java-home':
    file => "${stashInstallDir}/current/bin/setenv.sh",
    line => "export JAVA_HOME=/usr/lib/jvm/jdk1.6.0_39/"
  }

  line { 'host':
    file => '/etc/hosts',
    line => "${ipaddress}   ${fqdn} ${hostname}"
  }

  file { 'server.xml':
    path    => "${stashInstallDir}/current/conf/server.xml",
    content => template("atlassian/stash.server.xml.erb"),
    owner  => 'stash',
    group  => 'stash',
  }


  line { 'proxy-host':
    file => '/etc/hosts',
    line => '10.6.8.10  aktia.proxy',
  }

  line { 'proxy-config':
    file => '/opt/atlassian/stash/current/bin/setenv.sh',
    line => 'JAVA_OPTS="-Dhttp.proxyHost=aktia.proxy -Dhttp.proxyPort=8080 -Dhttp.nonProxyHosts=*.aktia.bank"',
  }


  define line ($file, $line, $position = 'start', $ensure = 'present') {
    case $position {
      start   : { $pos = '1i' }
      end     : { $pos = '$a' }
      default : { $pos = $position }
    }

    case $ensure {
      default : {
        err("unknown ensure value ${ensure}")
      }
      present : {
        exec { "/bin/sed -i '${pos}${line}' ${file}": unless => "/bin/grep -qFx '${line}' '${file}'" }
      }
      absent  : {
        exec { "/bin/grep -vFx '${line}' '${file}' | /usr/bin/tee '${file}' > /dev/null 2>&1": onlyif => "/bin/grep -qFx '${line}' '${file}'" 
        }
      }
    }
  }

}
