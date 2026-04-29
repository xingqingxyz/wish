Register-ArgumentCompleter -Native -CommandName dbus-run-session -ScriptBlock {
  param ([string]$wordToComplete, [System.Management.Automation.Language.CommandAst]$commandAst, [int]$cursorPosition)
  @(if ($wordToComplete.StartsWith('-')) {
      '--config-file=', '--config-file', '--dbus-daemon=', '--dbus-daemon', '--help', '--version'
    }).Where{ $_ -like "$wordToComplete*" }
}
