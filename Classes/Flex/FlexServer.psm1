<#
 * FlexServer
 * 
 * Implementation for FlexLM license servers
 * Makes use of Flexera lmutils binary for remote querying.
 *
 * @author Stephen Mills
 * @license MIT 
#>

Using module ".\..\LicenseServer.psm1"
Using module ".\FlexFeature.psm1"

class FlexServer : LicenseServer {
    
    [String]$DaemonName
    [String]$DaemonStatus
    [String]$DaemonVersion
    [String]$LicenseFile

    FlexServer([String]$Hostname, [Int16]$Port, [String]$QueryUtilityPath, [Boolean]$ResolveHostname) : base ($Hostname, $Port, $QueryUtilityPath, $ResolveHostname) {
        
    }

    [void]AddFeature([FlexFeature]$Feature) {
        $this.Features.Add($Feature)
    }

    # Fetch Vendor Daemon Status
    [void]GetStatus() {
        $this.ParseStatus($this.QueryStatusRemoteMgmtTool())
    }

    # Fetch Vendor Daemon Features
    [void]GetFeatures() {
        $this.ParseFeatures($this.QueryFeaturesRemoteMgmtTool())
    }

    hidden [System.Array]QueryStatusRemoteMgmtTool() {
        return [System.Array](Invoke-Expression -Command "$($this.QueryUtilityPath) lmstat -c $($this.Port)@$($this.Hostname)")
    }

    hidden [System.Array]QueryFeaturesRemoteMgmtTool() {
        return [System.Collections.ArrayList](Invoke-Expression -Command "$($this.QueryUtilityPath) lmstat -c $($this.Port)@$($this.Hostname) -i")
    }

    hidden [System.Array]QueryFeatureUsageRemoteMgmtTool() {
        return @() #tba
    }
 
    # Parse lmutil status output
    hidden [void]ParseStatus([System.Array]$QueryResultSet) {
        try {
            $QueryResultSet = $QueryResultSet.Split("`r").Trim()
            $this.LicenseFile = ((($QueryResultSet[5]) -Split ":\s")[1]).Trim().TrimEnd(":")
            $this.DaemonName = (($QueryResultSet[11]).Split()[0]).TrimEnd(":")

            switch -Wildcard ($QueryResultSet[11]) {

                # LMGRD is responding but the vendor daemon has exited or not started
                # Often because vendor daemon ran out of valid feautures to serve (feature expiry),
                # Or because the vendor daemon failed to start (ie: couldn't bind to port, MS VC++ runtimes missing, etc)
                "*down*" {
                    $this.DaemonStatus = "DOWN (review license & logs files for errors)"
                    $this.DaemonVersion = "DOWN"
                    break
                }

                # LMGRD is responding but the vendor daemon cannot be communicated with
                # Perhaps vendor daemon is on a firewalled port?
                "*Cannot*" {
                    $this.DaemonStatus = "COMMS ERROR, vendor daemon port may be misconfigured."
                    $this.DaemonVersion = "COMMS ERROR, vendor daemon port may be misconfigured."
                }

                # No errors detected, attempt to parse as normal
                default {
                    $this.DaemonStatus = ($QueryResultSet[11]).Split()[1]
                    $this.DaemonVersion = ($QueryResultSet[11]).Split()[2] 
                }

            }

        }

        # We failed to parse, assume something catastrophically failed and report the entire server as down.
        catch {
            $this.DaemonName = "LMGRD DOWN"
            $this.DaemonStatus = "LMGRD DOWN"
            $this.DaemonVersion = "LMGRD DOWN"
            $this.LicenseFile = "LMGRD DOWN"
        }
    }

    # Parses output from lmutil lmstat
    hidden [void]ParseFeatures([System.Array]$QueryResultSet) {
        [System.Collections.ArrayList]$QueryResultSet = $QueryResultSet.Split("`n")
        # LMtools feature listing begins at line 10, if the returned list has under 10 lines
        # then it has no features listed.
        # Note: This can occur when querying FlexLM Trusted Storage licenses, as features using
        # Trusted Storage often arent listed in the license file.
        if ($QueryResultSet.Count -gt 9) {
            $QueryResultSet.RemoveRange(0, 9) # remove filler lines from lmutil output
            # Parse license file features and add feature objects to the current license.
            foreach ($QueryResult in $QueryResultSet) {
                $FeatureName, $FeatureVersion, $FeatureLicenses, $FeatureVendor, $FeatureExpires = ($QueryResult -replace '\s+', ' ').Split(' ')
                $this.AddFeature([FlexFeature]::new($FeatureName, $FeatureVersion, $FeatureLicenses, $FeatureExpires, $FeatureVendor))
            }       
        } 
    }
}