/**
 * 时间选择器对话框组件
 */

// 🔥 新增：日期对象接口
interface DateObject {
  year: number;
  month: number;
  day: number;
}

@CustomDialog
export struct TimePickerDialog {
  controller?: CustomDialogController;
  // 时间数据
  @State dateList: string[] = this.generateDateList();
  @State hourList: string[] = this.generateHourList();
  @State minuteList: string[] = this.generateMinuteList();
  // 选中的值
  @State selectedDate: string = '';
  @State selectedHour: string = '';
  @State selectedMinute: string = '';
  // 回调函数
  cancel: () => void = () => {
  };
  confirm: (timestamp: number) => void = () => {
  };

  aboutToAppear(): void {
    // 设置默认选中当前时间
    const now = new Date();
    this.selectedDate = this.dateList[0]; // 默认选中第一个日期（今天）
    this.selectedHour = now.getHours().toString().padStart(2, '0');
    this.selectedMinute = now.getMinutes().toString().padStart(2, '0');
  }

  build() {
    Column() {
      // 标题
      Row() {
        Text('设置提醒时间')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#182431')
      }
      .padding({ bottom: 25 })
      .width('100%')
      .justifyContent(FlexAlign.Center)

      // 时间选择区域
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        // 日期选择
        Column() {
          Text('日期')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ bottom: 8 })

          TextPicker({ range: this.dateList })
            .width(140)
            .height(150)
            .onChange((value: string | string[]) => {
              if (typeof value === 'string') {
                this.selectedDate = value;
              }
            })
        }

