function Read-LocalPrfile {
	Write-Host ''
	$profilePath = Split-Path $myInvocation.MyCommand.Definition -Parent
	$profileFullName = "$profilePath\profile.json"
	if (Test-Path $profileFullName) {
		Write-Host 'profile found' -ForegroundColor Green	
		$profile = Get-Content $profileFullName
	}
	else {
		Write-Host 'Profile Not Found, starting with an empty profile'
		$profile = New-Object -TypeName psobject
	}

	#return
	$profile
}

function Get-LocalVersion($localProfile, $packageName) {
	# return
	$localProfile.$packageName.version
}

function Get-PackagePath ($localProfile, $packageName) {
	#return
	$localProfile.$packageName.packagePath
}

function Get-GithubRepo ($localRelease, $packageName) {
	#return
	$localProfile.$packageName.githubRepo
}

function Get-NuspecTemplate($profile, $packageName) {
	$templatePath = $localProfile.$packageName.templatePath
    $xml = [xml] $(Get-Content "$templatePath\$packageName.nuspec")
	Write-Host ''
    Write-Host 'successfull get the template file' -ForegroundColor Green
    
    # return
    $xml
}

function Save-Profile($localProfile) {
	$profilePath = Split-Path $myInvocation.MyCommand.Definition -Parent
	$profileFullName = "$profilePath\profile.json"
	ConvertFrom-Json $localProfile | Out-File $profileFullName -Encoding utf8
}
