//
//  POIViewControllerCell.m
//  BaiduMapPOI
//
//  Created by 戴明亮 on 17/4/11.
//  Copyright © 2017年 戴明亮. All rights reserved.
//

#import "POIViewControllerCell.h"

@interface POIViewControllerCell ()
@property (weak, nonatomic) IBOutlet UILabel *title_Label;
@property (weak, nonatomic) IBOutlet UILabel *address_Label;

@end

@implementation POIViewControllerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupUI];
    
    
    
}


- (void)setDmInfoModel:(DMBMKPoiInfo *)dmInfoModel
{
    _dmInfoModel = dmInfoModel;
    self.title_Label.text = _dmInfoModel.name;
    self.address_Label.text = _dmInfoModel.address;
}



- (void)setupUI{
   
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
