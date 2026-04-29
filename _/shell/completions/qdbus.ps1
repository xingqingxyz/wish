Register-ArgumentCompleter -Native -CommandName qdbus, dcop -ScriptBlock {
  param ([string]$wordToComplete, [System.Management.Automation.Language.CommandAst]$commandAst, [int]$cursorPosition)
  $line = $commandAst.ToString()
  $lastOffset = $commandAst.CommandElements[-1].Extent.EndOffset
  $env:COMP_LINE = $line
  $env:COMP_POINT = $cursorPosition
  Invoke-Expression $line.Substring(0, $lastOffset -lt $line.Length ? $lastOffset : $commandAst.CommandElements[-2].Extent.EndOffset)
}
