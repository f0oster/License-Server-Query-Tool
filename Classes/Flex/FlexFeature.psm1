<#
 * FlexFeature
 * 
 * Implementation for FlexLM license features
 *
 * @author Stephen Mills
 * @license MIT 
#>

Using module ".\..\Feature.psm1"

# A FlexLM feature
Class FlexFeature : Feature {

    # FlexLM vendor daemon name
    [String]$Vendor

    FlexFeature([String]$FeatureName, [String]$FeatureVersion, $FeatureLicenses, [String]$FeatureExpires, [String]$FeatureVendor) : base ($FeatureName, $FeatureVersion, $FeatureLicenses, $FeatureExpires) {
        $this.Vendor = $FeatureVendor
        $this.CalculateTimeTillExpiry()
    }

    # Calculate number of days left for feature
    [void]CalculateTimeTillExpiry() {
        if ($this.Expires -like '*perm*' -or $this.Expires -like '*-*-0') {
            $this.DaysTillExpiry = 2147483647
            $this.Perpetual = $true
        }
        else {
            $this.DaysTillExpiry = (New-TimeSpan -Start (Get-Date) -End $this.Expires).Days
        }
    }
	
}