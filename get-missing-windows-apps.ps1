# ============================================
# Compare provisioned vs installed Microsoft apps
# ============================================

# 1. Get provisioned Microsoft apps (system baseline)
$StagedApps = Get-AppxProvisionedPackage -Online |
    Where-Object { $_.DisplayName -like "Microsoft.*" } |
    Select-Object -ExpandProperty DisplayName |
    Sort-Object -Unique

# 2. Get installed Microsoft apps (current user)
$InstalledApps = Get-AppxPackage |
    Where-Object { $_.Name -like "Microsoft.*" } |
    Select-Object -ExpandProperty Name |
    Sort-Object -Unique

# 3. Compare lists to find missing apps
$MissingApps = Compare-Object `
    -ReferenceObject $StagedApps `
    -DifferenceObject $InstalledApps `
    -PassThru |
    Where-Object { $_.SideIndicator -eq "<=" }

# 4. Output results
if ($MissingApps) {
    Write-Host "`nThe following Microsoft apps are missing from the current user:`n" -ForegroundColor Yellow

    foreach ($app in $MissingApps) {
        Write-Host "$app" -ForegroundColor Red
    }
} else {
    Write-Host "`nNo missing Microsoft apps detected!" -ForegroundColor Green
}
