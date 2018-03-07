//
//  NotificateManager.h
//  RequestAuthority
//
//  Created by MenThu on 2018/1/8.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIUserNotificationSettings.h>
#import "NSObject+MultiDelegate.h"

typedef NS_ENUM(NSInteger, NotificationType) {
    NotificationTypeNotInquiry = 0, //尚未询问推送权限
    NotificationTypeOn, //推送权限开启
    NotificationTypeOff, //推送权限关闭
};

typedef void (^NotificationTypeCallBack) (NotificationType type);
typedef void (^RegisterNotificationCallBack) (BOOL isUserGranted);

@protocol NotificationManagerDelegate <NSObject>
@optional

/**
 *  定位权限发现变化
 @params type 当前应用的通知权限
 */
- (void)notificationTypeDidChange:(NotificationType)type;

@end

@interface NotificationManager : NSObject;

/** 单例 */
+ (instancetype)sharedInstance;

/** 获取推送权限 */
- (void)getNotificationType:(NotificationTypeCallBack)callBack;

/**
 *  注册推送
 *  只有在iOS10(含10)以上，才会回调callBack
 */
- (void)registerNotification:(RegisterNotificationCallBack)callBack;

/**
 *  iOS8~9，用户点击了按钮之后，需要appdelegate调用此方法获取结果
 */
- (void)userGrantAuthorizationSetting:(UIUserNotificationSettings *)setting;

/** 添加代理 */
- (void)addDelegate:(id<NotificationManagerDelegate>)delegate;

@end
