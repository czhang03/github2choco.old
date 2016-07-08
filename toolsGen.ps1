function Get-DownloadUrl ($release, $Regex32bit, $Regex64bit) {
    # get the package assets
	$assets = $release.assets
	# match 32 bit regex
	if ([string]::IsNullOrEmpty($Regex32bit)) {
		Write-Host 'no 32 bit regex provided.'
		$32assets = @()
	}
	else {
		$32assets = $($assets | where {$_.name -like $Regex32bit})
	}
	# match 64 bit regex
	if ([string]::IsNullOrEmpty($Regex64bit)) {
		Write-Host 'no 64 bit regex provided.'
		$64assets = @()
	}
	else {
		$64assets = $($assets | where {$_.name -like $Regex64bit})
	}
	# log
	Write-Host ''
	Write-Host 'successfully found the package url' -ForegroundColor Green

    # get url
    if($64assets) {
		$Url64 = $64assets[0].browser_download_url  # take the first url
		Write-Host ''
		Write-Host 'the 64 bit package url is: ' -ForegroundColor Yellow -NoNewline
		Write-Host $Url64
    }
    if($32assets) {
		$Url32 = $32assets[0].browser_download_url # take the first url
		Write-Host ''
		Write-Host 'the 32 bit package url is: ' -ForegroundColor Yellow -NoNewline
		Write-Host $Url32
    }

    # return
    $Url64, $Url32
}

function Get-FileHash ($Url64, $Url32) {
	# download the installer to get the hash
	if($Url64) {
		# download the 64 bit package
		Write-Host 'Downloading 64 bit package to find the hash...' -ForegroundColor Green
		$webclient = New-Object net.webclient
		$webclient.Headers.Add('user-agent', [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox)
		$downloadFileName = "$tempDir\$packageName.x64.installer"
		$webclient.DownloadFile($Url64, $downloadFileName)
		$Hash64 = (Get-FileHash -Path $downloadFileName -Algorithm SHA256).hash
		Write-Host 'successfully get hash of 64bit package' -ForegroundColor Green
		Write-Host 'the sha256 hash of 64bit package is: ' -NoNewline -ForegroundColor Yellow
		Write-Host $Hash64
	}
	else{
		Write-Host
		Write-Warning '64 bit package not found' 
		Read-Host 'Press enter to continue, press Ctrl-C to stop'	
	}
	if($Url32) {
		# download the 64 bit package
		Write-Host 'Downloading 32 bit package to find the hash...'
		$downloadFileName = "$tempDir\$packageName.x32.installer"
		$webclient = New-Object net.webclient
		$webclient.Headers.Add('user-agent', [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox)
		$webclient.DownloadFile($Url32, $downloadFileName)
		$Hash32 = (Get-FileHash -Path $downloadFileName -Algorithm SHA256).hash
		Write-Host 'successfully get hash of 32bit package' -ForegroundColor Green
		Write-Host 'the sha256 hash of 32bit package is: ' -NoNewline -ForegroundColor Yellow
		Write-Host $Hash32
	}
	else {
		Write-Host ''
		Write-Warning '32 bit package not found' 
		Read-Host 'Press enter to continue, press Ctrl-C to stop'	
	}

    # return
    $Hash64, $Hash32
}

function New-InstallString ($Url64, $Url32, $Hash64, $Hash32) {
	# make the install string
	$installPathStr = '$(Split-Path -Parent $MyInvocation.MyCommand.Definition)'
	$installStr = "Install-ChocolateyZipPackage -packageName '$packageName' -UnzipLocation $installPathStr"
	if($Url64) {
		$installStr += " -Url64bit '$Url64' -Checksum64 '$Hash64' -ChecksumType64 'sha256'"
	}
	if($Url32) {
		$installStr += " -Url '$Url32' -Checksum '$Hash32' -ChecksumType 'sha256'"
	}

    #return
	$installStr 
}

function Write-Tools ($Path, $release, $Regex32bit, $Regex64bit) {
	# get the download url
	$Url64, $Url32 = Get-DownloadUrl -release $release -Regex32bit $Regex32bit -Regex64bit $Regex64bit
	$Hash64, $Hash32 = Get-FileHash -Url64 $Url64 -Url32 $Url32
	$installStr = New-InstallString -Url64 $Url64 -Url32 $Url32 -Hash64 $Hash64 -Hash32 $Hash32
    $installStr | Out-File "$Path\chocolateyinstall.ps1" -Encoding utf8
}
