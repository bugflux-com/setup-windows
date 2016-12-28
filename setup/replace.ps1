param([string]$my_file = "my_file", [string]$find = "find", [string]$replace = "replace")

$content = [System.IO.File]::ReadAllText($my_file).Replace($find,$replace)
[System.IO.File]::WriteAllText($my_file, $content)