param([string]$zipfile = "zipfile", [string]$outpath = "outpath")
Add-Type -AssemblyName System.IO.Compression.FileSystem

[System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)