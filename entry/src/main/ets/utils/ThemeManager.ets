/**
 * 主题管理器
 */

import { StorageService } from '../service/StorageService';
import { AppConstants } from '../constants/AppConstants';
import { common, ConfigurationConstant } from '@kit.AbilityKit';

export enum ThemeMode {
  AUTO = 'auto',
  LIGHT = 'light',
  DARK = 'dark'
}

interface ThemeColors {
  background: string;
  surface: string;
  primary: string;
  primaryVariant: string;
  secondary: string;
  textPrimary: string;
  textSecondary: string;
  divider: string;
  error: string;
  warning: string;
  success: string;
}


@Observed
export class ThemeManager {
  private static instance: ThemeManager;
  private storageService: StorageService;
  @Track currentTheme: ThemeMode = ThemeMode.AUTO;
  @Track isDarkMode: boolean = false;
  @Track fontSize: number = AppConstants.FONT_SIZE.MEDIUM;
  // 主题颜色定义
  @Track readonly lightTheme: ThemeColors = {
    background: '#F1F3F5',
    surface: '#FFFFFF',
    primary: '#007DFF',
    primaryVariant: '#0056CC',
    secondary: '#36B366',
    textPrimary: '#182431',
    textSecondary: '#666666',
    divider: '#E4E4E4',
    error: '#FA2A2D',
    warning: '#FF8A00',
    success: '#36B366'
  };
  @Track readonly darkTheme: ThemeColors = {
    background: '#191C1C',
    surface: '#2F3030',
    primary: '#4A90E2',
    primaryVariant: '#357ABD',
    secondary: '#4CAF50',
    textPrimary: '#E5E5E5',
    textSecondary: '#999999',
    divider: '#3A3A3A',
    error: '#FF5252',
    warning: '#FF9800',
    success: '#4CAF50'
  };

  private constructor() {
    this.storageService = StorageService.getInstance();
    this.initializeTheme();
  }

  static getInstance(): ThemeManager {
    if (!ThemeManager.instance) {
      ThemeManager.instance = new ThemeManager();
    }
    return ThemeManager.instance;
  }

  /**
   * 初始化主题
   */
  private async initializeTheme(): Promise<void> {
    try {
      // 加载保存的主题设置
      const savedTheme = await this.storageService.loadSetting(
        AppConstants.STORAGE_KEYS.THEME,
        ThemeMode.AUTO
      ) as ThemeMode;

      const savedFontSize = await this.storageService.loadSetting(
        AppConstants.STORAGE_KEYS.FONT_SIZE,
        AppConstants.FONT_SIZE.MEDIUM
      ) as number;

      this.currentTheme = savedTheme;
      this.fontSize = savedFontSize;

      this.updateTheme();
    } catch (error) {
      console.error('Initialize theme failed:', error);
    }
  }

  /**
   * 设置主题模式
   */
  async setThemeMode(mode: ThemeMode): Promise<void> {
    try {
      this.currentTheme = mode;
      await this.storageService.saveSetting(AppConstants.STORAGE_KEYS.THEME, mode);
      this.updateTheme();
    } catch (error) {
      console.error('Set theme mode failed:', error);
    }
  }

  /**
   * 设置字体大小
   */
  async setFontSize(size: number): Promise<void> {
    try {
      this.fontSize = size;
      await this.storageService.saveSetting(AppConstants.STORAGE_KEYS.FONT_SIZE, size);
    } catch (error) {
      console.error('Set font size failed:', error);
    }
  }

  /**
   * 更新主题
   */
  private updateTheme(): void {
    if (this.currentTheme === ThemeMode.AUTO) {
      // 跟随系统主题
      this.isDarkMode = this.isSystemDarkMode();
    } else {
      this.isDarkMode = this.currentTheme === ThemeMode.DARK;
    }

    // 应用主题到全局
    this.applyThemeToSystem();
  }

  /**
   * 检查系统是否为深色模式
   */
  private isSystemDarkMode(): boolean {
    try {
      // 获取应用上下文配置
      const context = getContext() as common.UIAbilityContext;
      if (context && context.config) {
        return context.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
      }
    } catch (error) {
      console.error('Get system theme failed:', error);
    }
    // 默认返回浅色模式
    return false;
  }

  /**
   * 应用主题到系统
   * 用于设置系统级别的主题属性，如状态栏、导航栏颜色等
   */
  private applyThemeToSystem(): void {
    // 这里可以设置系统级别的主题属性
    // 例如状态栏颜色等
    console.info('Theme applied:', this.isDarkMode ? 'Dark' : 'Light');
  }

