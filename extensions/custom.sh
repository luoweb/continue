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

# Translate configuration descriptions
$xsed 's#"markdownDescription": "Continue collects anonymous usage data, cleaned of PII, to help us improve the product for our users. Read more  at \[continue.dev › Telemetry\]\(https://docs.continue.dev/telemetry\)."#"markdownDescription": "Continue 收集匿名使用数据（已清除个人身份信息），以帮助我们为用户改进产品。阅读更多：[continue.dev › 遥测](https://docs.continue.dev/telemetry)。"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"markdownDeprecationMessage": "This setting is deprecated and will be removed in a later version. Please use the _Telemetry > Allow Anonymous Telemetry_ setting in the extension'"'"'s User Settings page.",#"markdownDeprecationMessage": "此设置已弃用，将在后续版本中移除。请使用扩展用户设置页面中的 _遥测 > 允许匿名遥测_ 设置。"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"deprecationMessage": "Please use the _Telemetry > Allow Anonymous Telemetry_ setting in the extension'"'"'s User Settings page.",#"deprecationMessage": "请使用扩展用户设置页面中的 _遥测 > 允许匿名遥测_ 设置。"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"description": "Show inline suggestion to use the Continue keyboard shortcuts (e.g. \"Cmd/Ctrl L to select code, Cmd/Ctrl I to edit\")."#"description": "显示使用 Continue 键盘快捷键的内联建议（例如 \"Cmd/Ctrl L 选择代码，Cmd/Ctrl I 编辑\"）。"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"description": "Disable the quick fix feature."#"description": "禁用快速修复功能。"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"markdownDescription": "Enable the experimental Quick Actions feature. Read our walkthrough to learn about configuration and how to share feedback: \[continue.dev › Walkthrough: Quick Actions (experimental)\]\(https://docs.continue.dev/customize/deep-dives/vscode-actions#quick-actions\)"#"markdownDescription": "启用实验性快速操作功能。阅读我们的演练指南以了解配置和如何分享反馈：[continue.dev › 演练：快速操作（实验性）](https://docs.continue.dev/customize/deep-dives/vscode-actions#quick-actions)"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"markdownDescription": "Enable Continue'"'"'s tab autocomplete feature. Read our walkthrough to learn about configuration and how to share feedback: \[continue.dev › Walkthrough: Tab Autocomplete (beta)\]\(https://docs.continue.dev/features/tab-autocomplete\)"#"markdownDescription": "启用 Continue 的 Tab 自动补全功能。阅读我们的演练指南以了解配置和如何分享反馈：[continue.dev › 演练：Tab 自动补全（测试版）](https://docs.continue.dev/features/tab-autocomplete)"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"markdownDescription": "Enable Continue'"'"'s next edit feature. Read our docs to learn about configuration and how to share feedback: \[continue.dev › Features › Autocomplete › Next Edit (experimental)\]\(https://docs.continue.dev/features/autocomplete/next-edit\)"#"markdownDescription": "启用 Continue 的下一个编辑功能。阅读我们的文档以了解配置和如何分享反馈：[continue.dev › 功能 › 自动补全 › 下一个编辑（实验性）](https://docs.continue.dev/features/autocomplete/next-edit)"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"markdownDescription": "Pause Continue'"'"'s tab autocomplete feature when your battery is low."#"markdownDescription": "当电池电量低时暂停 Continue 的 Tab 自动补全功能。"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"markdownDescription": "Pause Continue'"'"'s codebase index on start."#"markdownDescription": "启动时暂停 Continue 的代码库索引。"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"markdownDescription": "Enable a console to log and explore model inputs and outputs. It can be found in the bottom panel."#"markdownDescription": "启用控制台以记录和探索模型输入和输出。可以在底部面板中找到。"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"markdownDescription": "If your team is set up to use shared configuration, enter the server URL here and your user token below to enable automatic syncing."#"markdownDescription": "如果您的团队设置了使用共享配置，请在此处输入服务器 URL 和下方的用户令牌以启用自动同步。"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"markdownDescription": "If your team is set up to use shared configuration, enter your user token here and your server URL above to enable automatic syncing."#"markdownDescription": "如果您的团队设置了使用共享配置，请在此处输入用户令牌和上方的服务器 URL 以启用自动同步。"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"description": "The period of time in minutes between automatic syncs."#"description": "自动同步之间的时间间隔（分钟）。"#g' ${baseDir}/../extensions/vscode/package.json

