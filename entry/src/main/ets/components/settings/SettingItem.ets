/**
 * 设置项通用组件 - 简化版
 */

import { ThemeManager } from '../../utils/ThemeManager';
import { AppConstants } from '../../constants/AppConstants';

@Component
export struct SettingItem {
  @State private themeManager: ThemeManager = ThemeManager.getInstance();
  // 必传参数
  @Prop title: string = '';
  @Prop subtitle: string = '';
  onItemClick?: () => void;
  @Prop iconResource: Resource;
  @Prop titleColor: string;

  build() {
    Button() {
      Row() {
        // 左侧图标
        if (this.iconResource) {
          Image(this.iconResource)
            .width(24)
            .height(24)
            .fillColor(this.themeManager.getPrimaryTextColor())
            .margin({ right: AppConstants.SPACING.MEDIUM })
        }

        // 主要内容区域
        Column() {
          Text(this.title)
            .fontSize(this.themeManager.getScaledFontSize(AppConstants.FONT_SIZE.MEDIUM))
            .fontColor(this.titleColor || this.themeManager.getPrimaryTextColor())
            .fontWeight(FontWeight.Medium)
            .alignSelf(ItemAlign.Start)

          if (this.subtitle) {
            Text(this.subtitle)
              .fontSize(this.themeManager.getScaledFontSize(AppConstants.FONT_SIZE.SMALL))
              .fontColor(this.themeManager.getSecondaryTextColor())
              .alignSelf(ItemAlign.Start)
              .margin({ top: 2 })
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        // 右侧箭头
        Image($r('app.media.arrow_right'))
          .width(16)
          .height(16)
          .fillColor(this.themeManager.getSecondaryTextColor())
      }
      .width('100%')
      .padding(AppConstants.SPACING.MEDIUM)
      .alignItems(VerticalAlign.Center)
    }
    .backgroundColor(this.themeManager.getSurfaceColor())
    .borderRadius(AppConstants.UI.BORDER_RADIUS_MEDIUM)
    .margin({ bottom: AppConstants.SPACING.SMALL })
    .onClick(() => {
      this.onItemClick?.();
    })
  }
}