//
//  ViewController.m
//  MapTest
//
//  Created by JokerV on 15/6/5.
//  Copyright (c) 2015年 JokerV. All rights reserved.
//

#import "ViewController.h"

#import <BaiduMapAPI/BMKMapView.h>
#import <BaiduMapAPI/BMapKit.h>

#import "UIImage+ResizeImage.h"
#import "UPStackMenu.h"
#import "DXPopover.h"

#import "MyAnimatedAnnionView.h"

NS_ENUM(NSInteger, LocationType){
    Follow,
    FollowWithHeading
};

#define _NotificationStackMenuDismiss @"StackMenuDismissNotification"
#define _annotationMark @"AnnotationMark"
#define _indexNumber @"RecurrenceIndexToZERO"

#define MYBUNDLE_NAME @"mapapi.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath:MYBUNDLE_PATH]


@interface ViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,UPStackMenuDelegate,BMKPoiSearchDelegate,BMKAnnotation>

@property (strong,nonatomic) BMKMapView *mapView;

@property (strong,nonatomic) BMKLocationService *locationService;
@property (strong,nonatomic) BMKGeoCodeSearch *geoSearch;
@property (strong,nonatomic) BMKPoiSearch *poiSearch;

@property (assign,nonatomic) enum LocationType locatonType;

@property (weak, nonatomic) IBOutlet UILabel *labelTopInfomation;
@property (weak, nonatomic) IBOutlet UIView *popContainerView;
@property (assign,nonatomic) CGRect originalFrame;


@property (weak, nonatomic) IBOutlet UIView *upStackMenu;
@property (strong,nonatomic) UPStackMenu *stackMenu;
@property (strong,nonatomic) DXPopover *popover;



//Others
@property (strong,nonatomic) NSMutableArray *arrayConstraints;
@property (assign,nonatomic) BOOL showOut;
//坐标
@property (assign,nonatomic) CLLocationCoordinate2D location2D;
@property (strong,nonatomic) BMKCircle *overlayCicle;
@property (strong,nonatomic) BMKPolygon *overlayPolygon;
@property (strong,nonatomic) BMKPolyline *overlayPolyline;
@property (strong,nonatomic) BMKArcline *overlayArcline;
@property (strong,nonatomic) BMKGroundOverlay *overlayGround;
@property (strong,nonatomic) BMKPointAnnotation *overlayPointAnnotation;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardEvent:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardEvent:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardEvent:) name:_NotificationStackMenuDismiss object:nil];
    
    [self createViewSubviews];
    
    [self createMapView];
    
}

-(void)viewDidLayoutSubviews{
    
    if (!_arrayConstraints) {
        self.arrayConstraints = [NSMutableArray array];
        [[self.view constraints] enumerateObjectsUsingBlock:^(NSLayoutConstraint *obj, NSUInteger idx, BOOL *stop) {
            int num = 0;
            if (obj.firstItem == self.popContainerView) {
                num ++;
                [_arrayConstraints addObject:obj];
            }
        }];
    }
    
    _stackMenu.delegate ? 0 : [self createStackMenu];
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
}


-(void)createMapView{
    self.mapView = [[BMKMapView alloc]initWithFrame:self.view.bounds];
    self.locationService = [[BMKLocationService alloc]init];
    self.poiSearch = [[BMKPoiSearch alloc]init];
    
    [self.locationService startUserLocationService];
    
    _mapView.showMapScaleBar = YES;
    _mapView.mapScaleBarPosition = CGPointMake(_mapView.frame.size.width-70, _mapView.frame.size.height-53);
    _mapView.showsUserLocation = NO;
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;
    _mapView.showsUserLocation = YES;
    _mapView.isSelectedAnnotationViewFront = YES;
    
    //定位精度
    [BMKLocationService setLocationDistanceFilter:10.f];
    //更新距离
    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    
    [_mapView setZoomLevel:17];
    
    
    [self.view addSubview:_mapView];
}

-(void)createViewSubviews{
    self.popover = [DXPopover popover];
    
}

