param(
	[Parameter(Mandatory=$true, Position=0)]
	[ValidateSet('new', 'update')]
    [string] $command,
	[Parameter(Mandatory=$false, Position=1)]
	[string] $package,
	[string] $packageType,
    [switch] $All,
    [switch] $Force,
	[switch] $Alpha,
	[switch] $Nightly
)

$ErrorActionPreference = 'stop'

# set the workspace location
$workspaceLocation = Split-Path $myInvocation.MyCommand.Definition -Parent

# load modules
. $workspaceLocation\zipPackageWriter.ps1

# create a new choco package
if ($command -eq 'new') {
	# package is the github repo name
	$githubRepo = $package

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

}

# update zip package
if ($command -eq 'update') {
	# package is the package name, not github repo name
	$packageName = $package
	if ($all) {
		# do the work here
		Update-AllZipPackage -Force $Force
	}
	else {
		# do the work here
		Update-ZipPackage -packageName $packageName -Force $Force
	}
	
	
}

