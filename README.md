## Nessus Export Scripts

 Various scripts to export data from Tenable Nessus.  Tested primarily with Nessus Essentials, should work for all licenses.


## Scripts
/Powershell - Powershell scripts
  
/Perl - Perl scripts

## Usage
 ### Perl: 
    
    Edit config.xml with necessary parameters
    
    perl ./nessus-export.pl --xml config.xml  
    
    or
    
    perl ./nessus-export.pl --server <server> --port <port> --scanId <#> --filename <text to prepend> --format <csv/html/pdf/nessusdb> --user <username> --pass <password>
    
### Powershell
    
      Edit config.xml with necessary parameters
              
      PowerShell -File .\Nessus-Exporter-xml.ps1  (Reads from config.xml)
      
      or
      
      PowerShell -File .\Nessus-Exporter-cmd.ps1 -server <IP> -port <port> -scanId <ID> -filename <filename> -format <csv/pdf/html> -accessKey <> -secretKey <>
      
