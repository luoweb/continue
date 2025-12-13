#!/bin/bash

baseDir=$(cd `dirname $0`;pwd)
cd $baseDir
execStartTime=`date +%Y%m%d-%H:%M:%S`

echo "${execStartTime} Exe Dir: $baseDir"
xsed='sed -i'
system=`uname`
if [ "$system" == "Darwin" ]; then
  echo "This is macOS"
  xsed="sed -i .bak"
else
  echo "This is Linux"
  xsed='sed -i'
fi

echo "########## custom replace begin ########## "


echo "ui custom"

# 目标文件路径（请替换为你的实际文件路径，如 ./src/components/Login.jsx）
TARGET_FILE=${baseDir}/../gui/src/components/OnboardingCard/components/OnboardingCardLanding.tsx

# $xsed 's#<p className="mb-5 mt-0 w-full text-sm">#\{/*<p className="mb-5 mt-0 w-full text-sm">#g' ${TARGET_FILE}
# $xsed 's#<ContinueLogo height={75} />#{/* <ContinueLogo height={75} /> */}#g' ${TARGET_FILE}
# $xsed '/Log in to Continue Hub/ { n; s#$#*/\}#; }'  ${TARGET_FILE}
# $xsed 's#Or, configure your own models#Configure your own models#g'  ${TARGET_FILE}

echo "########## custom logo ##########"
cp -pv ${baseDir}/../extensions/vscode/media/icon-custom.png ${baseDir}/../extensions/vscode/media/icon.png
cp -pv ${baseDir}/../extensions/vscode/media/sidebar-icon-custom.png ${baseDir}/../extensions/vscode/media/sidebar-icon.png


echo "########## custom plugin ########## "
# find ../web/ -type f -name "*.ts" -o -name "*.tsx" | xargs grep -E "[ '\"]Dify[ '\"]"| awk -F ':' '{print $1}' | xargs -I@ bash -c "${xsed} -i.bak 's#Dify#LLMAI#g' @"
$xsed 's#"name": "continue",#"name": "aicoder",#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"publisher": "Continue",#"publisher": "Roweb",#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#Continue Dev#Roweb Dev#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"homepage": "https://continue.dev"#"homepage": "https://roweb.cn"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#https://hub.continue.dev/#https://hub.roweb.cn/#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#https://github.com/continuedev/continue#https://github.com/blockai/aicoder#g' ${baseDir}/../extensions/vscode/package.json
# $xsed 's#"publisher":.*#"publisher": "roweb",#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"label": "Continue"#"label": "分布式编码助手"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"name": "Continue#"name": "AiCoder#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#          "title": "Continue",#          "title": "AiCoder",#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#      "title": "Continue",#      "title": "分布式编码助手",#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"displayName":.*#"displayName": "分布式编码助手",#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#  "description": "The leading open-source AI code agent",#  "description": "编码智能体，助效能提升",#g' ${baseDir}/../extensions/vscode/package.json
# $xsed 's#          "description":.*#          "description": "编码智能体，助效能提升"#g' ../extensions/vscode/package.json
# $xsed 's#"category": "Continue"#"category": "AiCoder"#g' ${baseDir}/../extensions/vscode/package.json
# $xsed 's#"group": "Continue"#"group": "AiCoder"#g' ${baseDir}/../extensions/vscode/package.json

# $xsed 's#continue#aicoder#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#aicoderdev/config-types":#continuedev/config-types":#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#aicoderdev/fetch":#continuedev/fetch":#g' ${baseDir}/../extensions/vscode/package.json


# $xsed 's#"title": "Continue",#"title": "分布式编码助手",#g' ../extensions/vscode/package.json
# $xsed 's#"title": "Continue Console",#"title": "编码助手控制台",#g' ../extensions/vscode/package.json
# $xsed 's#"Enable Continue#"Enable AiCoder#g' ../extensions/vscode/package.json
# $xsed 's#"Pause Continue#"Pause AiCoder#g' ../extensions/vscode/package.json
# $xsed 's#"name": "Continue#"name": "AiCoder#g' ../extensions/vscode/package.json

