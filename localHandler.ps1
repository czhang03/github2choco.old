function Read-LocalPrfile {
	Write-Host ''
	$profilePath = $workspaceLocation
	$profileFullName = "$profilePath\profile.json"
	if (Test-Path $profileFullName) {
		Write-Host 'profile found' -ForegroundColor Green	
		$profile = Get-Content $profileFullName | ConvertFrom-Json
	}
	else {
		Write-Host 'Profile Not Found, starting with an empty profile'
		$profile = New-Object -TypeName psobject
	}

	#return
	$profile
}

function Save-Profile($localProfile) {
	$profilePath = $workspaceLocation
	$profileFullName = "$profilePath\profile.json"
	ConvertTo-Json $localProfile | Out-File $profileFullName -Encoding utf8

	Write-Host 'Profile Successfully saved'
}
