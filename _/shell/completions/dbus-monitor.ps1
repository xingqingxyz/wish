Register-ArgumentCompleter -Native -CommandName dbus-monitor -ScriptBlock {
  param ([string]$wordToComplete, [System.Management.Automation.Language.CommandAst]$commandAst, [int]$cursorPosition)
  @(if ($wordToComplete.StartsWith('-')) {
      '--system', '--session', '--address', '--profile', '--monitor'
    }).Where{ $_ -like "$wordToComplete*" }
}
