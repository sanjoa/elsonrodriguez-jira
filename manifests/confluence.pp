class atlassian::confluence inherits atlassian::base {
  # Change version number in order to install a more recent Confluence version
  # Remember to verify that the response.varfile.erb template has the correct contents
  $confluenceVersion = "4.3.5-${variant}"

  $confluenceInstallerFileName = "atlassian-confluence-${confluenceVersion}.bin"
  $confluenceInstallDir = "${atlassianDir}/confluence"

  @atlassian::base::atlassianuser { 'confluence': home => $confluenceInstallDir }
  realize(Atlassian::Base::Atlassianuser[confluence])

  @atlassian::base::atlassianinstance { 'confluence':
    installerFileName => $confluenceInstallerFileName,
    installDir        => $confluenceInstallDir,
    version           => $confluenceVersion,
  }
  realize(Atlassian::Base::Atlassianinstance[confluence])

}