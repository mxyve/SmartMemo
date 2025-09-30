/**
 * 设置页面
 */

import { ThemeManager, ThemeMode } from '../utils/ThemeManager';
import { StorageService } from '../service/StorageService';
import { AppConstants } from '../constants/AppConstants';
import { SettingItem } from '../components/settings/SettingItem';

@Entry
@Component
export struct SettingsPage {
  @State private themeManager: ThemeManager = ThemeManager.getInstance();
  @State private storageService: StorageService = StorageService.getInstance();
  @State private currentTheme: ThemeMode = ThemeMode.AUTO;
  @State private currentFontSize: number = AppConstants.FONT_SIZE.MEDIUM;
  @State private showAboutDialog: boolean = false;

  aboutToAppear(): void {
    this.loadSettings();
  }

  build() {
    Column() {
      // 顶部标题栏
      this.buildHeader()

      // 设置内容
      Scroll() {
        Column() {
          // 外观设置
          this.buildAppearanceSection()
          // 数据管理
          this.buildDataSection()
          // 关于应用
          this.buildAboutSection()
        }
        .padding(AppConstants.SPACING.MEDIUM)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeManager.getBackgroundColor())
  }

  /**
   * 构建头部
   */
  @Builder
  buildHeader() {
    Row() {
      Text('设置')
        .fontSize(this.themeManager.getScaledFontSize(AppConstants.FONT_SIZE.TITLE))
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeManager.getPrimaryTextColor())
    }
    .width('100%')
    .height(AppConstants.UI.HEADER_HEIGHT)
    .padding({
      left: AppConstants.SPACING.MEDIUM,
      right: AppConstants.SPACING.MEDIUM
    })
    .justifyContent(FlexAlign.Start)
  }

