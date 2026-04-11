<#
.SYNOPSIS
Update wallpaper from bing.
 #>
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

# ===================== 配置项 =====================
$WALLPAPER_DIR = Convert-Path ~/Pictures/bing_wallpapers
$RESOLUTION = 'UHD'
$REGION = 'zh-CN'
# ===================== /配置项 =====================

Write-Information "===== $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') 开始更新 Bing 壁纸 ====="

# 初始化目录
if (!(Test-Path -LiteralPath $WALLPAPER_DIR)) {
  New-Item -ItemType Directory $WALLPAPER_DIR -Force
}

# 获取壁纸 URL
$apiUrl = "https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=$REGION"
$resp = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing -TimeoutSec 10
if (!$resp.images.Count) {
  throw '未从 Bing API 获取到 images 数据'
}
$wallpaperUrl = "https://www.bing.com$($resp.images[0].urlbase)_$RESOLUTION.jpg"
$wallpaperPath = [System.IO.Path]::Join($WALLPAPER_DIR, "$($resp.images[0].hsh).jpg")

# 下载壁纸（重复则跳过）
if (Test-Path -LiteralPath $wallpaperPath) {
  Write-Warning "今日壁纸已存在，无需重复下载: $wallpaperPath"
}
else {
  try {
    Write-Information "开始下载壁纸: $wallpaperUrl"
    Invoke-RestMethod -Uri $wallpaperUrl -OutFile $wallpaperPath -TimeoutSec 30
    Write-Information "壁纸下载完成: $wallpaperPath"
  }
  catch {
    Write-Error "下载壁纸失败: $_"
  }
}

# 设置壁纸
Set-Wallpaper $wallpaperPath
