# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

SmartMemo 是一款基于 HarmonyOS 6.0.0 开发的现代化个人备忘录应用，使用 ArkTS/ETS 语言和 Stage 模型架构。

## 构建和开发命令

### 基础构建命令
```bash
# 安装依赖
npm install

# 开发构建
hvigor assembleHap --mode debug

# 发布构建
hvigor assembleHap --mode release

# 清理构建
hvigor clean

# 运行测试
hvigor test

# 代码检查（使用配置的 eslint 规则）
npm run lint
```

### 单元测试
```bash
# 测试文件位于 entry/src/ohosTest/
# 运行特定测试模块
hvigor test --target ohosTest
```

## 核心架构

### MVVM 架构模式
- **Model**: `model/MemoItem.ets` - 数据模型，包含备忘录的完整数据结构
- **ViewModel**: `viewmodel/MemoListViewModel.ets` - 业务逻辑层，处理数据操作和状态管理
- **View**: `pages/` - 页面组件，响应式 UI 界面

### 关键设计模式

**单例模式**：
- `StorageService` - 数据持久化服务
- `ThemeManager` - 主题管理器

**观察者模式**：
- 使用 `@Observed` 和 `@State` 实现响应式数据绑定
- MemoItem 和 ViewModel 支持自动 UI 更新

### 数据流向
1. **用户操作** → `Pages` (View层)
2. **事件处理** → `ViewModel` (逻辑层)
3. **数据持久化** → `StorageService` (服务层)
4. **状态更新** → 自动触发 UI 重新渲染

### 核心服务

**StorageService**：
- 使用 `@ohos.data.preferences` 进行轻量级数据存储
- 支持数据导入导出（JSON格式）
- 提供完整的CRUD操作接口

**ThemeManager**：
- 管理浅色/深色/自动主题切换
- 提供统一的颜色和字体大小获取接口
- 支持主题状态持久化

### 导航架构
```
SplashPage (启动页)
    ↓
MainPage (TabBar容器)
    ├── MemoListPage (备忘录列表)
    │   └── MemoDetailPage (详情页)
    ├── CategoryPage (分类页面，开发中)
    └── SettingsPage (设置页面)
```

### 组件层次结构

**公共组件** (`components/common/`):
- `LoadingDialog` - 加载提示对话框

**业务组件** (`components/memo/`):
- `PrioritySelector` - 优先级选择器

### 关键数据结构

**MemoItem 核心字段**：
```typescript
{
  id: string;              // 唯一标识（时间戳+随机字符串）
  title: string;           // 标题
  content: string;         // 内容
  tags: string[];          // 标签数组
  priority: Priority;      // 优先级枚举 (0:低, 1:中, 2:高)
  createTime: number;      // 创建时间戳
  updateTime: number;      // 更新时间戳
  reminderTime?: number;   // 可选提醒时间
  attachments: Attachment[]; // 附件数组
  isCompleted: boolean;    // 完成状态
  isStarred: boolean;      // 星标状态
}
```

### 状态管理特点

**MemoListViewModel 关键方法**：
- `applyFilterAndSort()` - 复杂的筛选和排序逻辑，支持多维度过滤
- `toggleMemoSelection()` - 批量选择模式管理
- 实时搜索功能（标题、内容、标签全文搜索）

### 主题系统设计

**ThemeManager 核心功能**：
- 三种模式：Auto（跟随系统）、Light、Dark
- 颜色配置：每种主题包含完整的颜色定义
- 字体缩放：基于用户偏好的动态字体大小调整
- 响应式主题切换：自动应用到所有UI组件

### 开发注意事项

**代码风格**：
- 所有注释使用中文
- 遵循 ESLint 安全规则配置（见 `code-linter.json5`）
- 组件方法使用 `@Builder` 装饰器构建可复用UI

**数据安全**：
- 代码检查器配置了严格的安全规则
- 禁用不安全的加密算法和哈希方法

**性能优化**：
- 使用 `@Track` 进行精细化状态管理
- 列表渲染使用 `ForEach` 和唯一key优化
- 复杂UI使用 `@Builder` 方法分离逻辑

### 文件结构关键点

**入口文件**：`entryability/EntryAbility.ets` - 应用生命周期管理，服务初始化

**常量定义**：`constants/AppConstants.ets` - 集中管理UI尺寸、动画时长、颜色等常量

**工具类**：`utils/ThemeManager.ets` - 主题相关的工具方法

**页面路由**：页面间导航使用 `router.pushUrl()` 进行参数传递