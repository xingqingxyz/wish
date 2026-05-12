Register-ArgumentCompleter -Native -CommandName jd -ScriptBlock {
  param ([string]$wordToComplete, [System.Management.Automation.Language.CommandAst]$commandAst, [int]$cursorPosition)
  @(if ($wordToComplete.StartsWith('-')) {
      '-color', '-color-words', '-f=jd', '-f=patch', '-f=merge', '-git-diff-driver', '-mset', '-o=', '-opts=', '-p', '-port=', '-precision=0.01', '-precision=0.01', '-set', '-setkeys=', '-t=jd2patch', '-t=jd2merge', '-t=patch2jd', '-t=merge2jd', '-t=json2yaml', '-t=yaml2json', '-v2', '-version', '-yaml'
    }).Where{ $_ -like "$wordToComplete*" }
}