# Translate commands titles
$xsed 's#"title": "Apply code from chat"#"title": "应用聊天中的代码"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Accept Diff"#"title": "接受差异"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Reject Diff"#"title": "拒绝差异"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Accept Vertical Diff Block"#"title": "接受垂直差异块"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Reject Vertical Diff Block"#"title": "拒绝垂直差异块"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Add to Edit"#"title": "添加到编辑"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Add Highlighted Code to Context and Clear Chat"#"title": "将高亮代码添加到上下文并清空聊天"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Add to Chat"#"title": "添加到聊天"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Debug Terminal"#"title": "调试终端"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Exit Edit Mode"#"title": "退出编辑模式"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Open Settings"#"title": "打开设置"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Toggle Autocomplete Enabled"#"title": "切换自动补全"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Continue: Force Autocomplete"#"title": "Continue: 强制自动补全"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Select Files as Context"#"title": "选择文件作为上下文"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "New Session"#"title": "新建会话"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Share Current Chat Session as Markdown"#"title": "分享当前聊天会话为 Markdown"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "View History"#"title": "查看历史"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "View Logs"#"title": "查看日志"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Clear Console"#"title": "清空控制台"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Navigate to a path"#"title": "导航到路径"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Write Comments for this Code"#"title": "为此代码编写注释"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Write a Docstring for this Code"#"title": "为此代码编写文档字符串"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Fix this Code"#"title": "修复此代码"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Optimize this Code"#"title": "优化此代码"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Fix Grammar / Spelling"#"title": "修复语法/拼写"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Codebase Force Re-Index"#"title": "代码库强制重新索引"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Rebuild codebase index"#"title": "重建代码库索引"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Docs Index"#"title": "文档索引"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Docs Force Re-Index"#"title": "文档强制重新索引"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Focus Continue Chat"#"title": "聚焦 Continue 聊天"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Enter Enterprise License Key"#"title": "输入企业许可证密钥"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Continue: Toggle Next Edit"#"title": "Continue: 切换下一个编辑"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Hide Next Edit Suggestion"#"title": "隐藏下一个编辑建议"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Accept Next Edit Suggestion"#"title": "接受下一个编辑建议"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Continue: Force Next Edit"#"title": "Continue: 强制下一个编辑"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Continue: Accept Jump Suggestion"#"title": "Continue: 接受跳转建议"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Continue: Reject Jump Suggestion"#"title": "Continue: 拒绝跳转建议"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Generate Rule"#"title": "生成规则"#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#"title": "Open in new window"#"title": "在新窗口中打开"#g' ${baseDir}/../extensions/vscode/package.json

# Translate keybindings titles
$xsed 's#"title": "Edit code with natural language"#"title": "使用自然语言编辑代码"#g' ${baseDir}/../extensions/vscode/package.json

# $xsed 's#"category": "Continue"#"category": "AiCoder"#g' ${baseDir}/../extensions/vscode/package.json
# $xsed 's#"group": "Continue"#"group": "AiCoder"#g' ${baseDir}/../extensions/vscode/package.json

# $xsed 's#continue#aicoder#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#aicoderdev/config-types":#continuedev/config-types":#g' ${baseDir}/../extensions/vscode/package.json
$xsed 's#aicoderdev/fetch":#continuedev/fetch":#g' ${baseDir}/../extensions/vscode/package.json

echo "########## custom gui ########## "

$xsed 's#return <OnboardingProvidersTab />;#return <OnboardingLocalTab />;#g' ${baseDir}/../gui/src/components/OnboardingCard/OnboardingCard.tsx
$xsed 's#return <OnboardingModelsAddOnTab />;#return <OnboardingLocalTab />;#g' ${baseDir}/../gui/src/components/OnboardingCard/OnboardingCard.tsx


$xsed 's#to toggle config#切换配置#g' ${baseDir}/../gui/src/components/AssistantAndOrgListbox/index.tsx
# 简化 session 按钮的文本
$xsed 's#<span className="text-2xs">Log out</span>#<span className="text-2xs"></span>#g' ${baseDir}/../gui/src/components/AssistantAndOrgListbox/index.tsx
$xsed 's#<span className="text-2xs">Log in</span>#<span className="text-2xs"></span>#g' ${baseDir}/../gui/src/components/AssistantAndOrgListbox/index.tsx
$xsed 's#<ArrowRightStartOnRectangleIcon className="ml-1.5 mr-2 h-3.5 w-3.5 flex-shrink-0" />##g' ${baseDir}/../gui/src/components/AssistantAndOrgListbox/index.tsx
$xsed 's#<ArrowRightStartOnRectangleIcon className="ml-1.5 mr-2 h-3.5 w-3.5 flex-shrink-0 rotate-180" />##g' ${baseDir}/../gui/src/components/AssistantAndOrgListbox/index.tsx
$xsed 's#<span className="text-2xs">Reload</span>#<span className="text-2xs">重新加载</span>#g' ${baseDir}/../gui/src/components/AssistantAndOrgListbox/index.tsx

$xsed 's#View errors#查看错误#g' ${baseDir}/../gui/src/components/AssistantAndOrgListbox/AssistantOption.tsx
$xsed 's#"Ask anything, #"询问任何事情，#g' ${baseDir}/../gui/src/components/mainInput/TipTapEditor/utils/editorConfig.ts
$xsed 's# to add context"# 添加上下文"#g' ${baseDir}/../gui/src/components/mainInput/TipTapEditor/utils/editorConfig.ts

