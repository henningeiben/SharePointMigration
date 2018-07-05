<#
.SYNOPSIS
    Erstellt eine Infrastruktur auf der Basis von Migrationen
.DESCRIPTION
    TBD
.PARAMETER webUrl
    Die URL an die die Migration angewendet werden soll
.PARAMETER targetDeployment
    bis zu welcher Migration soll die Infrastruktur erstellt werden
.PARAMETER username
    Optional: Benutzername zur Authentifizierung an der WebURL
.PARAMETER password
    Optional: Passwort zur Authentifizierung an der WebURL als SecureString
.EXAMPLE
    Create-Structure -webUrl https://acme.local.com/sites/foo
.EXAMPLE
    Create-Structure -webUrl https://acme.local.com/sites/foo -username bigboss -password ('password' | ConvertTo-SecureString -AsPlainText -Force)
#>
param (
[parameter(Mandatory = $true)]
    [string]$webUrl,
    [parameter(Mandatory = $false)]
    [string]$targetDeployment,
    [parameter(Mandatory = $false)]
    [string]$username,
    [parameter(Mandatory = $false)]
    [SecureString]$password
)

### Config-Section
#$webUrl = "<%= $PLASTER_PARAM_SiteUrl %>"

### Loading Libraries
$script:0 = $myInvocation.MyCommand.Definition
$dp0 = Split-Path -Parent -Path $script:0

# assume DLLs are in the same folder as the script
Add-Type -Path "$dp0\Microsoft.SharePoint.Client.Runtime.dll"
Add-Type -Path "$dp0\Microsoft.SharePoint.Client.dll"

Import-Module "$dp0\migrations\nintex-functions.psm1"
Import-Module "$dp0\migrations\common-functions.psm1"

try {
<%
    if ($PLASTER_PARAM_Edition -eq 'Online')
    {
@'
Import-Module "SharePointPnPPowerShellOnline" 3>$null
### Authentication
if ($username -and $password) {
    $cred = New-Object System.Management.Automation.PSCredential -argumentlist $username, $password
    Connect-PnPOnline -Url $webUrl -Credentials $cred        
}
else {
    Connect-PnPOnline -Url $webUrl -UseWebLogin
}
'@
    }
    else 
    {
@'
Import-Module "SharePointPnPPowerShell2013" 3>$null
### Authentication
$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($webUrl)
if ($username -and $password) {
    $cred = New-Object System.Management.Automation.PSCredential -argumentlist $username, $password
    Connect-PnPOnline -Url $webUrl -Credentials $cred        
}
else {
    Connect-PnPOnline -Url $webUrl -CurrentCredentials
}
'@
    }
%>
}
catch {
    throw $_
}


$allScripts = Get-ChildItem -Path "$dp0\migrations\" -Directory

foreach ($currentScript in $allScripts) {    
    $currentDeployment = $currentScript.Name
    $previousDeployment = "{0:000}" -f [math]::Max($currentDeployment - 1, 0);

    Invoke-Migration `
        -fieldName "<%= $PLASTER_PARAM_FieldName %>" `
        -currentDeployment $currentDeployment `
        -targetDeployment $targetDeployment `
        -previousDeployment $previousDeployment `
        -down:$false `
        -path "$dp0\migrations\$currentScript"
}