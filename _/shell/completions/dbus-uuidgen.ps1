Register-ArgumentCompleter -Native -CommandName dbus-uuidgen -ScriptBlock {
  param ([string]$wordToComplete, [System.Management.Automation.Language.CommandAst]$commandAst, [int]$cursorPosition)
  @(if ($wordToComplete.StartsWith('-')) {
      '--get', '--get=', '--ensure', '--ensure=', '--version'
    }).Where{ $_ -like "$wordToComplete*" }
}
