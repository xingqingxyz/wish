<#
.NOTES
Generate:
$o = @{}
$re = [regex]::new('^ {4}(?:(--[-\w]+(?: <)?)|(-\w)(?:, (--[-\w]+(?: <)?))?)')
xan compgen xan '' xan | ForEach-Object {
  try {
    $o[$_] = xan $_ -h | ForEach-Object {
      if ($m = $re.Match($_).Groups) {
        $m[1].Value.Replace(' <', '=')
        $m[2].Value
        $m[3].Value.Replace(' <', '=')
      }
    } | Sort-Object -Unique
  }
  catch {
    $_
  }
}
$o.GetEnumerator().ForEach{
  $value = $_.Value | ConvertTo-Json -Compress
  $value = $value.Substring(1, $value.Length - 2)
  @"
  '$($_.Key)' {
    $value
    break
  }
"@
} | Set-Clipboard
 #>
using namespace System.Management.Automation.Language

Register-ArgumentCompleter -Native -CommandName xan -ScriptBlock {
  param ([string]$wordToComplete, [CommandAst]$commandAst, [int]$cursorPosition)
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
  @(if (!$wordToComplete.StartsWith('-')) {
      switch ($command) {
        '' {
          xan compgen xan $wordToComplete xan
          break
        }
        'help' {
          'cheatsheet', 'functions', 'aggs', 'scraping', 'window'
          break
        }
      }
    }
    else {
      switch ($command) {
        '' {
          '-h', '--help', '--version', '-n', '--no-headers', '-d', '--delimiter='
          break
        }
        'transform' {
          '--delimiter=', '--evaluate-file', '--help', '--no-headers', '--output=', '--parallel', '--rename=', '--threads=', '-d', '-f', '-h', '-n', '-o', '-p', '-r', '-t'
          break
        }
        'fmt' {
          '--ascii', '--crlf', '--delimiter=', '--escape=', '--help', '--in-place', '--out-delimiter=', '--output=', '--quote-always', '--quote-never', '--quote=', '--tabs', '-d', '-h', '-i', '-o', '-t'
          break
        }
        'join' {
          '--anti', '--cross', '--delimiter=', '--drop-key=', '--full', '--help', '--ignore-case', '--inner', '--left', '--no-headers', '--nulls', '--output=', '--prefix-left=', '--prefix-right=', '--right', '--semi', '-d', '-h', '-i', '-L', '-n', '-o', '-R'
          break
        }
        'behead' {
          '--append', '--delimiter=', '--help', '--output=', '-A', '-d', '-h', '-o'
          break
        }
        'groupby' {
          '--along-cols=', '--along-matrix=', '--delimiter=', '--help', '--keep=', '--no-headers', '--output=', '--parallel', '--sorted', '--threads=', '--total=', '-C', '-d', '-h', '-M', '-n', '-o', '-p', '-S', '-t'
          break
        }
        'parallel' {
          '--all', '--approx', '--buffer-size=', '--cardinality', '--compress', '--delimiter=', '--help', '--limit=', '--no-extra', '--no-headers', '--nulls', '--output=', '--path-column=', '--preprocess=', '--progress', '--quartiles', '--select=', '--sep=', '--shell-preprocess=', '--source-column=', '--threads=', '-a', '-B', '-c', '-d', '-H', '-l', '-n', '-o', '-P', '-q', '-s', '-t', '-z'
          break
        }
        'input' {
          '--bed', '--cdx', '--comment=', '--delimiter=', '--escape=', '--gff', '--gtf', '--gzip', '--help', '--no-quoting', '--output=', '--quote=', '--sam', '--skip-lines=', '--skip-until=', '--skip-while=', '--tabs', '--tolerant', '--trim', '--vcf', '--zstd', '-d', '-h', '-L', '-o', '-T', '-U', '-W'
          break
        }
        'headers' {
          '--color=', '--csv', '--delimiter=', '--help', '--just-names', '--output=', '--start=', '-d', '-h', '-j', '-o', '-s'
          break
        }
        'network' {
          '--degrees', '--delimiter=', '--disjoint-keys', '--format=', '--gexf-version=', '--help', '--largest-component', '--minify', '--no-headers', '--node-column=', '--nodes=', '--output=', '--sample-size=', '--simple', '--undirected', '--union-find', '-D', '-f', '-h', '-L', '-n', '-o', '-S', '-U'
          break
        }
        'view' {
          '--all', '--color=', '--cols=', '--delimiter=', '--expand', '--groupby=', '--help', '--hide-headers', '--hide-index', '--hide-info', '--limit=', '--no-headers', '--pager', '--rainbow', '--repeat-headers=', '--reveal-whitespace=', '--right=', '--sanitize-emojis', '--select=', '--significance=', '--tee', '--theme=', '-A', '-d', '-E', '-g', '-h', '-I', '-l', '-M', '-n', '-p', '-r', '-s', '-t'
          break
        }
        'sample' {
          '--delimiter=', '--groupby=', '--help', '--no-headers', '--output=', '--seed=', '--weight=', '-d', '-g', '-h', '-n', '-o', '-w'
          break
        }
        'vocab' {
          '--b-value=', '--chi2-significance=', '--delimiter=', '--distrib', '--doc=', '--forward', '--G2-significance=', '--help', '--implode', '--k1-value=', '--min-count=', '--no-headers', '--output=', '--sep=', '--specificity', '--tf-weight=', '--token=', '--window=', '-D', '-F', '-h', '-n', '-o', '-T', '-w'
          break
        }
        'fill' {
          '--delimiter=', '--help', '--no-headers', '--output=', '--select=', '--value=', '-d', '-h', '-n', '-o', '-s', '-v'
          break
        }
        'search' {
          '--add-pattern=', '--all', '--breakdown', '--count=', '--damerau-levenshtein=', '--delimiter=', '--empty', '--exact', '--flag=', '--help', '--ignore-case', '--invert-match', '--left', '--levenshtein=', '--limit=', '--name-column=', '--no-headers', '--non-empty', '--output=', '--overlapping', '--parallel', '--pattern-column=', '--patterns=', '--regex', '--replace=', '--replacement-column=', '--select=', '--sep=', '--threads=', '--unique-matches=', '--url-prefix', '-A', '-b', '-c', '-D', '-E', '-f', '-h', '-i', '-l', '-n', '-o', '-P', '-r', '-s', '-t', '-U', '-v'
          break
        }
        'blank' {
          '--delimiter=', '--help', '--no-headers', '--output=', '--redact=', '--select=', '-d', '-h', '-n', '-o', '-r', '-s'
          break
        }
        'stats' {
          '--all', '--approx', '--cardinality', '--delimiter=', '--groupby=', '--help', '--no-headers', '--nulls', '--output=', '--parallel', '--quartiles', '--select=', '--threads=', '-A', '-c', '-d', '-g', '-h', '-n', '-o', '-p', '-q', '-s', '-t'
          break
        }
        'frequency' {
          '--all', '--approx', '--delimiter=', '--groupby=', '--help', '--limit=', '--no-extra', '--no-headers', '--no-limit-we-reach-for-the-sky', '--output=', '--parallel', '--select=', '--sep=', '--threads=', '-a', '-d', '-g', '-h', '-l', '-n', '-o', '-p', '-s', '-t'
          break
        }
        'unpivot' {
          '--delimiter=', '--help', '--name-column=', '--no-headers', '--output=', '--value-column=', '-d', '-h', '-N', '-o', '-V'
          break
        }
        'reverse' {
          '--delimiter=', '--help', '--no-headers', '--output=', '-d', '-h', '-n', '-o'
          break
        }
        'split' {
          '--chunks=', '--delimiter=', '--filename=', '--help', '--no-headers', '--out-dir=', '--segments', '--size=', '-c', '-d', '-f', '-h', '-n', '-O', '-S'
          break
        }
        'implode' {
          '--cmp=', '--delimiter=', '--help', '--no-headers', '--output=', '--pluralize', '--rename=', '--sep=', '-d', '-h', '-n', '-o', '-P', '-r'
          break
        }
        'hist' {
          '--bar-size=', '--category=', '--color=', '--cols=', '--compress-gaps=', '--dates', '--delimiter=', '--domain-max=', '--field=', '--help', '--hide-percent', '--label=', '--log', '--name=', '--no-headers', '--rainbow', '--scale=', '--unit=', '--value=', '-B', '-c', '-d', '-f', '-G', '-h', '-l', '-m', '-n', '-P', '-R', '-u', '-v'
          break
        }
        'dedup' {
          '--check', '--choose=', '--delimiter=', '--external', '--flag=', '--help', '--keep-duplicates', '--keep-last', '--no-headers', '--output=', '--select=', '--sorted', '-C', '-d', '-e', '-f', '-h', '-k', '-l', '-n', '-o', '-s'
          break
        }
        'slice' {
          '--byte-offset=', '--delimiter=', '--end-byte=', '--end-condition=', '--end=', '--help', '--index=', '--indices=', '--last=', '--len=', '--no-headers', '--output=', '--raw', '--skip=', '--start-condition=', '--start=', '-B', '-d', '-e', '-h', '-I', '-L', '-n', '-o', '-S'
          break
        }
        'heatmap' {
          '--align=', '--ascii', '--color=', '--cram=', '--delimiter=', '--diverging', '--fill', '--gradient=', '--help', '--label=', '--max=', '--min=', '--no-headers', '--normalize=', '--repeat-headers=', '--show-gradients', '--show-normalized', '--show-numbers', '--size=', '--unit', '--values=', '--width=', '-a', '-C', '-D', '-F', '-G', '-h', '-l', '-M', '-n', '-S', '-U', '-v', '-w', '-Z'
          break
        }
        'fixlengths' {
          '--delimiter=', '--help', '--length=', '--output=', '--trust-header', '-d', '-H', '-l', '-o'
          break
        }
        'window' {
          '--delimiter=', '--groupby=', '--help', '--no-headers', '--output=', '-d', '-g', '-h', '-n', '-o'
          break
        }
        'bins' {
          '--bins=', '--delimiter=', '--exact', '--help', '--heuristic=', '--label=', '--max-bins=', '--max=', '--min=', '--no-extra', '--no-headers', '--output=', '--select=', '-b', '-d', '-e', '-H', '-l', '-m', '-n', '-o', '-s'
          break
        }
        'tokenize' {
          '--aerated', '--column=', '--delimiter=', '--drop=', '--filter-junk', '--flatmap=', '--help', '--keep-text', '--keep=', '--lower', '--max-token=', '--min-token=', '--ngrams-sep=', '--ngrams=', '--no-headers', '--output=', '--parallel', '--sep=', '--simple', '--split-hyphens', '--squeeze', '--stemmer=', '--stoplist=', '--threads=', '--token-type=', '--unidecode', '--uniq', '--vocab-token-id=', '--vocab-token=', '--vocab=', '-A', '-c', '-D', '-F', '-h', '-J', '-K', '-L', '-M', '-n', '-o', '-p', '-S', '-t', '-u', '-V'
          break
        }
        'cluster' {
          '--delimiter=', '--help', '--key=', '--no-headers', '--output=', '-d', '-h', '-k', '-n', '-o'
          break
        }
        'range' {
          '--column-name=', '--help', '--inclusive', '--output=', '--start=', '--step=', '-c', '-h', '-i', '-o', '-s'
          break
        }
        'map' {
          '--delimiter=', '--evaluate-file', '--filter', '--help', '--no-headers', '--output=', '--overwrite', '--parallel', '--threads=', '-d', '-f', '-h', '-n', '-O', '-p', '-t'
          break
        }
        'top' {
          '--delimiter=', '--groupby=', '--help', '--lexicographic', '--limit=', '--no-headers', '--output=', '--rank=', '--reverse', '--ties', '-d', '-g', '-h', '-L', '-n', '-o', '-R', '-T'
          break
        }
        'enum' {
          '--accumulate', '--byte-offset', '--column-name=', '--delimiter=', '--help', '--no-headers', '--output=', '--start=', '-A', '-B', '-c', '-d', '-h', '-n', '-o', '-S'
          break
        }
        'partition' {
          '--case-sensitive', '--delimiter=', '--drop', '--filename=', '--help', '--no-headers', '--out-dir=', '--prefix-length=', '--sorted', '-C', '-d', '-f', '-h', '-n', '-O', '-p', '-S'
          break
        }
        'progress' {
          '--bytes', '--delimiter=', '--help', '--no-headers', '--output=', '--prebuffer=', '--smooth', '--title=', '--total=', '-B', '-d', '-h', '-n', '-o', '-S'
          break
        }
        'flatmap' {
          '--delimiter=', '--evaluate-file', '--help', '--no-headers', '--output=', '--parallel', '--replace=', '--threads=', '-d', '-f', '-h', '-n', '-o', '-p', '-r', '-t'
          break
        }
        'count' {
          '--approx', '--delimiter=', '--help', '--no-headers', '--output=', '--parallel', '--threads=', '-a', '-d', '-h', '-n', '-o', '-p', '-t'
          break
        }
        'sort' {
          '--cells', '--check', '--columns', '--count=', '--delimiter=', '--external', '--help', '--memory-limit=', '--no-headers', '--numeric', '--output=', '--parallel', '--reverse', '--select=', '--tmp-dir=', '--uniq', '--unstable', '-c', '-d', '-e', '-h', '-m', '-N', '-o', '-p', '-R', '-s', '-u'
          break
        }
        'help' {
          '--color=', '--help', '--json', '--md', '--open', '--pager', '--section=', '-h', '-O', '-p', '-S'
          break
        }
        'flatten' {
          '--color=', '--cols=', '--condense', '--csv', '--delimiter=', '--flatter', '--help', '--highlight=', '--ignore-case', '--limit=', '--no-headers', '--non-empty', '--output=', '--rainbow', '--row-separator=', '--select=', '--sep=', '--split=', '--wrap', '-c', '-d', '-F', '-h', '-i', '-l', '-n', '-o', '-R', '-s', '-w'
          break
        }
        'select' {
          '--delimiter=', '--evaluate', '--evaluate-file', '--help', '--no-headers', '--output=', '-d', '-e', '-f', '-h', '-n', '-o'
          break
        }
        'transpose' {
          '--delimiter=', '--help', '--output=', '-d', '-h', '-o'
          break
        }
        'explode' {
          '--delimiter=', '--drop-empty', '--help', '--no-headers', '--output=', '--rename=', '--sep=', '--singularize', '-D', '-h', '-n', '-o', '-r', '-S'
          break
        }
        'fuzzy-join' {
          '--delimiter=', '--drop-key=', '--help', '--ignore-case', '--left', '--no-headers', '--output=', '--parallel', '--prefix-left=', '--prefix-right=', '--regex', '--simplified', '--threads=', '--url-prefix', '-D', '-h', '-i', '-L', '-n', '-o', '-p', '-R', '-S', '-t', '-u'
          break
        }
        'plot' {
          '--aggregate=', '--bars', '--category=', '--color=', '--cols=', '--count', '--delimiter=', '--granularity=', '--grid', '--help', '--ignore', '--line', '--marker=', '--no-headers', '--regression-line', '--rows=', '--share-x-scale=', '--share-y-scale=', '--small-multiples=', '--time', '--timezone=', '--x-max=', '--x-min=', '--x-scale=', '--x-ticks=', '--y-max=', '--y-min=', '--y-scale=', '--y-ticks=', '-A', '-B', '-c', '-d', '-G', '-h', '-i', '-L', '-M', '-n', '-R', '-S', '-T'
          break
        }
        'pivot' {
          '--column-sep=', '--delimiter=', '--groupby=', '--help', '--no-headers', '--output=', '-d', '-g', '-h', '-n', '-o', '-P'
          break
        }
        'rename' {
          '--delimiter=', '--force', '--help', '--no-headers', '--output=', '--prefix=', '--replace', '--select=', '--slugify', '--suffix=', '-d', '-f', '-h', '-n', '-o', '-p', '-R', '-s', '-x'
          break
        }
        'agg' {
          '--along-cols=', '--along-matrix=', '--along-rows=', '--delimiter=', '--help', '--no-headers', '--output=', '--parallel', '--threads=', '-C', '-d', '-h', '-M', '-n', '-o', '-p', '-R', '-t'
          break
        }
        'eval' {
          '--explain', '--headers=', '--help', '--row=', '--serialize', '-E', '-H', '-R', '-S'
          break
        }
        'from' {
          '--column=', '--format=', '--help', '--key-column=', '--list-sheets', '--nth-table=', '--output=', '--sample-size=', '--sheet-index=', '--sheet-name=', '--single-object', '--sort-keys', '--value-column=', '-c', '-f', '-h', '-n', '-o'
          break
        }
        'scrape' {
          '--delimiter=', '--encoding=', '--evaluate-file=', '--evaluate=', '--foreach=', '--help', '--input-dir=', '--keep=', '--no-headers', '--output=', '--parallel', '--sep=', '--threads=', '--url-column=', '-d', '-E', '-F', '-h', '-I', '-k', '-n', '-o', '-p', '-t', '-u'
          break
        }
        'merge' {
          '--delimiter=', '--help', '--no-headers', '--numeric', '--output=', '--path-column=', '--paths=', '--reverse', '--select=', '--source-column=', '--uniq', '-d', '-h', '-N', '-o', '-R', '-S', '-u'
          break
        }
        'filter' {
          '--delimiter=', '--evaluate-file', '--help', '--invert-match', '--limit=', '--no-headers', '--output=', '--parallel', '--threads=', '-d', '-f', '-h', '-l', '-n', '-o', '-p', '-t', '-v'
          break
        }
        'cat' {
          '--delimiter=', '--help', '--no-headers', '--output=', '--pad', '--path-column=', '--paths=', '--source-column=', '-d', '-h', '-n', '-o', '-p', '-S'
          break
        }
        'matrix' {
          '--delimiter=', '--fill-diagonal', '--help', '--no-headers', '--output=', '--select=', '--undirected', '--weight=', '-d', '-h', '-n', '-o', '-s', '-U', '-w'
          break
        }
        'shuffle' {
          '--delimiter=', '--external', '--help', '--no-headers', '--output=', '--seed=', '-d', '-e', '-h', '-n', '-o'
          break
        }
        'guillotine' {
          '--append', '--delimiter=', '--help', '--output=', '-A', '-d', '-h', '-o'
          break
        }
      }
    }).Where{ $_ -like "$wordToComplete*" }
}
