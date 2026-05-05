# ensure English home dirs
if ($PSCulture -cne 'en-US') {
  [string[]]$prevDirs = Get-Content -LiteralPath ~/.config/user-dirs.dirs | ForEach-Object { if ($_.StartsWith('XDG_')) { $_.Split('/', 2)[1].TrimEnd('"') } }
  env LC_ALL=en_US xdg-user-dirs-update --force
  $PSCulture.Replace('-', '_') > ~/.config/user-dirs.locale
  [string[]]$newDirs = Get-Content -LiteralPath ~/.config/user-dirs.dirs | ForEach-Object { if ($_.StartsWith('XDG_')) { $_.Split('/', 2)[1].TrimEnd('"') } }
  Set-Location
  New-Item -ItemType Directory $newDirs -ea Ignore
  for ($i = 0; $i -lt $prevDirs.Count; $i++) {
    if (Test-Path -LiteralPath $newDirs[$i] -PathType Leaf) {
      Move-Item -LiteralPath $newDirs[$i] "$($newDirs[$i]).bak"
      New-Item -ItemType Directory $newDirs[$i]
    }
    if ($newDirs[$i] -ceq $prevDirs[$i]) {
      continue
    }
    if (Test-Path -LiteralPath $prevDirs[$i] -PathType Container) {
      Move-Item "$($prevDirs[$i])/*" $newDirs[$i]
      Remove-Item -LiteralPath $prevDirs[$i]
    }
  }
  Set-Location -
}
# data dirs for GithubRelease
[string[]]$dirs = @(
  "$HOME/.local/bin"
  "$HOME/.local/share/applications"
  "$HOME/.local/share/bash-completion/completions"
  "$HOME/.local/share/fonts/truetype"
  "$HOME/.local/share/jar"
  "$HOME/.local/share/icons/hicolor/scalable/apps"
  1..8 | ForEach-Object { "$HOME/.local/share/man/man$_" }
)
New-Item -ItemType Directory $dirs -Force
# history
New-Item -ItemType SymbolicLink -Force -Target ConsoleHost_history.txt "$HOME/.local/share/powershell/PSReadLine/Visual Studio Code Host_history.txt"
# autostart
New-Item -ItemType Directory ~/.config/autostart -Force
[string[]]$desktop = switch ((Get-Command fcitx5, wechat, alacritty, ghostty, kitty -CommandType Application -TotalCount 1 -ea Ignore).Name) {
  'fcitx5' { 'org.fcitx.Fcitx5.desktop'; continue }
  'wechat' { 'wechat.desktop'; continue }
  'alacritty' { 'Alacritty.desktop'; break }
  'ghostty' { 'com.mitchellh.ghostty.desktop'; break }
  'kitty' { 'kitty.desktop'; break }
}
$desktop.ForEach{ New-Item -ItemType SymbolicLink -Force -Target /usr/share/applications/$_ ~/.config/autostart/$_ }
