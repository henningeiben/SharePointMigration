param (
    [string]$targetDeployment,
    [string]$webUrl
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

<%
    if ($PLASTER_PARAM_Edition -eq 'Online')
    {
@'
Import-Module "SharePointPnPPowerShellOnline"
### Authentication
Connect-PnPOnline -Url \$webUrl -UseWebLogin        
'@
    }
    else 
    {
@'
Import-Module "SharePointPnPPowerShell2013"
### Authentication
$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($webUrl)
Connect-PnPOnline -Url $webUrl -CurrentCredentials
'@
    }
%>

$ctx = Get-PnPContext


$allScripts = Get-ChildItem -Path "$dp0\migrations\" -Directory

foreach ($currentScript in $allScripts) {    
    # & "$dp0\migrations\$currentScript\run.ps1" -ctx $ctx

    $currentDeployment = $currentScript.Name
    $previousDeployment = "{0:000}" -f [math]::Max($currentDeployment - 1, 0);

    Invoke-Migration -ctx $ctx `
        -fieldName "<%= $PLASTER_PARAM_FieldName %>" `
        -currentDeployment $currentDeployment `
        -targetDeployment $targetDeployment `
        -previousDeployment $previousDeployment `
        -down:$false `
        -path "$dp0\migrations\$currentScript"
}