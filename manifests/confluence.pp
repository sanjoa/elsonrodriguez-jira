class atlassian::confluence inherits atlassian::base {
  # Change version number in order to install a more recent confluence version
  # Remember to verify that the response.varfile.erb template has the correct contents
  $confluenceVersion = "4.3.5-${variant}"

  $confluenceInstallerFileName = "atlassian-confluence-${confluenceVersion}.bin"
  $confluenceInstallDir = "${atlassianDir}/confluence"

  @atlassian::installer::atlassianuser { 'confluence': home => '${confluenceInstallDir}' }
  realize(Atlassianuser[confluence])

  @atlassian::installer::atlassianinstance { 'confluence':
    installerFileName => $confluenceInstallerFileName,
    installDir        => $confluenceInstallDir,
    version           => $confluenceVersion,
  }
  realize(Atlassianinstance[confluence])

}