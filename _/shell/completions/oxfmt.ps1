Register-ArgumentCompleter -Native -CommandName oxfmt -ScriptBlock {
  param ([string]$wordToComplete, [System.Management.Automation.Language.CommandAst]$commandAst, [int]$cursorPosition)
  @(if ($wordToComplete.StartsWith('-')) {
      '--init', '--migrate=prettier', '--migrate=biome', '--lsp', '--stdin-filepath=', '--write', '--check', '--list-different', '-c', '--config=', '--disable-nested-config', '--ignore-path=', '--with-node-modules', '--no-error-on-unmatched-pattern', '--threads=1', '--threads=16', '--threads=32', '-h', '--help', '-V', '--version'
    }).Where{ $_ -like "$wordToComplete*" }
}
