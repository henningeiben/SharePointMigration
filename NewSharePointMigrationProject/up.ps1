param (
    # [OfficeDevPnP.Core.PnPClientContext] $ctx
     $ctx
)

$script:0 = $myInvocation.MyCommand.Definition
$script:dp0 = Split-Path -Parent -Path $0

$groupName = "busitec QM"

$siteColumns = Import-Csv "$dp0\site-columns.csv" -Delimiter ";" -Encoding Default
$siteContenTypes = Import-Csv "$dp0\site-contenttypes.csv" -Delimiter ";" -Encoding Default
$lists = Import-Csv "$dp0\site-lists.csv" -Delimiter ";" -Encoding Default
$views = Import-Csv "$dp0\site-views.csv" -Delimiter ";" -Encoding Default

Write-Progress -Id 1 -Activity "Creating Site-Columns" -PercentComplete (1 / 4 * 100)
$i = 1
foreach ($column in $siteColumns) {
    Write-Progress -Id 2 -ParentId 1 -Activity "Creating Column '$($column.DisplayName)'" -PercentComplete ($i / $($siteColumns.Count) * 100)

    $requiredSwitch = [System.Convert]::ToBoolean($column.Required)

    if ($column.Type -eq "Choice") {
        $newField = Add-PnPField -DisplayName $column.DisplayName -InternalName $column.InternalName -Type $column.Type -Group $groupName -Choices $column.Options.Split(";") -Required:$requiredSwitch
    }
    elseif ($column.Type -eq "DateTime" -and ![string]::IsNullOrEmpty($column.Options)) {        
        $newField = Add-PnPField -DisplayName $column.DisplayName -InternalName $column.InternalName -Type $column.Type -Group $groupName -Required:$requiredSwitch
        $newField.DisplayFormat = $column.Options
        $newField.Update()
    }
    else {
        $newField = Add-PnPField -DisplayName $column.DisplayName -InternalName $column.InternalName -Type $column.Type -Group $groupName -Required:$requiredSwitch
    }
    if (![string]::IsNullOrEmpty($column.Description)) {
        $newField.Description = $column.Description
        $newField.Update()
    }
    if ($newField.Context.HasPendingRequest) {
        $newField.Context.ExecuteQuery()
    }
    $i++
}
Write-Progress -Id 2 -ParentId 1 -Completed -Activity "Done"

Write-Progress -Id 1 -Activity "Creating Site-ContentTypes" -PercentComplete (2 / 4 * 100)
$i = 1
foreach ($contentType in $siteContenTypes) {
    Write-Progress -Id 2 -ParentId 1 -Activity "Creating ContentType '$($contentType.Name)'" -PercentComplete ($i / $($siteContenTypes.Count) * 100)

    $parentCT = Get-PnPContentType -Identity $contentType.ParentName
    $newCT = Add-PnPContentType -Name $contentType.Name -Group $groupName -ParentContentType $parentCT
    foreach ($column in $contentType.Columns.Split(';')) {
        Add-PnPFieldToContentType -Field $column -ContentType $newCT
    }
    $i++
}
Write-Progress -Id 2 -ParentId 1 -Completed -Activity "Done"


Write-Progress -Id 1 -Activity "Creating Lists and Libraries" -PercentComplete (3 / 4 * 100)
$i = 1
foreach ($list in $lists) {
    Write-Progress -Id 2 -ParentId 1 -Activity "Creating List/Library '$($list.Name)'" -PercentComplete ($i / $($lists.Count) * 100)
    
    $ctSwitch = ![string]::IsNullOrEmpty($list.ContentTypes)
    $qlSwitch = [System.Convert]::ToBoolean($list.OnQuickLaunch)

    New-PnPList -Title $list.Name -Url $list.URL -Template $list.Template -EnableContentTypes:$ctSwitch -OnQuickLaunch:$qlSwitch
    if ($ctSwitch) {
        foreach ($contentType in $list.ContentTypes.Split(';')) {
            Add-PnPContentTypeToList -List $list.Name -ContentType $contentType
        }
    }    
    if ($list.Hidden -eq "true") {
        $newList = Get-PnPList -Identity $list.Name
        $newList.Hidden = $true
        $newList.Update()
        $newList.Context.ExecuteQuery()
    } 
    $i++
}
Write-Progress -Id 2 -ParentId 1 -Completed -Activity "Done"

Write-Progress -Id 1 -Activity "Creating Views" -PercentComplete (4 / 4 * 100)
$i = 1
foreach ($view in $views) {
    Write-Progress -Id 2 -ParentId 1 -Activity "Creating view '$($view.Name)'" -PercentComplete ($i / $($views.Count) * 100)

    $fields = $view.Fields.Split(';')
    $newView = Get-PnPView -List $view.List -Identity $view.Name
    if (!$newView) {
        $newView = Add-PnPView -List $view.List -Title $view.Name -Fields $fields
    }
    else {
        $newView.ViewFields.RemoveAll()
        foreach ($field in $fields) {
            $newView.ViewFields.Add($field)
        }
        $newView.Update()
    }
    if (![string]::IsNullOrEmpty($view.Grouping)) {
        $newView.ViewQuery = "<GroupBy Collapse='False' GroupLimit='300'><FieldRef Name='$($view.Grouping)' /></GroupBy>"
        $newView.Aggregations = "off"
        $newView.Update()
    }
    if ($newView.Context.HasPendingRequest) {
        $newView.Context.ExecuteQuery()
    }
    $i++
}
Write-Progress -Id 2 -ParentId 1 -Completed -Activity "Done"


Write-Progress -Id 1 -Completed -Activity "Done"