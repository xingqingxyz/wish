Register-ArgumentCompleter -Native -CommandName gdbus -ScriptBlock {
  param ([string]$wordToComplete, [System.Management.Automation.Language.CommandAst]$commandAst, [int]$cursorPosition)
  gdbus complete $commandAst.ToString() $cursorPosition | Where-Object { $_ -like "$wordToComplete*" }
}
