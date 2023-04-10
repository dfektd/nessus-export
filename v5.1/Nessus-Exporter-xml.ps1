<#
.DESCRIPTION
    Powershell script to export data from Nessus, reads from config.xml
    Edit config.xml with appropriate values.   

#>

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

#[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

#load data from config
[xml]$Data=Get-Content .\config.xml
$server = $Data.config.server
$port = $Data.config.port
$scanID = $Data.config.scanId
$filename = $Data.config.filename
$format = $Data.config.format
$accessKey = $Data.config.accessKey
$secretKey = $Data.config.secretKey


$Url = "https://${server}:${port}/scans/${scanID}/export"
$body = @{
        "format" = "$format" } |ConvertTo-Json

$header = @{
		"X-ApiKeys" = "accessKey=${accessKey}; secretKey=${secretKey}"
		"Content-Type" = "application/json"
}

[string]$response = Invoke-WebRequest -Uri $Url -Method Post -Headers $header -Body $body

#seperate file id for download
Get-Variable response
$f_id = $response.Split(":{}")
$file_id = $f_id[3]
Get-Variable file_id

#check file is status ready
$statusURL = "https://${server}:${port}/scans/${scanID}/export/${file_id}/status"
[string]$status = Invoke-WebRequest -Uri $statusURL -Method Get -Headers $header 
while ($status -ne '{"status":"ready"}')
	{
		[string]$status = Invoke-WebRequest -Uri $statusURL -Method Get -Headers $header 
		Get-Variable status	
	}
$exportURL = "https://${server}:${port}/scans/${scanID}/export/${file_id}/download"

#download file from server
Invoke-WebRequest -Uri $exportURL -Method GET -Headers $header -Outfile .\${filename}_${file_id}.$format 
