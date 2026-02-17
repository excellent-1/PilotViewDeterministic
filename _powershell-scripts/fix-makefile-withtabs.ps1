$inputFile = "Makefile"
$outputFile = "Makefile.fixed"

Get-Content $inputFile | ForEach-Object {
    if ($_ -match "^[ ]{2,}[^ ]") {
        "`t" + ($_.TrimStart())
    } else {
        $_
    }
} | Set-Content $outputFile

Write-Host "Fixed file written to $outputFile"




Move-Item -Force Makefile.fixed Makefile