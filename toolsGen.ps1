. $workspaceLocation\localHandler.ps1

$tempDir = "$HOME\AppData\local\temp"

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

    return $Url64, $Url32
}

function Get-32bitInstallerHash ($Url32) {

	if($Url32) {
		# download the 32 bit package
		Write-Host ''
		Write-Host 'Downloading 32 bit package to find the hash...' -ForegroundColor Green
		# try to start download 
		try {
			$webclient = New-Object net.webclient
			$webclient.Headers.Add('user-agent', [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox)
			$downloadFileName = "$tempDir\$packageName.x32.installer"
			$webclient.DownloadFile($Url32, $downloadFileName)
		}
		# exception handle
		catch {
			Write-Host 'webclient fail to download the file with the following error message:' -ForegroundColor Red
			Write-Host $_.exception.message -ForegroundColor Red
			Write-Host 'you can mannelly download the file and give me the file path'
			Write-Host 'or you can input the hash and the hash type'
			Write-Host '(you can enter empty hash to disable checksum for this version)'
			$option = Read-Host 'input [H]ash or [P]ath'
			if (($option.ToLower() -eq 'h') -or ($option.ToLower() -eq 'hash'))  {
				$Hash32 = Read-Host 'input the hash'
				$HashType32 = Read-Host 'input hash type (sha1, md5, sha256)'

				# just quit and give the hash
				return $Hash32, $HashType32
			}
			elseif (($option.ToLower() -eq 'f') -or ($option.ToLower() -eq 'file')) {
				$downloadFileName = Read-Host 'input the full path of the file'
			}
		}

		# get hash
		$Hash32 = (Get-FileHash -Path $downloadFileName -Algorithm SHA256).hash
		Write-Host 'successfully get hash of 32bit package' -ForegroundColor Green
		Write-Host 'the sha256 hash of 32bit package is: ' -NoNewline -ForegroundColor Yellow
		Write-Host $Hash32
	}
	else {
		Write-Host ''
		Write-Warning '32 bit package not found' 
		Read-Host 'Press enter to continue, press Ctrl-C to stop'
		$Hash32 = ''
	}

    return $Hash32, 'sha256'
}


function Get-64bitInstallerHash ($Url64) {
	if($Url64) {
		# download the 64 bit package
		Write-Host ''
		Write-Host 'Downloading 64 bit package to find the hash...' -ForegroundColor Green
		
		# try to start download 
		try {
			$webclient = New-Object net.webclient
			$webclient.Headers.Add('user-agent', [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox)
			$downloadFileName = "$tempDir\$packageName.x64.installer"
			$webclient.DownloadFile($Url64, $downloadFileName)
		}
		# fail to download the file
		catch {
			Write-Host 'webclient fail to download the file with the following error message:' -ForegroundColor Red
			Write-Host $_.exception.message -ForegroundColor Red
			Write-Host 'you can mannelly download the file and give me the file path'
			Write-Host 'or you can input the hash and the hash type'
			Write-Host '(you can enter empty hash to disable checksum for this version)'
			$option = Read-Host 'input [H]ash or [P]ath'
			# manully input the hash
			if (($option.ToLower() -eq 'h') -or ($option.ToLower() -eq 'hash'))  {
				$Hash64 = Read-Host 'input the hash'
				$HashType64 = Read-Host 'input hash type (sha1, md5, sha256)'

				# just quit and give the hash
				return $Hash64, $HashType64
			}
			# input the downloaded file
			elseif (($option.ToLower() -eq 'f') -or ($option.ToLower() -eq 'file')) {
				$downloadFileName = Read-Host 'input the full path of the file'
			}
		}
		
		# get hash
		$Hash64 = (Get-FileHash -Path $downloadFileName -Algorithm SHA256).hash
		Write-Host 'successfully get hash of 64bit package' -ForegroundColor Green
		Write-Host 'the sha256 hash of 64bit package is: ' -NoNewline -ForegroundColor Yellow
		Write-Host $Hash64
	}
	else{
		Write-Host
		Write-Warning '64 bit package not found' 
		Read-Host 'Press enter to continue, press Ctrl-C to stop'
		$Hash64 = ''	
	}

    return $Hash64, 'sha256'
}

function New-InstallString ($Url64, $Url32, $Hash64, $Hash32, $HashType32, $HashType64) {
	# make the install string
	$installPathStr = '$(Split-Path -Parent $MyInvocation.MyCommand.Definition)'
	$installStr = "Install-ChocolateyZipPackage -packageName '$packageName' -UnzipLocation $installPathStr"
	if($Url64) {
		$installStr += " -Url64bit '$Url64'"
		if ($Hash64) {
			$installStr += "-Checksum64 '$Hash64' -ChecksumType64 '$HashType64'"
		}
	}
	if($Url32) {
		$installStr += " -Url '$Url32'"
		if ($Hash32) {
			$installStr += "-Checksum '$Hash32' -ChecksumType '$HashType32'"
		}
	}

	return $installStr 
}

function Write-Tools ($Path, $release, $Regex32bit, $Regex64bit) {
	# get the download url
	$Url64, $Url32 = Get-DownloadUrl -release $release -Regex32bit $Regex32bit -Regex64bit $Regex64bit
	$Hash32, $HashType32 = Get-32bitInstallerHash -Url32 $Url32
	$Hash64, $HashType64 = Get-64bitInstallerHash -Url64 $Url64 
	$installStr = New-InstallString -Url64 $Url64 -Url32 $Url32 -Hash64 $Hash64 -Hash32 $Hash32 -HashType32 $HashType32 -HashType64 $HashType64
    $installStr | Out-File "$Path\chocolateyinstall.ps1" -Encoding utf8
}
