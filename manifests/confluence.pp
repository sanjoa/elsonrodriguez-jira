class confluence::installer inherits atlassian::installer {
  # Change version number in order to install a more recent confluence version
  # Remember to verify that the response.varfile.erb template has the correct contents
  $confluenceVersion = "4.3.5-${variant}"

  $confluenceInstallerFileName = "atlassian-confluence-${confluenceVersion}.bin"
  $confluenceInstallDir = "${atlassianDir}/confluence"

  @atlassian::installer::atlassianUser { 'confluence': home => '${confluenceInstallDir}' }
  realize(AtlassianUser[confluence])

  @atlassian::installer::atlassianInstance { 'confluence':
    installerFileName => $confluenceInstallerFileName,
    installDir        => $confluenceInstallDir,
    version           => $confluenceVersion,
  }
  realize(AtlassianInstance[confluence])

}