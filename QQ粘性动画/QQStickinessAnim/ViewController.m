//
//  ViewController.m
//  QQStickinessAnim
//
//  Created by 郑亚伟 on 2016/12/27.
//  Copyright © 2016年 郑亚伟. All rights reserved.
//

#import "ViewController.h"
#import "ZWBadgeValue.h"
@interface ViewController ()
@property(nonatomic,strong)ZWBadgeValue *badgeValue;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _badgeValue = [[ZWBadgeValue alloc]initWithFrame:CGRectMake(100, 100, 20, 20) withSuperView:self.view];
    [_badgeValue setTitle:@"5" forState:UIControlStateNormal];
    [self.view addSubview:self.badgeValue];
    [_badgeValue addTarget:self action:@selector(badgeValueBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)badgeValueBtnClick:(UIButton *)badgeValueBtn{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"你点击了QQ粘性按钮" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:action1];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}


@end
