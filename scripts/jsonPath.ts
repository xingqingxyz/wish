import { getLocation, type JSONPath } from 'jsonc-parser'
import { text } from 'node:stream/consumers'

export function concatJsonPathJq(path: JSONPath) {
  if (!path.length) {
    return '.'
  }
  const reIdentifier = /^[a-z_]\w*$/i
  const s = path
    .map((key) =>
      typeof key === 'string'
        ? '.' + (reIdentifier.test(key) ? key : JSON.stringify(key))
        : `[${key}]`,
    )
    .join('')
  return s.startsWith('[') ? '.' + s : s
}

export function concatJsonPathJavaScript(path: JSONPath) {
  const reIdentifier = /^[a-z_$][\w$]*$/i
  return path
    .map((key) =>
      typeof key === 'string' && reIdentifier.test(key)
        ? '.' + key
        : JSON.stringify([key]),
    )
    .join('')
}

export function concatJsonPathPython(path: JSONPath) {
  return path.map((key) => JSON.stringify([key])).join('')
}

async function main() {
  if (process.argv.length != 5) {
    throw 'invalid arguments (type,line,column)'
  }
  if (process.stdin.isTTY) {
    throw 'please pass document text by stdin'
  }
  const type = process.argv[2]
  const line = parseInt(process.argv[3])
  const column = parseInt(process.argv[4])
  if (Number.isNaN(line) || Number.isNaN(column) || line < 0 || column < 0) {
    throw 'line or column must be non-negative integer'
  }
  const documentText = await text(process.stdin)
  const lines = documentText.split('\n', line + 1)
  if (lines[line]?.length < column) {
    throw 'position out of range'
  }
  const offset =
    lines
      .values()
      .take(line)
      .reduce((c, l) => c + l.length + 1, 0) + column
  const { path } = getLocation(documentText, offset)
  console.log(
    (type === 'js'
      ? concatJsonPathJavaScript
      : type === 'py'
        ? concatJsonPathPython
        : concatJsonPathJq)(path),
  )
}

await main()
