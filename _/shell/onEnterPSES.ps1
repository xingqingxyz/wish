#Requires -Modules PowerShellEditorServices.Commands

# preferences
$DebugPreference = 'Continue'

#region defs
function e.i {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
    [string]
    $Value
  )
  $psEditor.GetEditorContext().CurrentFile.InsertText($Value)
}

function e.jq {
  [CmdletBinding()]
  param (
    [Parameter(Position = 0)]
    [ValidateSet('jq', 'js', 'py')]
    [string]
    $Type = 'jq'
  )
  $context = $psEditor.GetEditorContext()
  if ($context.CurrentFile.Language -cnotmatch '^jsonc?$') {
    return Write-Error 'document language not jsonc like'
  }
  $context.CurrentFile.GetText() | node $PSScriptRoot/../../scripts/jsonPath.ts $Type ($context.CursorPosition.Line - 1) ($context.CursorPosition.Column - 1)
}
#endregion

# commands
Register-EditorCommand -Name 'hello' -DisplayName 'Hello World' -SuppressOutput -ScriptBlock {
  [CmdletBinding()]
  param (
    [Parameter()]
    [Microsoft.PowerShell.EditorServices.Extensions.EditorContext, Microsoft.PowerShell.EditorServices]
    $Context
  )
  $text = @(if ($IsLinux) {
      if ($env:XDG_SESSION_TYPE -ceq 'wayland') {
        wl-paste -p
      }
      else {
        xclip -o -selection primary
      }
    }
    else {
      (Get-Clipboard -Raw).Split("`n")
    }).Trim().Replace("'", "''") -join "', '"
  $Context.CurrentFile.InsertText("'$text'")
}
