#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .build/ModuleCache
export CLANG_MODULE_CACHE_PATH="$PWD/.build/ModuleCache"
swiftc -parse-as-library -O \
  Sources/PetCore/CrawlState.swift Sources/Nudi/SlugDrawing.swift \
  scripts/render-demo.swift -o .build/render-demo
.build/render-demo docs/menu-bar-demo.gif
