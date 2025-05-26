# disk-usage-report.ps1
# Outputs disk usage summary for all drives

Get-PSDrive -PSProvider FileSystem | ForEach-Object {
    $used = $_.Used
    $free = $_.Free
    $total = $_.Used + $_.Free
    $percentFree = [math]::Round(($free / $total) * 100, 2)

    [PSCustomObject]@{
        Name         = $_.Name
        Root         = $_.Root
        TotalGB      = "{0:N1}" -f ($total / 1GB)
        FreeGB       = "{0:N1}" -f ($free / 1GB)
        FreePercent  = "$percentFree`%"
    }
} | Format-Table -AutoSize