$xsed 's#content="Select Config"#content="选择配置"#g' ${baseDir}/../gui/src/components/mainInput/Lump/LumpToolbar/BlockSettingsTopToolbar.tsx
$xsed 's#View configuration errors#查看配置错误#g' ${baseDir}/../gui/src/components/mainInput/Lump/LumpToolbar/BlockSettingsTopToolbar.tsx
$xsed 's#Configure rules#配置规则#g' ${baseDir}/../gui/src/components/mainInput/Lump/LumpToolbar/BlockSettingsTopToolbar.tsx
$xsed 's#Configure tools#配置工具#g' ${baseDir}/../gui/src/components/mainInput/Lump/LumpToolbar/BlockSettingsTopToolbar.tsx
$xsed 's#Configure models#配置模型#g' ${baseDir}/../gui/src/components/mainInput/Lump/LumpToolbar/BlockSettingsTopToolbar.tsx
$xsed 's#: "Local Config",#: "本地配置",#g' ${baseDir}/../core/config/profile/LocalProfileLoader.ts
$xsed 's#: "Local Config",#: "本地配置",#g' ${baseDir}/../core/config/default.ts
$xsed 's#: "Local Config",#: "本地配置",#g' ${baseDir}/../core/config/yaml/default.ts
$xsed 's# Configs# 配置#g' ${baseDir}/../gui/src/components/AssistantAndOrgListbox/index.tsx

$xsed 's#? "Chat"#? "对话"#g' ${baseDir}/../gui/src/components/ModeSelect/ModeSelect.tsx
$xsed 's#: "Plan"#: "规划"#g' ${baseDir}/../gui/src/components/ModeSelect/ModeSelect.tsx
$xsed 's#? "Agent"#? "智能体"#g' ${baseDir}/../gui/src/components/ModeSelect/ModeSelect.tsx
$xsed 's#<span className="">Chat</span>#<span className="">对话</span>#g' ${baseDir}/../gui/src/components/ModeSelect/ModeSelect.tsx
$xsed 's#All tools disabled#所有工具不可用#g' ${baseDir}/../gui/src/components/ModeSelect/ModeSelect.tsx
$xsed 's#<span className="">Plan</span>#<span className="">规划</span>#g' ${baseDir}/../gui/src/components/ModeSelect/ModeSelect.tsx
$xsed 's#Read-only/MCP tools available#只读模式/MCP工具可用#g' ${baseDir}/../gui/src/components/ModeSelect/ModeSelect.tsx
$xsed 's#<span className="">Agent</span>#<span className="">智能体</span>#g' ${baseDir}/../gui/src/components/ModeSelect/ModeSelect.tsx
$xsed 's#All tools available#所有工具可用#g' ${baseDir}/../gui/src/components/ModeSelect/ModeSelect.tsx
$xsed 's#. for next mode#. 选择模式#g' ${baseDir}/../gui/src/components/ModeSelect/ModeSelect.tsx
$xsed 's#<span className="">Background</span>#<span className="">后台模式</span>#g' ${baseDir}/../gui/src/components/ModeSelect/ModeSelect.tsx
$xsed 's#Background mode cannot be used with local agents.#后台模式不能用于本地智能体#g' ${baseDir}/../gui/src/components/ModeSelect/ModeSelect.tsx

$xsed 's#content="Select Mode"#content="选择模式"#g' ${baseDir}/../gui/src/components/mainInput/InputToolbar.tsx
$xsed 's#content="Select Model"#content="选择模型"#g' ${baseDir}/../gui/src/components/mainInput/InputToolbar.tsx
$xsed 's#content="Attach Image"#content="添加图片"#g' ${baseDir}/../gui/src/components/mainInput/InputToolbar.tsx
$xsed 's#content="Attach Context"#content="添加上下文"#g' ${baseDir}/../gui/src/components/mainInput/InputToolbar.tsx
$xsed 's#Disable model reasoning#关闭推理模式#g' ${baseDir}/../gui/src/components/mainInput/InputToolbar.tsx
$xsed 's#Enable model reasoning#开启推理模式#g' ${baseDir}/../gui/src/components/mainInput/InputToolbar.tsx
$xsed 's#content="Send (⏎)"#content="发送 (⏎)"#g' ${baseDir}/../gui/src/components/mainInput/InputToolbar.tsx
$xsed 's#?? "Enter""#?? "发送"#g' ${baseDir}/../gui/src/components/mainInput/InputToolbar.tsx
$xsed 's#"Send With Active File"#"发送当前文件"#g' ${baseDir}/../gui/src/components/mainInput/InputToolbar.tsx
$xsed 's#"Send Without Active File"#"不发送当前文件"#g' ${baseDir}/../gui/src/components/mainInput/InputToolbar.tsx
$xsed 's#"Active file"#"当前文件"#g' ${baseDir}/../gui/src/components/mainInput/InputToolbar.tsx


$xsed 's#to toggle model#切换模型#g' ${baseDir}/../gui/src/components/modelSelection/ModelSelect.tsx
$xsed 's#Add Chat model#添加聊天模型#g' ${baseDir}/../gui/src/components/modelSelection/ModelSelect.tsx
$xsed 's#<span className="text-description text-xs font-medium">Models</span>#<span className="text-description text-xs font-medium">模型</span>#g' ${baseDir}/../gui/src/components/modelSelection/ModelSelect.tsx
$xsed 's#Last Session#最近会话#g' ${baseDir}/../gui/src/pages/gui/Chat.tsx

