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

echo "readme custom"
cp ${baseDir}/../extensions/vscode/README.zh.md ${baseDir}/../extensions/vscode/README.md

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
find ../ -type f -name "*.ts" -o -name "*.tsx" -o -name "*.json" -o -name "*.mdx" | xargs -I@ bash -c "${xsed} -i.bak 's#Continue.continue#Roweb.aicoder#g' @"
$xsed 's#"name": "continue",#"name": "aicoder",#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"publisher": "Continue",#"publisher": "Roweb",#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#Continue Dev#Roweb Dev#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"homepage": "https://continue.dev"#"homepage": "https://roweb.cn"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#https://hub.continue.dev/#https://hub.roweb.cn/#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#https://github.com/continuedev/continue#https://github.com/blockai/aicoder#g' ${baseDir}/../extensions/vscode/package.json
# $xsed 's#"publisher":.*#"publisher": "roweb",#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"label": "Continue"#"label": "分布式编码助手"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"name": "Continue#"name": "分布式编码助手#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#Continue Console#分布式编码助手#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#          "title": "Continue",#          "title": "分布式编码助手",#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#      "title": "Continue",#      "title": "分布式编码助手",#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"displayName":.*#"displayName": "分布式编码助手",#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#  "description": "The leading open-source AI code agent",#  "description": "研发智能体，助效能提升",#g' ${baseDir}/../extensions/vscode/package.json
# $xsed 's#          "description":.*#          "description": "编码智能体，助效能提升"#g' ../extensions/vscode/package.json
# $xsed 's#"category": "Continue"#"category": "AiCoder"#g' ${baseDir}/../extensions/vscode/package.json
# $xsed 's#"group": "Continue"#"group": "AiCoder"#g' ${baseDir}/../extensions/vscode/package.json

# $xsed 's#continue#aicoder#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#aicoderdev/config-types":#continuedev/config-types":#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#aicoderdev/fetch":#continuedev/fetch":#g' ${baseDir}/../extensions/vscode/package.json

echo "########## custom gui ########## "
$xsed 's#to toggle config#切换配置#g' ${baseDir}/../gui/src/components/AssistantAndOrgListbox/index.tsx
$xsed 's#<ArrowRightStartOnRectangleIcon className="ml-1.5 mr-2 h-3.5 w-3.5 flex-shrink-0 rotate-180" />##g' ${baseDir}/../gui/src/components/AssistantAndOrgListbox/index.tsx
$xsed 's#<span className="text-2xs">Log in</span>##g' ${baseDir}/../gui/src/components/AssistantAndOrgListbox/index.tsx
$xsed 's#<span className="text-2xs">Reload</span>#<span className="text-2xs">重新加载</span>#g' ${baseDir}/../gui/src/components/AssistantAndOrgListbox/index.tsx

$xsed 's#View errors#查看错误#g' ${baseDir}/../gui/src/components/AssistantAndOrgListbox/AssistantOption.tsx
$xsed 's#"Ask anything, .* to add context"#"询问任何事情，"@" 添加上下文"#g' ${baseDir}/../gui/src/components/mainInput/TipTapEditor/utils/editorConfig.ts

$xsed 's#content="Select Config"#content="选择配置"#g' ${baseDir}/../gui/src/components/mainInput/Lump/LumpToolbar/BlockSettingsTopToolbar.tsx
$xsed 's#View configuration errors#查看配置错误#g' ${baseDir}/../gui/src/components/mainInput/Lump/LumpToolbar/BlockSettingsTopToolbar.tsx
$xsed 's#Configure rules#配置规则#g' ${baseDir}/../gui/src/components/mainInput/Lump/LumpToolbar/BlockSettingsTopToolbar.tsx
$xsed 's#Configure tools#配置工具#g' ${baseDir}/../gui/src/components/mainInput/Lump/LumpToolbar/BlockSettingsTopToolbar.tsx
$xsed 's#Configure models#配置模型#g' ${baseDir}/../gui/src/components/mainInput/Lump/LumpToolbar/BlockSettingsTopToolbar.tsx

$xsed 's#<span className="">Chat</span>#<span className="">对话</span>#g' ${baseDir}/../gui/src/components/ModeSelect/ModeSelect.tsx
$xsed 's#All tools disabled#所有工具不可用#g' ${baseDir}/../gui/src/components/ModeSelect/ModeSelect.tsx
$xsed 's#<span className="">Plan</span>#<span className="">规划</span>#g' ${baseDir}/../gui/src/components/ModeSelect/ModeSelect.tsx
$xsed 's#Read-only/MCP tools available#只读模式/MCP工具可用#g' ${baseDir}/../gui/src/components/ModeSelect/ModeSelect.tsx
$xsed 's#<span className="">Agent</span>#<span className="">智能体</span>#g' ${baseDir}/../gui/src/components/ModeSelect/ModeSelect.tsx
$xsed 's#All tools available#所有工具可用#g' ${baseDir}/../gui/src/components/ModeSelect/ModeSelect.tsx
$xsed 's#. for next mode#. 选择模式#g' ${baseDir}/../gui/src/components/ModeSelect/ModeSelect.tsx

