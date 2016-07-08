param(
    [string] $command,
    [string] $githubRepo,
	[string] $packageName,
    [switch] $All,
    [switch] $Force,
	[switch] $Alpha,
	[switch] $Nightly
)

# set the workspace location
$workspaceLocation = Split-Path $myInvocation.MyCommand.Definition -Parent

# load defualt value
if (-Not ($packageName)){
	$packageName = $($githubRepo -split '/')[1]
}
if (-Not ($packagePath)) {
	$packagePath = "$HOME\github2chocoPackages\$packageName-choco"
}
if (-Not ($packagePath)) {
	$templatePath = "$packagePath\$packageName"
}

# turn all the path to full path to avoid confusion
$packagePath = [System.IO.Path]::GetFullPath($packagePath)
$templatePath = [System.IO.Path]::GetFullPath($templatePath)


# load modules
. $workspaceLocation\zipPackageWriter.ps1


# update zip package
if ($command -eq 'update') {
	Write-ZipPackage -packageName $packageName
}

