class jira::installer inherits atlassian::installer {
  # Change version number in order to install a more recent Jira version
  # Remember to verify that the response.varfile.erb template has the correct contents
  $jiraVersion = "5.2.4-${variant}"

  $jiraInstallerFileName = "atlassian-jira-${jiraVersion}.bin"
  $jiraInstallDir = "${atlassianDir}/jira"

  @atlassian::installer::atlassianUser { 'jira': home => '${jiraInstallDir}' }
  realize(AtlassianUser[jira])

  @atlassian::installer::atlassianInstance { 'jira':
    installerFileName => $jiraInstallerFileName,
    installDir        => $jiraInstallDir,
    version           => $jiraVersion,
  }
  realize(AtlassianInstance[jira])

}
