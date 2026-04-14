#!/usr/bin/env node
import { readFileSync, writeFileSync, existsSync } from 'node:fs'
import { basename, resolve } from 'node:path'

const svgToDataUri = (svgPath) => {
  const data = readFileSync(svgPath)
  return `data:image/svg+xml;base64,${data.toString('base64')}`
}

const svgToInline = (svgPath) => readFileSync(svgPath, 'utf8').trim()

const main = () => {
  if (process.argv.length < 4) {
    console.log(`Usage: ${basename(process.argv[1])} <input.html> <images_dir>`)
    process.exit(1)
  }

  const htmlPath = resolve(process.argv[2])
  const imagesDir = resolve(process.argv[3])

  let html = readFileSync(htmlPath, 'utf8')

  const replacements = new Map([
    ['{{LOGO_DATA_URI}}', ['logo.svg', svgToDataUri]],
    ['{{LOGO_WHITE_DATA_URI}}', ['logo-white.svg', svgToDataUri]],
    ['{{MOUNTAIN_SVG_INLINE}}', ['mountain.svg', svgToInline]],
    ['{{MOUNTAIN_WHITE_SVG_INLINE}}', ['mountain-white.svg', svgToInline]],
  ])

  for (const [placeholder, [filename, converter]] of replacements) {
    const filePath = resolve(imagesDir, filename)
    if (existsSync(filePath) && html.includes(placeholder)) {
      html = html.replaceAll(placeholder, converter(filePath))
      console.log(`  Replaced ${placeholder} from ${filename}`)
      continue
    }

    if (html.includes(placeholder)) {
      console.log(`  WARNING: ${filename} not found, ${placeholder} left as-is`)
    }
  }

  writeFileSync(htmlPath, html, 'utf8')
  console.log(`Done: ${htmlPath}`)
}

main()
