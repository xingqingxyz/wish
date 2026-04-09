$ErrorActionPreference = 'Stop'

$WALLPAPER_DIR = [System.IO.Path]::Join([System.Environment]::GetFolderPath('MyPictures'), 'unsplash_wallpapers')

function Save-RandomUnsplash {
  $json = Invoke-RestMethod 'https://api.unsplash.com/photos/random?topics=wallpapers&orientation=landscape' -Headers @{
    'Accept-Version' = 'v1'
    Authorization    = 'Client-ID ' + $env:UNSPLASH_ACCESS_KEY
  }
  if (!(Test-Path -LiteralPath $WALLPAPER_DIR)) {
    New-Item -ItemType Directory $WALLPAPER_DIR -Force
  }
  $wallpaperPath = [System.IO.Path]::Join($WALLPAPER_DIR, $json.slug + '.jpg')
  Invoke-RestMethod $json.urls.raw -Headers @{
    'User-Agent' = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0'
  } -OutFile $wallpaperPath -TimeoutSec 30
  $wallpaperPath
}

Set-Wallpaper (Save-RandomUnsplash)
