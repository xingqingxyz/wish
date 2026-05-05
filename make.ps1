[CmdletBinding()]
param (
  [Parameter()]
  [switch]
  $Build,
  [Parameter()]
  [switch]
  $Format,
  [Parameter()]
  [switch]
  $PreCommit,
  [Parameter()]
  [switch]
  $PostMerge,
  [Parameter()]
  [switch]
  $PostUpdate
)

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true
Push-Location -LiteralPath $PSScriptRoot
trap { Pop-Location }

if ($Build) {
  "pwsh -nop $($MyInvocation.MyCommand.Name) -PreCommit" > ./.git/hooks/pre-commit
  "pwsh -nop $($MyInvocation.MyCommand.Name) -PostMerge" > ./.git/hooks/post-update
  "pwsh -nop $($MyInvocation.MyCommand.Name) -PostUpdate" > ./.git/hooks/post-merge
  if (!$IsWindows) {
    chmod +x ./.git/hooks/pre-commit ./.git/hooks/post-update ./.git/hooks/post-merge
  }
  git submodule update --init --recursive --remote
  dotnet build -c Release
  pnpm up -r --latest
  uv sync --upgrade
}
elseif ($Format) {
  $ags = git config --file ./.gitmodules --get-regexp submodule.*.path | ForEach-Object {
    '-g!/' + $_.Split(' ', 2)[1]
  }
  & ./scripts/Invoke-CodeFormatter.ps1 -LiteralPath (rg $ags --files '--glob=*.{ps1,psd1,psm1}') -Inplace
  & ./scripts/Invoke-CodeFormatter.ps1 -LiteralPath (rg $ags --files '--glob=*.{ts,json,yml,toml,md,gql}') -Inplace
  & ./scripts/Invoke-CodeFormatter.ps1 -LiteralPath (rg $ags --files -tsh) -Inplace
  & ./scripts/Invoke-CodeFormatter.ps1 -LiteralPath (rg $ags --files -tpy -tjupyter) -Inplace
}
$PSStyle.OutputRendering = 'PlainText'
Write-Host "$PSCommandPath -$($PSBoundParameters.Keys)"
$dotBase = '_/' + $(switch ($true) {
    $IsMacOS { 'macos'; break }
    $IsWindows { 'windows'; break }
    default { 'linux'; break }
  })
if ($PreCommit) {
  git diff --cached --name-only --diff-filter=ACMRT | ForEach-Object {
    & ./scripts/Invoke-CodeFormatter.ps1 -LiteralPath $_ -Inplace
  }
  $email = git config --get user.email
  fd -HI -tf -tl -egpg --base-directory=$dotBase | ForEach-Object {
    gpg -eo $dotBase/$_ -r $email --batch --no-tty --yes ([System.IO.Path]::Join($HOME, $_.Substring(0, $_.Length - 4)))
  }
  git add .
}
else {
  switch -CaseSensitive -Regex (git diff --name-only HEAD..HEAD^) {
    '^scripts/(Export-EnvrionmentVariables|Initialize-Dotfiles|Initialize-Tasks)\.ps1$' {
      Write-Host ". $_"
      . $_
      continue
    }
    "^$dotBase/.+\.gpg$" {
      gpg -do ([System.IO.Path]::Join($HOME, $_.Substring(0, $dotBase.Length).Substring(0, $_.Length - 4))) --batch --no-tty --yes $_
      continue
    }
  }
  if ($PostMerge) {
  }
  elseif ($PostUpdate) {
  }
  else {
    throw [System.NotImplementedException]::new()
  }
}
Pop-Location
