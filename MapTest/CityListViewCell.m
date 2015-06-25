//
//  CityListViewCell.m
//  MapTest
//
//  Created by JokerV on 15/6/23.
//  Copyright (c) 2015年 JokerV. All rights reserved.
//

#import "CityListViewCell.h"

@interface CityListViewCell ()

@property (weak, nonatomic) IBOutlet UIProgressView *precessView;
@property (weak, nonatomic) IBOutlet UILabel *labelPercent;


@end

@implementation CityListViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (IBAction)actionButtonDownload:(id)sender {
    
}

- (IBAction)actionButtonPause:(id)sender {
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
