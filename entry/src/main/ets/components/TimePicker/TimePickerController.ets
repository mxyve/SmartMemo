/**
 * 时间选择器控制器
 * 用于控制时间选择器的显示和回调
 */
export class TimePickerController {
  // 打开对话框的方法
  private openDialogFunc: () => void = () => {
  };
  // 设置回调的方法
  private setCallbacksFunc: (cancel?: () => void, confirm?: (timestamp: number) => void) => void = () => {
  };

  /**
   * 打开时间选择器
   */
  openDialog(): void {
    this.openDialogFunc();
  }

  /**
   * 设置回调函数
   */
  setCallbacks(cancel?: () => void, confirm?: (timestamp: number) => void): void {
    this.setCallbacksFunc(cancel, confirm);
  }

  /**
   * 内部使用：设置打开对话框的函数
   */
  setOpenDialogFunc(func: () => void): void {
    this.openDialogFunc = func;
  }

  /**
   * 内部使用：设置回调函数设置的方法
   */
  setSetCallbacksFunc(func: (cancel?: () => void, confirm?: (timestamp: number) => void) => void): void {
    this.setCallbacksFunc = func;
  }
}