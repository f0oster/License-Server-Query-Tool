<#
 * Feature
 * 
 * Abstract base class for all license server features
 *
 * @author Stephen Mills
 * @license MIT 
#>

Class Feature {
    [String]$Name
    [String]$Version
    [Int32]$Licenses
    [String]$Expires

    [Int32]$DaysTillExpiry
    [Boolean]$Perpetual

    Feature($FeatureName, $FeatureVersion, $FeatureLicenses, $FeatureExpires) {
        $this.Name = $FeatureName
        $this.Version = $FeatureVersion
        $this.Licenses = $FeatureLicenses
        $this.Expires = $FeatureExpires
        
    }

    [void]CalculateTimeTillExpiry() {
        throw("Method CalculateTimeTillExpiry() must be overriden by inherited class.")
    }
	
}