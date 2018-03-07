//
//  AuthorityScheme.m
//  RequestAuthority
//
//  Created by MenThu on 2018/1/8.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import "AuthorityScheme.h"
#import <UIKit/UIApplication.h>

@implementation AuthorityScheme

+ (void)openSetting{
    CGFloat systemVersionValue = [UIDevice currentDevice].systemVersion.floatValue;
    if (systemVersionValue < 10) {
        [self openSettingServiceBlow10];
    }else{
        [self openSettingServiceAbove10];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
+ (void)openSettingServiceBlow10{
    NSURL *locationSettingUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:locationSettingUrl]) {
        BOOL success = [[UIApplication sharedApplication] openURL:locationSettingUrl];
        if (!success) {
            NSLog(@"ios10[--],打开失败");
        }else{
            NSLog(@"YES");
        }
    }
}
//App-Prefs:root=LOCATION_SERVICES App-Prefs:root=Privacy  prefs:root=LOCATION_SERVICES
#pragma clang diagnostic pop

+ (void)openSettingServiceAbove10{
    NSURL*locationSettingUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:locationSettingUrl]) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:locationSettingUrl options:params completionHandler:^(BOOL success) {
                if (!success) {
                    NSLog(@"ios10[++],打开失败");
                }else{
                    NSLog(@"YES");
                }
            }];
        }
    }
}

@end
