Register-ArgumentCompleter -Native -CommandName dbus-update-activation-environment -ScriptBlock {
  param ([string]$wordToComplete, [System.Management.Automation.Language.CommandAst]$commandAst, [int]$cursorPosition)
  @(if ($wordToComplete.StartsWith('-')) {
      '--all', '--systemd', '--verbose'
    }).Where{ $_ -like "$wordToComplete*" }
}
