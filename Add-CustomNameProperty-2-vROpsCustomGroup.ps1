# Prevent certificate and SSL/TLS issues
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $True }
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12

####################################
# Get token with local credentials #
####################################

# Enter your credentials and vROps FQDN
$username = "username"
$password = "password"
$vropsFQDN = "vrops.fqdn.com"

$firstHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$firstHeaders.Add("Content-Type", "application/json; utf-8")
$firstHeaders.Add("Accept", "application/json")

$firstBody = "{
`n  `"username`" : `"$username`",
`n  `"password`" : `"$password`",
`n  `"others`" : [ ],
`n  `"otherAttributes`" : { }
`n}"

# Call token method
$uriStr = "https://"+$vropsFQDN+"/suite-api/api/auth/token/acquire"
$myFirstUri = [System.uri]$uriStr

$firstResponse = Invoke-RestMethod $myFirstUri -Method 'POST' -Headers $firstHeaders -Body $firstBody

# We get the token
$token = $firstResponse.token

#####################
# Get Custom Groups #
#####################

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json; utf-8")
$headers.Add("Accept", "application/json")
$headers.Add("Authorization", "vRealizeOpsToken $token")

$body = @{}

$uriCustomGroup = "https://"+$vropsFQDN+"/suite-api/api/resources/groups"
$myCustomGroup = [System.uri]$uriCustomGroup

$response = Invoke-RestMethod $myCustomGroup -Method 'GET' -Headers $headers -Body $body
$response | ConvertTo-Json

# Change custom group container name this according to your needs. Department, Location, Universe etc.
$key = "Environment"


for($i=0; $i -lt $response.groups.Length; $i++){


# Check custom group container name. If equals to $key, continue and create Custom Property.
if($response.groups.GetValue($i).resourcekey.resourceKindKey -eq $key) {

$id = $response.groups.GetValue($i).id
$groupName = $response.groups.GetValue($i).resourcekey.name

$headers2 = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers2.Add("Authorization", "vRealizeOpsToken $token")
$headers2.Add("Accept", "application/json")
$headers2.Add("Content-Type", "application/json; utf-8")

# statKey : This is the property name that we will see in Custom Group's Property section.
# timestamps : You can use dynamic variable here. If you use older timestamp, vROps will assign it to latest one.
# values : This will assign groupName to each custom group.
$body2 = "{
`n  `"property-content`" : [ {
`n    `"statKey`" : `"application|name`",
`n    `"timestamps`" : [ 1605764821000 ],
`n    `"values`" : [ `"$groupName`" ]
`n  } ]
`n}"

$uriResource = "https://"+$vropsFQDN+"/suite-api/api/resources/"+$id+"/properties"
$myResourceUri = [System.uri]$uriResource

$response2 = Invoke-RestMethod $myResourceUri -Method 'POST' -Headers $headers2 -Body $body2

}
}