# Source: https://www.itdroplets.com/get-sems-goodwe-data-with-powershell/

# SEMS Portal Main URL
$url = "https://www.semsportal.com" #HTTP url: euapi.sems.com.cn:82

#Login URL: SEMS Portal wants to run queries with a token, so we must authenticate first
$urlLogin = "/api/v1/Common/CrossLogin"
#Email/Pwd to the SEMS Portal
$Credentials = Get-Credential -Message "Email/Password for the SEMS Portal"
#$Credentials

#Build the json with the credentials that will be passed to Invoke-WebRequest's body
$LoginInfo = "{""account"":""$($Credentials.UserName)"",""pwd"":""$($Credentials.GetNetworkCredential().Password)""}"
#$LoginInfo

#Headers needed for the token request
$headersLogin = @{ 
  "Content-Type" = "application/json"
  Token = '{"version":"v2.1.0","client":"android","language":"en"}'
}
# Send the POST request and convert the content from Json
$TokenRequest = (Invoke-WebRequest -Uri "$($url)$($urlLogin)" -Headers $headersLogin -Method Post -Body $LoginInfo -UseBasicParsing).Content | ConvertFrom-Json
#$TokenRequest
$TokenRequest.msg
Write-output ">> TokenRequest.data: $($TokenRequest.data)"

#
# url for the actual request
#
$urlRequest = "/api/v1/PowerStation/GetMonitorDetailByPowerstationId"

#Prepare the header for actual request
$headersRequest = @{
  Accept = "application/json"
  "token" = "{""version"":""v2.1.0"",""client"":""android"",""language"":""en"",""timestamp"":""$($TokenRequest.data.timestamp)"",""uid"":""$($TokenRequest.data.uid)"",""token"":""$($TokenRequest.data.token)""}"
}
#Prepare the body for the request
$RequestBody = @{powerStationId="11111111-aaaa-bbbb-cccc-222222333333"}

#Make the request
$Request = (Invoke-WebRequest -Uri "$($url)$($urlRequest)" -Headers $headersRequest -Method Post -Body $RequestBody -UseBasicParsing).Content | ConvertFrom-Json

#Write-Output ">> Results of Request.data:"
#$Request.data

#Write-Output ">>>> Result of Request.data.inverter:"
#$Request.data.inverter

Write-Output ">>>> Today's generation is $($Request.data.inverter.daily_generation)"

