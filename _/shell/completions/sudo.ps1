using namespace System.Management.Automation.Language

Register-ArgumentCompleter -Native -CommandName sudo, x -ScriptBlock {
  param ([string]$wordToComplete, [CommandAst]$commandAst, [int]$cursorPosition)
  for ($i = 1; $i -lt $commandAst.CommandElements.Count; $i++) {
    if (!$commandAst.CommandElements[$i].ToString().StartsWith('-')) {
      break
    }
  }
  switch ($commandAst.CommandElements.Count - $i) {
    { $_ -le 1 } {
      if ($wordToComplete.StartsWith('-')) {
        @(switch ([System.IO.Path]::GetFileNameWithoutExtension($commandAst.GetCommandName())) {
            'sudo' {
              if ($IsWindows) {
                '-E', '--preserve-env', '-N', '--new-window', '--disable-input', '--inline', '-D', '--chdir=', '-h', '--help', '-V', '--version'
                break
              }
              elseif ($IsLinux) {
                '-A', '--askpass', '-b', '--background', '-B', '--bell', '-C', '--close-from=', '-D', '--chdir=', '-E', '--preserve-env', '--preserve-env=', '-e', '--edit', '-g', '--group=', '-H', '--set-home', '-h', '--help', '-h', '--host=', '-i', '--login', '-K', '--remove-timestamp', '-k', '--reset-timestamp', '-l', '--list', '-n', '--non-interactive', '-P', '--preserve-groups', '-p', '--prompt=#', '-R', '--chroot=/root', '-r', '--role=', '-S', '--stdin', '-s', '--shell', '-t', '--type=', '-T', '--command-timeout=12000', '-U', '--other-user=', '-u', '--user=', '-V', '--version', '-v', '--validate'
                break
              }
              break
            }
          }).Where{ $_ -like "$wordToComplete*" }
        break
      }
      if (Test-Path $wordToComplete*) {
        [System.Management.Automation.CompletionCompleters]::CompleteFilename($wordToComplete)
      }
      else {
        [System.Management.Automation.CompletionCompleters]::CompleteCommand($wordToComplete)
      }
      break
    }
    default {
      [string]$line = $commandAst
      $commandName = [System.IO.Path]::GetFileNameWithoutExtension($commandAst.CommandElements[$i])
      $i = $commandAst.CommandElements[$i].Extent.StartOffset
      $line = $line.Substring($i)
      $cursorPosition -= $i
      $commandAst = [Parser]::ParseInput($line, [ref]$null, [ref]$null).EndBlock.Statements[0].PipelineElements[0]
      & (Get-ArgumentCompleter $commandName) $wordToComplete $commandAst $cursorPosition
      break
    }
  }
}
