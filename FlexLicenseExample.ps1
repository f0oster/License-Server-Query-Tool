<#
 * @author Stephen Mills
 * @license MIT 
 * @Notes:

The following script queries all provided servers and lists their status, total features and expired features.

==================
Example output
==================

Port Hostname                            ServerName                      DaemonName DaemonStatus                                          Expired Features Total Features
---- --------                            ----------                      ---------- ------------                                          ---------------- --------------
27040 lic-icnanometer.redacted           redacted                        mgcld      DOWN (review license & logs files for errors)                      118            118
27024 lic-STKD.redacted                  redacted                        STKD       DOWN (review license & logs files for errors)                       23             23
25755 lic-arena.redacted                 redacted                        flexsvr    UP                                                                  22             24
27111 lic-msc.redacted                   redacted                        MSC        UP                                                                  19            243
27049 lic-icfd.redacted                  redacted                        METACOMP   UP                                                                  16             23
27008 lic-autodesk.redacted              redacted                        adskflex   UP                                                                  11            117
27120 lic-cadence.redacted               redacted                        cdslmd     UP                                                                   9            235
 1711 lic-altera.redacted                redacted                        alterad    UP                                                                   1             11
27010 lic-avl.redacted                   redacted                        avl        DOWN (review license & logs files for errors)                        0              0
27035 lic-geomagic.redacted              redacted                        LMGRD DOWN LMGRD DOWN                                                           0              0
27036 lic-astos.redacted                 redacted                        LMGRD DOWN LMGRD DOWN                                                           0              0
27000 lic-3dvia.redacted                 redacted                        LMGRD DOWN LMGRD DOWN                                                           0              0
 1715 lic-msi.redacted                   redacted                        msi        UP                                                                   0             19
27018 lic-ads.redacted                   redacted                        agileesofd UP                                                                   0              4
27003 lic-arcgis.redacted                redacted                        ARCGIS     UP                                                                   0              1
 7788 lic-mathcad.redacted               redacted                        ptc_d      UP                                                                   0             33
27035 lic-geomagic.redacted              redacted                        geowatch   COMMS ERROR, vendor daemon port may be misconfigured.                0              9
27100 lic-origin.redacted                redacted                        orglab     UP                                                                   0              1

#>

Using module ".\Classes\Flex\FlexServer.psm1"

$LMUtilPath = "/path/to/lmutil.exe"
$ServiceAddresses = @(
    "27000@flexserver01",
    "27001@flexserver01",
    "27000@flexserver02"
)

# Fetch and return license info for the provided service addresses.
function Get-FlexLicenseInfo() {

    Param(
        [parameter(Mandatory = $true)]
        [Array] $ServiceAddresses 
    )

    $Licenses = [System.Collections.ArrayList]::new()

    foreach ($ServiceAddress in $ServiceAddresses) {
        $Port, $Hostname = $ServiceAddress.Split("@")
        $FlexLicense = [FlexServer]::new($Hostname, $Port, $LMUtilPath, $true)
        $FlexLicense.GetStatus()
        $FlexLicense.GetFeatures()
        $null = $Licenses.Add($FlexLicense) 
    }
        
    return $Licenses
    
}

Get-FlexLicenseInfo -ServiceAddresses $ServiceAddresses | Select-Object -Property Port, Hostname, ServerName, DaemonName, DaemonStatus, 
@{ Name = 'Expired Features'; Expression = {  
        (($_.Features | Where-Object { $_.DaysTillExpiry.GetType() -eq [Int32] -and $_.DaysTillExpiry -lt 1 }) | Measure-Object).Count
    }
},
@{ Name = 'Total Features'; Expression = {  
        ($_.Features).Count
    }
} `
| Sort-Object -Property "Expired Features" -Descending | Format-Table
