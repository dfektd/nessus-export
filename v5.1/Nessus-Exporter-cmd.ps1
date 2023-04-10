<#
.DESCRIPTION
    Command line based script to export scan results from Nessus for PowerShell Version 5.1
   
.EXAMPLE
    Export-Nessus -server <IP> -port <port> -scanId <ID> -filename <filename> -format <csv/pdf/html> -accessKey <> -secretKey <>
    Export-Nessus -server 192.168.1.100 -port 8834 -filename prod-scan -format csv -accessKey 1234 -secretKey 5678
    Port and Filename are optional.
#>


param ([string]$server, [int]$port='8834', [int]$scanId, [string]$filename='output', [string]$format, [string]$accessKey, [string]$secretKey)

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



if( ($server) -and ($scanId) -and ($format) -and ($accessKey) -and ($secretKey) )

{

	$Url	= "https://${server}:${port}/scans/${scanID}/export"
	$body 	= @{
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
    [string]$status = Invoke-WebRequest -Uri $statusURL -Method Get -Headers $header -verbose
    while ($status -ne '{"status":"ready"}')
	    {
		    [string]$status = Invoke-WebRequest -Uri $statusURL -Method Get -Headers $header 
		    Get-Variable status	
	    }

	$exportURL = "https://${server}:${port}/scans/$scanId/export/$file_id/download"
	#download file from server
	Invoke-WebRequest -Uri $exportURL -Method Get -Headers $header -Outfile .\${filename}_$file_id.$format

	}

else {
	write-host  "Missing Params! `nUsage: Export-Nessus -server <IP> -port <port> -scanID <ID> -filename <filename> -format <csv/pdf/html> -accessKey <> -secretKey <>`nPort and filename are optional"

	}
