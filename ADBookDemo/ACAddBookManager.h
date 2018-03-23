//
//  ACAddBookManager.h
//  ADBookDemo
//
//  Created by ChenWei on 2018/3/23.
//  Copyright © 2018年 QiaoData. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef __IPHONE_9_0
#import <Contacts/Contacts.h>
#endif
#import <AddressBook/AddressBook.h>
@class ACAddBookModel;


#pragma mark 宏定义

typedef NS_ENUM(NSInteger, ACAddBookAuthStatus){
    
    /// 默认状态 还没确认
    ACAddBookAuthStatusNotDetermined = 0,
    /// 被拒绝状态 用户不可修改的
    ACAddBookAuthStatusRestricted,
    /// 被拒绝
    ACAddBookAuthStatusDenied,
    /// 已经授权
    ACAddBookAuthStatusAuthorized
};

/// 授权状态回调
typedef void(^ACAdBookAuthStatusHandle)(ACAddBookAuthStatus status);

/**
 获取通讯录内容回调
 
 @param status 当前授权状态
 @param adds  通讯录内容
 */
typedef void(^ACAdBookHandle)(ACAddBookAuthStatus status, NSArray<ACAddBookModel *> *adds);

#pragma mark - ACAddBookManager

@interface ACAddBookManager : NSObject

+ (instancetype)shareManager;

/// 查询授权状态
+ (void)getAuthStatusWithHandle:(ACAdBookAuthStatusHandle)authHandle;

/// 申请权限
+ (void)requestAuthWithHandle:(ACAdBookAuthStatusHandle)authHandle;

/// 获取通讯录内容
+ (void)getAdBooksWithHandle:(ACAdBookHandle)booksHandle;

/// 打开系统设置页面
+ (void)applyOpenSystmeConfig;

@end

#pragma mark - Model

@interface ACAddBookModel : NSObject

///联系人id iOS9之前是1、2、3的形式，iOS9之后类似uuid
@property (nonatomic, copy) NSString *Id;
/// 联系人姓名
@property (nonatomic, copy) NSString *name;
/// 电话号码数组
@property (nonatomic, strong) NSMutableArray *mobileArray;


/// iOS9之前创建model
+ (instancetype)bookModelWithRecordRef:(ABRecordRef)ref;

/// iOS9之后创建model
+ (instancetype)bookModelWithContact:(CNContact *)ref NS_ENUM_AVAILABLE(10_11, 9_0);

@end
