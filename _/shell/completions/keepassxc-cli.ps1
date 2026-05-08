using namespace System.Management.Automation.Language

Register-ArgumentCompleter -Native -CommandName keepassxc-cli -ScriptBlock {
  param ([string]$wordToComplete, [System.Management.Automation.Language.CommandAst]$commandAst, [int]$cursorPosition)
  $command = @(foreach ($i in $commandAst.CommandElements) {
      if ($i.Extent.StartOffset -eq $commandAst.Extent.StartOffset -or $i.Extent.EndOffset -eq $cursorPosition) {
        continue
      }
      if ($i -isnot [StringConstantExpressionAst] -or
        $i.StringConstantType -ne [StringConstantType]::BareWord -or
        $i.Value.StartsWith('-')) {
        break
      }
      $i.Value
    }) -join ' '
  @(switch ($command) {
      '' {
        if ($wordToComplete.StartsWith('-')) {
          '--debug-info', '-?', '-h', '--help', '--help-all', '-v', '--version'
          break
        }
        'add', 'analyze', 'attachment-export', 'attachment-import', 'attachment-rm', 'clip', 'close', 'db-create', 'db-edit', 'db-info', 'diceware', 'edit', 'estimate', 'export', 'generate', 'help', 'import', 'ls', 'merge', 'mkdir', 'mv', 'open', 'rm', 'rmdir', 'search', 'show'
        break
      }
      'add' {
        if ($wordToComplete.StartsWith('-')) {
          '-q', '--quiet', '-k', '--key-file', '--no-password', '-y', '--yubikey', '-u', '--username', '--url', '--notes', '-p', '--password-prompt', '-g', '--generate', '-L', '--length', '-l', '--lower', '-U', '--upper', '-n', '--numeric', '-s', '--special', '-e', '--extended', '-x', '--exclude', '--exclude-similar', '--every-group', '-c', '--custom', '-h', '--help'
          break
        }
        break
      }
      'analyze' {
        if ($wordToComplete.StartsWith('-')) {
          '-q', '--quiet', '-k', '--key-file', '--no-password', '-y', '--yubikey', '-H', '--hibp', '--okon', '-h', '--help'
          break
        }
        break
      }
      'attachment-export' {
        if ($wordToComplete.StartsWith('-')) {
          '-q', '--quiet', '-k', '--key-file', '--no-password', '-y', '--yubikey', '--stdout', '-h', '--help'
          break
        }
        break
      }
      'attachment-import' {
        if ($wordToComplete.StartsWith('-')) {
          '-q', '--quiet', '-k', '--key-file', '--no-password', '-y', '--yubikey', '-f', '--force', '-h', '--help'
          break
        }
        break
      }
      'attachment-rm' {
        if ($wordToComplete.StartsWith('-')) {
          '-q', '--quiet', '-k', '--key-file', '--no-password', '-y', '--yubikey', '-h', '--help'
          break
        }
        break
      }
      'clip' {
        if ($wordToComplete.StartsWith('-')) {
          '-q', '--quiet', '-k', '--key-file', '--no-password', '-y', '--yubikey', '-a', '--attribute', '-t', '--totp', '-b', '--best-match', '-h', '--help'
          break
        }
        break
      }
      'db-create' {
        if ($wordToComplete.StartsWith('-')) {
          '-q', '--quiet', '--set-key-file', '-k', '-p', '--set-password', '-t', '--decryption-time', '-h', '--help'
          break
        }
        break
      }
      'db-edit' {
        if ($wordToComplete.StartsWith('-')) {
          '-q', '--quiet', '-k', '--key-file', '--no-password', '-y', '--yubikey', '--set-key-file', '-p', '--set-password', '--unset-key-file', '--unset-password', '-h', '--help'
          break
        }
        break
      }
      'db-info' {
        if ($wordToComplete.StartsWith('-')) {
          '-q', '--quiet', '-k', '--key-file', '--no-password', '-y', '--yubikey', '-h', '--help'
          break
        }
        break
      }
      'diceware' {
        if ($wordToComplete.StartsWith('-')) {
          '-q', '--quiet', '-W', '--words', '-w', '--word-list', '-h', '--help'
          break
        }
        break
      }
      'edit' {
        if ($wordToComplete.StartsWith('-')) {
          '-q', '--quiet', '-k', '--key-file', '--no-password', '-y', '--yubikey', '-u', '--username', '--url', '--notes', '-p', '--password-prompt', '-t', '--title', '-g', '--generate', '-L', '--length', '-l', '--lower', '-U', '--upper', '-n', '--numeric', '-s', '--special', '-e', '--extended', '-x', '--exclude', '--exclude-similar', '--every-group', '-c', '--custom', '-h', '--help'
          break
        }
        break
      }
      'estimate' {
        if ($wordToComplete.StartsWith('-')) {
          '-q', '--quiet', '-a', '--advanced', '-h', '--help'
          break
        }
        break
      }
      'export' {
        if ($wordToComplete.StartsWith('-')) {
          '-q', '--quiet', '-k', '--key-file', '--no-password', '-y', '--yubikey', '-f', '--format=xml', '--format=csv', '--format=html', '-h', '--help'
          break
        }
        break
      }
      'generate' {
        if ($wordToComplete.StartsWith('-')) {
          '-q', '--quiet', '-L', '--length', '-l', '--lower', '-U', '--upper', '-n', '--numeric', '-s', '--special', '-e', '--extended', '-x', '--exclude', '--exclude-similar', '--every-group', '-c', '--custom', '-h', '--help'
          break
        }
        break
      }
      'import' {
        if ($wordToComplete.StartsWith('-')) {
          '-q', '--quiet', '--set-key-file', '-k', '-p', '--set-password', '-t', '--decryption-time', '-h', '--help'
          break
        }
        break
      }
      'ls' {
        if ($wordToComplete.StartsWith('-')) {
          '-q', '--quiet', '-k', '--key-file', '--no-password', '-y', '--yubikey', '-R', '--recursive', '-f', '--flatten', '-h', '--help'
          break
        }
        break
      }
      'merge' {
        if ($wordToComplete.StartsWith('-')) {
          '-q', '--quiet', '-k', '--key-file', '--no-password', '-y', '--yubikey', '-s', '--same-credentials', '--key-file-from', '--no-password-from', '-d', '--dry-run', '--yubikey-from', '-h', '--help'
          break
        }
        break
      }
      'mkdir' {
        if ($wordToComplete.StartsWith('-')) {
          '-q', '--quiet', '-k', '--key-file', '--no-password', '-y', '--yubikey', '-h', '--help'
          break
        }
        break
      }
      'mv' {
        if ($wordToComplete.StartsWith('-')) {
          '-q', '--quiet', '-k', '--key-file', '--no-password', '-y', '--yubikey', '-h', '--help'
          break
        }
        break
      }
      'open' {
        if ($wordToComplete.StartsWith('-')) {
          '-q', '--quiet', '-k', '--key-file', '--no-password', '-y', '--yubikey', '-h', '--help'
          break
        }
        break
      }
      'rm' {
        if ($wordToComplete.StartsWith('-')) {
          '-q', '--quiet', '-k', '--key-file', '--no-password', '-y', '--yubikey', '-h', '--help'
          break
        }
        break
      }
      'rmdir' {
        if ($wordToComplete.StartsWith('-')) {
          '-q', '--quiet', '-k', '--key-file', '--no-password', '-y', '--yubikey', '-h', '--help'
          break
        }
        break
      }
      'search' {
        if ($wordToComplete.StartsWith('-')) {
          '-q', '--quiet', '-k', '--key-file', '--no-password', '-y', '--yubikey', '-h', '--help'
          break
        }
        break
      }
      'show' {
        if ($wordToComplete.StartsWith('-')) {
          '-q', '--quiet', '-k', '--key-file', '--no-password', '-y', '--yubikey', '-t', '--totp', '-a', '--attributes', '-s', '--show-protected', '--all', '--show-attachments', '-h', '--help'
          break
        }
        break
      }
    }
  ).Where{ $_ -like "$wordToComplete*" }
}