# Translate ConfigTabs
$xsed 's#label: "Back",#label: "返回",#g' ${baseDir}/../gui/src/pages/config/configTabs.tsx
$xsed 's#label: "Models",#label: "模型",#g' ${baseDir}/../gui/src/pages/config/configTabs.tsx
$xsed 's#label: "Rules",#label: "规则",#g' ${baseDir}/../gui/src/pages/config/configTabs.tsx
$xsed 's#label: "Tools",#label: "工具",#g' ${baseDir}/../gui/src/pages/config/configTabs.tsx
$xsed 's#label: "Configs",#label: "配置",#g' ${baseDir}/../gui/src/pages/config/configTabs.tsx
$xsed '/id: "organizations\"/,/^[[:space:]]*},[[:space:]]*$/d' ${baseDir}/../gui/src/pages/config/configTabs.tsx
$xsed -e ':a' -e 'N' -e '$!ba' -e 's/},\n[[:space:]]*{\n[[:space:]]*\],/},\n    ],/g' ${baseDir}/../gui/src/pages/config/configTabs.tsx
# $xsed 's#label: "Organizations",#label: "组织",#g' ${baseDir}/../gui/src/pages/config/configTabs.tsx
# awk '
# /id: "organizations"/ {
#     # 删除前一行（即对象开始的 {）
#     if (NR > 1) {
#         lines[NR-1] = ""
#     }
#     skip = 1
#     next
# }
# skip {
#     if (/^[[:space:]]*},[[:space:]]*$/) {
#         skip = 0
#     }
#     next
# }
# { lines[NR] = $0 }
# END {
#     for (i=1; i<=NR; i++) {
#         if (lines[i] != "") {
#             print lines[i]
#         }
#     }
# }
# ' /Users/block/code/continue/gui/src/pages/config/configTabs.tsx > /tmp/configTabs.tmp && mv /tmp/configTabs.tmp /Users/block/code/continue/gui/src/pages/config/configTabs.tsx

$xsed 's#label: "Indexing",#label: "索引",#g' ${baseDir}/../gui/src/pages/config/configTabs.tsx
$xsed 's#label: "Settings",#label: "设置",#g' ${baseDir}/../gui/src/pages/config/configTabs.tsx
$xsed 's#label: "Help",#label: "帮助",#g' ${baseDir}/../gui/src/pages/config/configTabs.tsx
$xsed 's#label: "Settings",#label: "设置",#g' ${baseDir}/../gui/src/pages/config/configTabs.tsx
# $xsed '/if (!session) {/,/^  }/d' ${baseDir}/../gui/src/pages/config/features/account/AccountDropdown.tsx
$xsed sed -i '' '/const ideMessenger = useContext(IdeMessengerContext);/a\
  // Force hide all elements\
  return null;' gui/src/pages/config/features/account/AccountDropdown.tsx
# Translate 用户设置

$xsed 's#User Settings#用户设置#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#title="Models"#title="模型"#g' ${baseDir}/../gui/src/pages/config/sections/ModelsSection.tsx
$xsed 's#addButtonTooltip="Add model"#addButtonTooltip="添加模型"#g' ${baseDir}/../gui/src/pages/config/sections/ModelsSection.tsx
$xsed 's#displayName="Chat"#displayName="对话"#g' ${baseDir}/../gui/src/pages/config/sections/ModelsSection.tsx
$xsed 's#Used in Chat, Plan, Agent mode#在对话、规划、智能体模式下使用#g' ${baseDir}/../gui/src/pages/config/sections/ModelsSection.tsx
$xsed 's#Learn more#更多#g' ${baseDir}/../gui/src/pages/config/sections/ModelsSection.tsx
$xsed 's#displayName="Autocomplete"#displayName="自动补全"#g' ${baseDir}/../gui/src/pages/config/sections/ModelsSection.tsx
$xsed 's#Used in inline code completions as you type#在你输入时，用于行内代码自动补全#g' ${baseDir}/../gui/src/pages/config/sections/ModelsSection.tsx

$xsed 's#displayName="Edit"#displayName="编辑"#g' ${baseDir}/../gui/src/pages/config/sections/ModelsSection.tsx
$xsed 's#displayName="Apply"#displayName="应用"#g' ${baseDir}/../gui/src/pages/config/sections/ModelsSection.tsx
$xsed 's#displayName="Embed"#displayName="嵌入"#g' ${baseDir}/../gui/src/pages/config/sections/ModelsSection.tsx
$xsed 's#displayName="Rerank"#displayName="重排序"#g' ${baseDir}/../gui/src/pages/config/sections/ModelsSection.tsx
$xsed 's#Used to transform a selected section of code#用于转换选定的代码段#g' ${baseDir}/../gui/src/pages/config/sections/ModelsSection.tsx
$xsed 's#Additional model roles#附加模型角色#g' ${baseDir}/../gui/src/pages/config/sections/ModelsSection.tsx
$xsed 's#Apply, Embed, Rerank#应用、嵌入、重新排序#g' ${baseDir}/../gui/src/pages/config/sections/ModelsSection.tsx
$xsed 's#Used to apply generated codeblocks to files#用于将生成的代码块应用到文件#g' ${baseDir}/../gui/src/pages/config/sections/ModelsSection.tsx
$xsed 's#Used to generate and query embeddings for the @codebase and @docs context providers#用于为@codebase和@docs上下文提供程序生成和查询嵌入#g' ${baseDir}/../gui/src/pages/config/sections/ModelsSection.tsx
$xsed 's#Used for reranking results from the @codebase and @docs context providers#用于重新排序来自@codebase和@docs上下文提供程序的结果#g' ${baseDir}/../gui/src/pages/config/sections/ModelsSection.tsx

