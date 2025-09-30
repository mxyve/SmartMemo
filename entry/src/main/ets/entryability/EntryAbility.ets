import { UIAbility, Want, Configuration, ConfigurationConstant } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { StorageService } from '../service/StorageService';
import { ThemeManager } from '../utils/ThemeManager';

export default class EntryAbility extends UIAbility {
  private mainWindow: window.Window | null = null;

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    try {
      this.mainWindow = windowStage.getMainWindowSync();
    } catch (error) {
      // TODO: Implement error handling.
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

  private async applyThemeStyle(colorMode: number | undefined): Promise<void> {
    if (!this.mainWindow) {
      return;
    }
    try {
      await this.mainWindow.setWindowSystemBarEnable(['status', 'navigation']);

      if (colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
        // 夜间模式
        await this.mainWindow.setWindowSystemBarProperties({
          statusBarColor: '#000000',
          statusBarContentColor: '#FFFFFF',
          navigationBarColor: '#000000',
          navigationBarContentColor: '#FFFFFF'
        });
        hilog.info(0x0000, 'SmartMemo', '夜间模式样式已应用');
      } else {
        // 浅色模式
        await this.mainWindow.setWindowSystemBarProperties({
          statusBarColor: '#FFFFFF',
          statusBarContentColor: '#000000',
          navigationBarColor: '#FFFFFF',
          navigationBarContentColor: '#000000'
        });
        hilog.info(0x0000, 'SmartMemo', '浅色模式样式已应用');
      }
    } catch (err) {
      hilog.error(0x0000, 'SmartMemo', '应用主题样式失败: %{public}s', JSON.stringify(err) ?? '');
    }
  }
}
