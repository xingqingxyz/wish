# data dirs for GithubRelease
New-Item -ItemType Directory -Force @(
  "$env:LOCALAPPDATA\prefix\bin"
  "$env:LOCALAPPDATA\prefix\share\jar"
  1..8 | ForEach-Object { "$env:LOCALAPPDATA\prefix\share\man\man$_" }
)
# windows terminal settings
Copy-Item -LiteralPath $PSScriptRoot/data/windows-terminal-settings.json $env:LOCALAPPDATA/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json, $env:LOCALAPPDATA/Packages/Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe/LocalState/settings.json -Force
# auto run apps on login
@(
  'C:\Program Files\Alacritty\alacritty.exe'
  'C:\Program Files\Tencent\Weixin\Weixin.exe'
).ForEach{
  $name = [System.IO.Path]::GetFileNameWithoutExtension($_)
  if (Test-Path -LiteralPath $_) {
    # FIXME: alacritty is not comfortable
    $value = $name -ceq 'alacritty' ? "C:\Windows\System32\conhost.exe `"$_`"" : $_
    New-ItemProperty -LiteralPath 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name $name -Value $value -PropertyType String -Force
  }
  else {
    Remove-ItemProperty -LiteralPath 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name $name -ea Ignore
  }
}
