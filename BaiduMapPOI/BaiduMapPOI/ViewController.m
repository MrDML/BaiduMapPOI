//
//  ViewController.m
//  BaiduMapPOI
//
//  Created by 戴明亮 on 17/4/10.
//  Copyright © 2017年 戴明亮. All rights reserved.
//

#import "ViewController.h"
#import "POIViewController.h"
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
@interface ViewController ()<BMKLocationServiceDelegate>
{
    // 定位
    BMKLocationService* _locService;
    NSString *_coordinateLat;
    NSString *_coordinateLong;
    BMKUserLocation *_userLocation;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initLocation];
    [self startLocation];
    
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
  // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _locService.delegate = nil;
    
}

/**
 定位
 */
- (void)initLocation
{
    _locService = [[BMKLocationService alloc]init];
}

/**
 开始定位
 */
- (void)startLocation
{
    [_locService startUserLocationService];
}



- (IBAction)addAddress:(id)sender {
    NSLog(@"-----");
    
    if (_coordinateLat != nil && _coordinateLong != nil && _userLocation != nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        POIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"POIViewController"];
        vc.coordinateLat = _coordinateLat;
        vc.coordinateLong = _coordinateLong;
        vc.UserLocation = _userLocation;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        NSLog(@"没有定位成功!");
    }
    
    
    
}


#pragma mark - 定位代理

/**
 *在地图View将要启动定位时，会调用此函数
 //*@param mapView 地图View
 */
- (void)willStartLocatingUser
{
    NSLog(@"start locate");
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    _userLocation = userLocation;
    //[_mapView updateLocationData:userLocation];
    NSLog(@"heading is %@",userLocation.heading);
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    //[_mapView updateLocationData:userLocation];
    
    /*名字解释 
     
     latitude  纬度
     longitude 经度
     
     121.457341,31.295403
     */
    
    // 纬度
    /*
     // 经度
     _coordinateXText.text = @"116.403981";
     // 纬度
     _coordinateYText.text = @"39.915101";
     */
    _coordinateLat = @"31.295403";
    //@"116.403981";
    // [NSString stringWithFormat:@"%f",userLocation.location.coordinate.latitude];
    // 经度
    _coordinateLong = @"121.457341";;
    //[NSString stringWithFormat:@"%f",userLocation.location.coordinate.longitude];
   
    _userLocation = userLocation;
    NSLog(@"----> %@ ----> %@",_coordinateLat,_coordinateLong);
    
    if (_coordinateLat != nil && _coordinateLong != nil ) { // 停止定位
        [_locService stopUserLocationService];
        
    }
    
    
    
    
}

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)didStopLocatingUser
{
    NSLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location error");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
