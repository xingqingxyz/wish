[CmdletBinding(DefaultParameterSetName = 'Path')]
[Alias('icf')]
[OutputType([string[]])]
param (
  [Parameter(Mandatory, Position = 0, ParameterSetName = 'Path')]
  [ValidateNotNullOrEmpty()]
  [SupportsWildcards()]
  [string[]]
  $Path,
  [Parameter(Mandatory, ParameterSetName = 'LiteralPath')]
  [Alias('LP')]
  [ValidateNotNullOrEmpty()]
  [string[]]
  $LiteralPath,
  [Parameter(Mandatory, Position = 0, ParameterSetName = 'Stdin')]
  [ValidateNotNullOrEmpty()]
  [string]
  $Language,
  [Parameter(ParameterSetName = 'Path')]
  [Parameter(ParameterSetName = 'LiteralPath')]
  [switch]
  $Inplace,
  [Parameter(ParameterSetName = 'Stdin')]
  [System.Object]
  $InputObject
)

function Get-CodeFormatParser ([string]$Path, [switch]$Inplace, [switch]$Stdin) {
  switch -CaseSensitive -Regex ([System.IO.Path]::GetExtension($Path).Substring(1)) {
    '^(?:c|m|mm|cpp|cc|cp|cxx|c\+\+|h|hh|hpp|hxx|h\+\+|inl|ipp|java|proto|protodevel)$' {
      if ($Inplace) {
        { clang-format -i --style=LLVM `-- $args[0] }
      }
      elseif ($Stdin) {
        { $input | clang-format --style=LLVM --assume-filename=$args[0] }
      }
      else {
        { clang-format --style=LLVM `-- $args[0] }
      }
      break
    }
    '^(?:dart)$' {
      if ($Inplace) {
        { dart format `-- $args[0] }
      }
      elseif ($Stdin) {
        { $input | dart format }
      }
      else {
        { dart format -o show --show none --summary none `-- $args[0] }
      }
      break
    }
    '^(?:cs|csx|fs|fsi|fsx|vb)$' {
      if ($Inplace) {
        { dotnet format --no-restore --include `-- $args[0] }
      }
      elseif ($Stdin) {
        {
          process {
            $file = [System.IO.Path]::GetRandomFileName() + [System.IO.Path]::GetExtension($args[0])
            $input > $file
            dotnet format --no-restore --include `-- $file
            Get-Content -LiteralPath $file
          }
          clean {
            Remove-Item -LiteralPath $file -Force
          }
        }
      }
      else {
        {
          process {
            $file = [System.IO.Path]::GetTempFileName()
            Copy-Item -LiteralPath $args[0] $file -Force
            dotnet format --no-restore --include `-- $args[0]
            Get-Content -LiteralPath $args[0]
          }
          clean {
            Copy-Item -LiteralPath $file $args[0] -Force
            Remove-Item -LiteralPath $file -Force
          }
        }
      }
      break
    }
    '^(?:go)$' {
      if ($Inplace) {
        { goimports -w `-- $args[0] }
      }
      elseif ($Stdin) {
        { $input | goimports }
      }
      else {
        { goimports `-- $args[0] }
      }
      break
    }
    '^(?:js|cjs|mjs|jsx|tsx|ts|cts|mts|json|jsonc|json5|yml|yaml|htm|html|xhtml|shtml|vue|gql|graphql|css|scss|sass|less|hbs|md|markdown)$' {
      if ($Inplace) {
        { prettier -w --ignore-path= `-- $args[0] }
      }
      elseif ($Stdin) {
        { $input | prettier --ignore-path= --stdin-filepath=$args[0] }
      }
      else {
        { prettier --ignore-path= `-- $args[0] }
      }
      break
    }
    '^(?:ps1|psm1|psd1)$' {
      if ($Inplace) {
        { PSScriptAnalyzer\Invoke-Formatter (Get-Content -Raw -LiteralPath $args[0]) -Settings $env:WISH_ROOT/CodeFormatting.psd1 | Out-File -NoNewline $args[0] }
      }
      elseif ($Stdin) {
        { PSScriptAnalyzer\Invoke-Formatter $input -Settings $env:WISH_ROOT/CodeFormatting.psd1 }
      }
      else {
        { PSScriptAnalyzer\Invoke-Formatter (Get-Content -Raw -LiteralPath $args[0]) -Settings $env:WISH_ROOT/CodeFormatting.psd1 }
      }
      break
    }
    '^(?:py|pyi|pyw|pyx|pxd|gyp|gypi)$' {
      if ($Inplace) {
        { ruff format -n `-- $args[0] }
      }
      elseif ($Stdin) {
        { $input | ruff format -n --stdin-filename $args[0] }
      }
      else {
        { Get-Content -LiteralPath $args[0] | ruff format -n --stdin-filename $args[0] }
      }
      break
    }
    '^(?:rs)$' {
      if ($Inplace) {
        { rustfmt `-- $args[0] }
      }
      elseif ($Stdin) {
        { $input | rustfmt --emit stdout }
      }
      else {
        { rustfmt --emit stdout `-- $args[0] }
      }
      break
    }
    '^(?:sh|bash|zsh|ash)$' {
      if ($Inplace) {
        { shfmt -i 2 -bn -ci -sr `-- $args[0] }
      }
      elseif ($Stdin) {
        { $input | shfmt -i 2 -bn -ci -sr --filename $args[0] }
      }
      else {
        { Get-Content -LiteralPath $args[0] | shfmt -i 2 -bn -ci -sr --filename $args[0] }
      }
      break
    }
    '^(?:toml)$' {
      if ($Inplace) {
        { taplo format `-- $args[0] }
      }
      elseif ($Stdin) {
        { $input | taplo format - --stdin-filepath=$args[0] }
      }
      else {
        { Get-Content -LiteralPath $args[0] | taplo format - --stdin-filepath=$args[0] }
      }
      break
    }
    '^(?:lua)$' {
      if ($Inplace) {
        { stylua `-- $args[0] }
      }
      elseif ($Stdin) {
        { $input | stylua }
      }
      else {
        { Get-Content -LiteralPath $args[0] | stylua }
      }
      break
    }
    '^(?:zig)$' {
      if ($Inplace) {
        { zig fmt $args[0] }
      }
      elseif ($Stdin) {
        { $input | zig fmt --stdin }
      }
      else {
        { Get-Content -LiteralPath $args[0] | zig fmt --stdin }
      }
      break
    }
    default {
      if ($Stdin) {
        { $input }
      }
      else {
        { Get-Content -LiteralPath $args[0] }
      }
      break
    }
  }
}

if ($MyInvocation.ExpectingInput) {
  if ($MyInvocation.PipelinePosition -lt $MyInvocation.PipelineLength) {
    return $input | & (Get-CodeFormatParser $Language -Stdin)
  }
  return $input | & (Get-CodeFormatParser $Language -Stdin) | bat -pl$Language
}
if ($Path) {
  $LiteralPath = Convert-Path $Path -Force
}
if ($Inplace) {
  return $LiteralPath.ForEach{ & (Get-CodeFormatParser $_ -Inplace) $_ }
}
if ($MyInvocation.PipelinePosition -lt $MyInvocation.PipelineLength) {
  return $LiteralPath.ForEach{ & (Get-CodeFormatParser $_) $_ }
}
$LiteralPath.ForEach{
  & (Get-CodeFormatParser $_) $_ | bat -p --color=always --file-name=$_
} | & $env:PAGER
