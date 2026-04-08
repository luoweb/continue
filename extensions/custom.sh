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
# $xsed 's#"Ask anything, #"询问任何事情，#g' ${baseDir}/../gui/src/components/mainInput/TipTapEditor/utils/editorConfig.ts
# $xsed 's# to add context"# 添加上下文"#g' ${baseDir}/../gui/src/components/mainInput/TipTapEditor/utils/editorConfig.ts

$xsed 's#content="Select Config"#content="选择配置"#g' ${baseDir}/../gui/src/components/mainInput/Lump/LumpToolbar/BlockSettingsTopToolbar.tsx
$xsed 's#View configuration errors#查看配置错误#g' ${baseDir}/../gui/src/components/mainInput/Lump/LumpToolbar/BlockSettingsTopToolbar.tsx
$xsed 's#Configure rules#配置规则#g' ${baseDir}/../gui/src/components/mainInput/Lump/LumpToolbar/BlockSettingsTopToolbar.tsx
$xsed 's#Configure tools#配置工具#g' ${baseDir}/../gui/src/components/mainInput/Lump/LumpToolbar/BlockSettingsTopToolbar.tsx
$xsed 's#Configure models#配置模型#g' ${baseDir}/../gui/src/components/mainInput/Lump/LumpToolbar/BlockSettingsTopToolbar.tsx

$xsed 's#? "Chat"#? "对话"#g' ${baseDir}/../gui/src/components/ModeSelect/ModeSelect.tsx
$xsed 's#? "Plan"#? "规划"#g' ${baseDir}/../gui/src/components/ModeSelect/ModeSelect.tsx
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
$xsed 's#"Send With Active File"#"发送当前文件"#g' ${baseDir}/../gui/src/components/mainInput/InputToolbar.tsx
$xsed 's#"Send Without Active File"#"不发送当前文件"#g' ${baseDir}/../gui/src/components/mainInput/InputToolbar.tsx
$xsed 's#"Active file"#"当前文件"#g' ${baseDir}/../gui/src/components/mainInput/InputToolbar.tsx


$xsed 's#to toggle model#切换模型#g' ${baseDir}/../gui/src/components/modelSelection/ModelSelect.tsx
$xsed 's#Add Chat model#添加聊天模型#g' ${baseDir}/../gui/src/components/modelSelection/ModelSelect.tsx
$xsed 's#<span className="text-description text-xs font-medium">Models</span>#<span className="text-description text-xs font-medium">模型</span>#g' ${baseDir}/../gui/src/components/modelSelection/ModelSelect.tsx
$xsed 's#Last Session#最近会话#g' ${baseDir}/../gui/src/pages/gui/Chat.tsx

$xsed 's#User Settings#用户设置#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
$xsed 's#title="Models"#title="模型"#g' ${baseDir}/../gui/src/pages/config/sections/ModelsSection.tsx
$xsed 's#addButtonTooltip="Add model"#addButtonTooltip="添加模型"#g' ${baseDir}/../gui/src/pages/config/sections/ModelsSection.tsx
$xsed 's#displayName="Chat"#displayName="对话"#g' ${baseDir}/../gui/src/pages/config/sections/ModelsSection.tsx
$xsed 's#Used in Chat, Plan, Agent mode#在对话、规划、智能体模式下使用#g' ${baseDir}/../gui/src/pages/config/sections/ModelsSection.tsx
$xsed 's#Learn more#更多#g' ${baseDir}/../gui/src/pages/config/sections/ModelsSection.tsx
$xsed 's#displayName="Autocomplete"#displayName="自动补全"#g' ${baseDir}/../gui/src/pages/config/sections/ModelsSection.tsx
$xsed 's#Used in inline code completions as you type#在你输入时，用于行内代码自动补全#g' ${baseDir}/../gui/src/pages/config/sections/ModelsSection.tsx

$xsed 's#displayName="Edit"#displayName="编辑"#g' ${baseDir}/../gui/src/pages/config/sections/ModelsSection.tsx
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
$xsed 's#placeholder="**/*.(txt,md)"#placeholder="**/*.(txt,md)"#g' ${baseDir}/../gui/src/pages/config/sections/UserSettingsSection.tsx
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
$xsed 's#Edit#编辑#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx
$xsed 's#Disconnect#断开连接#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx
$xsed 's#Reload#重新加载#g' ${baseDir}/../gui/src/pages/config/sections/ToolsSection.tsx

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

# Organizations translations
$xsed 's#title="Organizations"#title="组织"#g' ${baseDir}/../gui/src/pages/config/sections/OrganizationsSection.tsx
$xsed 's#addButtonTooltip="Add organization"#addButtonTooltip="添加组织"#g' ${baseDir}/../gui/src/pages/config/sections/OrganizationsSection.tsx
$xsed 's#Organizations are only available with cloud accounts. Sign in to manage organizations.#组织仅适用于云账户。登录以管理组织。#g' ${baseDir}/../gui/src/pages/config/sections/OrganizationsSection.tsx

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
