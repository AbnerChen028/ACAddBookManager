//
//  ACAddBookManager.m
//  ADBookDemo
//
//  Created by ChenWei on 2018/3/23.
//  Copyright © 2018年 QiaoData. All rights reserved.
//

#import "ACAddBookManager.h"

@interface ACAddBookManager ()

@property (nonatomic, strong) CNContactStore *contactStore NS_ENUM_AVAILABLE(10_11, 9_0);
@property (nonatomic) ABAddressBookRef addressBook;

@end

@implementation ACAddBookManager

#pragma mark - singletion
static ACAddBookManager *_instance;

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _instance;
}


#pragma mark - layzz
#ifdef __IPHONE_9_0
- (CNContactStore *)contactStore{
    if(!_contactStore){
        
        _contactStore = [[CNContactStore alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressBookChangediOS9Later:) name:CNContactStoreDidChangeNotification object:nil];
    }
    return _contactStore;
}
#endif

- (ABAddressBookRef)addressBook{
    if (!_addressBook) {
        _addressBook = ABAddressBookCreate();
        
        // 通讯录监听
        ABAddressBookRegisterExternalChangeCallback(_addressBook, addressBookChanged, (__bridge void *)(self));
    }
    return _addressBook;
}


#pragma mark - action
void addressBookChanged(ABAddressBookRef addressBook, CFDictionaryRef info, void *context){
    
    NSLog(@"info - %@", info);
    NSLog(@"info - %@", addressBook);
    NSLog(@"info - %@", context);
}

#ifdef __IPHONE_9_0
- (void)addressBookChangediOS9Later:(NSNotification *)notification{
    
    NSLog(@"%@", notification);
}
#endif

#pragma mark - public
+ (void)getAuthStatusWithHandle:(ACAdBookAuthStatusHandle)authHandle{
    
    if (@available(iOS 9.0, *)) {
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        
        switch (status) {
            case CNAuthorizationStatusNotDetermined:
                authHandle(ACAddBookAuthStatusNotDetermined);
                break;
            case CNAuthorizationStatusRestricted:
                authHandle(ACAddBookAuthStatusRestricted);
                break;
            case CNAuthorizationStatusDenied:
                authHandle(ACAddBookAuthStatusDenied);
                break;
            case CNAuthorizationStatusAuthorized:
                authHandle(ACAddBookAuthStatusAuthorized);
                break;
                
            default:
                break;
        }
    }else{
        
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        switch (status) {
            case kABAuthorizationStatusNotDetermined:
                authHandle(ACAddBookAuthStatusNotDetermined);
                break;
            case kABAuthorizationStatusRestricted:
                authHandle(ACAddBookAuthStatusRestricted);
                break;
            case kABAuthorizationStatusDenied:
                authHandle(ACAddBookAuthStatusDenied);
                break;
            case kABAuthorizationStatusAuthorized:
                authHandle(ACAddBookAuthStatusAuthorized);
                break;
            default:
                break;
        }
    }
}

/// 申请权限
+ (void)requestAuthWithHandle:(ACAdBookAuthStatusHandle)authHandle{
    
    [self getAuthStatusWithHandle:^(ACAddBookAuthStatus status) {
        
        // 默认状态需要请求
        if (status == ACAddBookAuthStatusNotDetermined) {
            
            if (@available(iOS 9.0, *)) {
                
                [[ACAddBookManager shareManager].contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                    if (granted) {
                        authHandle(ACAddBookAuthStatusAuthorized);
                    }else{
                        authHandle(ACAddBookAuthStatusDenied);
                    }
                }];
            }else{
                
                ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
                ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                    if (granted) {
                        authHandle(ACAddBookAuthStatusAuthorized);
                    }else{
                        authHandle(ACAddBookAuthStatusDenied);
                    }
                });
            }
            return;
        }
        
        // 直接返回状态
        authHandle(status);
    }];
}

/// 获取通讯录内容
+ (void)getAdBooksWithHandle:(ACAdBookHandle)booksHandle{
    
    [self getAuthStatusWithHandle:^(ACAddBookAuthStatus status) {
        
        // 如果被拒绝状态
        if (status == ACAddBookAuthStatusRestricted || status == ACAddBookAuthStatusDenied) {
            booksHandle(status, nil);
            return;
        }
        
        // 未授权状态
        if (status == ACAddBookAuthStatusNotDetermined) {
            [self requestAuthWithHandle:^(ACAddBookAuthStatus status) {
                
                if (status == ACAddBookAuthStatusAuthorized) {
                    NSArray *books = [[ACAddBookManager shareManager] getbooks];
                    booksHandle(status, books);
                }else{
                    booksHandle(status, nil);
                }
            }];
            return;
        }
        
        // 已经授权
        NSArray *allBooks = [[ACAddBookManager shareManager] getbooks];
        booksHandle(status, allBooks);
    }];
}

