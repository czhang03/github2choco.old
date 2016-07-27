function Read-LocalPrfile {
	Write-Host ''
	$profilePath = "$PSScriptRoot\.."
	$profileFullName = "$profilePath\profile.json"
	if (Test-Path $profileFullName) {
		Write-Host 'profile found' -ForegroundColor Green	
		$profile = Get-Content $profileFullName | ConvertFrom-Json
	}
	else {
		Write-Host 'Profile Not Found, starting with an empty profile'
		$profile = New-Object -TypeName psobject
	}

	
	return $profile
}

function Save-Profile($localProfile) {
	$profilePath = "$PSScriptRoot\.."
	$profileFullName = "$profilePath\profile.json"
	ConvertTo-Json $localProfile | Out-File $profileFullName -Encoding utf8

	Write-Host 'Profile Successfully saved'
}

function New-VersionLog ($packagePath, $newVersion) {
	# init variable
	$LogPath = Join-Path -Path $packagePath -ChildPath 'latestVersion'

	# log
	Write-Host 'logging the latest version in the folder for you to access the latest version programatically' -ForegroundColor Green
	Write-Host "version log location will be $ShortcutPath" -ForegroundColor Green

	# create short cut
	$newVersion | Out-File $LogPath -Encoding utf8

	#log
	Write-Host 'log saved' -ForegroundColor Green
}
