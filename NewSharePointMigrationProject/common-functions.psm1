function Invoke-Migration() {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        # [OfficeDevPnP.Core.PnPClientContext] $ctx,
        $ctx,
        [parameter(Mandatory = $true)]
        [string] $path,
        [parameter(Mandatory = $true)]
        [string] $fieldName,
        [parameter(Mandatory = $true)]
        [string] $currentDeployment,
        [parameter(Mandatory = $true)]
        [string] $previousDeployment,
        [parameter(Mandatory = $true)]
        [switch] $down,
        [string] $targetDeployment
    )
    process {

        # $fieldName = "STWMS-Deployment-Version"
        $web = $ctx.Web

        $allProps = $web.AllProperties
        $ctx.Load($allProps)
        $ctx.ExecuteQuery()
        if ($allProps.FieldValues.ContainsKey($fieldName)) {
            $deployVersion = $allProps[$fieldName]
        }
        else {
            $deployVersion = $noDeployment
        }

        Write-Host "Current Deployment: $deployVersion"

        if ($deployVersion -ge $currentDeployment) {
            if ($down -and $currentDeployment -gt $targetDeployment) {
                & "$path\down.ps1" -ctx $ctx

                $allProps[$fieldName] = $previousDeployment
                $web.Update()
            }
            elseif ($down -and $previousDeployment -le $targetDeployment) {
                Write-Verbose "Target-Deployment reached, not retracting $currentDeployment"        
            }
            else {
                Write-Host "Deployment $currentDeployment already applied; skipping"
            }
        }
        else {
            if ($down) {
                Write-Host "Deployment $currentDeployment not yet applied; skipping"
            }
            else {
                & "$path\up.ps1" -ctx $ctx

                $allProps[$fieldName] = $currentDeployment
                $web.Update()
            }
        }
        if ($ctx.HasPendingRequest) {
            $ctx.ExecuteQuery()
        }

        Write-Host "Done running Deployment $currentDeployment"
    }
}

Export-ModuleMember -Function Invoke-Migration