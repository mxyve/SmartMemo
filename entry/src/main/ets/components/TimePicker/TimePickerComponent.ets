/**
 * 时间选择器封装组件
 */

import { TimePickerController } from './TimePickerController';
import { TimePickerDialog } from './TimePickerDialog';

@Component
export struct TimePickerComponent {
  // 🔥 使用 @Link 绑定控制器
  @Link controller: TimePickerController;

  // 对话框控制器
  private dialogController: CustomDialogController | null = null;

  // 回调函数
  private onCancel?: () => void;
  private onConfirm?: (timestamp: number) => void;

  aboutToAppear(): void {
    // 初始化对话框
    this.initDialogController();

    // 将控制器的方法绑定到本组件
    this.controller.setOpenDialogFunc(this.openDialog.bind(this));
    this.controller.setSetCallbacksFunc(this.setCallbacks.bind(this));
  }

  aboutToDisappear(): void {
    this.dialogController = null;
  }

  /**
   * 初始化对话框控制器
   */
  private initDialogController(): void {
    this.dialogController = new CustomDialogController({
      builder: TimePickerDialog({
        cancel: () => {
          this.onCancel?.();
        },
        confirm: (timestamp: number) => {
          this.onConfirm?.(timestamp);
        }
      }),
      autoCancel: true,
      alignment: DialogAlignment.Bottom,
      offset: { dx: 0, dy: -20 },
      customStyle: true
    });
  }

  /**
   * 打开时间选择器
   */
  private openDialog(): void {
    console.log('TimePickerComponent: 打开时间选择器对话框');
    this.dialogController?.open();
  }

  /**
   * 设置回调函数
   */
  private setCallbacks(cancel?: () => void, confirm?: (timestamp: number) => void): void {
    this.onCancel = cancel;
    this.onConfirm = confirm;
  }

  build() {
    // 空实现，通过控制器操作
  }
}