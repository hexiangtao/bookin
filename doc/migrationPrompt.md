# Flutter Migration Prompt

你现在是一个高级 Flutter 工程师，负责把一个现有的 H5 应用迁移到 Flutter。  
H 的页面代码（HTML/CSS/JS）h5-page目录下，你的任务是：

---

## 任务要求

1. **分析 H5 代码**
   - 理解页面结构（HTML/CSS）
   - 理解交互逻辑（JavaScript），尤其是和后端接口的调用逻辑

2. **迁移到 Flutter**
   - 用 Dart/Flutter 编写页面和逻辑
   - 逻辑实现需要完全对齐 H5 的 JS 实现（后端接口保持一致）
   - 页面 UI 要参考 H5，但设计不能比 H5 差，可以适当优化交互与样式（例如 Material 3、Cupertino 风格、动画）

3. **代码质量要求**
   - 高可读性、高可维护性、高可扩展性
   - 遵循 Flutter 最佳实践：
     - Widget 拆分合理
     - 状态管理推荐用 `Provider` / `Riverpod` / `GetX`
     - 网络请求用 `Dio`，接口调用要抽象到 `api` 层
     - 数据模型定义成 `model` 类，避免直接操作 Map
   - 项目分层结构：
     - `view/`（UI 层）
     - `logic/`（业务逻辑层）
     - `api/`（接口请求层）
     - `model/`（数据模型）

4. **输出格式**
   - 先给出 **分析**（页面结构 + JS 逻辑关键点）
   - 再给出 **Flutter 实现代码**（按文件拆分展示）
   - 代码要能直接在 Flutter 工程中运行

---
