# == Class: jira
#
# Full description of class jira here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { jira:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2011 Your name here, unless otherwise noted.
#

# This class depends heavily on the installer behaviour.
# It's probably better to use this class to setup a jira instance to package up.
class jira::installer {
  include wget

  # http://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-5.2.4-x64.bin
  $atlassianDir = "/opt/atlassian"
  $jiraVersion = "5.2.4-x64"
  $jiraInstallerFileName = "atlassian-jira-${jiraVersion}.bin"
  $jiraInstallDir = "${atlassianDir}/jira"

  wget::fetch { "jira-installer":
    source      => "http://www.atlassian.com/software/jira/downloads/binary/${jiraInstallerFileName}",
    destination => "/tmp/${jiraInstallerFileName}",
    timeout     => 7200, # 2h
  }

  file { 'executable-installer':
    ensure => 'present',
    path   => "/tmp/${jiraInstallerFileName}",
    group  => 'jira',
    owner  => 'jira',
    mode   => 755,
  }

  file { 'atlassian-dir':
    ensure => "directory",
    path   => "${atlassianDir}",
    owner  => root,
    group  => root,
  }

  file { 'jira-home':
    path    => "${jiraInstallDir}",
    ensure  => "directory",
    require => File['atlassian-dir'],
    group   => 'jira',
    owner   => 'jira',
  }

  group { 'jira': ensure => present, }

  user { 'jira':
    ensure     => present,
    comment    => "Jira user",
    gid        => "jira",
    shell      => "/bin/bash",
    require    => [File['jira-home'], Group["jira"]],
    managehome => true,
    home       => "${jiraInstallDir}",
  }

  file { 'response-file':
    path    => "${jiraInstallDir}/.response.varfile",
    content => template('jira/response.varfile.erb'),
    group   => 'jira',
    owner   => 'jira',
  }

  exec { 'atlassian-installer-exec':
    path      => "/usr/bin:/usr/sbin:/bin",
    unless    => "test -d ${jiraInstallDir}/atlassian-jira-${jiraVersion}",
    command   => "/tmp/${jiraInstallerFileName} -q -varfile ${jiraInstallDir}/.response.varfile",
    cwd       => "${jiraInstallDir}/",
    user      => "jira",
    timeout   => 7200, # 2h
    require   => File['response-file'],
    subscribe => [Wget::Fetch["jira-installer"], File['executable-installer']],
    notify    => File["current-jira-link"],
  }

  file { 'current-jira-link':
    require => User['jira'],
    path    => "${jiraInstallDir}/current-jira",
    ensure  => link,
    target  => "${jiraInstallDir}/atlassian-jira-${jiraVersion}",
  }

}
