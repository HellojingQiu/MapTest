//
//  CityListViewCell.h
//  MapTest
//
//  Created by JokerV on 15/6/23.
//  Copyright (c) 2015年 JokerV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI/BMKOfflineMapType.h>

@interface CityListViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelCity;
@property (weak, nonatomic) IBOutlet UILabel *labelId;
@property (weak, nonatomic) IBOutlet UIProgressView *precessView;
@property (weak, nonatomic) IBOutlet UILabel *labelPercent;

@property (copy,nonatomic) void (^GetCellInfo)(int cityId);
@property (copy,nonatomic) BOOL (^PauseDownLoad)(int cityId);
@property (weak, nonatomic) IBOutlet UIButton *buttonDownload;
@property (weak, nonatomic) IBOutlet UIButton *buttonPause;
@end
