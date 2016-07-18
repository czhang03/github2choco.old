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

function New-LatestVersionLink ($packagePath, $newVersion) {
	# init variable
	$ShortcutPath = Join-Path -Path $packagePath -ChildPath 'latestVersion.lnk'
	$ShortcutTargetPath = Join-Path -Path $packagePath -ChildPath $newVersion

	# log
	Write-Host 'Creating shortcut for the latest version' -ForegroundColor Green
	Write-Host "shortcut location will be $ShortcutPath" -ForegroundColor Green

	# create short cut
	$WshShell = New-Object -comObject WScript.Shell
	$Shortcut = $WshShell.CreateShortcut($ShortcutPath) 
	$Shortcut.TargetPath = $ShortcutTargetPath
	$Shortcut.Save() 
	Remove-Variable 'Shortcut'
	Remove-Variable 'WshShell'

	#log
	Write-Host 'shortcut saved' -ForegroundColor Green
}