+ (void)applyOpenSystmeConfig{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

#pragma mark - private

/// 获取当前通讯录内容
- (NSArray *)getbooks{
    
    if (@available(iOS 9.0, *)) {
        
        return [self getBooksWithOS9Later];
    }else{
        
        return [self getBooksWithBeforeOS9];
    }
}

/// iOS9之后的获取方法
- (NSArray *)getBooksWithOS9Later{
    
    if (@available(iOS 9.0, *)) {
        
        NSArray *fetchKeys = @[[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName],CNContactPhoneNumbersKey,CNContactThumbnailImageDataKey];
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:fetchKeys];
        
        // 3.3.请求联系人
        
        NSMutableArray *contacts = [NSMutableArray array];
        __weak typeof(contacts) weakContacts = contacts;
        [self.contactStore enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact,BOOL * _Nonnull stop) {
            
            ACAddBookModel *model = [ACAddBookModel bookModelWithContact:contact];
            [weakContacts addObject:model];
        }];
        
        return contacts;
    }
    return nil;
}

/// iOS9之前的获取方法
- (NSArray *)getBooksWithBeforeOS9{
    
    CFArrayRef contants = ABAddressBookCopyArrayOfAllPeople(self.addressBook);
    
    //存放所有联系人的数组
    NSMutableArray <ACAddBookModel *> * contacts = [NSMutableArray arrayWithCapacity:0];
    
    //遍历获取所有的数据
    for (NSInteger i = 0; i < CFArrayGetCount(contants); i++){
        
        // 获得People对象
        ABRecordRef recordRef = CFArrayGetValueAtIndex(contants, i);
        ACAddBookModel * contactObject = [ACAddBookModel bookModelWithRecordRef:recordRef];
        [contacts addObject:contactObject];
        
        CFRelease(recordRef);
    }
    
    CFRelease(contants);
    
    return contacts;
}

@end

# pragma mark - Model
@implementation ACAddBookModel

- (NSMutableArray *)mobileArray{
    
    if (!_mobileArray) {
        _mobileArray = [NSMutableArray array];
    }
    return _mobileArray;
}

+ (instancetype)bookModelWithRecordRef:(ABRecordRef)ref{
    
    ACAddBookModel *model = [[self  alloc] init];
    
    // 获取ID
    NSString *Id = [NSString stringWithFormat:@"%@",@(ABRecordGetRecordID(ref))];
    model.Id = Id;
    
    // 获取全名
    NSString *name = (__bridge_transfer NSString *)ABRecordCopyCompositeName(ref);
    if (!name) {
        name = @"";
    }
    
    // 获取头像数据
    //    NSData *imageData = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(ref, kABPersonImageFormatThumbnail);
    //    model.headerImage = [UIImage imageWithData:imageData];
    
    // 获取所有的电话号码
    ABMultiValueRef phones = ABRecordCopyValue(ref, kABPersonPhoneProperty);
    CFIndex phoneCount = ABMultiValueGetCount(phones);
    
    for (CFIndex i = 0; i < phoneCount; i++){
        
        // 号码
        NSString *phoneValue = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, i);
        NSString *mobile = phoneValue;
        
        [model.mobileArray addObject: mobile ? mobile : @"空号"];
    }
    
    CFRelease(phones);
    return model;
}

+ (instancetype)bookModelWithContact:(CNContact *)contact NS_ENUM_AVAILABLE(10_11, 9_0){
    
    ACAddBookModel *model = [[self  alloc] init];
    // 获取联系人全名
    NSString *name = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
    if (!name) {
        name = @"";
    }
    model.name = name;
    
    // 联系人头像
    //    model.headerImage = [UIImage imageWithData:contact.thumbnailImageData];
    
    // 获取一个人的所有电话号码
    NSArray *phones = contact.phoneNumbers;
    
    //联系人id
    model.Id = contact.identifier;
    
    for (CNLabeledValue *labelValue in phones){
        
        CNPhoneNumber *phoneNumber = labelValue.value;
        NSString *mobile = phoneNumber.stringValue;
        [model.mobileArray addObject: mobile];
    }
    return model;
}

@end
