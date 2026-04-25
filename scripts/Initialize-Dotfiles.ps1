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
    $target = $_.Replace($HOME, $root)
    if ($target.Length -eq $_.Length) {
      return Write-Warning "$_ is not a relative path to HOME, skip"
    }
    # remove existing file or link
    Remove-Item -LiteralPath $target -ea Ignore
    # copy the content directly
    Copy-Item -LiteralPath $_ (New-Item $target -Force) -Force
    New-Item -ItemType SymbolicLink -Force -Target $target $_
  }
}
elseif ($Uninstall) {
  return $LiteralPath.ForEach{
    $target = $_.Replace($HOME, $root)
    if ($target.Length -eq $_.Length) {
      return Write-Warning "$_ is not a relative path to HOME, skip"
    }
    $content = Get-Content -LiteralPath $target -Raw -Force -ea Ignore
    Remove-Item -LiteralPath $_, $target -Force -ea Ignore
    $content > $_
  }
}

$excludeDirs = ($IsWindows -or $IsMacOS) ? @() : 'shell', 'windows', 'macos'
fd -HIa -tf -tl $excludeDirs.ForEach{ "-E$_" } --base-directory=$root | ForEach-Object {
  $file = $_.Replace($root, $HOME)
  $target = (Get-Item -LiteralPath $_ -Force).ResolvedTarget
  if ($null -eq $target) {
    throw "Failed to resolve target for $_"
  }
  if ((Get-Item -LiteralPath $file -Force -ea Ignore).Target -cne $target) {
    New-Item -ItemType SymbolicLink -Force -Target $target $file
  }
}
if ($IsWindows) {
  Repair-GitSymlinks
}
