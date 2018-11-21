#requires -Version 5
$ErrorActionPreference = "Stop"
try
{
    $makeappx = (Get-Command -CommandType "Application" -Name MakeAppx.exe | Select-Object -Property 'Source' -First 1).Source
    $signtool = (Get-Command -CommandType "Application" -Name SignTool.exe | Select-Object -Property 'Source' -First 1).Source
}
catch
{
    Write-Error "MakeAppx.exe and SignTool.exe must be in the path before starting this script"
}

$pwd = ConvertTo-SecureString -String "UbuntuFontFamily" -Force -AsPlainText
if (-not (Test-Path -Path .\UbuntuFontFamily.pfx))
{
    $cert = New-SelfSignedCertificate -Type Custom -Subject "CN=Canonical Group Limited, L=London, C=UK" -KeyUsage DigitalSignature -FriendlyName Canonical -CertStoreLocation "Cert:\LocalMachine\My"
    Export-PfxCertificate -cert (Join-Path -Path Cert:\LocalMachine\My\ -ChildPath $cert.Thumbprint) -FilePath .\UbuntuFontFamily.pfx -Password $pwd
}

&$makeappx pack /o /d packagefiles /p ubuntu.appx /kf UbuntuFontFamily.pfx
&$signtool sign /a /fd SHA256 /f UbuntuFontFamily.pfx /p "UbuntuFontFamily" ubuntu.appx
