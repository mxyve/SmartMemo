/**
 * 应用常量定义（集中管理所有“可配置但相对稳定”的参数）
 * 设计目标：
 * 1) 去除魔法数字，统一全局口径（尺寸、时长、分页、文件限制等）
 * 2) 明确单位：长度优先按 vp 理解；时间统一毫秒；颜色统一 HEX
 * 3) 便于 Theme/配置中心统一调优与 A/B 对比
 */

/** 持久化存储用到的 Key 名集合（避免硬编码、键名冲突） */
interface StorageKeys {
  MEMOS: string; // 备忘录数据列表
  CATEGORIES: string; // 分类数据列表
  SETTINGS: string; // 全局设置（含语言、主题、排序等）
  THEME: string; // 当前主题（auto/light/dark）
  FONT_SIZE: string; // 字号缩放或选择
  LAST_BACKUP: string; // 最近备份时间戳
}

/** 本地数据库通用配置（RDB/IndexedDB/SQLite 等均可复用命名） */
interface DatabaseConfig {
  NAME: string; // 数据库名
  VERSION: number; // 版本号（升级迁移用）
  STORE_CONFIG: StoreConfig; // 主存储（表/对象仓库）配置
}

/** 存储对象配置（主表/主仓库名称） */
interface StoreConfig {
  name: string; // 默认主仓库/表名
}

/** 动画参数（单位：毫秒；弹簧参数为无量纲比例） */
interface AnimationConfig {
  DURATION_SHORT: number; // 短动画：按钮反馈、微动效
  DURATION_NORMAL: number; // 标准动画：切换、小型过渡
  DURATION_LONG: number; // 长动画：复杂过渡/进出场
  SPRING_RESPONSE: number; // 弹簧响应（越小越灵敏，0.5~0.7常用）
  SPRING_DAMPING_FRACTION: number; // 阻尼系数（0~1，越大越“稳”）
}

/** UI 尺寸规范（单位：vp，除非使用处特别声明） */
interface UIConfig {
  BORDER_RADIUS_SMALL: number; // 小圆角：列表项、Tag
  BORDER_RADIUS_MEDIUM: number; // 中圆角：卡片、对话框
  BORDER_RADIUS_LARGE: number; // 大圆角：浮层、底部面板
  CARD_ELEVATION: number; // 卡片投影等级/高度（按设计体系约定）
  BUTTON_HEIGHT: number; // 主/次级按钮高度
  INPUT_HEIGHT: number; // 输入框高度
  TAB_BAR_HEIGHT: number; // TabBar 高度
  HEADER_HEIGHT: number; // 顶部栏高度
  FLOATING_BUTTON_SIZE: number; // 悬浮操作按钮直径（方形时为边长）
}

/** 间距规范（单位：vp；用于容器内边距/组件间距） */
interface SpacingConfig {
  EXTRA_SMALL: number; // 极小间距：图标/文字之间
  SMALL: number; // 小间距：列表项内元素间
  MEDIUM: number; // 中等：组件块之间
  LARGE: number; // 大：区块分隔
  EXTRA_LARGE: number; // 特大：页面级边距/留白
}

/** 字体规范（单位：sp/vp；与主题字号缩放联动） */
interface FontSizeConfig {
  EXTRA_SMALL: number; // 说明/辅助信息
  SMALL: number; // 次级信息
  MEDIUM: number; // 正文/按钮文案（默认）
  LARGE: number; // 小标题/强调文本
  EXTRA_LARGE: number; // 模块标题/空态提示
  HEADLINE: number; // 标题（较显著）
  TITLE: number; // 主标题/页面标题
  DISPLAY: number; // 超大标题/主视觉
}

/** 主题模式标识（与系统/跟随系统对齐） */
interface ThemeConfig {
  AUTO: string; // 跟随系统
  LIGHT: string; // 亮色
  DARK: string; // 暗色
}


/** 分页加载相关（按业务峰值与网络状况适配） */
interface PaginationConfig {
  PAGE_SIZE: number; // 每页条数
  LOAD_MORE_THRESHOLD: number; // 触底提前量（剩余 N 项时触发加载）
}

/** 全文检索/本地搜索相关 */
interface SearchConfig {
  DEBOUNCE_TIME: number; // 输入防抖时间（毫秒）
  MIN_QUERY_LENGTH: number; // 最小检索长度（避免空/噪声）
  MAX_HISTORY: number; // 搜索历史上限（循环置换）
}


/** 提醒/闹钟的默认时间策略（单位：毫秒） */
interface ReminderConfig {
  MIN_ADVANCE_TIME: number; // 最小提前量（防误触）
  DEFAULT_ADVANCE_TIME: number; // 默认提前量
  MAX_ADVANCE_TIME: number; // 最大提前量（一天内）
}

