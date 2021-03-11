Using module ".\..\Classes\Flex\FlexServer.psm1"

$DoNotResolveHostname = $false
$Hostname = "localhost"
$LmUtilBinary = "NULL"
$Port = 27000

$Global:License = [FlexServer]::new($Hostname, $Port, $LmUtilBinary, $DoNotResolveHostname)

Describe -Name "FlexServerClasses - ParseStatus" {

$VendorDaemonStatusOutput = "lmutil - Copyright (c) 1989-2017 Flexera Software LLC. All Rights Reserved.
Flexible License Manager status on Mon 5/6/2019 18:04

[Detecting lmgrd processes...]
License server status: 27008@REDACTEDSERVERNAME
    License file(s) on REDACTEDSERVERNAME: F:\Program Files\Autodesk\Autodesk.lic:

REDACTEDSERVERNAME: license server UP (MASTER) v11.14.1

Vendor daemon status (on REDACTEDSERVERNAME):

  adskflex: UP v11.14.1"

    $License.ParseStatus($VendorDaemonStatusOutput)

    It "parses the vendor daemon name" {
        $License.DaemonName | Should -Be "adskflex"
    }

    It "parses the vendor daemon version" {
        $License.DaemonVersion | Should -Be "v11.14.1"
    }

    It "parses the server status" {
        $License.DaemonStatus | Should -Be "UP"
    }

    It "parses the license file path" {
        $License.LicenseFile | Should -Be "F:\Program Files\Autodesk\Autodesk.lic"
    }

}

Describe -Name "FlexServerClasses - ParseFeatures" {

$VendorDaemonFeatureOutputWithPerpetualFeature = "lmutil - Copyright (c) 1989-2017 Flexera Software LLC. All Rights Reserved.
Mon 5/6/2019 18:20

NOTE: lmstat -i does not give information from the server,
      but only reads the license file.  For this reason,
      lmstat -a is recommended instead.

Feature                         Version     #licenses    Vendor        Expires
_______                         _________   _________    ______        ________
License_Holder                  2016.050     999         msi           31-MAY-0
License_Holder                  2016.050     999         msi           permanent(no expiration date)
License_Holder                  2019.060     999         msi           28-jun-2020
MS_visualizer                   2016.050     5           msi           31-MAY-0
MS_dmol_ui                      2019.060     1           msi           30-JUN-0"

    $License.ParseFeatures($VendorDaemonFeatureOutputWithPerpetualFeature)

    It "should return 5 features" {
        $License.Features.Count | Should -Be 5
    }

    It "parses a feature name" {
        $License.Features[0].Name | Should -Be "License_Holder"
    }

    It "parses a vendor daemon name" {
        $License.Features[0].Vendor | Should -Be "msi"
    }

    It "parses a feature version" {
        $License.Features[0].Version | Should -Be "2016.050"
    }

    It "parses a features license quantity" {
        $License.Features[0].Licenses | Should -Be 999
    }

    It "parses a feature with a zero year expiry date (perpetual)" {
        $License.Features[0].Expires | Should -Be "31-MAY-0 "
    }

    It "parses a feature with a permanent expiry date (perpetual)" {
        $License.Features[1].Expires | Should -Be "permanent(no expiration date) "
    }

    It "parses a feature with a regular expiry date (non-perpetual)" {
        $License.Features[2].Expires | Should -Be "28-jun-2020 "
    }

}