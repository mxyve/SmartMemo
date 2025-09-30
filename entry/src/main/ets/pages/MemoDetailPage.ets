/**
 * 备忘录详情页面
 */

import { router } from '@kit.ArkUI';
import { MemoItem } from '../model/MemoItem';
import { StorageService } from '../service/StorageService';
import { ThemeManager } from '../utils/ThemeManager';
import { AppConstants } from '../constants/AppConstants';

@Entry
@Component
export struct MemoDetailPage {
  @State private memo: MemoItem = new MemoItem();
  @State private isEditMode: boolean = false;
  @State private themeManager: ThemeManager = ThemeManager.getInstance();
  @State private storageService: StorageService = StorageService.getInstance();
  @State private title: string = '';
  @State private content: string = '';
  @State private showReminderDialog: boolean = false;
  @State private isSaving: boolean = false;

  private routerParams: Record<string, Object> = {};

  aboutToAppear(): void {
    this.routerParams = router.getParams() as Record<string, Object>;
    this.initializePage();
  }

  build() {
    Column() {
      // 顶部工具栏
      this.buildToolbar()

      // 主要内容区域
      Scroll() {
        Column() {
          // 标题输入
          this.buildTitleInput()

          // 内容输入
          this.buildContentInput()

          // 提醒设置
          this.buildReminderSection()
        }
        .padding(AppConstants.SPACING.MEDIUM)
      }
      .layoutWeight(1)

      // 底部操作栏
      this.buildBottomActions()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeManager.getBackgroundColor())
  }

  /**
   * 构建顶部工具栏
   */
  @Builder
  buildToolbar() {
    Row() {
      // 返回按钮
      Button() {
        Image($r('app.media.arrow_left'))
          .width(24)
          .height(24)
          .fillColor(this.themeManager.getPrimaryTextColor())
      }
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        this.onBackPressed();
      })

