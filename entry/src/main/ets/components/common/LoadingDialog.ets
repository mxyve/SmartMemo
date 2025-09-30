/**
 * 加载对话框组件（自定义弹窗，常用于网络请求等待、数据装载过程）
 */

import { ThemeManager } from '../../utils/ThemeManager';
import { AppConstants } from '../../constants/AppConstants';

// 标记为自定义对话框组件；由 CustomDialogController 控制打开/关闭
@CustomDialog
export struct LoadingDialog {
  // 主题管理：单例获取主题色、字号等。使用 @State 以便主题变化时触发重建。
  // 注意：若 ThemeManager 未实现可观察（Observed/可通知）能力，则切换主题可能无法自动刷新。
  @State private themeManager: ThemeManager = ThemeManager.getInstance();
  // 控制器由外部注入（父组件持有），用于 open()/close() 控制对话框生命周期
  controller: CustomDialogController;
  // 文案可由外部传入，默认“加载中…”
  message: string = '加载中...';

  // 组件渲染结构
  build() {
    // 容器采用纵向排列
    Column() {
      // 系统 Loading 指示器：40x40，颜色取主题主色
      LoadingProgress()
        .width(40)
        .height(40)
        .color(this.themeManager.getPrimaryColor())

      // 提示文案：字号随主题缩放，颜色取主题主要文本色
      Text(this.message)
        .fontSize(this.themeManager.getScaledFontSize(AppConstants.FONT_SIZE.MEDIUM))
        .fontColor(this.themeManager.getPrimaryTextColor())
        .margin({ top: AppConstants.SPACING.MEDIUM })
    }
    // 对话框“卡片”宽度，内边距、圆角、背景色均来自主题常量
    .width(200)
    .padding(AppConstants.SPACING.LARGE)
    .backgroundColor(this.themeManager.getSurfaceColor())
    .borderRadius(AppConstants.UI.BORDER_RADIUS_MEDIUM)

    // 纵轴居中（Column 主轴为竖直方向）。建议同时设置 alignItems 实现横向居中，见下方“可选增强”
    .justifyContent(FlexAlign.Center)
  }
}
