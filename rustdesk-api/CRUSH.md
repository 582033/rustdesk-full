---
**项目语言偏好：** 与本项目相关的所有交流和生成的文档（包括本 `CRUSH.md` 文件）都应使用中文。
---

# CRUSH.md

本文件为 rustdesk-api 项目的构建、测试和贡献提供了一套指南。

## 构建、代码检查和测试命令

### 构建

要构建应用程序，请使用 `build.sh` 脚本。它同时支持 macOS 和 Linux 环境。

- **macOS**:
  ```bash
  ./build.sh darwin
  ```
- **Linux (需要 Docker)**:
  ```bash
  ./build.sh linux
  ```

### 测试

项目使用标准的 Go 测试框架。

- **运行所有测试**:
  ```bash
  go test ./...
  ```
- **运行单个测试**:
  ```bash
  go test {package_path} -run {TestName}
  ```
  *示例*: `go test ./utils -run TestEncryptPassword`

### 代码检查

虽然没有明确定义代码检查步骤，但本项目推荐的检查工具是 `golangci-lint`。

- **运行代码检查**:
  ```bash
  golangci-lint run
  ```

## 代码风格指南

### 格式化

所有 Go 代码都应使用 `gofmt` 进行格式化。

### 导入

导入应分为三组：
1. 标准库包
2. 第三方包
3. 项目内部包

### 命名约定

遵循标准的 Go 命名约定：
- `camelCase` 用于局部变量和未导出的函数。
- `PascalCase` 用于导出的标识符。

### 错误处理

使用标准的 `if err != nil` 模式进行错误处理。

### 关键库

本项目使用以下关键库：
- **Cobra**: 用于创建强大的命令行界面（CLI）应用程序。
- **Viper**: 用于处理应用程序配置。
- **Gorm**: 作为对象关系映射（ORM）工具用于数据库交互。
- **Custom Logger**: 用于结构化日志记录。
