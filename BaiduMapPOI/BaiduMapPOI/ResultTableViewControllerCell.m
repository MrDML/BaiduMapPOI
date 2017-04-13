//
//  ResultTableViewControllerCell.m
//  BaiduMapPOI
//
//  Created by 戴明亮 on 17/4/11.
//  Copyright © 2017年 戴明亮. All rights reserved.
//

#import "ResultTableViewControllerCell.h"

@interface ResultTableViewControllerCell ()
@property (weak, nonatomic) IBOutlet UILabel *title_Label;
@property (weak, nonatomic) IBOutlet UILabel *address_Label;

@end

@implementation ResultTableViewControllerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setInfoModel:(DMBMKPoiInfo *)infoModel
{
    _infoModel = infoModel;
    self.title_Label.text = _infoModel.name;
    self.address_Label.text = _infoModel.address;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
