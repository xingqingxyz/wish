[CmdletBinding(DefaultParameterSetName = 'Path')]
param (
  [Parameter()]
  [switch]
  $Install,
  [Parameter()]
  [switch]
  $Uninstall,
  [Parameter()]
  [switch]
  $Gpg,
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
$root = [System.IO.Path]::GetFullPath($PSScriptRoot + '/../_/' + $(switch ($true) {
      $IsMacOS { 'macos'; break }
      $IsWindows { 'windows'; break }
      default { 'linux'; break }
    }))

if ($Install) {
  if ($Gpg) {
    $email = git config --get user.email
  }
  return $LiteralPath.ForEach{
    $target = $_.Replace($HOME, $root)
    if ($target.Length -eq $_.Length) {
      return Write-Warning "$_ is not a relative path to HOME, skip"
    }
    if ($Gpg) {
      $target += '.gpg'
      New-Item $target -Force
      gpg -eo $target -r $email --yes $_
      return
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
    if ($Gpg) {
      $target += '.gpg'
      Remove-Item -LiteralPath $target -Force -ea Ignore
      return
    }
    $content = Get-Content -LiteralPath $target -Raw -Force -ea Ignore
    Remove-Item -LiteralPath $_, $target -Force -ea Ignore
    $content > $_
  }
}

fd -HIa -tf -tl --base-directory=$root | ForEach-Object {
  $file = $_.Replace($root, $HOME)
  $target = (Get-Item -LiteralPath $_ -Force).ResolvedTarget
  if ($file.EndsWith('.gpg')) {
    $file = $file.Substring(0, $file.Length - 4)
    gpg -do $file --yes $target
    return
  }
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
