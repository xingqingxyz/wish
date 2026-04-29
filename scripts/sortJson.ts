#!/usr/bin/env node
import { readFile, writeFile } from 'node:fs/promises'

function sortObject(obj: object) {
  return Object.entries(obj)
    .sort((a, b) => a[0].localeCompare(b[0]))
    .reduce((o, [k, v]) => ((o[k] = sortAny(v)), o), {} as any) as object
}

function sortAny(value: any): any {
  switch (typeof value) {
    case 'string':
    case 'number':
    case 'boolean':
      return value
    case 'object':
      if (value === null || Array.isArray(value)) {
        return value
      }
      return sortObject(value)
    default:
      throw `unsupported type ${typeof value}`
  }
}

await Promise.all(
  process.argv
    .slice(2)
    .map(async (file) =>
      writeFile(
        file,
        JSON.stringify(
          sortAny(JSON.parse(await readFile(file, 'utf-8'))),
          undefined,
          2,
        ),
        'utf-8',
      ),
    ),
)
