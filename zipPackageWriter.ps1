# load other modules
. $workspaceLocation\localHandler.ps1
. $workspaceLocation\remoteHandler.ps1
. $workspaceLocation\nuspecGen.ps1
. $workspaceLocation\toolsGen.ps1

function New-VersionPackage ($release, $newVersion, $releaseNote) {
	# create the path
	$newPackagePath = "$packagePath\$newVersion"
	# use out-null to redirect the output to null. (do not show out put)
	New-Item $newPackagePath -ItemType Directory -Force -Confirm:$false | Out-Null
	New-Item "$newPackagePath\tools" -ItemType Directory -Force -Confirm:$false | Out-Null
	
	# create install scripts
	New-Tools -path "$newPackagePath\tools" -release $release
	New-NuspecFile -path $newPackagePath -version $newVersion -releaseNote $releaseNote

	# change the latest version
	$newVersion | Out-File "$packagePath\latest_version.txt" -Encoding utf8
}

function Write-ZipPackage($packageName) {
	
	# load variable
	$profile = Read-Profile
	$localVersion = $profile.$packageName.version
	$githubRepo = $profile.$packageName.githubRepo
	$release = Get-RemoteRelease -githubRepo $githubRepo
	$remoteVersion = Get-RemoteVersion -remoteRelease $release

	# execute if not force
	if (-Not $Force) {
		if($remoteVersion -ne $localVersion) {
			$releaseNote = $release.body.replace("\n", "`r`n")
			New-VersionPackage -release $release -version $remoteVersion -releaseNote $releaseNote
		}
		else {
			Write-Host 'remote and local version match, exiting...' -ForegroundColor Green
		}
	}
	# force execute
	else {
		Write-Warning 'Force executing'
		$releaseNote = $release.body.replace("\n", "`r`n")
		New-VersionPackage -release $release -version $remoteVersion -releaseNote $releaseNote -description $description
	}

	# update the profile
	$profile.$packageName.version = $remoteVersion
	Save-Profile -localProfile $profile
}
