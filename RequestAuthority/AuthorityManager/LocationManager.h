//
//  AuthorityManager.h
//  RequestAuthority
//
//  Created by MenThu on 2018/1/8.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>
#import "NSObject+MultiDelegate.h"

typedef NS_ENUM(NSInteger, LocationType) {
    LocationTypeNotEnable = 0, //用户尚未开始定位服务
    LocationTypeNotInquiry, //尚未询问
    LocationTypeDenied, //拒绝定位权限
    LocationTypeAllowWhenInUse, //允许应用前台定位
    LocationTypeAllowAlways, //前台后台
};

typedef NS_ENUM(NSInteger, RequestType) {
    RequestTypeWhenInUse = 0, //请求前台定位权限
    RequestTypeAlways, //前后台权限
};

typedef void(^LocationTypeResult)(LocationType currentType);

@protocol LocationManagerDelegate <NSObject>
@optional

/**
 *  定位权限发现变化
 @params currentType 当前应用的定位权限
 */
- (void)locationTypeDidChange:(LocationType)currentType;

@end

@interface LocationManager : NSObject

/** 单例 */
+ (instancetype)sharedInstance;

/**
 *  获取当前的定位权限
 *  若权限为尚未询问，则方法内自动调用requestAuthorityType:finish:
 */
- (void)getLocationType:(LocationTypeResult)callBack;

/** 请求定位权限 */
- (void)requestAuthorityType:(RequestType)requestType finish:(LocationTypeResult)callBack;

/** 添加代理 */
- (void)addDelegate:(id<LocationManagerDelegate>)delegate;

@end
