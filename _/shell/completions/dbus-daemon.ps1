Register-ArgumentCompleter -Native -CommandName dbus-daemon -ScriptBlock {
  param ([string]$wordToComplete, [System.Management.Automation.Language.CommandAst]$commandAst, [int]$cursorPosition)
  @(if ($wordToComplete.StartsWith('-')) {
      '--config-file=', '--fork', '--nofork', '--print-address', '--print-address=', '--print-pid', '--print-pid=', '--session', '--system', '--version', '--introspect', '--address', '--address=', '--systemd-activation', '--nopidfile', '--syslog', '--syslog-only', '--nosyslog', '--ready-event-handle='
    }).Where{ $_ -like "$wordToComplete*" }
}
