using namespace System.Management.Automation.Language

Register-ArgumentCompleter -Native -CommandName busctl -ScriptBlock {
  param ([string]$wordToComplete, [CommandAst]$commandAst, [int]$cursorPosition)
  $mode = '--system'
  $commands = @(foreach ($i in $commandAst.CommandElements) {
      if ($i.Extent.StartOffset -eq $commandAst.Extent.StartOffset -or $i.Extent.EndOffset -eq $cursorPosition) {
        continue
      }
      if ($i -isnot [StringConstantExpressionAst] -or
        $i.StringConstantType -ne [StringConstantType]::BareWord -or
        $i.Value.StartsWith('-')) {
        if ($i -is [StringConstantExpressionAst] -and $i.Value -ceq '--user' -or
          ($foreach | Where-Object Value -CEQ '--user')) {
          $mode = '--user'
        }
        break
      }
      $i.Value
    })
  @(if ($wordToComplete.StartsWith('-')) {
      '-h', '--help', '--version', '--no-pager', '--no-legend', '-l', '--full', '--system', '--user', '-H', '--host', '-M', '--machine', '--address', '--show-machine', '--unique', '--acquired', '--activatable', '--match=', '--size=', '--list', '-q', '--quiet', '--verbose', '--json=pretty', '--json=short', '--json=off', '-j', '--xml-interface', '--expect-reply=true', '--expect-reply=false', '--auto-start=true', '--auto-start=false', '--allow-interactive-authorization=true', '--allow-interactive-authorization=false', '--timeout=10', '--augment-creds=true', '--augment-creds=false', '--watch-bind=true', '--watch-bind=false', '--destination', '-N', '--limit-messages='
    }
    else {
      switch -CaseSensitive -Regex ($commands -join ' ') {
        '^(|help)$' {
          $cursorPosition -= $wordToComplete.Length
          foreach ($i in $commandAst.CommandElements) {
            if ($i.Extent.StartOffset -ge $cursorPosition) {
              break
            }
            $prev = $i
          }
          $prev = $prev -is [System.Management.Automation.Language.StringConstantExpressionAst] ? $prev.Value : $prev.ToString()
          switch -CaseSensitive -Regex ($prev) {
            '^(-H|--host)$' { bash -c 'compgen -A hostname'; break }
            '^--destination$' { busctl $mode list --no-legend --no-pager --full 2>$null | ForEach-Object { ($_ -csplit '\s+', 2)[0] }; break }
            '^--machine$' { machinectl list --full --max-addresses=0 --no-legend --no-pager 2>$null | ForEach-Object { ($_ -csplit '\s+', 2)[0] }; '.host'; break }
          }
          'list', 'status', 'monitor', 'capture', 'tree', 'introspect', 'call', 'emit', 'wait', 'get-property', 'set-property', 'help'
          break
        }
        '^(status|monitor|capture|tree|introspect|call|get-property|set-property|emit|wait)$' {
          busctl $mode list --no-legend --no-pager --full 2>$null | ForEach-Object { ($_ -csplit '\s+', 2)[0] }
          break
        }
        '^(emit|wait|introspect|call|get-property|set-property) \S+$' {
          busctl $mode tree --list --no-legend --no-pager $commands[1] 2>$null | ForEach-Object { ($_ -csplit '\s+', 2)[0] }
          break
        }
        '^(emit|wait|introspect|call|get-property|set-property) \S+ \S+$' {
          busctl $mode introspect --list --no-legend --no-pager $commands[1, 2] 2>$null | ForEach-Object {
            $words = $_ -csplit '\s+', 3
            if ($words[1] -ceq 'interface') {
              $words[0]
            }
          }
          break
        }
        '^(call|emit|set-property) \S+ \S+ \S+ \S+$' {
          busctl $mode introspect --list --no-legend --no-pager $commands[1, 2, 3] 2>$null | ForEach-Object {
            $words = $_ -csplit '\s+'
            if ($words[2] -cne '-' -and $words[0].Substring(1) -ceq $commands[4]) {
              $words[2]
            }
          }
          break
        }
        '^(emit|wait) \S+ \S+ \S+$' {
          busctl $mode tree --list --no-legend --no-pager $commands[1, 2, 3] 2>$null | ForEach-Object {
            $words = $_ -csplit '\s+', 3
            if ($words[1] -ceq 'signal') {
              $words[0].Substring(1)
            }
          }
          break
        }
        '^call \S+ \S+ \S+$' {
          busctl $mode introspect --list --no-legend --no-pager $commands[1, 2, 3] 2>$null | ForEach-Object {
            $words = $_ -csplit '\s+', 3
            if ($words[1] -ceq 'method') {
              $words[0].Substring(1)
            }
          }
          break
        }
        '^emit \S+ \S+ \S+$' {
          busctl $mode tree --list --no-legend --no-pager $commands[1, 2, 3] 2>$null | ForEach-Object {
            $words = $_ -csplit '\s+', 4
            if ($words[2] -cne '-' -and $words[0].Substring(1) -ceq $commands[4]) {
              $words[2]
            }
          }
          break
        }
        '^get-property \S+ \S+ \S+$' {
          busctl $mode introspect --list --no-legend --no-pager $commands[1, 2, 3] 2>$null | ForEach-Object {
            $words = $_ -csplit '\s+', 3
            if ($words[1] -ceq 'property') {
              $words[0].Substring(1)
            }
          }
          break
        }
        '^set-property \S+ \S+ \S+$' {
          busctl $mode introspect --list --no-legend --no-pager $commands[1, 2, 3] 2>$null | ForEach-Object {
            $words = $_ -csplit '\s+'
            if ($words[1] -ceq 'property' -and $words[4] -ceq 'writable') {
              $words[0].Substring(1)
            }
          }
          break
        }
      }
    }).Where{ $_ -like "$wordToComplete*" }
}
