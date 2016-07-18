function Get-RemoteRelease($githubRepo) {
	$githubUrl = "https://api.github.com/repos/$githubRepo/releases/latest"

	# get the github api to get info of the release
	try {
		$webClient = New-Object Net.WebClient
    	$webClient.Headers.Add('user-agent', [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox)
    	$Release = ConvertFrom-Json $($webClient.DownloadString($githubUrl))
	}
	catch  {
		Write-Host 'fetching github api failed with the following error message' -ForegroundColor Red
		Write-Host $_.exception.message -ForegroundColor Red
		Write-Host 'exiting the script'
		return
	}
    
	# log the info
	Write-Host ''
    Write-Host 'successfull fetched the remote' -ForegroundColor Green
	Write-Host 'the latest version is: ' -NoNewline -ForegroundColor Yellow
	Write-Host $Release.tag_name
	Write-Host 'the author is: ' -NoNewline -ForegroundColor Yellow
	Write-Host $Release.author.login
	Write-Host 'The release is created at: '-NoNewline -ForegroundColor Yellow
	Write-Host $Release.created_at
	Write-Host 'The release is published at: ' -NoNewline -ForegroundColor Yellow
	Write-Host $Release.published_at

    return $Release
}

function Get-RemoteVersion ($remoteRelease) {
	$tag = $remoteRelease.tag_name.toLower()
	$version = $tag.Replace('v', '')
	Write-Host ''
	Write-Host "successfully get the version of the remote, the version is $version" -ForegroundColor Green 

	return $version
}
