# 分布式编码助手

## 🔍 工作原理

分布式编码助手在每个拉取请求上运行AI代理作为GitHub状态检查。每个代理都是你仓库中 `.continue/checks/` 目录下的一个markdown文件。如果代码看起来不错，会显示绿色；如果有问题，会显示红色并提供建议的差异。

下面是一个执行安全审查的示例：

```yaml
---
name: 安全审查
description: 审查PR中的基本安全漏洞
---
审查此PR并检查：
- 没有硬编码的密钥或API密钥
- 所有新的API端点都有输入验证
- 错误响应使用标准错误格式
```

## 📦 安装CLI

AI检查由开源的分布式编码助手CLI (`cn`) 提供支持。
运行：

```bash
cn --auto
```

## 🎯 核心特性

- **智能代码审查**：AI自动检查代码质量和安全问题
- **自定义检查**：通过简单的markdown文件定义你的检查规则
- **CI集成**：在GitHub Actions中自动运行检查
- **直观的反馈**：清晰的绿色/红色状态和详细的建议
- **开源免费**：完全开源，基于Apache 2.0许可证

## 🤝 贡献

阅读[贡献指南](https://github.com/blockai/aicoder/blob/main/CONTRIBUTING.md)，并加入[GitHub讨论](https://github.com/blockai/aicoder/discussions)。

## 📄 许可证

[Apache 2.0 © 2023-2024 Roweb](./LICENSE)

---

<div align="center">
  <p>✨ 分布式编码助手 - 让代码审查更智能、更高效 ✨</p>
</div>
