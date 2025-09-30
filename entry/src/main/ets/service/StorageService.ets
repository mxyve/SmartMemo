/**
 * 存储服务 - 负责数据的持久化存储
 */

import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { MemoItem, Category } from '../model/MemoItem';
import { AppConstants } from '../constants/AppConstants';

interface ExportData {
  version: string;
  exportTime: number;
  memos: Record<string, Object>[];
  categories: Category[];
}

interface ImportData {
  memos?: Record<string, Object>[];
  categories?: Category[];
}

interface StorageStats {
  memosCount: number;
  categoriesCount: number;
  totalSize: number;
}

// 默认设置对象的接口
interface DefaultSetting {}

type Context = common.UIAbilityContext;

export class StorageService {
  private static instance: StorageService;
  private preferences: preferences.Preferences | null = null;

  private constructor() {
  }

  static getInstance(): StorageService {
    if (!StorageService.instance) {
      StorageService.instance = new StorageService();
    }
    return StorageService.instance;
  }

  /**
   * 初始化存储服务
   */
  async init(context: Context): Promise<void> {
    try {
      this.preferences = await preferences.getPreferences(context, 'SmartMemoPrefs');
    } catch (error) {
      console.error('StorageService init failed:', error);
      throw new Error(String(error));
    }
  }

  /**
   * 保存备忘录列表
   */
  async saveMemos(memos: MemoItem[]): Promise<void> {
    if (!this.preferences) {
      throw new Error('StorageService not initialized');
    }

    try {
      const memosData = memos.map(memo => memo.toJSON());
      await this.preferences.put(AppConstants.STORAGE_KEYS.MEMOS, JSON.stringify(memosData));
      await this.preferences.flush();
    } catch (error) {
      console.error('Save memos failed:', error);
      throw new Error(String(error));
    }
  }

  /**
   * 加载备忘录列表
   */
  async loadMemos(): Promise<MemoItem[]> {
    if (!this.preferences) {
      throw new Error('StorageService not initialized');
    }

    try {
      const memosStr = await this.preferences.get(AppConstants.STORAGE_KEYS.MEMOS, '[]') as string;
      const memosData = JSON.parse(memosStr) as Record<string, Object>[];
      return memosData.map((data: Record<string, Object>) => MemoItem.fromJSON(data));
    } catch (error) {
      console.error('Load memos failed:', error);
      return [];
    }
  }

  /**
   * 保存单个备忘录
   */
  async saveMemo(memo: MemoItem): Promise<void> {
    const memos = await this.loadMemos();
    const index = memos.findIndex(m => m.id === memo.id);

    if (index >= 0) {
      memos[index] = memo;
    } else {
      memos.push(memo);
    }

    await this.saveMemos(memos);
  }

  /**
   * 删除备忘录
   */
  async deleteMemo(memoId: string): Promise<void> {
    const memos = await this.loadMemos();
    const filteredMemos = memos.filter(memo => memo.id !== memoId);
    await this.saveMemos(filteredMemos);
  }

  /**
   * 保存分类列表
   */
  async saveCategories(categories: Category[]): Promise<void> {
    if (!this.preferences) {
      throw new Error('StorageService not initialized');
    }

    try {
      await this.preferences.put(AppConstants.STORAGE_KEYS.CATEGORIES, JSON.stringify(categories));
      await this.preferences.flush();
    } catch (error) {
      console.error('Save categories failed:', error);
      throw new Error(String(error));
    }
  }

  /**
   * 加载分类列表
   */
  async loadCategories(): Promise<Category[]> {
    if (!this.preferences) {
      throw new Error('StorageService not initialized');
    }

    try {
      const categoriesStr = await this.preferences.get(AppConstants.STORAGE_KEYS.CATEGORIES, '[]') as string;
      return JSON.parse(categoriesStr);
    } catch (error) {
      console.error('Load categories failed:', error);
      return [];
    }
  }

  /**
   * 保存应用设置
   */
  async saveSetting(key: string, value: Object): Promise<void> {
    if (!this.preferences) {
      throw new Error('StorageService not initialized');
    }

    try {
      await this.preferences.put(key, JSON.stringify(value));
      await this.preferences.flush();
    } catch (error) {
      console.error('Save setting failed:', error);
      throw new Error(String(error));
    }
  }

  /**
   * 加载应用设置
   */
  async loadSetting(key: string, defaultValue: Object = {} as DefaultSetting): Promise<Object> {
    if (!this.preferences) {
      throw new Error('StorageService not initialized');
    }

    try {
      const valueStr = await this.preferences.get(key, JSON.stringify(defaultValue)) as string;
      return JSON.parse(valueStr);
    } catch (error) {
      console.error('Load setting failed:', error);
      return defaultValue;
    }
  }

  /**
   * 清除所有数据
   */
  async clearAllData(): Promise<void> {
    if (!this.preferences) {
      throw new Error('StorageService not initialized');
    }

    try {
      await this.preferences.clear();
      await this.preferences.flush();
    } catch (error) {
      console.error('Clear all data failed:', error);
      throw new Error(String(error));
    }
  }

  /**
   * 导出数据
   */
  async exportData(): Promise<string> {
    // 加载所有备忘录和分类数据
    const memos = await this.loadMemos();
    const categories = await this.loadCategories();

    // 构建导出数据结构，包含版本信息和时间戳
    const exportData: ExportData = {
      version: '1.0.0', // 数据格式版本，用于向后兼容
      exportTime: Date.now(), // 导出时间戳，方便用户识别导出文件
      memos: memos.map(memo => memo.toJSON()), // 将备忘录对象转换为JSON格式
      categories: categories // 分类数据直接使用，已经是JSON格式
    };

    // 返回格式化的JSON字符串，使用2个空格缩进提高可读性
    return JSON.stringify(exportData, null, 2);
  }

  /**
   * 导入数据
   */
  async importData(dataStr: string): Promise<void> {
    try {
      // 解析JSON字符串为导入数据对象
      const importData = JSON.parse(dataStr) as ImportData;

      // 处理备忘录数据导入
      if (importData.memos) {
        // 将JSON数据转换为MemoItem对象数组
        const memos = importData.memos.map((data: Record<string, Object>) => MemoItem.fromJSON(data));
        // 保存到本地存储，会覆盖现有数据
        await this.saveMemos(memos);
      }

      // 处理分类数据导入
      if (importData.categories) {
        // 直接保存分类数据，会覆盖现有分类
        await this.saveCategories(importData.categories);
      }
    } catch (error) {
      console.error('Import data failed:', error);
      // 重新抛出错误，让调用方处理
      throw new Error(String(error));
    }
  }

  /**
   * 获取存储统计信息
   */
  async getStorageStats(): Promise<StorageStats> {
    const memos = await this.loadMemos();
    const categories = await this.loadCategories();

    const memosSize = JSON.stringify(memos).length;
    const categoriesSize = JSON.stringify(categories).length;

    return {
      memosCount: memos.length,
      categoriesCount: categories.length,
      totalSize: memosSize + categoriesSize
    };
  }
}