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