-(void)createStackMenu{
    if (_stackMenu) [_stackMenu removeAllItems];
    
    _stackMenu = [[UPStackMenu alloc]initWithContentView:_upStackMenu];
    _stackMenu.delegate = self;
//    _stackMenu.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height-30);
//    _stackMenu.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height-30);
    
    UPStackMenuItem *squareItem = [[UPStackMenuItem alloc]initWithImage:[[UIImage imageNamed:@"square"] imageWithColor:[UIColor blueColor]] highlightedImage:nil title:@"POI搜索功能"];
    UPStackMenuItem *circleItem = [[UPStackMenuItem alloc]initWithImage:[[UIImage imageNamed:@"circle"] imageWithColor:[UIColor blueColor]] highlightedImage:nil title:@"热力图"];
    UPStackMenuItem *triangleItem = [[UPStackMenuItem alloc]initWithImage:[[UIImage imageNamed:@"triangle"] imageWithColor:[UIColor blueColor]] highlightedImage:nil title:@"泡泡视图"];
    UPStackMenuItem *crossItem = [[UPStackMenuItem alloc]initWithImage:[[UIImage imageNamed:@"cross"] imageWithColor:[UIColor blueColor]] highlightedImage:nil title:@"十字"];
    
    NSMutableArray *muArray = [NSMutableArray arrayWithObjects:squareItem,circleItem,triangleItem,crossItem, nil];
    [muArray enumerateObjectsUsingBlock:^(UPStackMenuItem *obj, NSUInteger idx, BOOL *stop) {
        [obj setTitleColor:[UIColor blueColor]];
    }];
    
    _stackMenu.animationType = UPStackMenuAnimationType_progressive;
    _stackMenu.stackPosition = UPStackMenuStackPosition_up;
    _stackMenu.openAnimationDuration = .4;
    _stackMenu.closeAnimationDuration = .4;
    [muArray enumerateObjectsUsingBlock:^(UPStackMenuItem *obj, NSUInteger idx, BOOL *stop) {
        idx%2 ? (obj.labelPosition = UPStackMenuItemLabelPosition_left): (obj.labelPosition = UPStackMenuItemLabelPosition_right);
    }];
    
    [_stackMenu addItems:muArray];
    [self.view addSubview:_stackMenu];
    
    [self setStackIconClosed:YES];
}

-(void)setStackIconClosed:(BOOL)closed{
    
    UIImageView *imageView = [_upStackMenu subviews][0];
    float angle = closed ? 0 : (M_PI * (135) / 180.0);
    [UIView animateWithDuration:.3 animations:^{
        [imageView.layer setAffineTransform:CGAffineTransformRotate(CGAffineTransformIdentity, angle)];
    }];
}

#pragma mark - Arction

-(void)keyBoardEvent:(NSNotification *)notification{
    CGRect screenSize = [UIScreen mainScreen].bounds;

    
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        if (screenSize.size.height - CGRectGetMaxY([_popContainerView superview] == self.view ? _popContainerView.frame : [_popContainerView superview].frame) < 214 && !_showOut) {
            _showOut = YES;
            
            [UIView animateWithDuration:0.3 animations:^{
                CGRect rect = self.view.bounds;
                rect.origin.y += 214;
//                rect.size.height += 214;
                self.view.bounds = rect;
            }];
            
            NSLog(@"1");
        }
        
        
    }else if ([notification.name isEqualToString:UIKeyboardWillHideNotification]){
        if (_showOut) {
            _showOut = NO;
            
            [UIView animateWithDuration:0.3 animations:^{
                CGRect rect = self.view.bounds;
                rect.origin.y -= 214;
//                rect.size.height -= 214;
                self.view.bounds = rect;
            }];
        }
    }else if ([notification.name isEqualToString:_NotificationStackMenuDismiss]){
        if(_stackMenu.isOpen){
            [_stackMenu closeStack];
            [self stackMenuWillClose:_stackMenu];
            return;
        }
    }else{
        NSLog(@"未知");
    }
}


#pragma mark - UPStackMenuDelegate

-(void)stackMenuWillOpen:(UPStackMenu *)menu{
    if (![_upStackMenu subviews].count) return;
    
    [(MainView *)self.view setIsShow:YES];
    [self setStackIconClosed:NO];
}

-(void)stackMenuWillClose:(UPStackMenu *)menu{
    if (![_upStackMenu subviews].count) return;
    
    [(MainView *)self.view setIsShow:NO];
    [self setStackIconClosed:YES];
}

