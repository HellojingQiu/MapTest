//
//  ViewController.h
//  MapTest
//
//  Created by JokerV on 15/6/5.
//  Copyright (c) 2015年 JokerV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController


@end

@interface MainView : UIView

@property (assign,nonatomic) BOOL isShow;

@end

@interface LittleViewController : UIViewController

@property (copy,nonatomic) void (^littleViewSearchBlock)(NSString *provience,NSString *establish,NSInteger index);
@property (assign,nonatomic) NSInteger index;

@end