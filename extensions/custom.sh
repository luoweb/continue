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
# $xsed 's#"name": "continue",#"name": "aicoder",#g' ${baseDir}/../extensions/vscode/package.json
# $xsed 's#"publisher": "Continue",#"publisher": "Roweb",#g' ${baseDir}/../extensions/vscode/package.json

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

# 替换URL
find ${baseDir}/../ -type f -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.mdx" -o -name "*.json" -o -name "*.md" | grep -v node_modules | grep -v ".bak" | grep -v Start | xargs $xsed 's#https://hub.continue.dev/#https://hub.roweb.cn/#g'
find ${baseDir}/../ -type f -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.mdx" -o -name "*.json" -o -name "*.md" | grep -v node_modules | grep -v ".bak" | grep -v Start | xargs $xsed 's#https://continue.dev/#https://roweb.cn/#g'
find ${baseDir}/../ -type f -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.mdx" -o -name "*.json" -o -name "*.md" | grep -v node_modules | grep -v ".bak" | grep -v Start | xargs $xsed 's#https://github.com/continuedev/continue#https://github.com/blockai/aicoder#g'

# 替换配置项
find ${baseDir}/../ -type f -name "*.json" -o -name "*.xml" -o -name "*.ts" | grep -v node_modules | grep -v ".bak" | grep -v Start | grep -v run | xargs $xsed 's#"continue-#"aicoder-#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#"name": "continue"#"name": "aicoder"#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#"publisher": "Continue"#"publisher": "Roweb"#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#"displayName": "Continue#"displayName": "分布式编码助手#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#continueGUIView#aicoderGUIView#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#.continuerc.json#.aicoderc.json#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#"category": "Continue"#"category": "分布式编码助手"#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#"group": "Continue"#"group": "分布式编码助手"#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#Continue collects#AICODER collects#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#the Continue keyboard#the AICODER keyboard#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed "s#Continue's tab#AICODER's tab#g"
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed "s#Continue's next#AICODER's next#g"
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed "s#Continue's codebase#AICODER's codebase#g"

# 替换文件和路径
find ${baseDir}/../ -type f -name "*.ts" -o -name "*.tsx" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#.continueignore#.aicoderignore#g'
find ${baseDir}/../ -type f -name "*.ts" -o -name "*.tsx" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#.continuerc.json#.aicoderc.json#g'

# 替换配置键
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#continue\.#aicoder.#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#focusContinueInput#focusAicoderInput#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#focusContinueInputWithoutClear#focusAicoderInputWithoutClear#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#Continue: Force Autocomplete#AICODER: Force Autocomplete#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#Focus Continue Chat#Focus AICODER Chat#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#Continue: Toggle Next Edit#AICODER: Toggle Next Edit#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#Continue: Force Next Edit#AICODER: Force Next Edit#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#Continue: Accept Jump Suggestion#AICODER: Accept Jump Suggestion#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#Continue: Reject Jump Suggestion#AICODER: Reject Jump Suggestion#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#continueSubMenu#aicoderSubMenu#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#0_acontinue#0_aaicoder#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#continueConsoleView#aicoderConsoleView#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#"id": "continue"#"id": "aicoder"#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#"id": "continueConsole"#"id": "aicoderConsole"#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#"title": "Continue Console"#"title": "AICODER Console"#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#"continue": \[#"aicoder": \[#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#"continueConsole": \[#"aicoderConsole": \[#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#\*\*/\.continue\*/config\.json#\*\*/\.aicoder\*/config\.json#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#./continue_rc_schema\.json#./aicoder_rc_schema\.json#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#CONTINUE_GLOBAL_DIR#AICODER_GLOBAL_DIR#g'
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#SerializedContinueConfig#SerializedAicoderConfig#g'

# 替换配置文件中的描述文本
find ${baseDir}/../ -type f -name "config_schema.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#Continue should not use#AICODER should not use#g'
find ${baseDir}/../ -type f -name "config_schema.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#you can start asking questions through Continue#you can start asking questions through AICODER#g'
find ${baseDir}/../ -type f -name "config_schema.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#you can begin using Continue#you can begin using AICODER#g'
find ${baseDir}/../ -type f -name "config_schema.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#you can start using Continue#you can start using AICODER#g'
find ${baseDir}/../ -type f -name "config_schema.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#used in Continue#used in AICODER#g'
find ${baseDir}/../ -type f -name "config_schema.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#Continue will generate#AICODER will generate#g'
find ${baseDir}/../ -type f -name "config_schema.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed "s#Continue doesn't let#AICODER doesn't let#g"
find ${baseDir}/../ -type f -name "config_schema.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#Continue will not index#AICODER will not index#g'
find ${baseDir}/../ -type f -name "config_schema.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#Continue will not make#AICODER will not make#g'

# 替换URL参数
find ${baseDir}/../ -type f -name "config_schema.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#utm_source=github_continuedev#utm_source=github_roweb#g'
find ${baseDir}/../ -type f -name "config_schema.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#utm_source=continue#utm_source=aicoder#g'

# 替换测试路径
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#test-continue#test-aicoder#g'

# 替换UI文本
find ${baseDir}/../ -type f -name "*.tsx" -o -name "*.ts" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#Continue Dev#Roweb Dev#g'
find ${baseDir}/../ -type f -name "*.tsx" -o -name "*.ts" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#Continue Hub#Roweb Hub#g'

# 替换代码中的变量和常量
find ${baseDir}/../ -type f -name "*.ts" -o -name "*.tsx" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#continueEnabled#aicoderEnabled#g'
find ${baseDir}/../ -type f -name "*.ts" -o -name "*.tsx" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#continueTestEnvironment#aicoderTestEnvironment#g'
find ${baseDir}/../ -type f -name "*.ts" -o -name "*.tsx" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#continueGUIView#aicoderGUIView#g'
find ${baseDir}/../ -type f -name "*.ts" -o -name "*.tsx" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#focusContinueInput#focusAicoderInput#g'
find ${baseDir}/../ -type f -name "*.ts" -o -name "*.tsx" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#focusContinueInputWithoutClear#focusAicoderInputWithoutClear#g'
find ${baseDir}/../ -type f -name "*.ts" -o -name "*.tsx" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#continueConsoleView#aicoderConsoleView#g'
find ${baseDir}/../ -type f -name "*.ts" -o -name "*.tsx" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#SerializedContinueConfig#SerializedAicoderConfig#g'
find ${baseDir}/../ -type f -name "*.ts" -o -name "*.tsx" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#CONTINUE_GLOBAL_DIR#AICODER_GLOBAL_DIR#g'

# 替换markdown文件
find ${baseDir}/../ -type f -name "*.md" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#Continue#AICODER#g'
find ${baseDir}/../ -type f -name "*.md" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#continue#aicoder#g'

# 替换包名引用
find ${baseDir}/../ -type f -name "*.json" | grep -v node_modules | grep -v ".bak" | xargs $xsed 's#@continuedev/#@roweb/#g'

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
