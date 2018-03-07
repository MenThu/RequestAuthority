//
//  SecondController.m
//  RequestAuthority
//
//  Created by MenThu on 2018/3/6.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import "SecondController.h"
#import "LocationManager.h"

@interface SecondController () <LocationManagerDelegate>

@end

@implementation SecondController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[LocationManager sharedInstance] addDelegate:self];
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
    [[LocationManager sharedInstance] logDelegateArray];
}

@end