  /**
   * 响应系统配置变化
   * 当系统主题发生变化时调用此方法
   */
  onConfigurationUpdate(): void {
    if (this.currentTheme === ThemeMode.AUTO) {
      const wasInDarkMode = this.isDarkMode;
      this.isDarkMode = this.isSystemDarkMode();

      // 只有当主题真正发生变化时才重新应用
      if (wasInDarkMode !== this.isDarkMode) {
        this.applyThemeToSystem();
      }
    }
  }

  /**
   * 获取当前主题颜色
   * 根据当前的深色模式状态返回对应的主题色彩配置
   */
  getThemeColors(): ThemeColors {
    // 根据当前主题模式返回相应的颜色配置对象
    return this.isDarkMode ? this.darkTheme : this.lightTheme;
  }

  /**
   * 获取错误颜色
   */
  getErrorColor(): string {
    return this.isDarkMode ? this.darkTheme.error : this.lightTheme.error;
  }

  /**
   * 获取成功颜色
   */
  getSuccessColor(): string {
    return this.isDarkMode ? this.darkTheme.success : this.lightTheme.success;
  }

  /**
   * 获取背景颜色
   */
  getBackgroundColor(): string {
    return this.isDarkMode ? this.darkTheme.background : this.lightTheme.background;
  }

  /**
   * 获取表面颜色
   */
  getSurfaceColor(): string {
    return this.isDarkMode ? this.darkTheme.surface : this.lightTheme.surface;
  }

  /**
   * 获取主要文本颜色
   */
  getPrimaryTextColor(): string {
    return this.isDarkMode ? this.darkTheme.textPrimary : this.lightTheme.textPrimary;
  }

  /**
   * 获取次要文本颜色
   */
  getSecondaryTextColor(): string {
    return this.isDarkMode ? this.darkTheme.textSecondary : this.lightTheme.textSecondary;
  }

  /**
   * 获取主题色
   */
  getPrimaryColor(): string {
    return this.isDarkMode ? this.darkTheme.primary : this.lightTheme.primary;
  }

  /**
   * 获取分割线颜色
   */
  getDividerColor(): string {
    return this.isDarkMode ? this.darkTheme.divider : this.lightTheme.divider;
  }

  /**
   * 获取字体大小缩放比例
   * 以中等字体大小为基准计算缩放倍数
   */
  getFontSizeScale(): number {
    // 以中等字体大小作为基准（1.0倍），计算当前字体大小的缩放比例
    return this.fontSize / AppConstants.FONT_SIZE.MEDIUM;
  }

  /**
   * 获取缩放后的字体大小
   * 根据用户设置的字体大小偏好对基础字体大小进行缩放
   */
  getScaledFontSize(baseSize: number): number {
    // 将基础字体大小乘以缩放比例，返回最终的字体大小
    return baseSize * this.getFontSizeScale();
  }

  /**
   * 切换主题模式
   */
  async toggleTheme(): Promise<void> {
    const nextTheme = this.getNextThemeMode();
    await this.setThemeMode(nextTheme);
  }

  /**
   * 获取下一个主题模式
   * 实现主题模式的循环切换：自动 -> 浅色 -> 深色 -> 自动
   */
  private getNextThemeMode(): ThemeMode {
    switch (this.currentTheme) {
      case ThemeMode.AUTO:
        return ThemeMode.LIGHT; // 自动模式切换到浅色模式
      case ThemeMode.LIGHT:
        return ThemeMode.DARK; // 浅色模式切换到深色模式
      case ThemeMode.DARK:
        return ThemeMode.AUTO; // 深色模式切换回自动模式
      default:
        return ThemeMode.AUTO; // 异常情况下默认返回自动模式
    }
  }

  /**
   * 获取主题模式显示名称
   */
  getThemeModeDisplayName(mode?: ThemeMode): string {
    const targetMode = mode || this.currentTheme;
    switch (targetMode) {
      case ThemeMode.AUTO:
        return '跟随系统';
      case ThemeMode.LIGHT:
        return '浅色主题';
      case ThemeMode.DARK:
        return '深色主题';
      default:
        return '未知';
    }
  }

  /**
   * 监听系统主题变化
   */
  onSystemThemeChanged(isDark: boolean): void {
    if (this.currentTheme === ThemeMode.AUTO) {
      this.isDarkMode = isDark;
      this.applyThemeToSystem();
    }
  }
}