$xsed 's#title="User Settings"#title="用户设置"#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#title="Chat"#title="对话"#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#title="Show Session Tabs"#title="显示会话标签"#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#Displays tabs above the chat as an alternative way to organize and access your sessions.#在对话上方显示标签，作为组织和访问会话的替代方式。#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#title="Wrap Codeblocks"#title="换行代码块"#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#Wraps long lines in code blocks instead of showing horizontal scroll.#在代码块中换行长行，而不是显示水平滚动。#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#title="Show Chat Scrollbar"#title="显示对话滚动条"#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#Enables a scrollbar in the chat window.#在对话窗口中启用滚动条。#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#title="Text-to-Speech Output"#title="文本到语音输出"#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#Reads LLM responses aloud with TTS.#使用 TTS 大声朗读 LLM 响应。#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#title="Enable Session Titles"#title="启用会话标题"#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#Generates summary titles for each chat session after the first message, using the current Chat model.#在第一条消息后为每个聊天会话生成摘要标题，使用当前对话模型。#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#title="Format Markdown"#title="格式化 Markdown"#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#If off, shows responses as raw text.#如果关闭，显示响应为原始文本。#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#title="Telemetry"#title="遥测"#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#title="Allow Anonymous Telemetry"#title="允许匿名遥测"#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#Allows Continue to send anonymous telemetry.#允许 Continue 发送匿名遥测。#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#title="Appearance"#title="外观"#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#title="Font Size"#title="字体大小"#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#Specifies base font size for UI elements.#指定 UI 元素的基准字体大小。#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#title="Autocomplete"#title="自动补全"#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#title="Multiline Autocompletions"#title="多行自动补全"#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#Controls multiline completions for autocomplete.#控制自动补全的多行补全。#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#{ label: "Auto", value: "auto" }#{ label: "自动", value: "auto" }#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#{ label: "Always", value: "always" }#{ label: "总是", value: "always" }#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#{ label: "Never", value: "never" }#{ label: "从不", value: "never" }#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#title="Autocomplete Timeout (ms)"#title="自动补全超时 (ms)"#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#Maximum time in milliseconds for autocomplete request/retrieval.#自动补全请求/检索的最大时间（毫秒）。#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#title="Autocomplete Debounce (ms)"#title="自动补全防抖 (ms)"#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#Minimum time in milliseconds to trigger an autocomplete request after a change.#更改后触发自动补全请求的最小时间（毫秒）。#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#title="Disable autocomplete in files"#title="在文件中禁用自动补全"#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#List of comma-separated glob pattern to disable autocomplete in matching files.#以逗号分隔的 glob 模式列表，用于在匹配文件中禁用自动补全。#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#placeholder="\*\*/\*\.\(txt,md\)"#placeholder="**/*.(txt,md)"#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#title="Experimental"#title="实验性"#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#title="Show Experimental Settings"#title="显示实验性设置"#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#title="Add Current File by Default"#title="默认添加当前文件"#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's# the currently open file is added as context in every new conversation.#当前打开的文件在每个新对话中作为上下文添加。#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#title="Enable experimental tools"#title="启用实验性工具"#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's# enables access to experimental tools that are still in development.#启用对仍在开发中的实验性工具的访问。#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#title="Only use system message tools"#title="仅使用系统消息工具"#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's# Continue will not attempt to use native tool calling and will only use system message tools.#Continue 将不会尝试使用原生工具调用，而只会使用系统消息工具。#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#title="@Codebase: use tool calling only"#title="@代码库：仅使用工具调用"#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's# @codebase context provider will only use tool calling for code retrieval.#@代码库上下文提供程序将仅使用工具调用进行代码检索。#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#title="Stream after tool rejection"#title="工具拒绝后流式传输"#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's# streaming will continue after the tool call is rejected.#工具调用被拒绝后流式传输将继续。#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx

