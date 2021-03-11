<#
 * LicenseServer
 * 
 * Abstract base class for all license servers
 *
 * @author Stephen Mills
 * @license MIT 
#>

class LicenseServer {

    [String]$Hostname
    [String]$ServerName
    [Int16]$Port
    [String]$QueryUtilityPath

    [System.Collections.ArrayList]$Features

    LicenseServer([String]$Hostname, [Int16]$Port, [String]$QueryUtilityPath, [Boolean]$ResolveHostname) {

        $Type = $this.GetType()

        if ($Type -eq [LicenseServer]) {
            throw("Class $type is an abstract class and must be inherited, not directly instantiated.")
        } 

        $this.Hostname = $Hostname
        $this.Port = $Port
        $this.QueryUtilityPath = $QueryUtilityPath
        $this.Features = [System.Collections.ArrayList]::new()

        # Get the HOST/A Record for the associated DNS name (useful when unique CNAME records are used for each license service)
        if ($ResolveHostname) {
            try {
                $this.ServerName = Resolve-DnsName -Name $this.Hostname |
                Where-Object { $_.QueryType -eq 'A' } |
                Select-Object -Expand Name
            }
            catch {
                $this.ServerName = "UNRESOLVABLE"
            }
        }
        else {
            $this.ServerName = $Hostname
        }

    }

    [System.Array]QueryRemoteMgmtTool() {
        throw("Method QueryRemoteMgmtTool() must be overriden by inherited classes.")
    }

    [System.Array]ParseStatus() {
        throw("Method ParseStatus() must be overriden by inherited classes.")
    }

    [System.Array]ParseFeatures() {
        throw("Method ParseFeatures() must be overriden by inherited classes.")
    }

}