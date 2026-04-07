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
$xsed 's#View configuration errors#查看配置错误#g' ${baseDir}/../extensions/cli/src/ui/UserInput.tsx

# $xsed 's#"name": "@continuedev/cli"#"name": "@aicoder/cli"#g' ${baseDir}/../extensions/cli/package.json
$xsed 's#"description": "Continue CLI"#"description": "AICoder CLI"#g' ${baseDir}/../extensions/cli/package.json
