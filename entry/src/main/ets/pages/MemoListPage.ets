/**
 * 备忘录列表页面
 */

import { router } from '@kit.ArkUI';
import { MemoItem } from '../model/MemoItem';
import { MemoListViewModel } from '../viewmodel/MemoListViewModel';
import { ThemeManager } from '../utils/ThemeManager';
import { AppConstants, SortType, FilterType } from '../constants/AppConstants';

@Entry
@Component
export struct MemoListPage {
  @State private viewModel: MemoListViewModel = new MemoListViewModel();
  @State private themeManager: ThemeManager = ThemeManager.getInstance();
  @State private showSearchBar: boolean = false;
  @State private searchText: string = '';
  @Prop @Watch('onRefreshTriggered') refreshTrigger: number = 0;

  aboutToAppear(): void {
    this.viewModel.initialize();
  }

  onPageShow(): void {
    // 页面显示时刷新数据
    this.viewModel.refresh();
  }

  onRefreshTriggered(): void {
    // 外部触发刷新
    this.viewModel.refresh();
  }

  /**
   * 格式化列表中的提醒时间显示
   */
  private formatReminderTimeForList(timestamp: number): string {
    const now = new Date();
    const reminderDate = new Date(timestamp);
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const reminderDay = new Date(reminderDate.getFullYear(), reminderDate.getMonth(), reminderDate.getDate());

    const timeStr =
      `${reminderDate.getHours().toString().padStart(2, '0')}:${reminderDate.getMinutes().toString().padStart(2, '0')}`;

    // 计算天数差
    const dayDiff = Math.floor((reminderDay.getTime() - today.getTime()) / (24 * 60 * 60 * 1000));

    if (dayDiff === 0) {
      return `今天 ${timeStr}`;
    } else if (dayDiff === 1) {
      return `明天 ${timeStr}`;
    } else if (dayDiff === 2) {
      return `后天 ${timeStr}`;
    } else if (dayDiff > 2 && dayDiff < 7) {
      const weekDays = ['日', '一', '二', '三', '四', '五', '六'];
      const weekDay = weekDays[reminderDate.getDay()];
      return `周${weekDay} ${timeStr}`;
    } else {
      return `${reminderDate.getMonth() + 1}月${reminderDate.getDate()}日 ${timeStr}`;
    }
  }

