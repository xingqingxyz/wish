[CmdletBinding(DefaultParameterSetName = 'Path')]
param (
  [Parameter()]
  [switch]
  $Install,
  [Parameter()]
  [switch]
  $Uninstall,
  [Parameter(Position = 0, ParameterSetName = 'Path')]
  [SupportsWildcards()]
  [string[]]
  $Path,
  [Parameter(Position = 0, ParameterSetName = 'LiteralPath')]
  [Alias('LP')]
  [string[]]
  $LiteralPath
)

if ($Path) {
  $LiteralPath = Convert-Path $Path
}
$root = [System.IO.Path]::GetDirectoryName($PSScriptRoot)
$root = switch ($true) {
  $IsWindows { "$root\_\windows"; break }
  $IsMacOS { "$root/_/macos"; break }
  default { "$root/_"; break }
}

if ($Install) {
  return $LiteralPath.ForEach{
    $path = $_.Replace($HOME, $root)
    if ($path.Length -eq $_.Length) {
      return Write-Warning "$_ is not a relative path to HOME, skip"
    }
    Copy-Item -LiteralPath $_ (New-Item $path -Force) -Force
    New-Item -ItemType SymbolicLink -Force -Target $path $_
  }
}
elseif ($Uninstall) {
  return $LiteralPath.ForEach{
    $path = $_.Replace($HOME, $root)
    if ($path.Length -eq $_.Length) {
      return Write-Warning "$_ is not a relative path to HOME, skip"
    }
    $content = Get-Content -LiteralPath $path -Raw -Force -ea Ignore
    Remove-Item -LiteralPath $_, $path -Force -ea Ignore
    $content > $_
  }
}

$excludeDirs = ($IsWindows -or $IsMacOS) ? @() : 'shell', 'windows', 'macos'
fd -HIa -tf -tl $excludeDirs.ForEach{ "-E$_" } --base-directory=$root | ForEach-Object {
  $path = $_.Replace($root, $HOME)
  $target = (Get-Item -LiteralPath $_ -Force).ResolvedTarget
  if ($null -eq $target) {
    throw "Failed to resolve target for $_"
  }
  if ((Get-Item -LiteralPath $path -Force -ea Ignore).Target -cne $target) {
    New-Item -ItemType SymbolicLink -Force -Target $target $path
  }
}
if ($IsWindows) {
  Repair-GitSymlinks
}
