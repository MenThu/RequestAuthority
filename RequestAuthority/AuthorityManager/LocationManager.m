//
//  AuthorityManager.m
//  RequestAuthority
//
//  Created by MenThu on 2018/1/8.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import "LocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIApplication.h>

@interface LocationManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign, readwrite) LocationType currentType;
@property (nonatomic, copy) LocationTypeResult callBack;
@property (nonatomic, assign) BOOL isFirstCallRequest;

@end

@implementation LocationManager

#pragma mark - LifeCircle
+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static LocationManager *_instance = nil;
    dispatch_once(&onceToken, ^{
        _instance = [[LocationManager alloc] init];
    });
    return _instance;
}

- (instancetype)init{
    if (self = [super init]) {
        self.currentType = [self getLocationType];
        self.isFirstCallRequest = YES;
        if (self.currentType != LocationTypeNotInquiry && self.currentType != LocationTypeNotEnable) {
            [self requestAuthorityType:RequestTypeWhenInUse];
        }
    }
    return self;
}

#pragma mark - Public
- (void)getLocationType:(LocationTypeResult)callBack{
    self.currentType = [self getLocationType];
    if (self.currentType == LocationTypeNotInquiry) {
        self.callBack = callBack;
        [self requestAuthorityType:RequestTypeWhenInUse];
    }else{
        if (callBack) {
            callBack(self.currentType);
        }
    }
}

- (void)requestAuthorityType:(RequestType)requestType finish:(LocationTypeResult)callBack{
    self.callBack = callBack;
    [self requestAuthorityType:requestType];
}

/**
 *  一般的，只有在尚未询问的状态下，请求定位权限，才会弹出系统对话窗口
 *  但是此方法，在任何状态下都调用了一次requestWhenInUseAuthorization(或者requestAlwaysAuthorization)方法
 *  这么做是因为，只有在调用了以上两种方法之后，应用才能在回调方法中接受到新的定位状态
 */
- (void)requestAuthorityType:(RequestType)requestType{
    if (self.isFirstCallRequest) {
        self.isFirstCallRequest = NO;
        if (requestType == RequestTypeWhenInUse) {
            [self.locationManager requestWhenInUseAuthorization];
        }else if (requestType == RequestTypeAlways){
            [self.locationManager requestAlwaysAuthorization];
        }
    }
}

- (void)addDelegate:(id<LocationManagerDelegate>)delegate{
    [super addDelegate:delegate];
}

#pragma mark - Private
/** 获取当前定位权限 */
- (LocationType)getLocationType{
    LocationType type = LocationTypeNotEnable;
    if ([CLLocationManager locationServicesEnabled]) {
        type = [self converCLAuthorityStatus2Type:[CLLocationManager authorizationStatus]];
    }
    return type;
}

/** 转换定位权限 */
- (LocationType)converCLAuthorityStatus2Type:(CLAuthorizationStatus)status{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined://尚未询问
            return LocationTypeNotInquiry;
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse://前台
            return LocationTypeAllowWhenInUse;
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways://前后台
            return LocationTypeAllowAlways;
            break;
            
        case kCLAuthorizationStatusRestricted: //被拒绝
        case kCLAuthorizationStatusDenied:
            return LocationTypeDenied;
            break;
            
        default:
            break;
    }
}

/** 检查定位权限是否发生了变化，若发现了变化则广播通知 */
- (void)checkLocationAuthorityIsChange:(LocationType)newType{
    if (self.currentType != newType) {
        __weak typeof(self) weakSelf = self;
        LocationType temp = self.currentType;
        self.currentType = newType;
        if (self.callBack) {
            self.callBack(newType);
            self.callBack = nil;
        }
        if (temp != LocationTypeNotInquiry) {
            [self operationDelegate:^(id delegate) {
                if ([delegate respondsToSelector:@selector(locationTypeDidChange:)]) {
                    [delegate locationTypeDidChange:weakSelf.currentType];
                }
            }];
        }
    }
}

#pragma mark - 定位回调代理
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if ([CLLocationManager locationServicesEnabled]) {
        [self checkLocationAuthorityIsChange:[self converCLAuthorityStatus2Type:status]];
    }else{
        [self checkLocationAuthorityIsChange:LocationTypeNotEnable];
    }
}

#pragma mark - Getter
- (CLLocationManager *)locationManager{
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}
@end
