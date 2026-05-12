#!/usr/bin/env node
import { readFile, writeFile } from 'node:fs/promises'

function sortObject(obj: any): any {
  if (Array.isArray(obj)) {
    return obj.map(sortObject)
  }
  if (typeof obj === 'object' && obj !== null) {
    return Object.keys(obj)
      .sort()
      .reduce((sorted, key) => {
        sorted[key] = sortObject(obj[key])
        return sorted
      }, {} as any)
  }
  return obj
}

await Promise.all(
  process.argv
    .slice(2)
    .map(async (file) =>
      writeFile(
        file,
        JSON.stringify(
          sortObject(JSON.parse(await readFile(file, 'utf-8'))),
          undefined,
          2,
        ),
        'utf-8',
      ),
    ),
)
