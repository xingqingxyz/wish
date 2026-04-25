Register-ArgumentCompleter -Native -CommandName tsc -ScriptBlock {
  param ([string]$wordToComplete, [System.Management.Automation.Language.CommandAst]$commandAst, [int]$cursorPosition)
  $cursorPosition -= $wordToComplete.Length
  foreach ($i in $commandAst.CommandElements) {
    if ($i.Extent.StartOffset -ge $cursorPosition) {
      break
    }
    $prev = $i
  }
  $prev = $prev -is [System.Management.Automation.Language.StringConstantExpressionAst] ? $prev.Value : $prev.ToString()
  @(switch -CaseSensitive -Regex ($prev) {
      '^(-m|--module)$' { 'commonjs', 'es6/es2015', 'es2020', 'es2022', 'esnext', 'node16', 'node18', 'node20', 'nodenext', 'preserve'; break }
      '^(-t|--target)$' { 'es6', 'es2015', 'es2016', 'es2017', 'es2018', 'es2019', 'es2020', 'es2021', 'es2022', 'es2023', 'es2024', 'es2025', 'esnext'; break }
      '^--lib$' { 'es5', 'es6', 'es2015', 'es7', 'es2016', 'es2017', 'es2018', 'es2019', 'es2020', 'es2021', 'es2022', 'es2023', 'es2024', 'es2025', 'esnext', 'dom', 'dom.iterable', 'dom.asynciterable', 'webworker', 'webworker.importscripts', 'webworker.iterable', 'webworker.asynciterable', 'scripthost', 'es2015.core', 'es2015.collection', 'es2015.generator', 'es2015.iterable', 'es2015.promise', 'es2015.proxy', 'es2015.reflect', 'es2015.symbol', 'es2015.symbol.wellknown', 'es2016.array.include', 'es2016.intl', 'es2017.arraybuffer', 'es2017.date', 'es2017.object', 'es2017.sharedmemory', 'es2017.string', 'es2017.intl', 'es2017.typedarrays', 'es2018.asyncgenerator', 'es2018.asynciterable', 'esnext.asynciterable', 'es2018.intl', 'es2018.promise', 'es2018.regexp', 'es2019.array', 'es2019.object', 'es2019.string', 'es2019.symbol', 'esnext.symbol', 'es2019.intl', 'es2020.bigint', 'esnext.bigint', 'es2020.date', 'es2020.promise', 'es2020.sharedmemory', 'es2020.string', 'es2020.symbol.wellknown', 'es2020.intl', 'es2020.number', 'es2021.promise', 'es2021.string', 'es2021.weakref', 'esnext.weakref', 'es2021.intl', 'es2022.array', 'es2022.error', 'es2022.intl', 'es2022.object', 'es2022.string', 'es2022.regexp', 'es2023.array', 'es2023.collection', 'es2023.intl', 'es2024.arraybuffer', 'es2024.collection', 'es2024.object', 'esnext.object', 'es2024.promise', 'es2024.regexp', 'esnext.regexp', 'es2024.sharedmemory', 'es2024.string', 'esnext.string', 'es2025.collection', 'es2025.float16', 'esnext.float16', 'es2025.intl', 'es2025.iterator', 'esnext.iterator', 'es2025.promise', 'esnext.promise', 'es2025.regexp', 'esnext.array', 'esnext.collection', 'esnext.date', 'esnext.decorators', 'esnext.disposable', 'esnext.error', 'esnext.intl', 'esnext.sharedmemory', 'esnext.temporal', 'esnext.typedarrays', 'decorators', 'decorators.legacy'; break }
      '^--jsx$' { 'preserve', 'react', 'react-native', 'react-jsx', 'react-jsxdev'; break }
      '^--(pretty|declaration|declarationMap|emitDeclarationOnly|sourceMap|noEmit|allowJs|checkJs|removeComments|strict|esModuleInterop)$' { 'false'; break }
      default {
        if ($wordToComplete.StartsWith('-')) {
          '--help', '-h', '--watch', '-w', '--all', '--version', '-v', '--init', '--project', '-p', '--showConfig', '--ignoreConfig', '--build', '-b', '--pretty', '--declaration', '-d', '--declarationMap', '--emitDeclarationOnly', '--sourceMap', '--noEmit', '--target', '-t', '--module', '-m', '--lib', '--allowJs', '--checkJs', '--jsx', '--outFile', '--outDir', '--removeComments', '--strict', '--types', '--esModuleInterop'
          break
        }
        break
      }
    }).Where{ $_ -like "$wordToComplete*" }
}
