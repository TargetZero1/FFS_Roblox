#!/usr/bin/env bash
content_dir_path=$1

luau-lsp analyze $content_dir_path \
--sourcemap=sourcemap.json \
--ignore="Packages/**" \
--ignore="ColdFusion/**" \
--flag:LuauTypeInferIterationLimit=0 \
--flag:LuauCheckRecursionLimit=0 \
--flag:LuauTypeInferRecursionLimit=0 \
--flag:LuauTarjanChildLimit=0 \
--flag:LuauTypeInferTypePackLoopLimit=0 \
--flag:LuauVisitRecursionLimit=0 \
--definitions=types/globalTypes.d.lua \
 > tests/lsp/$content_dir_path.txt 2>&1
echo "${content_dir_path} lsp errors: $(wc -l < tests/lsp/${content_dir_path}.txt)"
