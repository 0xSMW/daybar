#!/usr/bin/env node

import { execFileSync } from "node:child_process";
import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const artworkDirectory = dirname(fileURLToPath(import.meta.url));
const repositoryRoot = resolve(artworkDirectory, "..");
const assetDirectory = resolve(
  repositoryRoot,
  "DayBar/Assets.xcassets/AppIcon.appiconset",
);
const templatePath = resolve(artworkDirectory, "calendar.badge.svg");
const sourcePath = resolve(artworkDirectory, "DayBarIcon.svg");

const template = readFileSync(templatePath, "utf8");
const regularSymbol = template.match(
  /<g id="Regular-S"[^>]*>([\s\S]*?)\n  <\/g>/,
)?.[1];

if (!regularSymbol) {
  throw new Error("The exported calendar.badge template has no Regular-S symbol.");
}

const paths = [...regularSymbol.matchAll(/<path class="([^"]+)" d="([^"]+)"\/>/g)];
if (paths.length !== 3) {
  throw new Error(`Expected three calendar.badge layers, found ${paths.length}.`);
}

const layers = paths.map(([, className, data]) => {
  const fill = className.includes("monochrome-1") ? "#fff" : "#17171a";
  return `    <path fill="${fill}" d="${data}"/>`;
});

const svg = `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">
  <title>Daybar app icon</title>
  <desc>Apple SF Symbol calendar.badge on a native macOS icon tile.</desc>
  <defs>
    <linearGradient id="tile" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#ffffff"/>
      <stop offset="1" stop-color="#e8e8ed"/>
    </linearGradient>
    <filter id="shadow" x="-20%" y="-20%" width="140%" height="150%">
      <feDropShadow dx="0" dy="12" stdDeviation="14" flood-color="#000000" flood-opacity="0.24"/>
    </filter>
  </defs>
  <rect x="100" y="100" width="824" height="824" rx="235" fill="url(#tile)" filter="url(#shadow)"/>
  <rect x="101" y="101" width="822" height="822" rx="234" fill="none" stroke="#000000" stroke-opacity="0.10" stroke-width="2"/>
  <g transform="translate(115 799) scale(7.1)">
${layers.join("\n")}
  </g>
</svg>
`;

writeFileSync(sourcePath, svg);
mkdirSync(assetDirectory, { recursive: true });

const exports = [
  ["AppIcon-16x16.png", 16],
  ["AppIcon-16x16@2x.png", 32],
  ["AppIcon-32x32.png", 32],
  ["AppIcon-32x32@2x.png", 64],
  ["AppIcon-128x128.png", 128],
  ["AppIcon-128x128@2x.png", 256],
  ["AppIcon-256x256.png", 256],
  ["AppIcon-256x256@2x.png", 512],
  ["AppIcon-512x512.png", 512],
  ["AppIcon-512x512@2x.png", 1024],
];

for (const [filename, size] of exports) {
  execFileSync("rsvg-convert", [
    "--width",
    String(size),
    "--height",
    String(size),
    sourcePath,
    "--output",
    resolve(assetDirectory, filename),
  ]);
}
