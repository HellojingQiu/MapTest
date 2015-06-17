//
//  MyAnimatedAnnionView.h
//  MapTest
//
//  Created by JokerV on 15/6/9.
//  Copyright (c) 2015年 JokerV. All rights reserved.
//

#import <BaiduMapAPI/BMKAnnotationView.h>

@interface MyAnimatedAnnionView : BMKAnnotationView

@property (nonatomic,strong) NSMutableArray *annotationImages;
@property (nonatomic,strong) UIImageView *annotationImageView;

@end
