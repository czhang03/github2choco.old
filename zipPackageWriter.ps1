param(
	[String] $packagePath,
	[String] $templatePath,
	[string] $githubRepo,
	[switch] $Force,
	[switch] $Alpha,
	[switch] $Nightly,
	[string] $Regex32bit,
	[string] $Regex64bit,
	[string] $packageName
)

$ErrorActionPreference = "stop"

# set the workspace location
$workspaceLocation = Split-Path $myInvocation.MyCommand.Definition -Parent

# turn all the path to full path to avoid confusion
$packagePath = [System.IO.Path]::GetFullPath($packagePath)
$templatePath = [System.IO.Path]::GetFullPath($templatePath)

# load defualt value
$tempDir = "$HOME\AppData\Local\Temp"
if(-Not ($templatePath)){
	$templatePath = "$packagePath\template"
}

if (-Not ($packageName)) {
	$packageName = Split-Path -Path $packagePath -Leaf
}

# load other modules
. $workspaceLocation/nuspecGen.ps1
. $workspaceLocation/remoteHandler.ps1 -githubRepo $githubRepo
. $workspaceLocation/localHandler.ps1 -packagePath $packagePath -templatePath $templatePath -packageName $packageName

function New-Tools ($Path, $release) {
	# get the package url
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

	# download the installer to get the hash
	if($64assets) {
		$Url64 = $64assets[0].browser_download_url  # take the first url
		Write-Host ''
		Write-Host 'the 64 bit package url is: ' -ForegroundColor Yellow -NoNewline
		Write-Host $Url64

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
	if($32assets) {
		$Url32 = $32assets[0].browser_download_url # take the first url
		Write-Host ''
		Write-Host 'the 32 bit package url is: ' -ForegroundColor Yellow -NoNewline
		Write-Host $Url32

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

	# make the install string
	$installPathStr = '$(Split-Path -Parent $MyInvocation.MyCommand.Definition)'
	$installStr = "Install-ChocolateyZipPackage -packageName '$packageName' -UnzipLocation $installPathStr"
	if($Url64) {
		$installStr += " -Url64bit '$Url64' -Checksum64 '$Hash64' -ChecksumType64 'sha256'"
	}
	if($Url32) {
		$installStr += " -Url '$Url32' -Checksum '$Hash32' -ChecksumType 'sha256'"
	}

	$installStr | Out-File "$Path\chocolateyinstall.ps1" -Encoding utf8
}

function New-Package ($release, $version, $releaseNote, $description) {
	# create the path
	$newPackagePath = "$packagePath\$version"
	# use out-null to redirect the output to null. (do not show out put)
	New-Item $newPackagePath -ItemType Directory -Force -Confirm:$false | Out-Null
	New-Item "$newPackagePath\tools" -ItemType Directory -Force -Confirm:$false | Out-Null
	
	# create install scripts
	New-Tools -path "$newPackagePath\tools" -release $release
	New-NuspecFile -path $newPackagePath -version $version -releaseNote $releaseNote -description $description

	# change the latest version
	$version | Out-File "$packagePath\latest_version.txt" -Encoding utf8
}

function Write-ZipPackage {
	$release = Get-RemoteRelease
	$remoteVersion = Get-RemoteVersion -remoteRelease $release
	$localVersion = Get-LocalVersion
	if (-Not $Force) {
		if($remoteVersion -ne $localVersion) {
			$releaseNote = $release.body.replace("\n", "`r`n")
			$nuspecTemplate = Get-NuspecTemplate
			$description = $nuspecTemplate.package.metadata.description
			New-Package -release $release -version $remoteVersion -releaseNote $releaseNote -description $description
		}
		else {
			Write-Host 'remote and local version match, exiting...' -ForegroundColor Green
		}
	}
	else {
		Write-Warning 'Force executing'
		$releaseNote = $release.body.replace("\n", "`r`n")
		$nuspecTemplate = Get-NuspecTemplate
		$description = $nuspecTemplate.package.metadata.description
		New-Package -release $release -version $remoteVersion -releaseNote $releaseNote -description $description
	}
}
