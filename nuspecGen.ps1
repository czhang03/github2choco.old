function New-NuspecFile($Path, $version, $releaseNote, $description) {
	$template = Get-NuspecTemplate

	# set value
	$template.package.metadata.description = $description
	$template.package.metadata.releaseNotes = $releaseNote
	# set version
	if ($Nightly) {
		$template.package.metadata.version = "$version-nightly"
	}
	elseif ($Alpha) {
		$template.package.metadata.version = "$version-alpha"
	}
	else {
		$template.package.metadata.version = "$version"	
	}

	$template.Save("$Path\$packageName.nuspec")
}
