[CmdletBinding()]
param (
  [ArgumentCompleter({
      [OutputType([System.Management.Automation.CompletionResult])]
      param (
        [string]$CommandName,
        [string]$ParameterName,
        [string]$WordToComplete,
        [System.Management.Automation.Language.CommandAst]$CommandAst,
        [System.Collections.IDictionary]$FakeBoundParameters
      )
      ('alacritty', 'bat', 'windows_terminal').Where{ $_ -like "$WordToComplete*" }
    })]
  [Parameter(Position = 0)]
  [ValidateNotNullOrEmpty()]
  [string]
  $AppName = $(if ($env:ALACRITTY_LOG) { 'alacritty' }
    elseif ($env:WT_SESSION) { 'windows_terminal' }
    else { 'bat' })
)

$mode = (Get-DarkMode) ? 'dark' : 'light'
$oldTheme = bash $PSScriptRoot/theme.sh get $AppName $mode
$themes = switch ($AppName) {
  alacritty { Split-Path -Resolve -LeafBase $env:WISH_ROOT/alacritty-theme/themes/*; break }
  bat { bat --list-themes; break }
  windows_terminal { 'CGA', 'Campbell', 'Campbell Powershell', 'Dark+', 'Dimidium', 'IBM 5153', 'One Half Dark', 'One Half Light', 'Ottosson', 'Solarized Dark', 'Solarized Light', 'Tango Dark', 'Tango Light', 'VSCode Dark Modern', 'VSCode Light Modern', 'Vintage'; break }
  # no default
}
try {
  $theme = $themes | fzf --preview="bash `"$PSScriptRoot/theme.sh`" preview $AppName {} $mode" --prompt="$oldTheme >"
  Write-Debug "set $AppName theme from $oldTheme to $theme"
  if ($AppName -ceq 'bat') {
    bash $PSScriptRoot/theme.sh set $AppName $theme $mode
  }
  yq -i ".$mode.$AppName = `"$theme`"" $PSScriptRoot/data/theme.json
}
catch {
  if ($AppName -cne 'bat') {
    Write-Debug "reset old theme $oldTheme for $AppName"
    bash $PSScriptRoot/theme.sh set $AppName $oldTheme $mode
  }
}
