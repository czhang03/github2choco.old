# set the workspace location
$workspaceLocation = Split-Path $myInvocation.MyCommand.Definition -Parent

# turn all the path to full path to avoid confusion
$packagePath = [System.IO.Path]::GetFullPath($packagePath)
$templatePath = [System.IO.Path]::GetFullPath($templatePath)

# load defualt value
$tempDir = "$HOME\AppData\Local\Temp"
if(-Not ($templatePath)){
	$templatePath = "$packagePath\template"
}

if (-Not ($packageName)) {
	$packageName = Split-Path -Path $packagePath -Leaf
}

# load other modules
. $workspaceLocation/nuspecGen.ps1
. $workspaceLocation/remoteHandler.ps1
. $workspaceLocation/localHandler.ps1

function New-Package ($release, $version, $releaseNote, $description) {
	# create the path
	$newPackagePath = "$packagePath\$version"
	# use out-null to redirect the output to null. (do not show out put)
	New-Item $newPackagePath -ItemType Directory -Force -Confirm:$false | Out-Null
	New-Item "$newPackagePath\tools" -ItemType Directory -Force -Confirm:$false | Out-Null
	
	# create install scripts
	New-Tools -path "$newPackagePath\tools" -release $release
	New-NuspecFile -path $newPackagePath -version $version -releaseNote $releaseNote -description $description

	# change the latest version
	$version | Out-File "$packagePath\latest_version.txt" -Encoding utf8
}

function Write-ZipPackage {
	$release = Get-RemoteRelease -githubRepo $githubRepo
	$remoteVersion = Get-RemoteVersion -remoteRelease $release
	$localVersion = Get-LocalVersion
	if (-Not $Force) {
		if($remoteVersion -ne $localVersion) {
			$releaseNote = $release.body.replace("\n", "`r`n")
			$nuspecTemplate = Get-NuspecTemplate
			$description = $nuspecTemplate.package.metadata.description
			New-Package -release $release -version $remoteVersion -releaseNote $releaseNote -description $description
		}
		else {
			Write-Host 'remote and local version match, exiting...' -ForegroundColor Green
		}
	}
	else {
		Write-Warning 'Force executing'
		$releaseNote = $release.body.replace("\n", "`r`n")
		$nuspecTemplate = Get-NuspecTemplate
		$description = $nuspecTemplate.package.metadata.description
		New-Package -release $release -version $remoteVersion -releaseNote $releaseNote -description $description
	}
}
