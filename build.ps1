$pwd = ConvertTo-SecureString -String "UbuntuFontFamily" -Force -AsPlainText 
if (-not (Test-Path -Path .\UbuntuFontFamily.pfx)) {
    New-SelfSignedCertificate -Type Custom -Subject "CN=Canonical Group Limited, L=London, C=UK" -KeyUsage DigitalSignature -FriendlyName Canonical -CertStoreLocation "Cert:\LocalMachine\My"
    Export-PfxCertificate -cert "Cert:\LocalMachine\My\61149C821041F02B1BA30B589F6B6E1D1A34CDF3" -FilePath .\UbuntuFontFamily.pfx -Password $pwd
}

#I don't want powershell files to be packaged
ATTRIB +H Invoke-BatchFile.ps1
ATTRIB +H build.ps1
pushd VSSETUP
ATTRIB +H * /S
popd

$makeappx = (Get-Command -CommandType Application -Name MakeAppx.exe | Select-Object -Property Source -First 1).Source
if ([String]::IsNullOrEmpty($makeappx)) {
    Write-Error "start-powershell from a visual studio command prompt" 
    return
}
$signtool = (Get-Command -CommandType Application -Name SignTool.exe  | Select-Object -Property Source -First 1).Source
if ([String]::IsNullOrEmpty($signtool)) {
    Write-Error "start-powershell from a visual studio command prompt" 
    return
}

&$makeappx pack /o /d . /p ubuntu.appx /kf UbuntuFontFamily.pfx
&$signtool sign /a /fd SHA256 /f UbuntuFontFamily.pfx /p "UbuntuFontFamily" ubuntu.appx


ATTRIB -H VSSETUP
ATTRIB -H * /S
