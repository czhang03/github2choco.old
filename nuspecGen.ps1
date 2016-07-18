. $workspaceLocation\localHandler.ps1

function Get-NuspecTemplate($templatePath, $packageName) {
    $xml = [xml] $(Get-Content "$templatePath\$packageName.nuspec")
	Write-Host ''
    Write-Host 'successfull get the template file' -ForegroundColor Green
    
    return $xml
}

function Write-NuspecFile($Path, $packageName, $templatePath, $version, $releaseNote, $pre) {
	$template = Get-NuspecTemplate -packageName $packageName -templatePath $templatePath

	# set value
	$template.package.metadata.releaseNotes = $releaseNote
	# set version
	if ($pre -eq 'nightly') {
		$template.package.metadata.version = "$version-nightly"
	}
	elseif ($pre -eq 'alpha') {
		$template.package.metadata.version = "$version-alpha"
	}
	else {
		$template.package.metadata.version = "$version"	
	}

	$template.Save("$Path\$packageName.nuspec")
}
