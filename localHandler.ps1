param(
    [string] $packagePath,
    [string] $templatePath,
    [string] $packageName
)

function Get-LocalVersion {
	if (Test-Path "$packagePath\latest_version.txt") {
		$version = Get-Content "$packagePath\latest_version.txt"
		Write-Host ''
		Write-Host 'successfully get the local version' -ForegroundColor Green
		Write-Host 'the local version is: ' -NoNewline -ForegroundColor Yellow
		Write-Host $version
	}
	else {
		Write-Warning 'no latest version file found'
		Write-Host 'use version 0.0.0 to continue' -ForegroundColor Green
	}
    

	# return
	$version
    
}

function Get-NuspecTemplate {
    $xml = [xml] $(Get-Content "$templatePath\$packageName.nuspec")
	Write-Host ''
    Write-Host 'successfull get the template file' -ForegroundColor Green
    
    # return
    $xml
}