  build() {
    Column() {
      // 顶部工具栏
      this.buildToolbar()
      // 搜索栏
      if (this.showSearchBar) {
        this.buildSearchBar()
      }
      // 备忘录列表
      this.buildMemoList()
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
      Text('备忘录')
        .fontSize(this.themeManager.getScaledFontSize(AppConstants.FONT_SIZE.TITLE))
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeManager.getPrimaryTextColor())
      Blank()
      // 搜索按钮
      Button() {
        Image($r('app.media.search'))
          .width(20)
          .height(20)
          .fillColor(this.themeManager.getPrimaryTextColor())
      }
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        this.showSearchBar = !this.showSearchBar;
        if (!this.showSearchBar) {
          this.searchText = '';
          this.viewModel.searchMemos('');
        }
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
   * 构建搜索栏
   */
  @Builder
  buildSearchBar() {
    Row() {
      TextInput({
        placeholder: '搜索备忘录...',
        text: this.searchText
      })
        .layoutWeight(1)
        .height(40)
        .borderRadius(AppConstants.UI.BORDER_RADIUS_MEDIUM)
        .backgroundColor(this.themeManager.getSurfaceColor())
        .onChange((value: string) => {
          this.searchText = value;
          this.viewModel.searchMemos(value);
        })

      Button() {
        Image($r('app.media.clear'))
          .width(16)
          .height(16)
          .fillColor(this.themeManager.getSecondaryTextColor())
      }
      .width(32)
      .height(32)
      .backgroundColor(Color.Transparent)
      .margin({ left: AppConstants.SPACING.SMALL })
      .onClick(() => {
        this.showSearchBar = false;
        this.searchText = '';
        this.viewModel.searchMemos('');
      })
    }
    .width('100%')
    .padding({
      left: AppConstants.SPACING.MEDIUM,
      right: AppConstants.SPACING.MEDIUM,
      bottom: AppConstants.SPACING.SMALL
    })
    .animation({
      duration: AppConstants.ANIMATION.DURATION_NORMAL,
      curve: Curve.EaseInOut
    })
  }

  /**
   * 构建备忘录列表
   */
  @Builder
  buildMemoList() {
    if (this.viewModel.isLoading) {
      // 加载中状态
      Column() {
        LoadingProgress()
          .width(32)
          .height(32)
          .color(this.themeManager.getPrimaryColor())

        Text('加载中...')
          .fontSize(this.themeManager.getScaledFontSize(AppConstants.FONT_SIZE.MEDIUM))
          .fontColor(this.themeManager.getSecondaryTextColor())
          .margin({ top: AppConstants.SPACING.MEDIUM })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else if (this.viewModel.filteredMemoList.length === 0) {
      // 空状态
      Column() {
        Image($r('app.media.ic_empty'))
          .width(120)
          .height(120)
          .opacity(0.6)

        Text('暂无备忘录')
          .fontSize(this.themeManager.getScaledFontSize(AppConstants.FONT_SIZE.LARGE))
          .fontColor(this.themeManager.getSecondaryTextColor())
          .margin({ top: AppConstants.SPACING.LARGE })

        Text('点击右下角按钮添加第一条备忘录')
          .fontSize(this.themeManager.getScaledFontSize(AppConstants.FONT_SIZE.MEDIUM))
          .fontColor(this.themeManager.getSecondaryTextColor())
          .margin({ top: AppConstants.SPACING.SMALL })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      // 备忘录列表
      List() {
        ForEach(this.viewModel.filteredMemoList, (memo: MemoItem, index: number) => {
          ListItem() {
            this.buildMemoCard(memo, index)
          }
          .swipeAction({
            end: this.buildSwipeActions(memo)
          })
          .onClick(() => {
            if (this.viewModel.isSelectionMode) {
              this.viewModel.toggleMemoSelection(memo.id);
            } else {
              this.navigateToMemoDetail(memo);
            }
          })
        }, (memo: MemoItem) => memo.id)
      }
      .layoutWeight(1)
      .width('95%')
      .height('100%')
      .padding({
        top: 8,
        bottom: AppConstants.SPACING.MEDIUM
      })
      .alignSelf(ItemAlign.Center)
    }
  }

  /**
   * 构建备忘录卡片
   */
  @Builder
  buildMemoCard(memo: MemoItem, index: number) {
    Column() {
      Row() {
        // 条件显示选择框 - 只在选择模式下显示
        if (this.viewModel.isSelectionMode) {
          Checkbox({
            name: memo.id, // 使用备忘录ID作为唯一标识
            group: 'memoSelection' // 分组管理选择框
          })
            .select(this.viewModel.selectedMemos.has(memo.id)) // 根据选中状态设置勾选
            .onChange((value: boolean) => {
              // 选择状态改变时通知ViewModel更新选中集合
              this.viewModel.toggleMemoSelection(memo.id);
            })
            .margin({ right: AppConstants.SPACING.SMALL })
        }

        // 主要内容区域
        Column() {
          // 标题行 - 包含标题文本和状态图标
          Row() {
            Text(memo.title || '无标题') // 显示标题，空标题时显示占位文本
              .fontSize(this.themeManager.getScaledFontSize(AppConstants.FONT_SIZE.LARGE))
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeManager.getPrimaryTextColor())
              .maxLines(1) // 限制单行显示
              .textOverflow({ overflow: TextOverflow.Ellipsis }) // 超长文本显示省略号
              .layoutWeight(1) // 占用剩余空间

            // 状态图标组 - 显示星标和完成状态
            Row() {
              if (memo.isStarred) {
                Text('⭐') // 星标图标
                  .fontSize(16)
                  .margin({ left: 4 })
              }
              if (memo.isCompleted) {
                Text('✅') // 完成状态图标
                  .fontSize(16)
                  .margin({ left: 4 })
              }
            }
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)

          // 内容预览（只有在有内容时才显示，并且只显示一行）
          if (memo.content && memo.content.trim()) {
            Text(memo.content)
              .fontSize(13)
              .fontColor(this.themeManager.getSecondaryTextColor())
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ top: 4 })
              .width('100%')
          }

          // 🔥 新增：提醒时间显示（如果有提醒时间）
          if (memo.reminderTime && memo.reminderTime > 0) {
            Row() {
              Image($r('app.media.alarm')) // 提醒闹钟图标
                .width(12)
                .height(12)
                .fillColor(this.themeManager.getPrimaryColor())
                .margin({ right: 4 })

              Text(this.formatReminderTimeForList(memo.reminderTime))
                .fontSize(11)
                .fontColor(this.themeManager.getPrimaryColor())
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .margin({ top: 4 })
            .alignItems(VerticalAlign.Center)
          }


          // 底部信息行 - 显示标签、优先级、功能图标和时间
          Row() {


            // // 功能图标指示器 - 显示备忘录的特殊属性
            // if (memo.reminderTime) {
            //   Image($r('app.media.alarm')) // 提醒闹钟图标
            //     .width(10)
            //     .height(10)
            //     .margin({ right: 4 })
            // }

            Blank() // 弹性空白区域，将时间推到右侧

            // 更新时间 - 显示相对时间格式
            Text(this.formatTime(memo.updateTime))
              .fontSize(11)
              .fontColor(this.themeManager.getSecondaryTextColor())
          }
          .width('100%')
          .margin({ top: 6 })
          .alignItems(VerticalAlign.Center)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ right: 16 })
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .padding({
      left: 16,
      right: 16,
      top: 10,
      bottom: 10
    })
    .backgroundColor(this.themeManager.getSurfaceColor())
    .borderRadius(8)
    .margin({
      bottom: 6
    })
    .shadow({
      radius: 2,
      color: this.themeManager.isDarkMode ? 'rgba(0, 0, 0, 0.15)' : 'rgba(0, 0, 0, 0.04)',
      offsetY: 1
    })
    .animation({
      duration: AppConstants.ANIMATION.DURATION_SHORT,
      curve: Curve.EaseInOut
    })
    .opacity(memo.isCompleted ? 0.7 : 1.0)
  }

  /**
   * 构建滑动操作
   */
  @Builder
  buildSwipeActions(memo: MemoItem) {
    Row() {
      // 星标按钮
      Column() {
        // Image($r('app.media.star'))
        //   .width(22)
        //   .height(22)
        //   .fillColor(Color.White)

        Text(memo.isStarred ? '已星标' : '加星标')
          .fontSize(14)
          .fontColor(Color.White)
          .margin({ top: 2 })
      }
      .width(72)
      .height('60%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(memo.isStarred ? '#FF9500' : '#FFD700')
      .onClick(async () => {
        await this.viewModel.toggleMemoStarred(memo.id);
      })
      .animation({
        duration: 200,
        curve: Curve.EaseInOut
      })

      // 完成按钮
      Column() {
        // Image($r('app.media.finish'))
        //   .width(22)
        //   .height(22)
        //   .fillColor(Color.White)

        Text(memo.isCompleted ? '取消完成' : '标记完成')
          .fontSize(14)
          .fontColor(Color.White)
          .margin({ top: 2 })
      }
      .width(72)
      .height('60%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(memo.isCompleted ? '#34C759' : '#30D158')
      .onClick(async () => {
        await this.viewModel.toggleMemoCompleted(memo.id);
      })
      .animation({
        duration: 200,
        curve: Curve.EaseInOut
      })

      // 删除按钮
      Column() {
        // Image($r('app.media.delete'))
        //   .width(22)
        //   .height(22)
        //   .fillColor(Color.White)

        Text('删除')
          .fontSize(14)
          .fontColor(Color.White)
          .margin({ top: 2 })
      }
      .width(72)
      .height('60%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#FF3B30')
      .onClick(() => {
        this.showDeleteConfirmDialog(memo);
      })
      .animation({
        duration: 200,
        curve: Curve.EaseInOut
      })
    }
    .borderRadius(8)
    .shadow({
      radius: 4,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetY: 2
    })
  }

  /**
   * 格式化时间 - 将时间戳转换为易读的相对时间格式
   */
  private formatTime(timestamp: number): string {
    const now = Date.now(); // 获取当前时间戳
    const diff = now - timestamp; // 计算时间差（毫秒）

    // 定义时间单位常量（毫秒）
    const minute = 60 * 1000; // 1分钟 = 60,000毫秒
    const hour = 60 * minute; // 1小时 = 60分钟
    const day = 24 * hour; // 1天 = 24小时

    // 根据时间差返回不同的格式
    if (diff < minute) {
      // 小于1分钟显示"刚刚"
      return '刚刚';
    } else if (diff < hour) {
      // 小于1小时显示"X分钟前"
      return `${Math.floor(diff / minute)}分钟前`;
    } else if (diff < day) {
      // 小于1天显示"X小时前"
      return `${Math.floor(diff / hour)}小时前`;
    } else if (diff < 7 * day) {
      // 小于7天显示"X天前"
      return `${Math.floor(diff / day)}天前`;
    } else {
      // 超过7天显示具体日期（月/日格式）
      const date = new Date(timestamp);
      return `${date.getMonth() + 1}/${date.getDate()}`; // getMonth()返回0-11，需要+1
    }
  }

  /**
   * 导航到备忘录详情
   */
  private navigateToMemoDetail(memo: MemoItem): void {
    router.pushUrl({
      url: 'pages/MemoDetailPage',
      params: {
        mode: 'edit',
        memoId: memo.id
      }
    }).catch((error: Error) => {
      console.error('Navigate to memo detail failed:', error);
    });
  }

  /**
   * 显示删除确认对话框
   */
  private showDeleteConfirmDialog(memo: MemoItem): void {
    AlertDialog.show({
      title: '确认删除',
      message: `确定要删除备忘录"${memo.title || '无标题'}"吗？`,
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: this.themeManager.getErrorColor(), // 删除确认按钮用红色文字
        action: () => {
          this.viewModel.deleteMemo(memo.id);
        }
      }
    });
  }
}