$TLS_CA_CN = Read-Host -Prompt "Enter desired Certificate Authority common name (e.g. server.com): "
$SHARED_SAN = Read-Host -Prompt "Enter desired server common name (e.g. vault.server.com) (this will be the same value provided to the module's leader_tls_servername variable):"

Write-Host "Generating CA"
$rootca = New-SelfSignedCertificate -CertStoreLocation cert:\CurrentUser\My -DnsName $TLS_CA_CN -KeyUsage CertSign,CRLSign -TextExtension @("2.5.29.19={text}CA=TRUE") -NotAfter(Get-Date).AddDays(30)
Write-Host "Writing CA public cert to rootca.pem"
$rootcaPem=new-object System.Text.StringBuilder
$rootcaPem.AppendLine("-----BEGIN CERTIFICATE-----")
$rootcaPem.AppendLine([System.Convert]::ToBase64String($rootca.RawData,1))
$rootcaPem.AppendLine("-----END CERTIFICATE-----")
$rootcaPem.ToString() | out-file rootca.pem
Write-Host "Generating server cert"
$vaultcert = New-SelfSignedCertificate -CertStoreLocation cert:\CurrentUser\My -Subject $SHARED_SAN -KeyUsage DigitalSignature,KeyAgreement,KeyEncipherment -Type Custom -TextExtension @("2.5.29.17={text}DNS=$SHARED_SAN&DNS=localhost&IPAddress=127.0.0.1","2.5.29.37={text}1.3.6.1.5.5.7.3.2,1.3.6.1.5.5.7.3.1") -Signer $rootca -NotAfter(Get-Date).AddDays(30)
Write-Host "Bundling cert, key, and CA cert into certificate-to-import.pfx"
Export-PfxCertificate -FilePath certificate-to-import.pfx -Cert $vaultcert -Password (new-object System.Security.SecureString)