      Text(this.isEditMode ? '编辑备忘录' : '新建备忘录')
        .fontSize(this.themeManager.getScaledFontSize(AppConstants.FONT_SIZE.TITLE))
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeManager.getPrimaryTextColor())
        .margin({ left: AppConstants.SPACING.MEDIUM })

      Blank()

      // 保存按钮
      Button() {
        if (this.isSaving) {
          LoadingProgress()
            .width(20)
            .height(20)
            .color(this.themeManager.getPrimaryColor())
        } else {
          Image($r('app.media.save'))
            .width(24)
            .height(24)
            .fillColor(this.themeManager.getPrimaryColor())
        }
      }
      .backgroundColor(Color.Transparent)
      .enabled(!this.isSaving)
      .onClick(() => {
        this.saveMemo();
      })
    }
    .width('100%')
    .height(AppConstants.UI.HEADER_HEIGHT)
    .padding({
      left: AppConstants.SPACING.MEDIUM,
      right: AppConstants.SPACING.MEDIUM
    })
  }

  /**
   * 构建标题输入
   */
  @Builder
  buildTitleInput() {
    Column() {
      Text('标题')
        .fontSize(this.themeManager.getScaledFontSize(AppConstants.FONT_SIZE.MEDIUM))
        .fontColor(this.themeManager.getSecondaryTextColor())
        .alignSelf(ItemAlign.Start)

      TextInput({
        placeholder: '请输入备忘录标题...',
        text: this.title
      })
        .fontSize(this.themeManager.getScaledFontSize(AppConstants.FONT_SIZE.LARGE))
        .fontColor(this.themeManager.getPrimaryTextColor())
        .backgroundColor(this.themeManager.getSurfaceColor())
        .borderRadius(AppConstants.UI.BORDER_RADIUS_MEDIUM)
        .padding(AppConstants.SPACING.MEDIUM)
        .margin({ top: AppConstants.SPACING.SMALL })
        .onChange((value: string) => {
          this.title = value;
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: AppConstants.SPACING.LARGE })
  }

  /**
   * 构建内容输入
   */
  @Builder
  buildContentInput() {
    Column() {
      Text('内容')
        .fontSize(this.themeManager.getScaledFontSize(AppConstants.FONT_SIZE.MEDIUM))
        .fontColor(this.themeManager.getSecondaryTextColor())
        .alignSelf(ItemAlign.Start)

      TextArea({
        placeholder: '请输入备忘录内容...',
        text: this.content
      })
        .fontSize(this.themeManager.getScaledFontSize(AppConstants.FONT_SIZE.MEDIUM))
        .fontColor(this.themeManager.getPrimaryTextColor())
        .backgroundColor(this.themeManager.getSurfaceColor())
        .borderRadius(AppConstants.UI.BORDER_RADIUS_MEDIUM)
        .padding(AppConstants.SPACING.MEDIUM)
        .margin({ top: AppConstants.SPACING.SMALL })
        .height(200)
        .onChange((value: string) => {
          this.content = value;
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: AppConstants.SPACING.LARGE })
  }


  /**
   * 构建提醒设置
   */
  @Builder
  buildReminderSection() {
    Row() {
      Text('提醒时间')
        .fontSize(this.themeManager.getScaledFontSize(AppConstants.FONT_SIZE.MEDIUM))
        .fontColor(this.themeManager.getSecondaryTextColor())

      Blank()

      Button() {
        Row() {
          Image($r('app.media.alarm'))
            .width(16)
            .height(16)
            .fillColor(this.memo.reminderTime ? this.themeManager.getPrimaryColor() : this.themeManager.getSecondaryTextColor())

          Text(this.memo.reminderTime ? this.formatReminderTime(this.memo.reminderTime) : '设置提醒')
            .fontSize(this.themeManager.getScaledFontSize(AppConstants.FONT_SIZE.MEDIUM))
            .fontColor(this.memo.reminderTime ? this.themeManager.getPrimaryColor() : this.themeManager.getSecondaryTextColor())
            .margin({ left: AppConstants.SPACING.SMALL })

          Image($r('app.media.arrow_right'))
            .width(16)
            .height(16)
            .fillColor(this.themeManager.getSecondaryTextColor())
            .margin({ left: AppConstants.SPACING.SMALL })
        }
      }
      .backgroundColor(this.themeManager.getSurfaceColor())
      .borderRadius(AppConstants.UI.BORDER_RADIUS_MEDIUM)
      .padding({
        left: AppConstants.SPACING.MEDIUM,
        right: AppConstants.SPACING.MEDIUM,
        top: AppConstants.SPACING.SMALL,
        bottom: AppConstants.SPACING.SMALL
      })
      .onClick(() => {
        this.showReminderDialog = true;
      })
    }
    .width('100%')
    .margin({ bottom: AppConstants.SPACING.LARGE })
  }


  /**
   * 构建底部操作栏
   */
  @Builder
  buildBottomActions() {
    Row() {
      // 取消按钮
      Button('取消')
        .fontSize(this.themeManager.getScaledFontSize(AppConstants.FONT_SIZE.MEDIUM))
        .fontColor(this.themeManager.getSecondaryTextColor())
        .backgroundColor(Color.Transparent)
        .borderWidth(1)
        .borderColor(this.themeManager.getDividerColor())
        .borderRadius(AppConstants.UI.BORDER_RADIUS_MEDIUM)
        .layoutWeight(1)
        .height(AppConstants.UI.BUTTON_HEIGHT)
        .onClick(() => {
          this.onBackPressed();
        })

      Blank()
        .width(AppConstants.SPACING.MEDIUM)

      // 保存按钮
      Button('保存')
        .fontSize(this.themeManager.getScaledFontSize(AppConstants.FONT_SIZE.MEDIUM))
        .fontColor(Color.White)
        .backgroundColor(this.themeManager.getPrimaryColor())
        .borderRadius(AppConstants.UI.BORDER_RADIUS_MEDIUM)
        .layoutWeight(1)
        .height(AppConstants.UI.BUTTON_HEIGHT)
        .enabled(!this.isSaving)
        .onClick(() => {
          this.saveMemo();
        })
    }
    .width('100%')
    .padding(AppConstants.SPACING.MEDIUM)
    .backgroundColor(this.themeManager.getSurfaceColor())
  }

  /**
   * 初始化页面
   */
  private async initializePage(): Promise<void> {
    const mode = this.routerParams['mode'] as string;
    this.isEditMode = mode === 'edit';

    if (this.isEditMode) {
      const memoId = this.routerParams['memoId'] as string;
      await this.loadMemo(memoId);
    }

    this.title = this.memo.title;
    this.content = this.memo.content;
  }

  /**
   * 加载备忘录
   */
  private async loadMemo(memoId: string): Promise<void> {
    try {
      const memos = await this.storageService.loadMemos();
      const foundMemo = memos.find(m => m.id === memoId);
      if (foundMemo) {
        this.memo = foundMemo;
      }
    } catch (error) {
      console.error('Load memo failed:', error);
    }
  }

  /**
   * 保存备忘录
   */
  private async saveMemo(): Promise<void> {
    if (!this.title.trim()) {
      AlertDialog.show({
        title: '提示',
        message: '请输入备忘录标题',
        primaryButton: {
          value: '确定',
          action: () => {}
        }
      });
      return;
    }

    this.isSaving = true;

    try {
      this.memo.title = this.title.trim();
      this.memo.content = this.content.trim();
      this.memo.updateTimeStamp();

      await this.storageService.saveMemo(this.memo);

      // 返回上一页
      router.back();
    } catch (error) {
      console.error('Save memo failed:', error);
      AlertDialog.show({
        title: '错误',
        message: '保存失败，请重试',
        primaryButton: {
          value: '确定',
          action: () => {}
        }
      });
    } finally {
      this.isSaving = false;
    }
  }

  /**
   * 返回上一页
   */
  private onBackPressed(): void {
    if (this.hasUnsavedChanges()) {
      AlertDialog.show({
        title: '确认退出',
        message: '有未保存的更改，确定要退出吗？',
        primaryButton: {
          value: '取消',
          action: () => {}
        },
        secondaryButton: {
          value: '退出',
          fontColor: this.themeManager.getErrorColor(), // 放弃修改按钮用红色警告
          action: () => {
            router.back();
          }
        }
      });
    } else {
      router.back();
    }
  }

  /**
   * 检查是否有未保存的更改
   */
  private hasUnsavedChanges(): boolean {
    return this.title !== this.memo.title ||
           this.content !== this.memo.content;
  }


  /**
   * 格式化提醒时间
   */
  private formatReminderTime(timestamp: number): string {
    const date = new Date(timestamp);
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const reminderDate = new Date(date.getFullYear(), date.getMonth(), date.getDate());

    const timeStr = `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;

    if (reminderDate.getTime() === today.getTime()) {
      return `今天 ${timeStr}`;
    } else if (reminderDate.getTime() === today.getTime() + 24 * 60 * 60 * 1000) {
      return `明天 ${timeStr}`;
    } else {
      return `${date.getMonth() + 1}/${date.getDate()} ${timeStr}`;
    }
  }
}