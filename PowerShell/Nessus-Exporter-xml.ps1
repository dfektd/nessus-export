<#
.DESCRIPTION
    Powershell script to export data from Nessus, reads from config.xml
   
.EXAMPLE
    Export-Nessus -server <IP> -port <port> -scanID <ID> -filename <filename> -format <csv/pdf/html> -accessKey <> -secretKey <>
    Export-Nessus -server 192.168.1.100 -port 8834 -filename prod-scan -format csv -accessKey 1234 -secretKey 5678
    Port and Filename are optional.
#>

#load data from config
[xml]$Data=Get-Content .\config.xml
$server = $Data.config.server
$port = $Data.config.port
$scanID = $Data.config.scanId
$filename = $Data.config.filename
$format = $Data.config.format
$accessKey = $Data.config.accessKey
$secretKey = $Data.config.secretKey

#ignore ssl errors for 5.1
$code= @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
            public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) {
                return true;
            }
        }
"@
Add-Type -TypeDefinition $code -Language CSharp
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

$Url	= "https://${server}:${port}/scans/${scanID}/export"
	$body 	= @{
		"format" = "$format" } |ConvertTo-Json
	$header = @{
		"X-ApiKeys" = "accessKey=${accessKey}; secretKey=${secretKey}"
		"Content-Type" = "application/json"
	}

	[string]$response = Invoke-WebRequest -Uri $Url -Method Post -Headers $header -Body $body

	#Start-Sleep -Seconds 60
	Get-Variable response
	$f_id = $response.Split(":{}")
	$file_id = $f_id[3]
	Get-Variable file_id
	$exportURL = "https://${server}:${port}/scans/$scanID/export/$file_id/download"
	#download file from server
	Invoke-WebRequest -Uri $exportURL -Method GET -Headers $header -Outfile .\${filename}_$file_id.$format
