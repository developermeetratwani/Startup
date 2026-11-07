<#
.SYNOPSIS
    Automated Production Build & Deployment Script for XYZ Startup to Firebase Hosting.
.DESCRIPTION
    Builds the 4 Flutter Web applications (Customer, Vendor, Driver, Admin) in release mode
    and deploys to Firebase Hosting.
.EXAMPLE
    .\deploy_hosting.ps1 -All
    .\deploy_hosting.ps1 -App admin
#>
param(
    [ValidateSet("all", "customer", "vendor", "driver", "admin")]
    [string]$App = "all",
    [switch]$SkipBuild,
    [switch]$DeployOnly
)

$ErrorActionPreference = "Stop"
$rootDir = $PSScriptRoot

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  XYZ STARTUP — PRODUCTION FIREBASE HOSTING DEPLOYMENT" -ForegroundColor Cyan
Write-Host "  Ahmedabad & Gandhinagar Hyperlocal Fashion Marketplace" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$apps = @{
    "customer" = @{ path = "apps/customer_app"; target = "customer"; name = "Customer Marketplace" }
    "vendor"   = @{ path = "apps/vendor_app";   target = "vendor";   name = "Vendor Business Portal" }
    "driver"   = @{ path = "apps/driver_app";   target = "driver";   name = "Delivery Partner App" }
    "admin"    = @{ path = "apps/admin_web";    target = "admin";    name = "Admin Management Desk" }
}

$targetsToDeploy = @()
if ($App -eq "all") {
    $targetsToDeploy = @("customer", "vendor", "driver", "admin")
} else {
    $targetsToDeploy = @($App)
}

# 1. Build Phase
if (-not $SkipBuild -and -not $DeployOnly) {
    foreach ($key in $targetsToDeploy) {
        $info = $apps[$key]
        $appPath = Join-Path $rootDir $info.path
        Write-Host "`n🔨 Building $($info.name) in Release Mode ($appPath)..." -ForegroundColor Yellow
        Push-Location $appPath
        try {
            flutter build web --release --base-href "/"
            Write-Host "✅ Build succeeded for $($info.name)" -ForegroundColor Green
        } catch {
            Write-Host "❌ Build failed for $($info.name): $_" -ForegroundColor Red
            Pop-Location
            exit 1
        }
        Pop-Location
    }
}

# 2. Deploy Phase
Write-Host "`n🚀 Deploying to Firebase Hosting..." -ForegroundColor Yellow
Push-Location $rootDir
try {
    if ($App -eq "all") {
        Write-Host "Executing: firebase deploy --only hosting" -ForegroundColor Cyan
        firebase deploy --only hosting
    } else {
        $targetName = $apps[$App].target
        Write-Host "Executing: firebase deploy --only hosting:$targetName" -ForegroundColor Cyan
        firebase deploy --only "hosting:$targetName"
    }
    Write-Host "`n🎉 Deployment Complete! Your applications are live on Firebase Global CDN." -ForegroundColor Green
} catch {
    Write-Host "❌ Deployment error: $_" -ForegroundColor Red
} finally {
    Pop-Location
}
