[CmdletBinding()]
param (
  [Parameter()]
  [pscredential]
  $Credential = (Get-Credential),
  [Parameter()]
  [switch]
  $Sync,
  [Parameter()]
  [switch]
  $Push,
  [Parameter()]
  [switch]
  $Pull,
  [Parameter()]
  [SupportsWildcards()]
  [string[]]
  $Path,
  [Parameter()]
  [string[]]
  $LiteralPath
)
$data = Get-Content -LiteralPath $PSScriptRoot/data/webdav.json | ConvertFrom-Json
if ($Sync) {
  $data.items.ForEach{
    $url = $data.url + $_.target
    [datetime]$webModifyDate = curl -X PROPFIND --user ($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password) $url |
      yq -pxml '([]+."d:multistatus"."d:response")[0]."d:propstat"."d:prop"."d:getlastmodified"'
    $localModifyDate = (Get-Item $_.source -Force -ea Ignore).LastWriteTime
    if ($localModifyDate -eq $webModifyDate) {
      Write-Debug "skipping updated $($_.source)"
    }
    elseif ($localModifyDate -lt $webModifyDate) {
      Write-Debug "overwriting $($_.source) from $url"
      if ($null -eq $localModifyDate) {
        New-Item $_.source -Force
      }
      Invoke-RestMethod -Method Get $url -Credential $Credential -OutFile $_.source
    }
    else {
      Write-Debug "putting $($_.source) to $url"
      Invoke-RestMethod -Method Put $url -Credential $Credential -InFile $_.source
    }
  }
  return
}
if (!$Push -and !$Pull) {
  throw [System.NotImplementedException]::new()
}
$pathMap = @{}
$data.items.ForEach{
  $source = (Convert-Path $_.source -ea Ignore) ?? $_.source
  $target = $data.url + $_.target
  $pathMap[$source] = $target
}
if ($Path) {
  $LiteralPath = Convert-Path $Path
}
$LiteralPath.ForEach{
  if ($pathMap.Contains($_)) {
    if ($Push) {
      Invoke-RestMethod -Method Put $pathMap[$_] -Credential $Credential -InFile $_
    }
    else {
      Invoke-RestMethod -Method Get $pathMap[$_] -Credential $Credential -OutFile $_
    }
  }
}