-(void)stackMenu:(UPStackMenu *)menu didTouchItem:(UPStackMenuItem *)item atIndex:(NSUInteger)index{
    NSLog(@"item %@ touched",item.title);
    if ([item.title isEqualToString:@"POI搜索功能"]) {
        
        
        [_popover showAtView:item withContentView:_popContainerView inView:self.view];
        
        __weak ViewController *weakself = self;
        _popover.didDismissHandler = ^{
            weakself.popContainerView.layer.cornerRadius = 0;
            weakself.popContainerView.hidden = YES;
            [weakself.view addSubview:weakself.popContainerView];
            
            [weakself.view addConstraints:weakself.arrayConstraints];
            
//            [weakself.view layoutIfNeeded];
        };
        return;
    }
    
    if ([item.title isEqualToString:@"热力图"]) {
//        [_mapView addHeatMap:<#(BMKHeatMap *)#>];
    }
    
}

#pragma mark - MapView Delegate

-(void)viewWillAppear:(BOOL)animated{
    [_mapView viewWillAppear];
    _mapView.delegate = self;
    _locationService.delegate = self;
    _poiSearch.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil;
    _locationService.delegate = nil;
    _poiSearch.delegate = self;
}

-(void)mapViewDidFinishLoading:(BMKMapView *)mapView{
    NSLog(@"地图初始化完成!");
}

-(void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view{
    [mapView bringSubviewToFront:view];
    [mapView setNeedsDisplay];
}

-(void)mapView:(BMKMapView *)mapView didAddAnnotationViews:(NSArray *)views{
    NSLog(@"didAddAnnotationViews");
}

/**
 *  生成指针视图时的处理函数
 *
 *  @param mapView    主视图
 *  @param annotation 指针参数
 *
 *  @return 处理后的指针视图
 */
-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation{
    
    
    
    //point
    if (annotation == _overlayPointAnnotation) {
        NSString  *annotationViewId = @"annotationPin";
        BMKPinAnnotationView *annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationViewId];
        if (annotationView == nil) {
            annotationView = [[BMKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:annotationViewId];
            annotationView.pinColor = BMKPinAnnotationColorGreen;
            annotationView.animatesDrop = YES;
            annotationView.draggable = YES;
        }
        return annotationView;
    }
    
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *pinAnnotiationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:_annotationMark];
        if (!pinAnnotiationView) {
            pinAnnotiationView = [[BMKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:_annotationMark];
            pinAnnotiationView.pinColor = BMKPinAnnotationColorGreen;
            pinAnnotiationView.image = [UIImage imageNamed:@"pin"];
            pinAnnotiationView.animatesDrop = YES;
            
            
            UIView *view = [[NSBundle mainBundle]loadNibNamed:@"PinView" owner:nil options:nil][0];
            UILabel *title = (UILabel *)[view viewWithTag:1041];
            UILabel *detail = (UILabel *)[view viewWithTag:1042];
            UIImageView *imageView = (UIImageView *)[view viewWithTag:1043];
            if (title && detail && imageView) {
                title.text = annotation.title;
                detail.text = annotation.subtitle;
                //arc4random()%x 是选取0-(x-1)的范围
                imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"1__%d%d.jpg",arc4random()%3,arc4random()%9+1]];
                
            }
            
            pinAnnotiationView.paopaoView = [[BMKActionPaopaoView alloc]initWithCustomView:view];
        };
        
        pinAnnotiationView.centerOffset = CGPointMake(0, -(pinAnnotiationView.frame.size.height*.5));
        pinAnnotiationView.annotation = annotation;
        pinAnnotiationView.canShowCallout = YES;
        pinAnnotiationView.draggable = NO;
        
        
        return pinAnnotiationView;
    }
    
    //anno effet
    NSString *annotationCustomId = @"annotationCustom";
    MyAnimatedAnnionView *annotationView = (MyAnimatedAnnionView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationCustomId];
    if (!annotationView) {
        annotationView = [[MyAnimatedAnnionView alloc]initWithAnnotation:annotation reuseIdentifier:annotationCustomId];
    }
    NSMutableArray *images = [NSMutableArray array];
    for (int i = 0; i<4; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"poi_%d.png",i]];
        [images addObject:image];
    }
    annotationView.annotationImages = images;
    return annotationView;
}

