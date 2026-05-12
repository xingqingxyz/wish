[CmdletBinding()]
param (
  [Parameter()]
  [switch]
  $Init,
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

if ($Init) {
  "pwsh -nop $($MyInvocation.MyCommand.Name) -PreCommit" > ./.git/hooks/pre-commit
  "pwsh -nop $($MyInvocation.MyCommand.Name) -PostMerge" > ./.git/hooks/post-update
  "pwsh -nop $($MyInvocation.MyCommand.Name) -PostUpdate" > ./.git/hooks/post-merge
  if (!$IsWindows) {
    chmod +x ./.git/hooks/pre-commit ./.git/hooks/post-update ./.git/hooks/post-merge
  }
  git submodule update --init --recursive --remote
  cargo build --release
  dotnet build -c Release
  go mod tidy
  pnpm self-update
  pnpm up -r --latest
  uv sync --upgrade
  $binDir = $IsWindows ? "$env:LOCALAPPDATA\prefix\bin" : "$HOME/.local/bin"
  $exe = go env GOEXE
  Split-Path -Resolve -Leaf cmd/* | ForEach-Object -Parallel {
    go build -trimpath -ldflags '-w -s' -o $Using:binDir/$($_.Name)$exe ./cmd/$_
  } -ThrottleLimit ($env:NUMBER_OF_PROCESSORS ?? 8)
}
$PSStyle.OutputRendering = 'PlainText'
Write-Host "$PSCommandPath -$($PSBoundParameters.Keys)"
if ($PreCommit) {
  git diff --cached --name-only --diff-filter=ACMRT | Tee-Object -Variable files | ForEach-Object {
    & ./scripts/Invoke-CodeFormatter.ps1 -LiteralPath $_ -Inplace -ea Ignore
  }
  git add $files
}
else {
  switch -CaseSensitive -Regex (git diff --name-only HEAD^..HEAD) {
    '^scripts/(Export-EnvrionmentVariables|Initialize-Dotfiles|Initialize-Tasks)\.ps1$' {
      Write-Host ". $_"
      . $_
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