echo "########## spec code replace ########## "
# $xsed 's#EXTENSION_NAME = "continue"#EXTENSION_NAME = "aicoder"#g' ${baseDir}/../core/control-plane/env.ts
# $xsed 's#"Continue.continue"#"Roweb.aicoder"#g' ${baseDir}/../extensions/vscode/src/util/vscode.ts
$xsed 's#Continue#AICODER#g' ${baseDir}/../*.md

echo "########## spec code batch replace ########## "

find ${baseDir}/../ -type f -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.mdx" | grep -v node_modules | grep -v ".bak" | grep -v Start | xargs $xsed 's#https://hub.continue.dev/#https://hub.roweb.cn/#g'
find ${baseDir}/../ -type f -name "*.json" -o -name "*.xml" -o -name "*.ts" | grep -v node_modules | grep -v ".bak" | grep -v Start | grep -v run | xargs $xsed 's#"continue-#"aicoder-#g'
# find ${baseDir}/../ -type f -name "*.json" -o -name "*.xml" -o -name "*.ts" | grep -v node_modules | grep -v ".bak" |  grep -v Start | grep -v run | xargs $xsed 's#"continue\.#"aicoder.#g'
find ${baseDir}/../ -type f -name "*.md" -o -name "*.json" -o -name "*.mdx" -o -name "*.ts" -o -name "oneper" | grep -v node_modules |grep -v ".bak" |  grep -v Start | grep -v run | xargs $xsed 's#Continue.continue#Roweb.aicoder#g'
# find ${baseDir}/../ -type f -name "*.md" -o -name "*.json" -o -name "*.mdx"  -o -name "*.ts" | grep -v node_modules | grep -v ".bak" | grep -v Start | grep -v run | xargs $xsed 's#"aicoder.continue#"aicoder.aicoder#g'
find ${baseDir}/../ -type f -name "*.md" -o -name "*.mdx" | grep -v node_modules | grep -v ".bak" | grep -v Start | grep -v run  | xargs $xsed 's#Continue#AICODER#g'
# find ${baseDir}/../ -type f -name "*.md" -o -name "*.json" -o -name "*.mdx" -o -name "*.ts" | grep -v node_modules |grep -v ".bak" |  grep -v Start | grep -v run | xargs $xsed 's#"aicoder.aicoder#"roweb.aicoder#g'

# find ${baseDir}/../extensions -type f -name "*.md" -o -name "*.mdx" | grep -v node_modules | grep -v ".bak" | grep -v Start | grep -v run  | xargs $xsed 's#AICODER.continue#Continue.continue#g'
# find ../web -type f -name "*.ts" -o -name "*.tsx" -o -name "*.js" | grep -v node_modules | xargs $xsed "s#logo-monochrome-white.svg#logo-monochrome-white-llmapp.svg#g"
# find ../web -type f -name "*.ts" -o -name "*.tsx" | xargs grep -E "[ '>\"]Dify[ '<\"\$\`]" | grep -vE "default as Dify |Dify.json|embedded-chatbot/index.tsx"
# find ../web -type f -name "*.ts" -o -name "*.tsx" | xargs grep -E "[ '>\"]Dify[ '<\"\$\`]" | grep -vE "default as Dify |Dify.json|embedded-chatbot/index.tsx" | awk -F ':' '{print $1}' | xargs -I@ sh -c "sed -i.bak 's#Dify#LLMAI#g' '@'"
# find ../web -type f -name "*.ts" -o -name "*.tsx" | xargs grep -E "https://github.com/langgenius/dify" | grep -vE " default as Dify |Dify.json|embedded-chatbot/index.tsx" | awk -F ':' '{print $1}' | xargs -I@ sh -c "sed -i.bak 's#https://github.com/langgenius/dify#https://github.com/blockmap/llmai#g' '@'"

# custom api:
# $xsed "s#Dify OpenAPI#BlockAI OpenAPI#g" ../api/controllers/service_api/index.py


execEndTime=`date +%Y%m%d-%H:%M:%S`

echo "${execEndTime} custom replace finished ########## "

exit 0
