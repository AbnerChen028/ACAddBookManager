# 一个轻量级通讯录管理工具

## 实现功能

* 授权状态查询
* 请求权限
* 获取通讯录内容
* 监听通讯录变化
* 打开系统设置

## 使用方法

1. 在项目`Info.plist` 添加 `Privacy - Contacts Usage Description` 说明
2. 将`ACAddBookManager.h`、`ACAddBookManager.m`文件拖入项目中


## 说明

1. `ACAddBookModel`可以根据自己实际情况定制，目前只处理了姓名和电话
2. 如果需要监听通讯录变化请根据自己实际青款实现`ACAddBookManager.m`中的一下方法：
    
    ```
    // iOS9之前
    void addressBookChanged(ABAddressBookRef addressBook, CFDictionaryRef info, void *context);
    
    // iOS9之后
    addressBookChangediOS9Later:(NSNotification *)notification;
    ```

