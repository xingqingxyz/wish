#Requires -Version 7.6

#region common
$root = [System.IO.Path]::GetDirectoryName((Get-Item -LiteralPath $PSCommandPath).ResolvedTarget)
# PSES
if (Get-Module PowerShellEditorServices.Commands -ea Ignore) {
  . $root/onEnterPSES.ps1
}
# load
. $root/complete.ps1
. $root/keybindings.ps1
. $root/z.ps1
Remove-Variable root
# the wish shell
Import-Module LSColors, Profile -ea SilentlyContinue
# excutable alias
Set-Variable -Option ReadOnly -Force _executableAliasMap @{
  grep = 'grep', '--color=auto'
  rg   = 'rg', '--hyperlink-format=vscode'
}
if ($env:TERM_PROGRAM -cnotlike 'vscode*') {
  $_executableAliasMap.fd = 'fd', '--hyperlink=auto'
}
#endregion

#region windows
if ($IsWindows) {
  Set-Item -LiteralPath $_executableAliasMap.Keys.ForEach{ "Function:$_" } {
    # prevent . invoke variable add
    if ($MyInvocation.InvocationName -ceq '.') {
      return & $MyInvocation.MyCommand $args
    }
    $cmd = $MyInvocation.MyCommand.Name
    if (!$_executableAliasMap.Contains($cmd)) {
      return Write-Error "alias not set $cmd"
    }
    # flat iterator args for native passing
    $cmd, $ags = $_executableAliasMap[$cmd] + $args.ForEach{ $_.Where{ $null -ne $_ } }
    $cmd = (Get-Command $cmd -Type Application -TotalCount 1 -ea Stop).Source
    if ($MyInvocation.ExpectingInput) {
      Write-Debug "| $cmd $ags"
      $input | & $cmd $ags
    }
    else {
      Write-Debug "$cmd $ags"
      & $cmd $ags
    }
  }
  # winget command-not-found
  $ExecutionContext.InvokeCommand.CommandNotFoundAction = {
    [System.Management.Automation.CommandLookupEventArgs]$e = $args[1]
    if ($e.CommandOrigin -ceq 'Runspace' -and !$e.CommandName.StartsWith('get-')) {
      $e.StopSearch = $true
      $lines = winget search -s winget -n 1 --no-vt (Split-Path -LeafBase $e.CommandName)
      if (!$?) {
        return
      }
      $id = [regex]::Match($lines[2], '(?<= )[-\w]+\.[-\w]+(?= )').Value
      if (!$id) {
        throw "cannot find winget package ($($lines[2]))"
      }
      # note: stdout and stderr are ignored
      winget show -s winget --id $id | Out-Host
      if (!$?) {
        throw "cannot show winget package ($id)"
      }
      $ok = Read-Host "Install $id`? (Y/N)"
      if ($ok -eq 'y') {
        sudo winget install -s winget --accept-package-agreements --no-vt --id $id
        if ($?) {
          $e.CommandScriptBlock = [scriptblock]::Create("Update-SessionEnvironment; if (`$MyInvocation.ExpectingInput) { `$input | & $($e.CommandName) `$args } else { & $($e.CommandName) `$args }")
          return
        }
      }
      $e.CommandScriptBlock = {}
    }
  }
  return
}
#endregion

#region linux
function md {
  <#
  .FORWARDHELPTARGETNAME New-Item
  .FORWARDHELPCATEGORY Cmdlet
  #>
  New-Item @args -Type Directory -Force
}

Remove-Alias md -ea Ignore
Set-Alias ls Get-ChildItem
if ($env:WSL_DISTRO_NAME) {
  $_executableAliasMap.rg = 'rg', "--hyperlink-format=vscode://file//wsl.localhost/$env:WSL_DISTRO_NAME{path}:{line}:{column}"
}
Set-Item -LiteralPath $_executableAliasMap.Keys.ForEach{ "Function:$_" } {
  # prevent . invoke variable add
  if ($MyInvocation.InvocationName -ceq '.') {
    return & $MyInvocation.MyCommand $args
  }
  $cmd = $MyInvocation.MyCommand.Name
  if (!$_executableAliasMap.Contains($cmd)) {
    return Write-Error "alias not set $cmd"
  }
  # flat iterator args for native passing
  $ags = , '--' + $_executableAliasMap[$cmd] + $args.ForEach{ $_.Where{ $null -ne $_ } }
  if ($MyInvocation.ExpectingInput) {
    Write-Debug "| /usr/bin/env $ags"
    $input | /usr/bin/env $ags
  }
  else {
    Write-Debug "/usr/bin/env $ags"
    /usr/bin/env $ags
  }
}
# command-not-found
[string]$scriptText = {
  [System.Management.Automation.CommandLookupEventArgs]$e = $args[1]
  if ($e.CommandOrigin -ceq 'Runspace' -and !$e.CommandName.StartsWith('get-')) {
    $e.StopSearch = $true
    $name = @(%search% /usr/bin/$($e.CommandName) 2>$null)[0]
    if (!$name) {
      return
    }
    # stdout and stderr are ignored unless sudo
    %cmd% info $name | Out-Host
    sudo %cmd% install $name 2>$null
    $e.CommandScriptBlock = $? ? [scriptblock]::Create("if (`$MyInvocation.ExpectingInput) { `$input | & $($e.CommandName) `$args } else { & $($e.CommandName) `$args }") : {}
  }
}
$cmd = (Get-Command apt, dnf -CommandType Application -TotalCount 1 -ea Ignore)[0].Name
$ExecutionContext.InvokeCommand.CommandNotFoundAction = [scriptblock]$scriptText.Replace('%search%', ($cmd -ceq 'apt' ? 'apt-file search -Fil' : "dnf repoquery --arch=$(arch) --file")).Replace('%cmd%', $cmd)
#endregion
