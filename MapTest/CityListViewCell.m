//
//  CityListViewCell.m
//  MapTest
//
//  Created by JokerV on 15/6/23.
//  Copyright (c) 2015年 JokerV. All rights reserved.
//

#import "CityListViewCell.h"

@interface CityListViewCell ()

@end

@implementation CityListViewCell

- (void)awakeFromNib {
    // Initialization code
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateView:) name:@"CityListCell" object:nil];
    
    [self.buttonDownload addTarget:self action:@selector(actionButtonDownload:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonPause addTarget:self action:@selector(actionButtonPause:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)actionButtonDownload:(UIButton *)sender {
    if (sender.tag == self.buttonDownload.tag) {
        self.precessView.progress = 0.5;
        self.labelPercent.text = @"0%";
        self.GetCellInfo([_labelId.text intValue]);
    }
}

- (IBAction)actionButtonPause:(UIButton *)sender {
    if (sender.tag == self.buttonPause.tag) {
        self.PauseDownLoad([_labelId.text intValue]);
    }
}

-(void)updateView:(NSNotification *)notification{
    if ([notification.name isEqualToString:@"CityListCell"]) {
        NSDictionary *dict = notification.userInfo;
        
//        @"cityID",
//        @"size",
//        @"serversize",
//        @"ratio",
//        @"status"
        NSLog(@"%d - %d",[(NSNumber *)dict[@"cityID"] intValue],self.buttonDownload.tag);
        
        if ([(NSNumber *)dict[@"cityID"] intValue] == self.buttonDownload.tag) {
            
            self.labelPercent.text = [NSString stringWithFormat:@"%d%%",[(NSNumber *)dict[@"ratio"] intValue]];
            [self.precessView setProgress:[(NSNumber *)dict[@"ratio"] intValue]/100.0];
        }
        
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