/**
 *  生成遮盖物视图时的处理函数
 *
 *  @param mapView 主视图
 *  @param overlay 覆盖物
 *
 *  @return 处理后的覆盖物视图
 */
-(BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay{
    if ([overlay isKindOfClass:[BMKCircle class]]) {
        BMKCircleView *circleView = [[BMKCircleView alloc]initWithOverlay:overlay];
        circleView.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        circleView.strokeColor = [[UIColor blueColor]colorWithAlphaComponent:0.5];
        circleView.lineWidth = 1;
        
        return circleView;
    }
    
    if([overlay isKindOfClass:[BMKPolyline class]]){
        BMKPolylineView *polylineView = [[BMKPolylineView alloc]initWithOverlay:overlay];
        polylineView.strokeColor = [[UIColor blueColor]colorWithAlphaComponent:1];
        polylineView.lineWidth = 20;
        [polylineView loadStrokeTextureImage:[UIImage imageNamed:@"texture_arrow"]];
        return polylineView;
    }
    
    if ([overlay isKindOfClass:[BMKGroundOverlay class]]) {
        BMKGroundOverlayView *groundView = [[BMKGroundOverlayView alloc] initWithOverlay:overlay];
        return groundView;
    }
    
    if ([overlay isKindOfClass:[BMKPolygon class]]) {
        BMKPolygonView *polygonView = [[BMKPolygonView alloc]initWithOverlay:overlay];
        polygonView.strokeColor = [[UIColor purpleColor]colorWithAlphaComponent:1];
        polygonView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        polygonView.lineWidth = 2.0;
        polygonView.lineDash = YES;
        return polygonView;
    }
    
    if ([overlay isKindOfClass:[BMKArcline class]]) {
        BMKArclineView *arclineView = [[BMKArclineView alloc]initWithArcline:overlay];
        arclineView.strokeColor = [UIColor blueColor];
        arclineView.lineDash = YES;
        arclineView.lineWidth = 3.0;
        return arclineView;
    }
    return nil;
}

/**
 *  气泡弹出后的显示
 *
 *  @param mapView 主地图
 *  @param view    矛视图
 */
-(void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view{
    self.labelTopInfomation.text = @"泡泡信息";
}

#pragma mark - Location Delegate

-(void)didUpdateUserHeading:(BMKUserLocation *)userLocation{
    self.location2D = userLocation.location.coordinate;
    [_mapView updateLocationData:userLocation];
}

-(void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    [_mapView updateLocationData:userLocation];
}

-(void)didFailToLocateUserWithError:(NSError *)error{
    NSLog(@"定位失败.失败码:%@",error);
}

#pragma mark - POI Search Delegate

-(void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult *)poiResult errorCode:(BMKSearchErrorCode)errorCode{
    NSArray *array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    
    if (errorCode == BMK_SEARCH_NO_ERROR) {
        for (int i = 0; i<poiResult.poiInfoList.count; i++) {
            BMKPoiInfo *poiInfo = [poiResult.poiInfoList objectAtIndex:i];
            BMKPointAnnotation *item = [[BMKPointAnnotation alloc]init];
            item.coordinate = poiInfo.pt;
            item.title = poiInfo.name;
            item.subtitle = poiInfo.address;
            [_mapView addAnnotation:item];
            if (i==0) {
                _mapView.centerCoordinate = poiInfo.pt;
            }
        }
    }else if (errorCode == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR) NSLog(@"检索点有歧义");
    else if(errorCode == BMK_SEARCH_RESULT_NOT_FOUND){
        _labelTopInfomation.text = @"未发现搜索结果,请点击重新搜索";
        [[NSNotificationCenter defaultCenter] postNotificationName:_indexNumber object:nil];
    };
}

#pragma mark - Overlays And Animates

-(BOOL)addOverLayView{
    self.labelTopInfomation.hidden = NO;
    //圆形覆盖物
    if (!_overlayGround) {
        CLLocationCoordinate2D coor;
        if (self.location2D.latitude) {
            coor.latitude = self.location2D.latitude;
            coor.longitude = self.location2D.longitude;
        }else{
            coor.latitude = 31.207796;
            coor.longitude = 121.642296;
        }
    
        _overlayGround = [BMKGroundOverlay groundOverlayWithPosition:coor
                                                           zoomLevel:13
                                                              anchor:CGPointZero
                                                                icon:[UIImage imageNamed:@"test"]];
        _overlayGround.alpha = 0.5;
        [_mapView addOverlay:_overlayGround];
        [self.labelTopInfomation setText:@"圆形覆盖物"];
        self.mapView.zoomLevel = 13;
        return YES;
   }
    
    //弧形线
    if (!_overlayArcline) {
        CLLocationCoordinate2D coords[3] = {0};
        coords[0].latitude = self.location2D.latitude;
        coords[0].longitude = self.location2D.longitude;
        coords[1].latitude = self.location2D.latitude - 0.2;
        coords[1].longitude = self.location2D.longitude - 0.2;
        coords[2].latitude = self.location2D.latitude - 0.3;
        coords[2].longitude = self.location2D.longitude - 0.4;
        _overlayArcline = [BMKArcline arclineWithCoordinates:coords];
        [self.labelTopInfomation setText:@"弧形线"];
        self.mapView.zoomLevel = 10;
        [_mapView addOverlay:_overlayArcline];
        return YES;
    }
    
    //圆形
    if (!_overlayCicle) {
        _overlayCicle = [BMKCircle circleWithCenterCoordinate:self.location2D radius:3000];
        [self.labelTopInfomation setText:@"圆形覆盖物"];
        self.mapView.zoomLevel = 13;
        [_mapView addOverlay:_overlayCicle];
        return YES;
    }
    
    //折线
    if(!_overlayPolyline){
        CLLocationCoordinate2D coors[2] = {0};
        coors[0].latitude = self.location2D.latitude;
        coors[0].longitude = self.location2D.longitude;
        coors[1].latitude = self.location2D.latitude + 0.2;
        coors[1].longitude = self.location2D.longitude + 0.3;
        _overlayPolyline = [BMKPolyline polylineWithCoordinates:coors count:2];
        [self.labelTopInfomation setText:@"折线"];
         _mapView.zoomLevel = 11;
        [_mapView addOverlay:_overlayPolyline];
        return YES;
    }
    
    //多边形
    if(!_overlayPolygon){
        CLLocationCoordinate2D coors[5] = {0};
        coors[0].latitude = self.location2D.latitude;
        coors[0].longitude = self.location2D.longitude;
        coors[1].latitude = self.location2D.latitude + 0.2;
        coors[1].longitude = self.location2D.longitude +0.3;
        coors[2].latitude = self.location2D.latitude + 0.23;
        coors[2].longitude = self.location2D.longitude + 0.28;
        coors[3].latitude = self.location2D.latitude + 0.9;
        coors[3].longitude = self.location2D.longitude + 0.35;
        coors[4].latitude = self.location2D.latitude + 1.2;
        coors[4].longitude = self.location2D.longitude + 0.4;
        coors[5].latitude = self.location2D.latitude + 1.5;
        coors[5].longitude = self.location2D.longitude + 0.48;
        _overlayPolygon = [BMKPolygon polygonWithCoordinates:coors count:5];
        [self.labelTopInfomation setText:@"多边形"];
        _mapView.zoomLevel= 10;
        [_mapView addOverlay:_overlayPolygon];
        return YES;
    }
    
    _mapView.zoomLevel = 13;
    return NO;
}

-(void)addAnimatedView{
    if (!_overlayPointAnnotation) {
        _overlayPointAnnotation = [[BMKPointAnnotation alloc]init];
        _overlayPointAnnotation.coordinate = self.location2D;
        _overlayPointAnnotation.title = @"我的所在地";
        _overlayPointAnnotation.subtitle = @"没错,这就是我的所在地,顺便说,这个指针可拖拽";
        
        [_mapView addAnnotation:_overlayPointAnnotation];
        _mapView.centerCoordinate = self.location2D;
        return;
    }
}

#pragma mark - Action event

- (IBAction)actionButtonClick:(UIButton *)sender {
    switch (Follow) {
        case Follow:{//跟随模式
            _mapView.showsUserLocation = NO;
            _mapView.userTrackingMode = BMKUserTrackingModeFollow;
            
            
            BMKLocationViewDisplayParam *param = [[BMKLocationViewDisplayParam alloc]init];
            param.isRotateAngleValid = YES;
            param.isAccuracyCircleShow = NO;
//            param.locationViewImgName = @"定位坐标";
//            param.locationViewOffsetX = 0;
//            param.locationViewOffsetY = 0;
            
            [_mapView setCenterCoordinate:self.location2D animated:YES];
            [_mapView updateLocationViewWithParam:param];
            
            _mapView.showsUserLocation = YES;
            self.locatonType = FollowWithHeading;
            
            NSLog(@"Follow");
        }break;
        case FollowWithHeading:{//罗盘模式
            _mapView.showsUserLocation = NO;
            _mapView.userTrackingMode = BMKUserTrackingModeFollowWithHeading;
            [_mapView setCenterCoordinate:self.location2D animated:YES];
            
            _mapView.showsUserLocation = YES;
            
            self.locatonType = Follow;
            NSLog(@"FollowWithHeading");
        }break;
        default:
            break;
    }
    _mapView.zoomLevel = 17;
//    _mapView.overlooking = -30;
}

- (IBAction)actionButtonClickOverlay:(id)sender {
    if(_mapView.overlays.count) [_mapView removeOverlays:_mapView.overlays];
    if(_mapView.annotations.count) [_mapView removeAnnotations:_mapView.annotations];
    
    [self addOverLayView] ? 0 : [self addAnimatedView];
}

- (IBAction)actionButtonClickPOIConvert:(id)sender {
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


#pragma mark - Alert 

-(void)alertMessageWithTitle:(NSString *)title andDetail:(NSString *)detail andBtnArray:(NSArray *)btnArray{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:detail preferredStyle:UIAlertControllerStyleAlert];
    
    for (int i = 0; i<btnArray.count; i++) {
        [alertController addAction:[UIAlertAction actionWithTitle:btnArray[i] style:UIAlertActionStyleDefault handler:nil]];
    }
    
    
    [self presentViewController:alertController animated:YES completion:nil];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.destinationViewController isKindOfClass:[LittleViewController class]]) {
        ((LittleViewController *)segue.destinationViewController).littleViewSearchBlock = ^(NSString *province,NSString *establish,NSInteger index){

            BMKNearbySearchOption *citySearchOption = [[BMKNearbySearchOption alloc]init];
            citySearchOption.pageIndex = index;
            citySearchOption.pageCapacity = 10;
            citySearchOption.location = _location2D;
            citySearchOption.radius = 2000;
            citySearchOption.keyword = establish;
            
            _labelTopInfomation.hidden = NO;
            
            if ([_poiSearch poiSearchNearBy:citySearchOption]) {
                _labelTopInfomation.text = @"检索成功";
                if(index == 0) _mapView.zoomLevel = 13;
            }else{
                _labelTopInfomation.text = @"检索失败";
            }
        };
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)dealloc{
    _mapView = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end


//main view
//hit test

@implementation MainView

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *hitView = [super hitTest:point withEvent:event];
    
    if (hitView == self) {
        return nil;
    }
    
    if ([hitView isKindOfClass:NSClassFromString(@"TapDetectingView")]) {
        [self endEditing:YES];
        if (self.isShow) {
            [[NSNotificationCenter defaultCenter]postNotificationName:_NotificationStackMenuDismiss object:self];
        }
    }
    return hitView;
}

@end


/**
 *  Little View
 */
@interface LittleViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textfieldProvince;
@property (weak, nonatomic) IBOutlet UITextField *textfieldEstablishment;

@end

@implementation LittleViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recurrenceIndexToZero:) name:_indexNumber object:nil];
    
}

- (IBAction)actionSearchClick:(id)sender {
    if (_littleViewSearchBlock) {
        NSLog(@"开始搜索!");
        if(_textfieldEstablishment.text.length && _textfieldEstablishment.text.length) _littleViewSearchBlock(_textfieldProvince.text,_textfieldEstablishment.text,_index++);
    }
}

-(void)recurrenceIndexToZero:(NSNotification *)notification{
    if ([notification.name isEqualToString:_indexNumber]) {
        self.index = 0;
        
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end






