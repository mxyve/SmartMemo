/**
 * 备忘录数据模型
 */

export interface Category {
  id: string;
  name: string;
  color: string;
  icon?: string;
  createTime: number;
}

interface MemoItemJSON {
  id: string;
  title: string;
  content: string;
  createTime: number;
  updateTime: number;
  reminderTime?: number;
  isCompleted: boolean;
  isStarred: boolean;
}


@Observed
export class MemoItem {
  @Track id: string = '';
  @Track title: string = '';
  @Track content: string = '';
  @Track createTime: number = 0;
  @Track updateTime: number = 0;
  @Track reminderTime?: number;
  @Track isCompleted: boolean = false;
  @Track isStarred: boolean = false;

  constructor(data?: Partial<MemoItem>) {
    if (data) {
      this.id = data.id || this.generateId();
      this.title = data.title || '';
      this.content = data.content || '';
      this.createTime = data.createTime || Date.now();
      this.updateTime = data.updateTime || Date.now();
      this.reminderTime = data.reminderTime;
      this.isCompleted = data.isCompleted || false;
      this.isStarred = data.isStarred || false;
    } else {
      this.id = this.generateId();
      this.createTime = Date.now();
      this.updateTime = Date.now();
    }
  }

  /**
   * 生成唯一的备忘录ID
   * 使用时间戳和随机字符串组合确保唯一性
   */
  private generateId(): string {
    return `memo_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  updateTimeStamp(): void {
    this.updateTime = Date.now();
  }


  toggleCompleted(): void {
    this.isCompleted = !this.isCompleted;
    this.updateTimeStamp();
  }

  toggleStarred(): void {
    this.isStarred = !this.isStarred;
    this.updateTimeStamp();
  }

  setReminder(timestamp: number): void {
    this.reminderTime = timestamp;
    this.updateTimeStamp();
  }

  clearReminder(): void {
    this.reminderTime = undefined;
    this.updateTimeStamp();
  }


  toJSON(): Record<string, Object> {
    // 使用辅助函数创建 Record 对象，避免直接使用对象字面量
    // 这样做是为了确保类型安全和避免编译器报错
    const createRecord = (): Record<string, Object> => {
      const record: Record<string, Object> = {} as Record<string, Object>;
      return record;
    };

    const jsonResult = createRecord();

    // 设置基础属性 - 这些属性始终存在，直接赋值
    jsonResult.id = this.id;
    jsonResult.title = this.title;
    jsonResult.content = this.content;
    jsonResult.createTime = this.createTime; // 时间戳，创建时设置
    jsonResult.updateTime = this.updateTime; // 时间戳，每次更新时修改
    jsonResult.isCompleted = this.isCompleted; // 布尔值，表示完成状态
    jsonResult.isStarred = this.isStarred; // 布尔值，表示收藏状态

    // 添加可选属性 - 只有在值存在时才添加到JSON中
    // 这样可以减少存储空间并保持JSON结构的简洁
    if (this.reminderTime !== undefined) {
      jsonResult.reminderTime = this.reminderTime; // 提醒时间戳
    }

    return jsonResult;
  }

  static fromJSON(data: Record<string, Object>): MemoItem {
    return new MemoItem(data as Partial<MemoItem>);
  }
}