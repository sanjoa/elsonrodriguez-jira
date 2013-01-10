class atlassian::jira inherits atlassian::base {
  # Change version number in order to install a more recent Jira version
  # Remember to verify that the response.varfile.erb template has the correct contents
  $jiraVersion = "5.2.4"

  $jiraInstallDir = "${atlassianDir}/jira"

  @atlassian::base::atlassianuser { 'jira': home => $jiraInstallDir }
  realize(Atlassian::Base::Atlassianuser[jira])

  @atlassian::base::atlassianinstance { 'jira':
    installDir => $jiraInstallDir,
    version    => $jiraVersion,
    dataDir    => "${jiraInstallDir}/jira-data",
  }
  realize(Atlassian::Base::Atlassianinstance[jira])

}
