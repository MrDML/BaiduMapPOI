//
//  DMBMKPoiInfo.h
//  BaiduMapPOI
//
//  Created by 戴明亮 on 17/4/11.
//  Copyright © 2017年 戴明亮. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMBMKPoiInfo : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *city;
- (instancetype)initWithPoiInfoDict:(NSDictionary *)dict;
+ (instancetype)poiInfoWithDict:(NSDictionary *)dict;
+ (NSMutableArray *)poiInfoWithArray:(NSArray *)array;
@end


/**
 name = %@, _address = %@, _city
 
 */