# Rules section translations
$xsed 's#title="Rules"#title="规则"#g' ${baseDir}/../gui/src/pages/config/sections/RulesSection.tsx
$xsed 's#addButtonTooltip="Add rules"#addButtonTooltip="添加规则"#g' ${baseDir}/../gui/src/pages/config/sections/RulesSection.tsx
$xsed 's#Reloading rules from your config...#正在从配置重新加载规则...#g' ${baseDir}/../gui/src/pages/config/sections/RulesSection.tsx
$xsed 's#message="No rules configured. Click the + button to add your first rule."#message="未配置规则。点击 + 按钮添加您的第一个规则。"#g' ${baseDir}/../gui/src/pages/config/sections/RulesSection.tsx
$xsed 's#title="Prompts"#title="提示"#g' ${baseDir}/../gui/src/pages/config/sections/RulesSection.tsx
$xsed 's#addButtonTooltip="Add prompt"#addButtonTooltip="添加提示"#g' ${baseDir}/../gui/src/pages/config/sections/RulesSection.tsx
$xsed 's#message="No prompts configured. Click the + button to add your first prompt."#message="未配置提示。点击 + 按钮添加您的第一个提示。"#g' ${baseDir}/../gui/src/pages/config/sections/RulesSection.tsx
$xsed 's#Delete Rule#删除规则#g' ${baseDir}/../gui/src/pages/config/sections/RulesSection.tsx
$xsed 's#Are you sure you want to delete this rule file?#您确定要删除此规则文件吗？#g' ${baseDir}/../gui/src/pages/config/sections/RulesSection.tsx
$xsed 's#Applies to files#适用于文件#g' ${baseDir}/../gui/src/pages/config/sections/RulesSection.tsx
$xsed 's#text="Expand"#text="展开"#g' ${baseDir}/../gui/src/pages/config/sections/RulesSection.tsx
$xsed 's#text="View"#text="查看"#g' ${baseDir}/../gui/src/pages/config/sections/RulesSection.tsx
$xsed 's#text="Edit"#text="编辑"#g' ${baseDir}/../gui/src/pages/config/sections/RulesSection.tsx
$xsed 's#text="Delete"#text="删除"#g' ${baseDir}/../gui/src/pages/config/sections/RulesSection.tsx

# Translate dropdown labels in RulesSection
$xsed 's#label: "Current workspace"#label: "当前工作区"#g' ${baseDir}/../gui/src/pages/config/sections/RulesSection.tsx
$xsed 's#label: "Global"#label: "全局"#g' ${baseDir}/../gui/src/pages/config/sections/RulesSection.tsx

# Tools section translations
$xsed 's#title="Tools"#title="工具"#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx
$xsed 's#subtext="Manage MCP servers and tool policies"#subtext="管理 MCP 服务器和工具策略"#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx
$xsed 's#All tools disabled in Chat, switch to Plan or Agent mode to use tools#在对话模式下所有工具被禁用，切换到规划或智能体模式以使用工具#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx
$xsed 's#Read-only tools available in Plan mode#在规划模式下只读工具可用#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx
$xsed 's#displayName="Built-in Tools"#displayName="内置工具"#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx
$xsed 's#title="MCP Servers"#title="MCP 服务器"#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx
$xsed 's#addButtonTooltip="Add MCP server"#addButtonTooltip="添加 MCP 服务器"#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx
$xsed 's#message="MCP servers are disabled in your organization"#message="MCP 服务器在您的组织中被禁用"#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx
$xsed 's#All MCPs are disabled in Chat, switch to Plan or Agent mode to use MCPs#在对话模式下所有 MCP 被禁用，切换到规划或智能体模式以使用 MCP#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx
$xsed 's#message="No MCP servers configured. Click the + button to add your first server."#message="未配置 MCP 服务器。点击 + 按钮添加您的第一个服务器。"#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx
$xsed 's#title="Prompts"#title="提示"#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx
$xsed 's#title="Resources"#title="资源"#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx
$xsed 's#No .* available#无 .* 可用#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx
$xsed 's#Logout#登出#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx
# $xsed 's#Edit#编辑#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx
# $xsed 's#Disconnect#断开连接#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx
$xsed 's#Reload#重新加载#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx

# More Tools translations: server status tooltips and auth text
$xsed 's#Active#已连接#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx
$xsed 's#Connecting#连接中#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx
$xsed 's#Inactive#未连接#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx
# $xsed 's#Off#已禁用#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx
$xsed 's#Authenticating#正在验证#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx
$xsed 's#Error#错误#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx
$xsed 's#Authenticate#验证#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx
$xsed 's#Remove authentication#移除验证#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx
$xsed 's#Authenticating\.\.\.#正在验证...#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx
$xsed 's#displayName={"Tools"}#displayName={"工具"}#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx

# Configs section translations
$xsed 's#title="Configs"#title="配置"#g' ${baseDir}/../gui/src/pages/config/sections/ConfigsSection.tsx
$xsed 's#addButtonTooltip="Add config"#addButtonTooltip="添加配置"#g' ${baseDir}/../gui/src/pages/config/sections/ConfigsSection.tsx
$xsed 's#content="Open configuration"#content="打开配置"#g' ${baseDir}/../gui/src/pages/config/sections/ConfigsSection.tsx
$xsed 's#message="No agents configured. Click the + button to add your first agent."#message="未配置智能体。点击 + 按钮添加您的第一个智能体。"#g' ${baseDir}/../gui/src/pages/config/sections/ConfigsSection.tsx

