param(
    [string] $command,
    [string] $githubRepo,
    [switch] $All,
    [switch] $Force,
	[string] $packagePath,
	[string] $templatePath,
	[string] $packageName,
	[switch] $Alpha,
	[switch] $Nightly
)

# set the workspace location
$workspaceLocation = Split-Path $myInvocation.MyCommand.Definition -Parent

if (-Not ($packageName)){
	$packageName = $($githubRepo -split '/')[1]
}
if (-Not ($packagePath)) {
	$packagePath = "$HOME\github2chocoPackages\$packageName-choco"
}
if (-Not ($packagePath)) {
	$templatePath = "$packagePath\$packageName"
}

# load modules
. $workspaceLocation\zipPackageWriter.ps1
