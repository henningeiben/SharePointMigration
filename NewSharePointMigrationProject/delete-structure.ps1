param (
    [string]$targetDeployment,
    [string]$webUrl
)

### Config-Section
#$webUrl = "http://sp2013.develop-busitec.de/projects/stw-ms/procurement/"

### Loading Libraries
$script:0 = $myInvocation.MyCommand.Definition
$dp0 = Split-Path -Parent -Path $script:0

# assume DLLs are in the same folder as the script
Add-Type -Path "$dp0\Microsoft.SharePoint.Client.Runtime.dll"
Add-Type -Path "$dp0\Microsoft.SharePoint.Client.dll"

Import-Module "$dp0\migrations\nintex-functions-onprem.psm1"
Import-Module "$dp0\migrations\common-functions.psm1"

# ## SharePoint 2013
# Import-Module "SharePointPnPPowerShell2013"
# ### Authentication
# $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($webUrl)
# Connect-PnPOnline -Url $webUrl -CurrentCredentials

## SharePoint Online
Import-Module "SharePointPnPPowerShellOnline"
### Authentication
Connect-PnPOnline -Url $webUrl -UseWebLogin
$ctx = Get-PnPContext


$allScripts = Get-ChildItem -Path "$dp0\migrations\" -Directory | Sort-Object -Descending

foreach ($currentScript in $allScripts) {    
    # & "$dp0\migrations\$currentScript\run.ps1" -ctx $ctx -down -targetDeployment $targetDeployment

    $currentDeployment = $currentScript.Name
    $previousDeployment = "{0:000}" -f [math]::Max($currentDeployment - 1, 0);

    Invoke-Migration -ctx $ctx `
        -fieldName "btecQM_Deployment_Version" `
        -currentDeployment $currentDeployment `
        -targetDeployment $targetDeployment `
        -previousDeployment $previousDeployment `
        -down:$true `
        -path "$dp0\migrations\$currentScript"

}