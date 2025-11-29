import { UIAbility, Want, Configuration, ConfigurationConstant } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { display } from '@kit.ArkUI';
import { StorageService } from '../service/StorageService';
import { ThemeManager } from '../utils/ThemeManager';

export default class EntryAbility extends UIAbility {
  private mainWindow: window.Window | null = null;

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    try {
      this.mainWindow = windowStage.getMainWindowSync();

      // 🔥 关键修改：设置沉浸式布局
      await this.setupImmersiveMode();

    } catch (error) {
      hilog.error(0x0000, 'SmartMemo', '获取主窗口失败: %{public}s', JSON.stringify(error) ?? '');
    }

    // 初始化存储服务
    try {
      const storageService = StorageService.getInstance();
      await storageService.init(this.context);
      hilog.info(0x0000, 'SmartMemo', 'StorageService 初始化成功');
    } catch (error) {
      hilog.error(0x0000, 'SmartMemo', 'StorageService 初始化失败: %{public}s', JSON.stringify(error) ?? '');
    }

    // 初始化主题管理器
    try {
      const themeManager = ThemeManager.getInstance();
      hilog.info(0x0000, 'SmartMemo', 'ThemeManager 初始化成功');
    } catch (error) {
      hilog.error(0x0000, 'SmartMemo', 'ThemeManager 初始化失败: %{public}s', JSON.stringify(error) ?? '');
    }

    // 应用当前主题
    this.applyThemeStyle(this.context.config?.colorMode);

    // 加载首页
    windowStage.loadContent('pages/SplashPage', () => {
    });
  }

  onConfigurationUpdated(config: Configuration): void {
    hilog.info(0x0000, 'SmartMemo', '系统配置更新，尝试应用新主题...');
    this.applyThemeStyle(config?.colorMode);
  }

  /**
   * 🔥 新增：设置沉浸式模式
   */
  private async setupImmersiveMode(): Promise<void> {
    if (!this.mainWindow) {
      return;
    }

    try {
      // 1. 设置布局全屏（关键步骤）
      await this.mainWindow.setWindowLayoutFullScreen(true);

      // 2. 启用系统栏
      await this.mainWindow.setWindowSystemBarEnable(['status', 'navigation']);

      // 3. 设置窗口全屏显示
      await this.mainWindow.setFullScreen(true);

      hilog.info(0x0000, 'SmartMemo', '沉浸式模式设置成功');

    } catch (error) {
      hilog.error(0x0000, 'SmartMemo', '设置沉浸式模式失败: %{public}s', JSON.stringify(error) ?? '');
    }
  }

  /**
   * 🔥 修改：适配沉浸式的主题应用方法
   */
  private async applyThemeStyle(colorMode: number | undefined): Promise<void> {
    if (!this.mainWindow) {
      return;
    }

    try {
      // 确保沉浸式设置已应用
      await this.setupImmersiveMode();

      if (colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
        // 夜间模式 - 使用半透明黑色
        await this.mainWindow.setWindowSystemBarProperties({
          statusBarColor: '#80000000', // 半透明黑色
          statusBarContentColor: '#FFFFFF', // 白色图标/文字
          navigationBarColor: '#80000000', // 半透明黑色
          navigationBarContentColor: '#FFFFFF' // 白色图标/文字
        });
        hilog.info(0x0000, 'SmartMemo', '夜间模式沉浸式样式已应用');
      } else {
        // 浅色模式 - 使用半透明白色Zz
        await this.mainWindow.setWindowSystemBarProperties({
          statusBarColor: '#80FFFFFF', // 半透明白色
          statusBarContentColor: '#000000', // 黑色图标/文字
          navigationBarColor: '#80FFFFFF', // 半透明白色
          navigationBarContentColor: '#000000' // 黑色图标/文字
        });
        hilog.info(0x0000, 'SmartMemo', '浅色模式沉浸式样式已应用');
      }
    } catch (err) {
      hilog.error(0x0000, 'SmartMemo', '应用沉浸式主题样式失败: %{public}s', JSON.stringify(err) ?? '');
    }
  }
}