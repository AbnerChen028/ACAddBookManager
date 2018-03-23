//
//  ViewController.m
//  ADBookDemo
//
//  Created by ChenWei on 2018/3/23.
//  Copyright © 2018年 QiaoData. All rights reserved.
//

#import "ViewController.h"
#import "ACAddBookManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (IBAction)getAuthStatus:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    [ACAddBookManager getAuthStatusWithHandle:^(ACAddBookAuthStatus status) {
        
        [weakSelf alertWithStatus:status];
    }];
}

- (IBAction)requestAuth:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    [ACAddBookManager requestAuthWithHandle:^(ACAddBookAuthStatus status) {
       
        [weakSelf alertWithStatus:status];
    }];
}
- (IBAction)getAddBook:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    [ACAddBookManager getAdBooksWithHandle:^(ACAddBookAuthStatus status, NSArray<ACAddBookModel *> *adds) {
       
        [weakSelf alertWithStatus:status];
        
        if (status == ACAddBookAuthStatusAuthorized) {
            
            NSLog(@"%@", adds);
        }
    }];
}
- (IBAction)openSystem:(id)sender {
    
    [ACAddBookManager applyOpenSystmeConfig];
}


- (void)alertWithStatus:(ACAddBookAuthStatus)status{
    
    NSString *tip = @"";
    switch (status) {
        case ACAddBookAuthStatusNotDetermined:
            tip = @"默认状态";
            break;
        case ACAddBookAuthStatusRestricted:
            tip = @"无法修改的拒绝";
            break;
        case ACAddBookAuthStatusDenied:
            tip = @"被拒绝";
            break;
        case ACAddBookAuthStatusAuthorized:
            tip = @"已授权";
            break;
            
        default:
            break;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:tip   preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *done = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:done];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
