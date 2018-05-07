$script:0 = $myInvocation.MyCommand.Definition
$script:dp0 = Split-Path -Parent -Path $script:0

$siteColumns = Import-Csv "$dp0\site-columns.csv" -Delimiter ";" -Encoding Default
$siteContenTypes = Import-Csv "$dp0\site-contenttypes.csv" -Delimiter ";" -Encoding Default
$lists = Import-Csv "$dp0\site-lists.csv" -Delimiter ";" -Encoding Default


Write-Progress -Id 1 -Activity "Deleting Lists and Libraries" -PercentComplete (1 / 3 * 100)
$i = 1
if ($lists.Count -gt 0) { [array]::Reverse($lists) }
foreach ($list in $lists) {
    if ($lists.Count -gt 0) {
        Write-Progress -Id 2 -ParentId 1 -Activity "Deleting Library '$($list.Name)'" -PercentComplete ($i / $($lists.Count) * 100)
    }

    Remove-PnPList -Identity $list.Name -Force -ErrorAction Ignore
}


Write-Progress -Id 1 -Activity "Deleting Site-ContentTypes" -PercentComplete (2 / 3 * 100)
$i = 1
if ($siteContenTypes.Count -gt 0) { [array]::Reverse($siteContenTypes) }
foreach ($contentType in $siteContenTypes) {
    if ($siteContenTypes.Count -gt 0) {
        Write-Progress -Id 2 -ParentId 1 -Activity "Deleting ContentType '$($contentType.Name)'" -PercentComplete ($i / $($siteContenTypes.Count) * 100)
    }

    Remove-PnPContentType -Identity $contentType.Name -Force -ErrorAction Ignore
    $i++
}

Write-Progress -Id 1 -Activity "Deleting Site-Columns" -PercentComplete (3 / 3 * 100)
$i = 1
if ($siteColumns.Count -gt 0) { [array]::Reverse($siteColumns) }
foreach ($column in $siteColumns) {
    if ($siteColumns.Count -gt 0) {
        Write-Progress -Id 2 -ParentId 1 -Activity "Deleting Column '$($column.DisplayName)'" -PercentComplete ($i / $($siteColumns.Count) * 100)
    }

    Remove-PnPField -Identity $column.InternalName -Force -ErrorAction Ignore
    $i++
}