param([string]$url = "url", [string]$path = "path")

$client = New-Object System.Net.WebClient
$client.DownloadFile($url, $path)