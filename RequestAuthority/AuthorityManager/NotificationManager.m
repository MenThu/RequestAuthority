//
//  NotificationManager.m
//  RequestAuthority
//
//  Created by MenThu on 2018/1/8.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import "NotificationManager.h"
#import <UIKit/UIApplication.h>
#import <UserNotifications/UserNotifications.h>

@interface NotificationManager ()

@property (nonatomic, assign) CGFloat systemVersion;
@property (nonatomic, assign) BOOL isUserOut;
@property (nonatomic, assign) BOOL isTypeInit;
@property (nonatomic, assign) NotificationType currentType;
@property (nonatomic, assign) BOOL isRegisterNotiMethodCall;
@property (nonatomic, copy) RegisterNotificationCallBack registerResultCallBack;

@end

@implementation NotificationManager

#pragma mark - LifeCircle
+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static NotificationManager *_instance = nil;
    dispatch_once(&onceToken, ^{
        _instance = [[NotificationManager alloc] init];
    });
    return _instance;
}

- (instancetype)init{
    if (self = [super init]) {
        self.isUserOut = NO;
        self.isTypeInit = NO;
        self.systemVersion = [UIDevice currentDevice].systemVersion.floatValue;
        self.isRegisterNotiMethodCall = [self readBoolValueFromUserDefault];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNotificationAuthority)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userOutSideApp)
                                                     name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

#pragma mark - Public
- (void)getNotificationType:(NotificationTypeCallBack)callBack{
    NSAssert(callBack != nil, @"");
    __weak typeof(self) weakSelf = self;
    if (@available(iOS 10.0, *)) {
        return [self getNotificationTypeLessThanEqualToiOS11:^(NotificationType type) {
            if (!weakSelf.isTypeInit) {
                weakSelf.currentType = type;
                weakSelf.isTypeInit = YES;
            }
            callBack(type);
        }];
    }else if (@available(iOS 8.0, *)){
        return [self getNotificationTypeLessThanEqualToiOS9:^(NotificationType type) {
            if (!weakSelf.isTypeInit) {
                weakSelf.currentType = type;
                weakSelf.isTypeInit = YES;
            }
            callBack(type);
        }];
    }
    NSAssert(NO, @"不支持iOS7及以下的系统");
}

- (void)registerNotification:(RegisterNotificationCallBack)callBack{
    if (self.isRegisterNotiMethodCall) {
        return;
    }
    self.isRegisterNotiMethodCall = YES;
    [self saveBoolValueInUserDefault];
    if (@available(iOS 10.0, *)) {
        [self registerNotificationLessEqualToiOS11:callBack];
    }else if (@available(iOS 8.0, *)){
        self.registerResultCallBack = callBack;
        [self registerNotificationLessEqualToiOS9];
    }else{
        NSAssert(NO, @"不支持iOS7及以下的系统");
    }
}

- (void)addDelegate:(id<NotificationManagerDelegate>)delegate{
    [super addDelegate:delegate];
}

#pragma mark - Private
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
- (void)userGrantAuthorizationSetting:(UIUserNotificationSettings *)setting{
    BOOL isUserGrant = NO;
    if (setting.types == UIUserNotificationTypeNone) {
        isUserGrant = NO;
    }else{
        isUserGrant = YES;
    }
    if (self.registerResultCallBack) {
        self.registerResultCallBack(isUserGrant);
        self.registerResultCallBack = nil;
    }
}

- (void)getNotificationTypeLessThanEqualToiOS9:(NotificationTypeCallBack)callBack{
    NotificationType type = NotificationTypeOff;
    UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (setting.types == UIUserNotificationTypeNone) {
        if (!self.isRegisterNotiMethodCall) {
            type = NotificationTypeNotInquiry;
        }else{
            type = NotificationTypeOff;
        }
    }else{
        type = NotificationTypeOn;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        callBack(type);
    });
}

- (void)registerNotificationLessEqualToiOS9{
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];//注释掉这句话，则只注册本地推送
    /**
     *  当用户点击了"不允许"或者"好"之后，系统会回调Appdelegate的application::didRegisterUserNotificationSettings方法
     **/
}
#pragma clang diagnostic pop
- (void)userOutSideApp{
    self.isUserOut = YES;
}

- (void)checkNotificationAuthority{
    if (!self.isUserOut) {
        return;
    }
    self.isUserOut = NO;
    __weak typeof(self) weakSelf = self;
    [self getNotificationType:^(NotificationType type) {
        if (weakSelf.currentType != type) {
            NotificationType temp = weakSelf.currentType;
            weakSelf.currentType = type;
            if (temp != NotificationTypeNotInquiry) {
                [weakSelf operationDelegate:^(id delegate) {
                    if ([delegate respondsToSelector:@selector(notificationTypeDidChange:)]) {
                        [delegate notificationTypeDidChange:type];
                    }
                }];
            }
        }
    }];
}

- (void)getNotificationTypeLessThanEqualToiOS11:(NotificationTypeCallBack)callBack{
    if (@available(iOS 10.0, *)) {
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            NotificationType type = NotificationTypeOff;
            if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {
                type = NotificationTypeNotInquiry;
            }else{
                if (settings.soundSetting == UNNotificationSettingEnabled &&
                    settings.badgeSetting == UNNotificationSettingEnabled &&
                    settings.alertSetting == UNNotificationSettingEnabled) {
                    type = NotificationTypeOn;
                }else{
                    type = NotificationTypeOff;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                callBack(type);
            });
        }];
    }
}

- (void)registerNotificationLessEqualToiOS11:(RegisterNotificationCallBack)callBack{
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        UNAuthorizationOptions options = UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert;
        [center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (callBack) {
                callBack(granted);
            }
        }];
    }
}

- (BOOL)readBoolValueFromUserDefault{
    NSNumber *temp = [[NSUserDefaults standardUserDefaults] objectForKey:@"isRegisterNotiMethodCall"];
    return temp.boolValue;
}

- (void)saveBoolValueInUserDefault{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(YES) forKey:@"isRegisterNotiMethodCall"];
    [defaults synchronize];
}

@end
