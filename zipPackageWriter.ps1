# load other modules
. $workspaceLocation\localHandler.ps1
. $workspaceLocation\remoteHandler.ps1
. $workspaceLocation\nuspecGen.ps1
. $workspaceLocation\toolsGen.ps1

function New-Package ($release, $version, $releaseNote) {
	# create the path
	$newPackagePath = "$packagePath\$version"
	# use out-null to redirect the output to null. (do not show out put)
	New-Item $newPackagePath -ItemType Directory -Force -Confirm:$false | Out-Null
	New-Item "$newPackagePath\tools" -ItemType Directory -Force -Confirm:$false | Out-Null
	
	# create install scripts
	New-Tools -path "$newPackagePath\tools" -release $release
	New-NuspecFile -path $newPackagePath -version $version -releaseNote $releaseNote

	# change the latest version
	$version | Out-File "$packagePath\latest_version.txt" -Encoding utf8
}

function Write-ZipPackage($githubRepo, $packageName) {
	$release = Get-RemoteRelease -githubRepo $githubRepo
	$profile = Read-Profile
	$remoteVersion = Get-RemoteVersion -remoteRelease $release
	$localVersion = $profile.$packageName.version
	if (-Not $Force) {
		if($remoteVersion -ne $localVersion) {
			$releaseNote = $release.body.replace("\n", "`r`n")
			New-Package -release $release -version $remoteVersion -releaseNote $releaseNote
		}
		else {
			Write-Host 'remote and local version match, exiting...' -ForegroundColor Green
		}
	}
	else {
		Write-Warning 'Force executing'
		$releaseNote = $release.body.replace("\n", "`r`n")
		New-Package -release $release -version $remoteVersion -releaseNote $releaseNote -description $description
	}
}