$xsed 's#content="Select Mode"#content="选择模式"#g' ${baseDir}/../gui/src/components/mainInput/InputToolbar.tsx
$xsed 's#content="Select Model"#content="选择模型"#g' ${baseDir}/../gui/src/components/mainInput/InputToolbar.tsx
$xsed 's#content="Attach Image"#content="添加图片"#g' ${baseDir}/../gui/src/components/mainInput/InputToolbar.tsx
$xsed 's#content="Attach Context"#content="添加上下文"#g' ${baseDir}/../gui/src/components/mainInput/InputToolbar.tsx
$xsed 's#Disable model reasoning#关闭推理模式#g' ${baseDir}/../gui/src/components/mainInput/InputToolbar.tsx
$xsed 's#Enable model reasoning#开启推理模式#g' ${baseDir}/../gui/src/components/mainInput/InputToolbar.tsx
$xsed 's#content="Send (⏎)"#content="发送 (⏎)"#g' ${baseDir}/../gui/src/components/mainInput/InputToolbar.tsx

$xsed 's#to toggle model#切换模型#g' ${baseDir}/../gui/src/components/modelSelection/ModelSelect.tsx
$xsed 's#Add Chat model#添加聊天模型#g' ${baseDir}/../gui/src/components/modelSelection/ModelSelect.tsx
$xsed 's#<span className="text-description text-xs font-medium">Models</span>#<span className="text-description text-xs font-medium">模型</span>#g' ${baseDir}/../gui/src/components/modelSelection/ModelSelect.tsx
$xsed 's#Last Session#最近会话#g' ${baseDir}/../gui/src/pages/gui/Chat.tsx

$xsed 's#<ConfigHeader title="User Settings" />#<ConfigHeader title="用户设置" />#g' ${baseDir}/gui/src/pages/config/sections/UserSettingsSection.tsx

# $xsed 's#"title": "Continue",#"title": "分布式编码助手",#g' ../extensions/vscode/package.json
# $xsed 's#"title": "Continue Console",#"title": "编码助手控制台",#g' ../extensions/vscode/package.json
# $xsed 's#"Enable Continue#"Enable AiCoder#g' ../extensions/vscode/package.json
# $xsed 's#"Pause Continue#"Pause AiCoder#g' ../extensions/vscode/package.json
# $xsed 's#"name": "Continue#"name": "AiCoder#g' ../extensions/vscode/package.json
echo "########## spec code replace ########## "
# $xsed 's#EXTENSION_NAME = "continue"#EXTENSION_NAME = "aicoder"#g' ${baseDir}/../core/control-plane/env.ts
# $xsed 's#"Continue.continue"#"Roweb.aicoder"#g' ${baseDir}/../extensions/vscode/src/util/vscode.ts
$xsed 's#Continue#分布式编码助手#g' ${baseDir}/../*.md

echo "########## spec code batch replace ########## "

find ${baseDir}/../ -type f -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.mdx" | grep -v node_modules | grep -v ".bak" | grep -v Start | xargs $xsed 's#https://hub.continue.dev/#https://hub.roweb.cn/#g'
find ${baseDir}/../ -type f -name "*.json" -o -name "*.xml" -o -name "*.ts" | grep -v node_modules | grep -v ".bak" | grep -v Start | grep -v run | xargs $xsed 's#"continue-#"aicoder-#g'
# find ${baseDir}/../ -type f -name "*.json" -o -name "*.xml" -o -name "*.ts" | grep -v node_modules | grep -v ".bak" |  grep -v Start | grep -v run | xargs $xsed 's#"continue\.#"aicoder.#g'
# find ${baseDir}/../ -type f -name "*.md" -o -name "*.json" -o -name "*.mdx" -o -name "*.ts" -o -name "oneper" | grep -v node_modules |grep -v ".bak" |  grep -v Start | grep -v run | xargs $xsed 's#Continue.continue#Roweb.aicoder#g'
# find ${baseDir}/../ -type f -name "*.md" -o -name "*.json" -o -name "*.mdx"  -o -name "*.ts" | grep -v node_modules | grep -v ".bak" | grep -v Start | grep -v run | xargs $xsed 's#"aicoder.continue#"aicoder.aicoder#g'
# find ${baseDir}/../ -type f -name "*.md" -o -name "*.mdx" | grep -v node_modules | grep -v ".bak" | grep -v Start | grep -v run  | xargs $xsed 's#Continue#AICODER#g'
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