# Indexing settings translations
$xsed 's#title="Indexing"#title="索引"#g' ${baseDir}/../gui/src/pages/config/sections/IndexingSettingsSection.tsx
$xsed 's#@codebase index#@代码库索引#g' ${baseDir}/../gui/src/pages/config/sections/IndexingSettingsSection.tsx
$xsed 's#Indexing is disabled#索引已禁用#g' ${baseDir}/../gui/src/pages/config/sections/IndexingSettingsSection.tsx
$xsed 's#title="Enable indexing"#title="启用索引"#g' ${baseDir}/../gui/src/pages/config/sections/IndexingSettingsSection.tsx
$xsed 's#Allows indexing of your codebase for search and context understanding. Note that indexing can consume significant system resources, especially on larger codebases.#允许索引您的代码库以进行搜索和上下文理解。请注意，索引可能会消耗大量系统资源，尤其是在较大的代码库中。#g' ${baseDir}/../gui/src/pages/config/sections/IndexingSettingsSection.tsx
$xsed 's#Indexing has been deprecated#索引已被弃用#g' ${baseDir}/../gui/src/pages/config/sections/IndexingSettingsSection.tsx
$xsed 's#make your agent aware of your codebase and documentation#让您的智能体了解您的代码库和文档#g' ${baseDir}/../gui/src/pages/config/sections/IndexingSettingsSection.tsx

# Fix remaining English phrase in indexing section
$xsed 's#Learn how to#了解如何#g' ${baseDir}/../gui/src/pages/config/sections/IndexingSettingsSection.tsx

# Organizations translations
$xsed 's#title="Organizations"#title="组织"#g' ${baseDir}/../gui/src/pages/config/sections/OrganizationsSection.tsx
$xsed 's#addButtonTooltip="Add organization"#addButtonTooltip="添加组织"#g' ${baseDir}/../gui/src/pages/config/sections/OrganizationsSection.tsx
$xsed 's#Organizations are only available with cloud accounts. Sign in to manage organizations.#组织仅适用于云账户。登录以管理组织。#g' ${baseDir}/../gui/src/pages/config/sections/OrganizationsSection.tsx

# Replace literal header text for Organizations page
$xsed 's#<h2 className="mb-0 text-xl font-semibold">Organizations</h2>#<h2 className="mb-0 text-xl font-semibold">组织</h2>#g' ${baseDir}/../gui/src/pages/config/sections/OrganizationsSection.tsx

# HelpSection translations (将 HelpSection 页面英文替换为中文)
$xsed 's#title="Help Center"#title="帮助中心"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx

# HelpSection shortcut descriptions translations
$xsed 's#description: "Toggle Selected Model"#description: "切换所选模型"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed 's#description: "Edit highlighted code"#description: "编辑选中代码"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
# $xsed 's#description: "New Chat / New Chat With Selected Code / Close Continue Sidebar If Chat Already In Focus"#description: "新建聊天 / 使用所选代码新建聊天 / 若聊天已聚焦则关闭 Continue 侧边栏"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed 's#"New Chat / New Chat With Selected Code / Close Continue Sidebar If Chat Already In Focus"#"新建对话 / 使用所选代码新建对话 / 若聊天已聚焦则关闭 插件 侧边栏"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed 's#description: "Cancel response"#description: "取消响应"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed 's#description: "Toggle inline edit focus"#description: "切换内联编辑焦点"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
# $xsed 's#description: "Focus Current Chat / Add Selected Code To Current Chat / Close Continue Sidebar If Chat Already In Focus"#description: "聚焦当前聊天 / 将选中代码添加到当前聊天 / 若聊天已聚焦则关闭 Continue 侧边栏"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed 's#"Focus Current Chat / Add Selected Code To Current Chat / Close Continue Sidebar If Chat Already In Focus"#"聚焦当前对话 / 将选中代码添加到当前对话 / 若聊天已聚焦则关闭 插件 侧边栏"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed 's#description: "Debug Terminal"#description: "调试终端"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed 's#description: "Reject Diff"#description: "拒绝差异"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed 's#description: "Accept Diff"#description: "接受差异"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed 's#description: "Reject Top Change in Diff"#description: "拒绝差异中顶部更改"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed 's#description: "Accept Top Change in Diff"#description: "接受差异中顶部更改"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed 's#description: "Toggle Autocomplete Enabled"#description: "切换自动补全"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed 's#description: "Force an Autocomplete Trigger"#description: "强制触发自动补全"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed 's#description: "Toggle Full Screen"#description: "切换全屏"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed 's#description: "Quick Input"#description: "快速输入"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed 's#description: "Toggle Sidebar"#description: "切换侧边栏"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
# 注释掉 Resources 部分的删除命令，改为仅翻译文本
# $xsed '/^[[:space:]]*\{\/\* Resources \*\/\}/,/^[[:space:]]*<\/div>[[:space:]]*$/d' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed  '177,216d' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed 's#title="Token usage"#title="词元(Token)使用情况"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed 's#description="Daily token usage across models"#description="各模型的每日令牌用量统计"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed 's#description="Open the current chat session file for troubleshooting"#description="打开当前聊天会话文件以进行故障排查"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed 's#description="Reopen the quickstart and tutorial file"#description="重新打开快速入门与教程文件"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx


