//
//  POIViewController.h
//  BaiduMapPOI
//
//  Created by 戴明亮 on 17/4/10.
//  Copyright © 2017年 戴明亮. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>

@interface POIViewController : UIViewController
// 经度
@property (nonatomic, strong) NSString *coordinateLat;
// 纬度
@property (nonatomic, strong) NSString *coordinateLong;

@property (nonatomic, strong) BMKUserLocation *UserLocation;

@end
