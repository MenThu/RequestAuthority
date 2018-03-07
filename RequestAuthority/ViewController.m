//
//  ViewController.m
//  RequestAuthority
//
//  Created by MenThu on 2018/1/8.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import "ViewController.h"
#import "LocationManager.h"
#import "AuthorityScheme.h"
#import "NotificationManager.h"

typedef NS_OPTIONS(NSUInteger, TestType) {
    TestTypeOne    = 0,      // the application may not present any UI upon a notification being received
    TestTypeTwo   = 1 << 0, // the application may badge its icon upon a notification being received
    TestTypeThree   = 1 << 1, // the application may play a sound upon a notification being received
    TestTypeFour   = 1 << 2, // the application may display an alert upon a notification being received
};

@interface ViewController () <LocationManagerDelegate, NotificationManagerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self locationTest];
}

- (void)notificationTest{
    [[NotificationManager sharedInstance] addDelegate:self];
    [[NotificationManager sharedInstance] getNotificationType:^(NotificationType type) {
        switch (type) {
            case NotificationTypeNotInquiry:
            {
                [[NotificationManager sharedInstance] registerNotification:^(BOOL isUserGranted) {
                    NSLog(@"用户=[%@]", isUserGranted ? @"授权了" : @"拒绝了");
                }];
            }
                break;
            case NotificationTypeOff:
            {
                [AuthorityScheme openSetting];
            }
                break;
            case NotificationTypeOn:
            {
                NSLog(@"通知允许了");
            }
                break;
                
            default:
                break;
        }
    }];
}

- (void)notificationTypeDidChange:(NotificationType)type{
    switch (type) {
        case NotificationTypeNotInquiry:
        {
            NSLog(@"尚未询问用户");
        }
            break;
        case NotificationTypeOff:
        {
            NSLog(@"用户拒绝了");
            UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [AuthorityScheme openSetting];
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertController *alterController = [UIAlertController alertControllerWithTitle:@"通知尚未开启" message:@"请打开" preferredStyle:UIAlertControllerStyleAlert];
            [alterController addAction:confirm];
            [alterController addAction:cancel];
            [self presentViewController:alterController animated:NO completion:nil];
        }
            break;
        case NotificationTypeOn:
        {
            NSLog(@"通知允许了");
        }
            break;
            
        default:
            break;
    }
}


- (void)locationTest{
    __weak typeof(self) weakSelf = self;
    [[LocationManager sharedInstance] addDelegate:self];
    
    [[LocationManager sharedInstance] getLocationType:^(LocationType currentType) {
        switch (currentType) {
            case LocationTypeNotEnable:
            {
                NSLog(@"用户没有开启定位功能");
            }
                break;
            case LocationTypeDenied:
            {
                NSLog(@"用户拒绝了定位功能");
                UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [AuthorityScheme openSetting];
                }];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                UIAlertController *alterController = [UIAlertController alertControllerWithTitle:@"定位尚未开启" message:@"请打开" preferredStyle:UIAlertControllerStyleAlert];
                [alterController addAction:confirm];
                [alterController addAction:cancel];
                [self presentViewController:alterController animated:NO completion:nil];
            }
                break;
            case LocationTypeAllowWhenInUse:
            {
                NSLog(@"前台定位功能");
            }
                break;
            case LocationTypeAllowAlways:
            {
                NSLog(@"总是拥有定位功能");
            }
                break;
                
            default:
                break;
        }
    }];
}

- (void)locationTypeDidChange:(LocationType)currentType{
    switch (currentType) {
        case LocationTypeNotEnable:
            NSLog(@"用户尚未开始定位服务");
            break;
        case LocationTypeNotInquiry:
            NSLog(@"尚未询问");
            break;
        case LocationTypeDenied:
            NSLog(@"拒绝定位权限");
            break;
        case LocationTypeAllowWhenInUse:
            NSLog(@"允许应用前台定位");
            break;
        case LocationTypeAllowAlways:
            NSLog(@"前台后台");
            break;
            
        default:
            break;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
