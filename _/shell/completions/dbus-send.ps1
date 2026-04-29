Register-ArgumentCompleter -Native -CommandName dbus-send -ScriptBlock {
  param ([string]$wordToComplete, [System.Management.Automation.Language.CommandAst]$commandAst, [int]$cursorPosition)
  @(if ($wordToComplete.StartsWith('-')) {
      '--dest', '--bus', '--peer', '--sender', '--dest=', '--print-reply', '--print-reply=literal', '--reply-timeout=25', '--system', '--session', '--bus=', '--peer=', '--sender=', '--type=signal', '--type=method_call'
    }).Where{ $_ -like "$wordToComplete*" }
}
