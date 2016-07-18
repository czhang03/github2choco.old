. $PSScriptRoot\localHandler.ps1

function Get-NuspecTemplate($templatePath, $packageName) {
    $xml = [xml] $(Get-Content "$templatePath\$packageName.nuspec")
	Write-Host ''
    Write-Host 'successfull get the template file' -ForegroundColor Green
    
    return $xml
}

function Write-NuspecFile($Path, $packageName, $nuspecFilePath, $version, $releaseNote, $pre) {
	$nuspecFile = Get-NuspecTemplate -packageName $packageName -templatePath $nuspecFilePath

	# set value
	$nuspecFile.package.metadata.releaseNotes = $releaseNote
	# set version
	if ($pre -eq 'nightly') {
		$nuspecFile.package.metadata.version = "$version-nightly"
	}
	elseif ($pre -eq 'alpha') {
		$nuspecFile.package.metadata.version = "$version-alpha"
	}
	else {
		$nuspecFile.package.metadata.version = "$version"	
	}

	$nuspecFile.Save("$Path\$packageName.nuspec")
}
