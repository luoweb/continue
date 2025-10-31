#!/bin/bash

xsed='sed -i'
system=`uname`
if [ "$system" == "Darwin" ]; then
  echo "This is macOS"
  xsed="sed -i .bak"
else
  echo "This is Linux"
  xsed='sed -i'
fi

# custom with config
# $xsed "s#'CAN_REPLACE_LOGO': 'False'#'CAN_REPLACE_LOGO': 'True'#g" ../api/config.py

# custom plugin
# find ../web/ -type f -name "*.ts" -o -name "*.tsx" | xargs grep -E "[ '\"]Dify[ '\"]"| awk -F ':' '{print $1}' | xargs -I@ bash -c "${xsed} -i.bak 's#Dify#LLMAI#g' @"
# $xsed 's#"name": "continue",#"name": "aicoder",#g' ../../extensions/vscode/package.json
# $xsed 's#Continue Dev#BlockAI Dev#g' ../../extensions/vscode/package.json
# $xsed 's#"homepage": "https://continue.dev"#"homepage": "https://aicoder.dev"#g' ../../extensions/vscode/package.json
# $xsed 's#https://hub.continue.dev/#https://hub.continue.dev/#g' ../../extensions/vscode/package.json
# $xsed 's#https://github.com/continuedev/continue#https://github.com/blockai/aicoder#g' ../../extensions/vscode/package.json
# $xsed "s#continue#aicoder#g" ../../extensions/vscode/package.json
# $xsed "s#continue#aicoder#g" ../../extensions/vscode/package.json
$xsed 's#"displayName":.*#"displayName": "分布式编码助手",#g' ../../extensions/vscode/package.json
$xsed 's#"description":.*#"description": "编码智能体，助效能提升",#g' ../../extensions/vscode/package.json
# $xsed 's#"publisher":.*#"publisher": "BlockAI",#g' ../../extensions/vscode/package.json
# $xsed 's#"title": "Continue",#"title": "分布式编码助手",#g' ../../extensions/vscode/package.json
# $xsed 's#"title": "Continue Console",#"title": "编码助手控制台",#g' ../../extensions/vscode/package.json
# $xsed 's#"Enable Continue#"Enable AiCoder#g' ../../extensions/vscode/package.json
# $xsed 's#"Pause Continue#"Pause AiCoder#g' ../../extensions/vscode/package.json
# $xsed 's#"name": "Continue#"name": "AiCoder#g' ../../extensions/vscode/package.json


# # $xsed "s#logo-monochrome-white.svg#logo-monochrome-white-llmapp.svg#g" ../web/app/components/base/logo/logo-site.tsx
# find ../../ -type f -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.mdx" | grep -v node_modules | xargs $xsed 's#https://hub.continue.dev/#https://hub.aicoder.dev/#g'
# find ../web -type f -name "*.ts" -o -name "*.tsx" -o -name "*.js" | grep -v node_modules | xargs $xsed "s#logo-monochrome-white.svg#logo-monochrome-white-llmapp.svg#g"
# find ../web -type f -name "*.ts" -o -name "*.tsx" | xargs grep -E "[ '>\"]Dify[ '<\"\$\`]" | grep -vE "default as Dify |Dify.json|embedded-chatbot/index.tsx"
# find ../web -type f -name "*.ts" -o -name "*.tsx" | xargs grep -E "[ '>\"]Dify[ '<\"\$\`]" | grep -vE "default as Dify |Dify.json|embedded-chatbot/index.tsx" | awk -F ':' '{print $1}' | xargs -I@ sh -c "sed -i.bak 's#Dify#LLMAI#g' '@'"
# find ../web -type f -name "*.ts" -o -name "*.tsx" | xargs grep -E "https://github.com/langgenius/dify" | grep -vE " default as Dify |Dify.json|embedded-chatbot/index.tsx" | awk -F ':' '{print $1}' | xargs -I@ sh -c "sed -i.bak 's#https://github.com/langgenius/dify#https://github.com/blockmap/llmai#g' '@'"

# custom api:
# $xsed "s#Dify OpenAPI#BlockAI OpenAPI#g" ../api/controllers/service_api/index.py
exit 0