/** 自动备份策略（单位：毫秒） */
interface BackupConfig {
  AUTO_BACKUP_INTERVAL: number; // 自动备份间隔
  MAX_BACKUP_FILES: number; // 本地最多保留的备份份数
}

/** 全局常量中心（均为只读静态，禁止运行时修改） */
export class AppConstants {
  // 存储键名（建议统一加业务前缀，避免与其它应用/模块冲突）
  static readonly STORAGE_KEYS: StorageKeys = {
    MEMOS: 'smart_memo_memos',
    CATEGORIES: 'smart_memo_categories',
    SETTINGS: 'smart_memo_settings',
    THEME: 'smart_memo_theme',
    FONT_SIZE: 'smart_memo_font_size',
    LAST_BACKUP: 'smart_memo_last_backup'
  };
  // 数据库配置（升级时提升 VERSION 并完成迁移）
  static readonly DATABASE: DatabaseConfig = {
    NAME: 'SmartMemoDatabase',
    VERSION: 1,
    STORE_CONFIG: {
      name: 'SmartMemoStore'
    }
  };
  // 动画参数（ms；弹簧参数与 UI 框架的物理动画保持一致语义）
  static readonly ANIMATION: AnimationConfig = {
    DURATION_SHORT: 200,
    DURATION_NORMAL: 300,
    DURATION_LONG: 500,
    SPRING_RESPONSE: 0.55,
    SPRING_DAMPING_FRACTION: 0.825
  };
  // UI 统一尺寸（vp）：圆角/按钮/输入/导航条等
  static readonly UI: UIConfig = {
    BORDER_RADIUS_SMALL: 8,
    BORDER_RADIUS_MEDIUM: 12,
    BORDER_RADIUS_LARGE: 16,
    CARD_ELEVATION: 2,
    BUTTON_HEIGHT: 44,
    INPUT_HEIGHT: 48,
    TAB_BAR_HEIGHT: 56,
    HEADER_HEIGHT: 56,
    FLOATING_BUTTON_SIZE: 56
  };
  // 间距体系（vp）：从 XS 到 XL 覆盖主流间距层级
  static readonly SPACING: SpacingConfig = {
    EXTRA_SMALL: 4,
    SMALL: 8,
    MEDIUM: 16,
    LARGE: 24,
    EXTRA_LARGE: 32
  };
  // 字体体系（sp/vp）：与主题字号缩放协同（示例值）
  static readonly FONT_SIZE: FontSizeConfig = {
    EXTRA_SMALL: 10,
    SMALL: 12,
    MEDIUM: 14,
    LARGE: 16,
    EXTRA_LARGE: 18,
    HEADLINE: 20,
    TITLE: 24,
    DISPLAY: 32
  };
  // 主题模式（与系统设置联动）
  static readonly THEME: ThemeConfig = {
    AUTO: 'auto',
    LIGHT: 'light',
    DARK: 'dark'
  };
  // 分页拉取策略（阈值 5：剩余 5 条时触发下一页）
  static readonly PAGINATION: PaginationConfig = {
    PAGE_SIZE: 20,
    LOAD_MORE_THRESHOLD: 5
  };
  // 本地搜索策略（300ms 防抖；最短 1 字符；历史最多 10 条）
  static readonly SEARCH: SearchConfig = {
    DEBOUNCE_TIME: 300,
    MIN_QUERY_LENGTH: 1,
    MAX_HISTORY: 10
  };
  // 提醒时间策略（毫秒）
  static readonly REMINDER: ReminderConfig = {
    MIN_ADVANCE_TIME: 5 * 60 * 1000, // 5 分钟
    DEFAULT_ADVANCE_TIME: 15 * 60 * 1000, // 15 分钟
    MAX_ADVANCE_TIME: 24 * 60 * 60 * 1000  // 24 小时
  };
  // 备份策略（每 7 天自动备份一次，最多保留 5 份）
  static readonly BACKUP: BackupConfig = {
    AUTO_BACKUP_INTERVAL: 7 * 24 * 60 * 60 * 1000, // 7 天
    MAX_BACKUP_FILES: 5
  };
}

/** 列表排序字段（后端/本地统一字段名，避免魔法字符串） */
export enum SortType {
  CREATE_TIME = 'createTime', // 创建时间
  UPDATE_TIME = 'updateTime', // 更新时间
  TITLE = 'title', // 标题
  REMINDER_TIME = 'reminderTime' // 提醒时间
}

/** 列表过滤类型（与筛选栏 UI 同步） */
export enum FilterType {
  ALL = 'all', // 全部
  COMPLETED = 'completed', // 已完成
  PENDING = 'pending', // 待处理
  STARRED = 'starred', // 已加星标
  WITH_REMINDER = 'withReminder', // 含提醒
}