        // 小时选择
        Column() {
          Text('时')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ bottom: 8 })

          TextPicker({ range: this.hourList })
            .width(80)
            .height(150)
            .onChange((value: string | string[]) => {
              if (typeof value === 'string') {
                this.selectedHour = value;
              }
            })
        }

        // 分钟选择
        Column() {
          Text('分')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ bottom: 8 })

          TextPicker({ range: this.minuteList })
            .width(80)
            .height(150)
            .onChange((value: string | string[]) => {
              if (typeof value === 'string') {
                this.selectedMinute = value;
              }
            })
        }
      }
      .width('100%')
      .padding({ left: 10, right: 10 })

      // 当前选择的时间显示
      Row() {
        Text(`选择的时间: ${this.getSelectedDateDisplay()}`)
          .fontSize(14)
          .fontColor('#1976D2')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 20 })

      // 按钮区域
      Row() {
        Button('取消', { type: ButtonType.Normal, stateEffect: true })
          .margin({ right: 12 })
          .borderRadius(8)
          .backgroundColor('#F5F5F5')
          .fontColor('#666666')
          .borderWidth(0)
          .fontSize(16)
          .layoutWeight(1)
          .height(44)
          .onClick(() => {
            this.controller?.close();
            this.cancel();
          })

        Button('确定', { type: ButtonType.Normal, stateEffect: true })
          .margin({ left: 12 })
          .borderRadius(8)
          .fontSize(16)
          .backgroundColor('#1976D2')
          .fontColor(Color.White)
          .layoutWeight(1)
          .height(44)
          .onClick(() => {
            const timestamp = this.getSelectedTimestamp();
            if (timestamp > 0) {
              this.confirm(timestamp);
              this.controller?.close();
            } else {
              // 时间解析失败处理
              console.error('时间解析失败');
            }
          })
      }
      .justifyContent(FlexAlign.Center)
      .padding({ top: 25 })
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
  }

  /**
   * 生成日期列表（未来30天，带中文显示）
   */
  private generateDateList(): string[] {
    const dates: string[] = [];
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());

    const weekDays = ['日', '一', '二', '三', '四', '五', '六'];

    for (let i = 0; i < 30; i++) {
      const date = new Date(today);
      date.setDate(today.getDate() + i);

      const month = date.getMonth() + 1;
      const day = date.getDate();
      const weekDay = weekDays[date.getDay()];

      let displayText = '';
      if (i === 0) {
        displayText = `今天 (${month}月${day}日 周${weekDay})`;
      } else if (i === 1) {
        displayText = `明天 (${month}月${day}日 周${weekDay})`;
      } else if (i === 2) {
        displayText = `后天 (${month}月${day}日 周${weekDay})`;
      } else {
        displayText = `${month}月${day}日 周${weekDay}`;
      }

      dates.push(displayText);
    }

    return dates;
  }

  /**
   * 生成小时列表（00-23）
   */
  private generateHourList(): string[] {
    const hours: string[] = [];
    for (let i = 0; i < 24; i++) {
      hours.push(i.toString().padStart(2, '0'));
    }
    return hours;
  }

  /**
   * 生成分钟列表（00-59，间隔5分钟）
   */
  private generateMinuteList(): string[] {
    const minutes: string[] = [];
    for (let i = 0; i < 60; i += 5) {
      minutes.push(i.toString().padStart(2, '0'));
    }
    return minutes;
  }

  /**
   * 获取选中的时间显示字符串
   */
  private getSelectedDateDisplay(): string {
    try {
      const dateObj: DateObject | null = this.parseChineseDate(this.selectedDate);
      const hour = this.selectedHour;
      const minute = this.selectedMinute;

      if (dateObj && hour && minute) {
        return `${dateObj.month}月${dateObj.day}日 ${hour}:${minute}`;
      }
    } catch (error) {
      console.error('时间显示格式化错误:', error);
    }

    return '请选择时间';
  }

  /**
   * 获取选中的时间戳
   */
  private getSelectedTimestamp(): number {
    try {
      // 解析选中的中文日期
      const dateObj: DateObject | null = this.parseChineseDate(this.selectedDate);
      const hour = Number(this.selectedHour);
      const minute = Number(this.selectedMinute);

      if (dateObj && !isNaN(hour) && !isNaN(minute)) {
        const selectedDateTime = new Date(dateObj.year, dateObj.month - 1, dateObj.day, hour, minute);

        // 检查时间是否在未来
        const now = new Date();
        if (selectedDateTime.getTime() > now.getTime()) {
          return selectedDateTime.getTime();
        } else {
          console.warn('选择的时间不能是过去时间');
          return -1; // 返回-1表示时间无效
        }
      }
    } catch (error) {
      console.error('时间解析错误:', error);
    }

    return -1; // 返回-1表示解析失败
  }

  /**
   * 解析中文日期字符串
   */
  private parseChineseDate(dateStr: string): DateObject | null {
    const now = new Date();
    const currentYear = now.getFullYear();

    if (!dateStr) {
      // 如果没有选择日期，返回今天
      return this.createDateObject(currentYear, now.getMonth() + 1, now.getDate());
    }

    // 匹配 "X月X日" 格式
    const match = dateStr.match(/(\d+)月(\d+)日/);
    if (match) {
      const month = Number(match[1]);
      const day = Number(match[2]);
      return this.createDateObject(currentYear, month, day);
    }

    // 如果是今天、明天、后天
    const today = new Date();
    if (dateStr.includes('今天')) {
      return this.createDateObject(
        today.getFullYear(),
        today.getMonth() + 1,
        today.getDate()
      );
    } else if (dateStr.includes('明天')) {
      const tomorrow = new Date(today);
      tomorrow.setDate(today.getDate() + 1);
      return this.createDateObject(
        tomorrow.getFullYear(),
        tomorrow.getMonth() + 1,
        tomorrow.getDate()
      );
    } else if (dateStr.includes('后天')) {
      const dayAfterTomorrow = new Date(today);
      dayAfterTomorrow.setDate(today.getDate() + 2);
      return this.createDateObject(
        dayAfterTomorrow.getFullYear(),
        dayAfterTomorrow.getMonth() + 1,
        dayAfterTomorrow.getDate()
      );
    }

    // 默认返回今天
    console.warn('无法解析日期字符串，使用今天作为默认值:', dateStr);
    return this.createDateObject(
      today.getFullYear(),
      today.getMonth() + 1,
      today.getDate()
    );
  }

  /**
   * 🔥 新增：创建日期对象的方法
   */
  private createDateObject(year: number, month: number, day: number): DateObject {
    return {
      year: year,
      month: month,
      day: day
    };
  }

  /**
   * 格式化日期为 YYYY-MM-DD（备用方法）
   */
  private formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  /**
   * 获取选中的时间字符串（原始方法，保持兼容）
   */
  private getSelectedDateString(): string {
    return `${this.selectedDate} ${this.selectedHour}:${this.selectedMinute}`;
  }
}