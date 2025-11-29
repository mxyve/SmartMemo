/**
 * 主页面 - TabBar导航结构
 */

import { router } from '@kit.ArkUI';
import { window } from '@kit.ArkUI'; // 🔥 新增导入
import { MemoListPage } from './MemoListPage';
import { SettingsPage } from './SettingsPage';
import { AppConstants } from '../constants/AppConstants';

interface TabBarItem {
  text: string;
  icon: Resource;
  selectedIcon: Resource;
}

@Entry
@Component
struct MainPage {
  @State currentTabIndex: number = 0;
  @State showFloatingButton: boolean = true;
  @State refreshTrigger: number = 0;
  // 🔥 新增：安全区域状态
  @State statusBarHeight: number = 0;
  @State navigationBarHeight: number = 0;
  // TabBar配置
  private tabBarData: TabBarItem[] = [
    {
      text: '备忘录',
      icon: $r('app.media.memo'),
      selectedIcon: $r('app.media.memo')
    },
    {
      text: '分类',
      icon: $r('app.media.category'),
      selectedIcon: $r('app.media.category')
    },
    {
      text: '设置',
      icon: $r('app.media.settings'),
      selectedIcon: $r('app.media.settings')
    }
  ];

  aboutToAppear(): void {
    // 🔥 新增：获取系统栏高度
    this.getSystemBarHeights();
  }

  /**
   * 🔥 新增：获取系统栏高度
   */
  private async getSystemBarHeights(): Promise<void> {
    try {
      const win = await window.getLastWindow(getContext(this));
      const avoidArea = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);

      // 状态栏高度（顶部）
      this.statusBarHeight = avoidArea.topRect.height;
      // 导航栏高度（底部）
      this.navigationBarHeight = avoidArea.bottomRect.height;

      console.info(`状态栏高度: ${this.statusBarHeight}, 导航栏高度: ${this.navigationBarHeight}`);
    } catch (error) {
      console.error('获取系统栏高度失败:', error);
      // 设置默认值
      this.statusBarHeight = 60;
      this.navigationBarHeight = 60;
    }
  }

  onPageShow(): void {
    // 页面显示时触发刷新
    this.refreshTrigger = Date.now();
  }

  build() {
    Stack() {
      // 🔥 修正：安全区域占位和主要内容
      Column() {
        // 状态栏占位（防止内容与状态栏重叠）
        Row()
          .width('100%')
          .height(this.statusBarHeight)
          .backgroundColor('transparent')

        // 主要内容区域
        Tabs({
          barPosition: BarPosition.End,
          index: this.currentTabIndex
        }) {
          // 备忘录页面
          TabContent() {
            MemoListPage({ refreshTrigger: this.refreshTrigger })
          }
          .tabBar(this.buildTabBarItem(0))

          // 分类页面
          TabContent() {
            this.buildCategoryPage()
          }
          .tabBar(this.buildTabBarItem(1))

          // 设置页面
          TabContent() {
            SettingsPage()
          }
          .tabBar(this.buildTabBarItem(2))
        }
        .onChange((index: number) => {
          this.currentTabIndex = index;
          // 在分类和设置页面隐藏悬浮按钮
          this.showFloatingButton = index === 0;
        })
        .animationDuration(AppConstants.ANIMATION.DURATION_NORMAL)
        .backgroundColor('transparent')
        .layoutWeight(1) // 🔥 新增：确保Tabs填满空间

        // 🔥 修正：导航栏占位移到Tabs外部
        Row()
          .width('100%')
          .height(this.navigationBarHeight)
          .backgroundColor('transparent')
      }
      .width('100%')
      .height('100%')

      // 🔥 修正：悬浮按钮放在Stack的最外层
      if (this.showFloatingButton) {
        Button() {
          Text('+')
            .fontSize(28)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }
        .width(56)
        .height(56)
        .borderRadius(28)
        .backgroundColor($r('app.color.primary_color'))
        .shadow({
          radius: 16,
          color: 'rgba(0, 125, 255, 0.4)',
          offsetY: 4
        })
        .onClick(() => {
          this.onAddButtonClick();
        })
        .position({
          x: '100%',
          y: '100%'
        })
        .markAnchor({
          x: 72, // 按钮宽度56 + 右边距16
          y: 128 // 按钮高度56 + 底部边距16 + TabBar高度56 + 导航栏高度
        })
        .animation({
          duration: AppConstants.ANIMATION.DURATION_NORMAL,
          curve: Curve.EaseInOut
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_light'))
  }

  /**
   * 构建TabBar项
   */
  @Builder
  buildTabBarItem(index: number) {
    Column() {
      // 图标区域，添加背景圆圈
      Stack() {
        if (this.currentTabIndex === index) {
          Circle()
            .width(32)
            .height(32)
            .fill($r('app.color.primary_color'))
            .opacity(0.15)
        }

        Image(this.currentTabIndex === index ?
          this.tabBarData[index].selectedIcon :
          this.tabBarData[index].icon)
          .width(22)
          .height(22)
          .fillColor(this.currentTabIndex === index ?
            $r('app.color.primary_color') :
            $r('app.color.text_secondary_light'))
      }
      .width(32)
      .height(32)

      // 文本标签
      Text(this.tabBarData[index].text)
        .fontSize(11)
        .fontWeight(this.currentTabIndex === index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.currentTabIndex === index ?
          $r('app.color.primary_color') :
          $r('app.color.text_secondary_light'))
        .margin({ top: 4 })
        .maxLines(1)
    }
    .width('100%')
    .height('100%')
    .padding({ top: 6, bottom: 6 })
    .justifyContent(FlexAlign.Center)
    .animation({
      duration: 200,
      curve: Curve.EaseInOut
    })
  }

  /**
   * 构建分类页面
   */
  @Builder
  buildCategoryPage() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('分类管理')
          .fontSize(AppConstants.FONT_SIZE.TITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary_light'))

        Blank()

        Image($r('app.media.new'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.onAddCategoryClick();
          })
      }
      .width('100%')
      .height(AppConstants.UI.HEADER_HEIGHT)
      .padding({
        left: AppConstants.SPACING.MEDIUM,
        right: AppConstants.SPACING.MEDIUM
      })

      Divider()
        .color($r('app.color.priority_high'))

      // 分类列表区域
      Column() {
        Text('分类功能开发中...')
          .fontSize(AppConstants.FONT_SIZE.MEDIUM)
          .fontColor($r('app.color.text_secondary_light'))
          .margin({ top: AppConstants.SPACING.EXTRA_LARGE })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_light'))
  }

  /**
   * 添加按钮点击事件
   */
  private onAddButtonClick(): void {
    // 导航到添加备忘录页面
    router.pushUrl({
      url: 'pages/MemoDetailPage',
      params: {
        mode: 'add'
      }
    }).catch((error: Error) => {
      console.error('Navigate to memo detail failed:', error);
    });
  }

  /**
   * 添加分类按钮点击事件
   */
  private onAddCategoryClick(): void {
    // TODO: 实现添加分类功能
    console.log('Add category clicked');
  }
}