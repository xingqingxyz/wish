[CmdletBinding()]
param (
  [Parameter()]
  [pscredential]
  $Credential = (Get-Credential)
)
$data = Import-PowerShellDataFile -LiteralPath $PSScriptRoot/data/webdav.psd1
$data.Items.ForEach{
  $url = $data.Url + $_.Target
  [datetime]$webModifyDate = Invoke-RestMethod -Method PROPFIND $url -Credential $Credential |
    yq -pxml '."d:multistatus"."d:response"[0]."d:propstat"."d:prop"."d:getlastmodified"'
  $localModifyDate = (Get-Item -LiteralPath $_.Source -Force -ea Ignore).LastWriteTime
  if ($localModifyDate -eq $webModifyDate) {
    Write-Debug "skipping updated $($_.Source)"
  }
  elseif ($localModifyDate -lt $webModifyDate) {
    Write-Debug "overwriting $($_.Source) from $url"
    if ($null -eq $localModifyDate) {
      New-Item $_.Source -Force
    }
    Invoke-RestMethod -Method Get $url -Credential $Credential -OutFile $_.Source
  }
  else {
    Write-Debug "putting $($_.Source) to $url"
    Invoke-RestMethod -Method Put $url -Credential $Credential -InFile $_.Source
  }
}
