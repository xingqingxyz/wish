[CmdletBinding()]
param (
  [Parameter(Position = 0)]
  [Alias('LP')]
  [ValidateNotNullOrEmpty()]
  [string[]]
  $LiteralPath,
  [Parameter()]
  [switch]
  $All,
  [Parameter()]
  [switch]
  $Go
)

$ErrorActionPreference = 'Stop'

if ($All) {
  if (!$IsWindows) {
    throw [System.NotImplementedException]::new()
  }
  $LiteralPath += @(
    'C:\Program Files\Git\mingw64\bin\brotli.exe'
    'C:\Program Files\Git\mingw64\bin\bunzip2.exe'
    'C:\Program Files\Git\mingw64\bin\bzip2.exe'
    'C:\Program Files\Git\mingw64\bin\pdftotext.exe'
    'C:\Program Files\Git\mingw64\bin\tclsh.exe'
    'C:\Program Files\Git\mingw64\bin\unxz.exe'
    'C:\Program Files\Git\mingw64\bin\xz.exe'
    'C:\Program Files\Git\usr\bin\awk.exe'
    'C:\Program Files\Git\usr\bin\bash.exe'
    'C:\Program Files\Git\usr\bin\file.exe'
    'C:\Program Files\Git\usr\bin\gpg.exe'
    'C:\Program Files\Git\usr\bin\grep.exe'
    'C:\Program Files\Git\usr\bin\gzip.exe'
    'C:\Program Files\Git\usr\bin\less.exe'
    'C:\Program Files\Git\usr\bin\openssl.exe'
    'C:\Program Files\Git\usr\bin\perl.exe'
    'C:\Program Files\Git\usr\bin\printf.exe'
    'C:\Program Files\Git\usr\bin\sed.exe'
    'C:\Program Files\Git\usr\bin\sh.exe'
    'C:\Program Files\Git\usr\bin\ssp.exe'
    'C:\Program Files\Git\usr\bin\uname.exe'
  )
  # clang-format, clang-tidy
  Use-DevelopmentEnvironment VisualStudio -ea Ignore
  if ($info = Get-Command clang-format.exe, clang-tidy.exe -CommandType Application -TotalCount 1 -ea Ignore) {
    $LiteralPath += $info.Source
  }
}

$LiteralPath.ForEach{
  if (![System.IO.Path]::IsPathFullyQualified($_)) {
    throw "Literalpath must be absolute: $_"
  }
}

$binDir = $IsWindows ? "$env:LOCALAPPDATA\prefix\bin" : "$HOME/.local/bin"
if ($Go) {
  return $LiteralPath | ForEach-Object -Parallel {
    go build -o $Using:binDir\$([System.IO.Path]::GetFileName($_)) -a -trimpath -ldflags "-s -w -X `"main.execPath=$_`"" ./cmd/fork
  } -ThrottleLimit ($env:NUMBER_OF_PROCESSORS ?? 8)
}
$LiteralPath.ForEach{
  @"
@echo off
set PATH=C:\Program Files\Git\usr\bin;C:\Program Files\Git\mingw64\bin;%PATH%
"$_" %*
"@ > $binDir\$([System.IO.Path]::GetFileNameWithoutExtension($_)).cmd
}