$xsed 's#<h3 className="mb-3 text-base font-medium">Resources</h3>#<h3 className="mb-3 text-base font-medium">资源</h3>#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed 's#<h3 className="mb-3 text-base font-medium">Tools</h3>#<h3 className="mb-3 text-base font-medium">工具</h3>#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed 's#<h3 className="mb-3 text-base font-medium">Keyboard Shortcuts</h3>#<h3 className="mb-3 text-base font-medium">键盘快捷键</h3>#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed 's#title="Documentation"#title="文档"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed 's#title="Have an issue\?"#title="遇到问题？"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed 's#title="Join the community!"#title="加入社区！"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed 's#title="Token usage"#title="令牌使用"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed 's#title="View current session history"#title="查看当前会话历史"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed 's#title="Quickstart"#title="快速上手"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed 's#title="Theme Test Page"#title="主题测试页"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx
$xsed 's#title="Help Center"#title="帮助中心"#g' ${baseDir}/../gui/src/pages/config/sections/HelpSection.tsx


$xsed 's#title="More"#title="更多"#g' ${baseDir}/../gui/src/pages/stats.tsx
$xsed 's#Tokens per Day#每日Token用量#g' ${baseDir}/../gui/src/pages/stats.tsx
$xsed 's#<Th>Day</Th>#"帮助中心"#g' ${baseDir}/../gui/src/pages/stats.tsx
$xsed 's#<Th>Generated Tokens</Th>#<Th>生成的Token数量</Th>#g' ${baseDir}/../gui/src/pages/stats.tsx
$xsed 's#<Th>Prompt Tokens</Th>#<Th>输入Token数量</Th>#g' ${baseDir}/../gui/src/pages/stats.tsx

$xsed 's#Tokens per Model#各模型Token用量#g' ${baseDir}/../gui/src/pages/stats.tsx
$xsed 's#<Th>Model</Th>#<Th>模型</Th>#g' ${baseDir}/../gui/src/pages/stats.tsx
$xsed 's#<Th>Generated Tokens</Th>#<Th>生成的Token数量</Th>#g' ${baseDir}/../gui/src/pages/stats.tsx
$xsed 's#<Th>Prompt Tokens</Th>#<Th>输入Token数量</Th>#g' ${baseDir}/../gui/src/pages/stats.tsx

## 状态栏
$xsed 's#Continue";#分布式编码助手";#g' ${baseDir}/vscode/src/autocomplete/statusBar.ts
$xsed 's#Use Next Edit over FIM autocomplete#优先使用 NextEdit 而非 FIM 补全#g' ${baseDir}/vscode/src/autocomplete/statusBar.ts
$xsed 's#Use FIM autocomplete over Next Edit#优先使用 FIM 补全而非 NextEdit#g' ${baseDir}/vscode/src/autocomplete/statusBar.ts
$xsed 's#Tab autocomplete is paused#Tab 自动补全已暂停#g' ${baseDir}/vscode/src/autocomplete/statusBar.ts
$xsed 's#Tab autocomplete is enabled#Tab 自动补全已启用#g' ${baseDir}/vscode/src/autocomplete/statusBar.ts
$xsed 's#Next Edit is enabled#NextEdit 已启用#g' ${baseDir}/vscode/src/autocomplete/statusBar.ts
$xsed 's#Enable autocomplete#启用自动补全#g' ${baseDir}/vscode/src/autocomplete/statusBar.ts
$xsed 's#Disable autocomplete#禁用自动补全#g' ${baseDir}/vscode/src/autocomplete/statusBar.ts
$xsed 's#Pause autocomplete#暂停自动补全#g' ${baseDir}/vscode/src/autocomplete/statusBar.ts

$xsed 's# Open settings# 打开设置#g' ${baseDir}/vscode/src/commands.ts
$xsed 's# Open chat# 打开对话#g' ${baseDir}/vscode/src/commands.ts
$xsed 's# OOpen full screen chat# 打开全屏对话#g' ${baseDir}/vscode/src/commands.ts
$xsed 's#"Switch model"#"切换模型"#g' ${baseDir}/vscode/src/commands.ts


### history page
# 搜索历史会话相关汉化
$xsed 's#"Search past sessions"#"搜索历史会话"#g' ${baseDir}/../gui/src/components/History/index.tsx
$xsed 's#No past sessions found. To start a new session, either click the#"未找到历史会话。要开始新会话，请点击"#g' ${baseDir}/../gui/src/components/History/index.tsx
$xsed 's#button or use the keyboard shortcut#"按钮或使用快捷键"#g' ${baseDir}/../gui/src/components/History/index.tsx
$xsed 's#Clear chats#"清空聊天记录"#g' ${baseDir}/../gui/src/components/History/index.tsx
$xsed 's#Chat history is saved to#"聊天记录已保存至"#g' ${baseDir}/../gui/src/components/History/index.tsx

# 时间分组汉化
$xsed 's#label: "Today"#label: "今日"#g' ${baseDir}/../gui/src/components/History/util.ts
$xsed 's#label: "This Week"#label: "本周"#g' ${baseDir}/../gui/src/components/History/util.ts
$xsed 's#label: "This Month"#label: "本月"#g' ${baseDir}/../gui/src/components/History/util.ts
$xsed 's#label: "This Older"#label: "更早"#g' ${baseDir}/../gui/src/components/History/util.ts

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
