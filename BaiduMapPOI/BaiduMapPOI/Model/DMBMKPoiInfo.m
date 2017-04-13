//
//  DMBMKPoiInfo.m
//  BaiduMapPOI
//
//  Created by 戴明亮 on 17/4/11.
//  Copyright © 2017年 戴明亮. All rights reserved.
//

#import "DMBMKPoiInfo.h"

@implementation DMBMKPoiInfo

- (instancetype)initWithPoiInfoDict:(NSDictionary *)dict
{
   self = [super init];
    if (self) {
        self.name = dict[@"name"];
        self.address = dict[@"address"];
        self.city = dict[@"city"];
    }
    return self;
}


+ (instancetype)poiInfoWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithPoiInfoDict:dict];
}

+ (NSMutableArray *)poiInfoWithArray:(NSArray *)array
{
    NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *dict in array) {
       DMBMKPoiInfo *infoModel = [self poiInfoWithDict:dict];
        [arrayM addObject:infoModel];
    }
    return arrayM;
}

@end
