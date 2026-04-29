& (Get-Command fd -CommandType Application -TotalCount 1) --gen-completions=powershell | Out-String | Invoke-Expression
