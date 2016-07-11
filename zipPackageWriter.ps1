# load other modules
. $workspaceLocation\localHandler.ps1
. $workspaceLocation\remoteHandler.ps1
. $workspaceLocation\nuspecGen.ps1
. $workspaceLocation\toolsGen.ps1

function New-VersionPackage ($profile, $release, $packageName) {
	# load info from remote release
	$newVersion = Get-RemoteVersion -remoteRelease $release
	$releaseNote = $release.body.replace("\n", "`r`n")

	# load info from the local profile
	$Regex32bit = $profile.$packageName.Regex32bit
	$Regex64bit = $profile.$packageName.Regex64bit
	$packagePath = $profile.$packageName.packagePath
	$templatePath = $profile.$packageName.templatePath

	# create the path
	$newPackagePath = "$packagePath\$newVersion"
	# use out-null to redirect the output to null. (do not show out put)
	New-Item $newPackagePath -ItemType Directory -Force -Confirm:$false | Out-Null
	New-Item "$newPackagePath\tools" -ItemType Directory -Force -Confirm:$false | Out-Null
	
	# create install scripts
	Write-Tools -path "$newPackagePath\tools" -release $release -Regex32bit $Regex32bit -Regex64bit $Regex64bit
	Write-NuspecFile -path $newPackagePath -packageName $packageName -version $newVersion -releaseNote $releaseNote -templatePath $templatePath

	# change the latest version
	$newVersion | Out-File "$packagePath\latest_version.txt" -Encoding utf8
}

function Update-ZipPackage($packageName, $Force) {
	
	# load variable
	$profile = Read-LocalPrfile
	$localVersion = $profile.$packageName.version
	$githubRepo = $profile.$packageName.githubRepo
	$release = Get-RemoteRelease -githubRepo $githubRepo
	$remoteVersion = Get-RemoteVersion -remoteRelease $release

	# execute if not force
	if (-Not $Force) {
		if($remoteVersion -ne $localVersion) {
			New-VersionPackage -profile $profile -release $release -packageName $packageName
		}
		else {
			Write-Host 'remote and local version match, exiting...' -ForegroundColor Green
		}
	}
	# force execute
	else {
		Write-Warning 'Force executing'
		New-VersionPackage -profile $profile -release $release -packageName $packageName
	}

	# update the profile
	$profile.$packageName.version = $remoteVersion
	Save-Profile -localProfile $profile
}
