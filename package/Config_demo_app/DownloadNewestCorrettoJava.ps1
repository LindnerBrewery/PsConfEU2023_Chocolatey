## Download corretto
[String]$uri = "https://corretto.aws/downloads/latest/amazon-corretto-17-x64-windows-jdk.zip"
$wr = invoke-WebRequest $uri -Method Head
Invoke-WebRequest -Uri $($wr.BaseResponse.RequestMessage.RequestUri.AbsoluteUri) -OutFile $PSScriptRoot/tools/$($wr.BaseResponse.RequestMessage.RequestUri.Segments[-1])