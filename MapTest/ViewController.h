//
//  ViewController.h
//  MapTest
//
//  Created by JokerV on 15/6/5.
//  Copyright (c) 2015年 JokerV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI/BMapKit.h>

typedef NS_ENUM(NSUInteger, ReachFashion) {
    StartPoint,
    EndPoint,
    FashionBus,
    FashionMetro,
    FashionCar,
    PathWay
};

@interface RouteAnnotation : BMKPointAnnotation

@property (assign,nonatomic) ReachFashion type; ///<0:起点 1：终点 2：公交 3：地铁 4:驾乘 5:途经点
@property (assign,nonatomic) int degree;

@end

@interface ViewController : UIViewController


@end

@interface MainView : UIView

@property (assign,nonatomic) BOOL isShow;

@end


@interface ButtonControlView : UIView

@end

//first viewcontroller - POISearch
@interface LittleViewController : UIViewController

@property (copy,nonatomic) void (^littleViewSearchBlock)(NSString *provience,NSString *establish,NSInteger index);
@property (assign,nonatomic) NSInteger index;

@end


typedef NS_ENUM(NSUInteger, GeoType) {
    ReverseGEOCoding = 0,
    ForwardGEOCoding
};

//second viewcontroller - GeoCode
@interface GeocodeViewController : UIViewController

@property (assign,nonatomic) GeoType geoType;

@property (copy,nonatomic) void (^GeoSearchBlock)(NSString *firstText,NSString *secondText,GeoType searchType);

@end

//third viewcontroller - Offline
@protocol OfflineMapViewDelegate;
@interface OfflineMapViewController : UIViewController

@property (assign,nonatomic) id<OfflineMapViewDelegate> delegate;
@property (strong,nonatomic) ViewController *controller;

@end

@protocol CityListDelegate;
@interface CityListViewContoller : UIViewController

@property (assign,nonatomic) id<CityListDelegate> delegate;

@end

/**
 *  fourth viewcotnroller - Route Search
 */

@interface RouteSearchViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *textFieldStartCity;
@property (weak, nonatomic) IBOutlet UITextField *textFieldStartPlace;
@property (weak, nonatomic) IBOutlet UITextField *textFieldEndCity;
@property (weak, nonatomic) IBOutlet UITextField *textFieldEndPlace;

@property (assign,nonatomic) ReachFashion reachFashion;

@end



@interface HitTestView : UIView

@end