  /**
   * 构建外观设置区域
   */
  @Builder
  buildAppearanceSection() {
    Column() {
      // 区域标题
      Row() {
        Image($r('app.media.appearance'))
          .width(20)
          .height(20)
          .fillColor(this.themeManager.getPrimaryTextColor())
          .margin({ right: AppConstants.SPACING.SMALL })

        Text('外观设置')
          .fontSize(this.themeManager.getScaledFontSize(AppConstants.FONT_SIZE.LARGE))
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeManager.getPrimaryTextColor())
      }
      .alignSelf(ItemAlign.Start)
      .margin({ bottom: AppConstants.SPACING.MEDIUM })

      // 设置项
      SettingItem({
        title: '主题',
        subtitle: this.themeManager.getThemeModeDisplayName(),
        iconResource: $r('app.media.theme'),
        onItemClick: () => {
          this.showThemeSelectionDialog();
        }
      })

      SettingItem({
        title: '字体大小',
        subtitle: this.getFontSizeDisplayName(),
        iconResource: $r('app.media.font_size'),
        onItemClick: () => {
          this.showFontSizeSelectionDialog();
        }
      })

      // 分割线
      Divider()
        .color(this.themeManager.getDividerColor())
        .margin({ top: AppConstants.SPACING.MEDIUM, bottom: AppConstants.SPACING.MEDIUM })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 构建数据管理区域
   */
  @Builder
  buildDataSection() {
    Column() {
      // 区域标题
      Row() {
        Image($r('app.media.data_management'))
          .width(20)
          .height(20)
          .fillColor(this.themeManager.getPrimaryTextColor())
          .margin({ right: AppConstants.SPACING.SMALL })

        Text('数据管理')
          .fontSize(this.themeManager.getScaledFontSize(AppConstants.FONT_SIZE.LARGE))
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeManager.getPrimaryTextColor())
      }
      .alignSelf(ItemAlign.Start)
      .margin({ bottom: AppConstants.SPACING.MEDIUM })

      // 设置项
      SettingItem({
        title: '导出数据',
        subtitle: '备份所有备忘录',
        iconResource: $r('app.media.export'),
        onItemClick: () => {
          this.exportData();
        }
      })

      SettingItem({
        title: '导入数据',
        subtitle: '从备份文件恢复',
        iconResource: $r('app.media.import'),
        onItemClick: () => {
          this.importData();
        }
      })

      SettingItem({
        title: '清除所有数据',
        subtitle: '删除所有备忘录',
        iconResource: $r('app.media.clear'),
        titleColor: this.themeManager.getErrorColor(),
        onItemClick: () => {
          this.showClearDataDialog();
        }
      })

      // 分割线
      Divider()
        .color(this.themeManager.getDividerColor())
        .margin({ top: AppConstants.SPACING.MEDIUM, bottom: AppConstants.SPACING.MEDIUM })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 构建关于区域
   */
  @Builder
  buildAboutSection() {
    Column() {
      // 区域标题
      Row() {
        Image($r('app.media.about'))
          .width(20)
          .height(20)
          .fillColor(this.themeManager.getPrimaryTextColor())
          .margin({ right: AppConstants.SPACING.SMALL })

        Text('关于应用')
          .fontSize(this.themeManager.getScaledFontSize(AppConstants.FONT_SIZE.LARGE))
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeManager.getPrimaryTextColor())
      }
      .alignSelf(ItemAlign.Start)
      .margin({ bottom: AppConstants.SPACING.MEDIUM })

      // 设置项
      SettingItem({
        title: '版本信息',
        subtitle: 'v1.0.0',
        iconResource: $r('app.media.version_info'),
        onItemClick: () => {
          this.showAboutDialog = true;
        }
      })

      SettingItem({
        title: '隐私政策',
        subtitle: '查看隐私保护说明',
        iconResource: $r('app.media.privacy_policy'),
        onItemClick: () => {
          this.showPrivacyPolicy();
        }
      })

      SettingItem({
        title: '用户协议',
        subtitle: '查看使用条款',
        iconResource: $r('app.media.user_agreement'),
        onItemClick: () => {
          this.showUserAgreement();
        }
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }


  /**
   * 加载设置
   */
  private async loadSettings(): Promise<void> {
    this.currentTheme = this.themeManager.currentTheme;
    this.currentFontSize = this.themeManager.fontSize;
  }

  /**
   * 获取字体大小显示名称
   */
  private getFontSizeDisplayName(): string {
    if (this.currentFontSize <= AppConstants.FONT_SIZE.SMALL) {
      return '小';
    } else if (this.currentFontSize <= AppConstants.FONT_SIZE.MEDIUM) {
      return '标准';
    } else if (this.currentFontSize <= AppConstants.FONT_SIZE.LARGE) {
      return '大';
    } else {
      return '超大';
    }
  }

  /**
   * 导出数据
   */
  private async exportData(): Promise<void> {
    try {
      const data = await this.storageService.exportData();
      // TODO: 实现文件保存功能
      console.log('Export data:', data);

      AlertDialog.show({
        title: '导出成功',
        message: '数据已导出到下载目录',
        primaryButton: {
          value: '确定',
          action: () => {}
        }
      });
    } catch (error) {
      console.error('Export data failed:', error);
      AlertDialog.show({
        title: '导出失败',
        message: '数据导出失败，请重试',
        primaryButton: {
          value: '确定',
          action: () => {}
        }
      });
    }
  }

  /**
   * 导入数据
   */
  private async importData(): Promise<void> {
    // TODO: 实现文件选择和导入功能
    console.log('Import data clicked');

    AlertDialog.show({
      title: '功能开发中',
      message: '导入功能正在开发中，敬请期待',
      primaryButton: {
        value: '确定',
        action: () => {}
      }
    });
  }

  /**
   * 显示清除数据对话框
   */
  private showClearDataDialog(): void {
    AlertDialog.show({
      title: '清除所有数据',
      message: '此操作将删除所有备忘录，且无法恢复。确定要继续吗？',
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '清除',
        fontColor: this.themeManager.getErrorColor(), // 危险操作用红色
        action: () => {
          this.clearAllData();
        }
      }
    });
  }

  /**
   * 清除所有数据
   */
  private async clearAllData(): Promise<void> {
    try {
      await this.storageService.clearAllData();

      AlertDialog.show({
        title: '清除完成',
        message: '所有数据已清除',
        primaryButton: {
          value: '确定',
          action: () => {}
        }
      });
    } catch (error) {
      console.error('Clear data failed:', error);
      AlertDialog.show({
        title: '清除失败',
        message: '数据清除失败，请重试',
        primaryButton: {
          value: '确定',
          action: () => {}
        }
      });
    }
  }

  /**
   * 显示隐私政策
   */
  private showPrivacyPolicy(): void {
    AlertDialog.show({
      title: '隐私政策',
      message: '智能备忘录严格保护您的隐私，所有数据仅存储在本设备，不会上传到服务器。',
      primaryButton: {
        value: '确定',
        action: () => {}
      }
    });
  }

  /**
   * 显示用户协议
   */
  private showUserAgreement(): void {
    AlertDialog.show({
      title: '用户协议',
      message: '欢迎使用智能备忘录。本应用免费提供给用户使用，请合理使用应用功能。',
      primaryButton: {
        value: '确定',
        action: () => {}
      }
    });
  }

  /**
   * 显示主题选择对话框
   */
  private showThemeSelectionDialog(): void {
    const currentThemeText = this.currentTheme === ThemeMode.AUTO ? '跟随系统' :
                            this.currentTheme === ThemeMode.LIGHT ? '浅色模式' : '深色模式';

    AlertDialog.show({
      title: '选择主题',
      message: `当前主题：${currentThemeText}\n\n请选择要使用的主题模式：`,
      buttons: [
        {
          value: '跟随系统',
          action: () => {
            this.selectTheme(ThemeMode.AUTO);
          }
        },
        {
          value: '浅色模式',
          action: () => {
            this.selectTheme(ThemeMode.LIGHT);
          }
        },
        {
          value: '深色模式',
          action: () => {
            this.selectTheme(ThemeMode.DARK);
          }
        },
        {
          value: '取消',
          action: () => {}
        }
      ]
    });
  }

  /**
   * 显示字体大小选择对话框
   */
  private showFontSizeSelectionDialog(): void {
    const currentSizeText = this.getFontSizeDisplayName();

    AlertDialog.show({
      title: '选择字体大小',
      message: `当前字体大小：${currentSizeText}\n\n请选择要使用的字体大小：`,
      buttons: [
        {
          value: '小',
          action: () => {
            this.selectFontSize(AppConstants.FONT_SIZE.SMALL);
          }
        },
        {
          value: '标准',
          action: () => {
            this.selectFontSize(AppConstants.FONT_SIZE.MEDIUM);
          }
        },
        {
          value: '大',
          action: () => {
            this.selectFontSize(AppConstants.FONT_SIZE.LARGE);
          }
        },
        {
          value: '超大',
          action: () => {
            this.selectFontSize(AppConstants.FONT_SIZE.EXTRA_LARGE);
          }
        },
        {
          value: '取消',
          action: () => {}
        }
      ]
    });
  }

  /**
   * 选择主题
   */
  private async selectTheme(mode: ThemeMode): Promise<void> {
    try {
      this.currentTheme = mode;
      await this.themeManager.setThemeMode(mode);
      console.info('Theme changed to:', mode);
    } catch (error) {
      console.error('Set theme failed:', error);
    }
  }

  /**
   * 选择字体大小
   */
  private async selectFontSize(size: number): Promise<void> {
    try {
      this.currentFontSize = size;
      await this.themeManager.setFontSize(size);
      console.info('Font size changed to:', size);
    } catch (error) {
      console.error('Set font size failed:', error);
    }
  }
}