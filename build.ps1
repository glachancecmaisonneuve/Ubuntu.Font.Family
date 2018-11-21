$pwd = ConvertTo-SecureString -String "UbuntuFontFamily" -Force -AsPlainText
if (-not (Test-Path -Path .\UbuntuFontFamily.pfx))
{
    New-SelfSignedCertificate -Type Custom -Subject "CN=Canonical Group Limited, L=London, C=UK" -KeyUsage DigitalSignature -FriendlyName Canonical -CertStoreLocation "Cert:\LocalMachine\My"
    Export-PfxCertificate -cert "Cert:\LocalMachine\My\61149C821041F02B1BA30B589F6B6E1D1A34CDF3" -FilePath .\UbuntuFontFamily.pfx -Password $pwd
}

$makeappx = (Get-Command -CommandType Application -Name MakeAppx.exe -ErrorAction Stop | Select-Object -Property Source -First 1 -ErrorAction Stop).Source
$signtool = (Get-Command -CommandType Application -Name SignTool.exe -ErrorAction Stop | Select-Object -Property Source -First 1 -ErrorAction Stop).Source

&$makeappx pack /o /d packagefiles /p ubuntu.appx /kf UbuntuFontFamily.pfx
&$signtool sign /a /fd SHA256 /f UbuntuFontFamily.pfx /p "UbuntuFontFamily" ubuntu.appx
