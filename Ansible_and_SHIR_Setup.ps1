# This is a wrapper script to execute both the WinRM setup script for Ansible and the SHIR setup script from Microsoft

# Sources
# Ansible(WinRM) Config: https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1
# SHIR Config: https://raw.githubusercontent.com/Azure/azure-quickstart-templates/00b79d2102c88b56502a63041936ef4dd62cf725/101-vms-with-selfhost-integration-runtime/gatewayInstall.ps1

param(
 [string]$gatewayKey,
 [string]$SubjectName = $env:COMPUTERNAME,
 [int]$CertValidityDays = 1095,
 [switch]$SkipNetworkProfileCheck,
 [bool]$CreateSelfSignedCert = $true,
 [switch]$ForceNewSSLCert,
 [switch]$GlobalHttpFirewallAccess,
 [switch]$DisableBasicAuth = $false,
 [switch]$EnableCredSSP,
 [string]$RemotingScriptURI = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1",
 [string]$SHIRScriptURI = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/00b79d2102c88b56502a63041936ef4dd62cf725/101-vms-with-selfhost-integration-runtime/gatewayInstall.ps1"
)


# Download Files
$RemotingScriptLocal = ".\ConfigureRemotingForAnsible.ps1"
Invoke-WebRequest -Uri $RemotingScriptURI -OutFile $RemotingScriptLocal
$SHIRScriptLocal = ".\InstallIntegrationRuntime.ps1"
Invoke-WebRequest -Uri $SHIRScriptURI -OutFile $SHIRScriptLocal


# Execute Scripts
& $RemotingScriptLocal -gatewayKey $gatewayKey

$shirParms = @{
    SubjectName = $SubjectName
    CertValidityDays = $CertValidityDays
    CreateSelfSignedCert = $CreateSelfSignedCert
}

if ($SkipNetworkProfileCheck) {
    $shirParms['SkipNetworkProfileCheck'] = $true
}
if ($ForceNewSSLCert) {
    $shirParms['ForceNewSSLCert'] = $true
}
if ($GlobalHttpFirewallAccess) {
    $shirParms['GlobalHttpFirewallAccess'] = $true
}
if ($DisableBasicAuth) {
    $shirParms['DisableBasicAuth'] = $true
}
if ($EnableCredSSP) {
    $shirParms['EnableCredSSP'] = $true
}

& SHIRScriptLocal @shirParms
