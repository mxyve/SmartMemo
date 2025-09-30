/**
 * 启动页
 */

import { router } from '@kit.ArkUI';
import { StorageService } from '../service/StorageService';
import { AppConstants } from '../constants/AppConstants';

@Entry
@Component
struct SplashPage {
  @State splashOpacity: number = 0;
  @State logoScale: number = 0.8;
  @State titleOpacity: number = 0;
  @State subtitleOpacity: number = 0;
  @State progressOpacity: number = 0;
  @State loadingProgress: number = 0;

  aboutToAppear(): void {
    this.startSplashAnimation();
    this.initializeApp();
  }

  build() {
    Stack() {
      // 背景渐变
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 135,
          colors: [
            ['#E3F2FD', 0.0],
            ['#BBDEFB', 0.5],
            ['#90CAF9', 1.0]
          ]
        })

      // 主要内容
      Column() {
        Blank()

        // Logo 区域
        Column() {
          // Logo 图标
          Image($r('app.media.icon'))
            .width(120)
            .height(120)
            .borderRadius(30)
            .shadow({
              radius: 20,
              color: 'rgba(0, 125, 255, 0.3)',
              offsetX: 0,
              offsetY: 10
            })
            .scale({ x: this.logoScale, y: this.logoScale })
            .animation({
              duration: AppConstants.ANIMATION.DURATION_LONG,
              curve: Curve.EaseOut,
              delay: 200
            })

          // 标题
          Text($r('app.string.splash_title'))
            .fontSize(AppConstants.FONT_SIZE.DISPLAY)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1976D2')
            .margin({ top: AppConstants.SPACING.LARGE })
            .opacity(this.titleOpacity)
            .animation({
              duration: AppConstants.ANIMATION.DURATION_NORMAL,
              curve: Curve.EaseOut,
              delay: 600
            })

          // 副标题
          Text($r('app.string.splash_subtitle'))
            .fontSize(AppConstants.FONT_SIZE.LARGE)
            .fontColor('#1976D2')
            .fontWeight(FontWeight.Medium)
            .margin({ top: AppConstants.SPACING.SMALL })
            .opacity(this.subtitleOpacity)
            .animation({
              duration: AppConstants.ANIMATION.DURATION_NORMAL,
              curve: Curve.EaseOut,
              delay: 800
            })
        }

        Blank()

        // 加载进度区域
        Column() {
          // 加载进度条
          Progress({
            value: this.loadingProgress,
            total: 100,
            type: ProgressType.Linear
          })
            .width('60%')
            .height(4)
            .color('#1976D2')
            .backgroundColor('#E3F2FD')
            .animation({
              duration: AppConstants.ANIMATION.DURATION_SHORT,
              curve: Curve.EaseInOut
            })

          // 加载文本
          Text('正在初始化...')
            .fontSize(AppConstants.FONT_SIZE.MEDIUM)
            .fontColor('#1976D2')
            .margin({ top: AppConstants.SPACING.MEDIUM })
        }
        .opacity(this.progressOpacity)
        .animation({
          duration: AppConstants.ANIMATION.DURATION_NORMAL,
          curve: Curve.EaseOut,
          delay: 1000
        })
        .margin({ bottom: AppConstants.SPACING.EXTRA_LARGE * 2 })
      }
      .width('100%')
      .height('100%')
      .opacity(this.splashOpacity)
      .animation({
        duration: AppConstants.ANIMATION.DURATION_LONG,
        curve: Curve.EaseOut
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  /**
   * 开始启动动画
   */
  private startSplashAnimation(): void {
    // 整体渐入
    setTimeout(() => {
      this.splashOpacity = 1;
    }, 100);

    // Logo缩放
    setTimeout(() => {
      this.logoScale = 1.0;
    }, 300);

    // 标题渐入
    setTimeout(() => {
      this.titleOpacity = 1;
    }, 600);

    // 副标题渐入
    setTimeout(() => {
      this.subtitleOpacity = 1;
    }, 800);

    // 进度条渐入
    setTimeout(() => {
      this.progressOpacity = 1;
    }, 1000);
  }

  /**
   * 初始化应用
   */
  private async initializeApp(): Promise<void> {
    try {
      // 模拟初始化步骤
      await this.updateProgress(20, '检查权限...');
      await this.checkPermissions();

      await this.updateProgress(40, '初始化数据...');
      await this.initializeData();

      await this.updateProgress(60, '加载配置...');
      await this.loadConfiguration();

      await this.updateProgress(80, '准备界面...');
      await this.prepareUI();

      await this.updateProgress(100, '完成');

      // 延迟跳转，让用户看到完成状态
      setTimeout(() => {
        this.navigateToMainPage();
      }, 500);

    } catch (error) {
      console.error('App initialization failed:', error);
      // 即使初始化失败，也要跳转到主页面
      setTimeout(() => {
        this.navigateToMainPage();
      }, 1000);
    }
  }

  /**
   * 更新进度
   */
  private async updateProgress(progress: number, message: string): Promise<void> {
    return new Promise((resolve) => {
      setTimeout(() => {
        this.loadingProgress = progress;
        resolve();
      }, 300 + Math.random() * 200); // 随机延迟，模拟真实加载
    });
  }

  /**
   * 检查权限
   */
  private async checkPermissions(): Promise<void> {
    // 这里可以添加权限检查逻辑
    return new Promise((resolve) => {
      setTimeout(resolve, 200);
    });
  }

  /**
   * 初始化数据
   */
  private async initializeData(): Promise<void> {
    try {
      const storageService = StorageService.getInstance();

      // 检查是否需要创建默认数据
      const memos = await storageService.loadMemos();
      if (memos.length === 0) {
        // 创建欢迎备忘录
        // 这里可以添加默认数据创建逻辑
      }
    } catch (error) {
      console.error('Initialize data failed:', error);
    }
  }

  /**
   * 加载配置
   */
  private async loadConfiguration(): Promise<void> {
    try {
      const storageService = StorageService.getInstance();

      // 加载主题设置
      const theme =
        await storageService.loadSetting(AppConstants.STORAGE_KEYS.THEME, AppConstants.THEME.AUTO) as string;

      // 应用主题设置
      // 这里可以添加主题应用逻辑

    } catch (error) {
      console.error('Load configuration failed:', error);
    }
  }

  /**
   * 准备UI
   */
  private async prepareUI(): Promise<void> {
    // 预加载资源或准备UI组件
    return new Promise((resolve) => {
      setTimeout(resolve, 200);
    });
  }

  /**
   * 跳转到主页面
   */
  private navigateToMainPage(): void {
    // 使用正确的路由API格式
    router.replaceUrl({ url: 'pages/MainPage' }).catch((error: Error) => {
      console.error('Navigate to main page failed:', error);
    });
  }
}