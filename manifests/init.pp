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

#This class depends heavily on the installer behaviour.
#It's probably better to use this class to setup a jira instance to package up.
class jira::installer {
  include wget
  
  # http://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-5.2.4-x64.bin
  $jiraVersion = "5.2.4-x64"
  $jiraInstallerFileName = "atlassian-jira-${jiraVersion}.bin"
  $jiraInstallDir = "/opt/atlassian/jira"

  wget::fetch { "atlassian-installer":
    source => "http://www.atlassian.com/software/jira/downloads/binary/${jiraInstallerFileName}",
    destination => "/tmp/${jiraInstallerFileName}",
    timeout => 30,
    mode   => 755,
  }

  file { 'responsefile':
    path    => "${jiraInstallDir}/.install4j/response.varfile",
    content => template('jira/response.varfile.erb'),   
  }
  
  exec { 'atlassian-installer-exec':
    command     => "/tmp/${jiraInstallerFileName}",
    refreshonly => true,
    subscribe   => Wget["atlassian-installer"],
    notify      => File["/opt/atlassian/jira/current"],
  } 

  file {"/opt/atlassian/jira/current":
     ensure => link,
     target => '/opt/atlassian/jira/atlassian-jira-${jiraVersion}',
   }

}
