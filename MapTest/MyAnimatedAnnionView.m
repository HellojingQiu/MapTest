//
//  MyAnimatedAnnionView.m
//  MapTest
//
//  Created by JokerV on 15/6/9.
//  Copyright (c) 2015年 JokerV. All rights reserved.
//

#import "MyAnimatedAnnionView.h"

@implementation MyAnimatedAnnionView

-(id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        [self setBounds:CGRectMake(0, 0, 32, 32)];//Bounds
        [self setBackgroundColor:[UIColor clearColor]];
        _annotationImageView = [[UIImageView alloc]initWithFrame:self.bounds];
        _annotationImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_annotationImageView];
    }
    return self;
}

/**
 *  annotationImages的set funcation
 *
 *  @param annotationImages image array
 */
-(void)setAnnotationImages:(NSMutableArray *)annotationImages{
    _annotationImages = annotationImages;
    [self updateImageView];
}


/**
 *  Update Annotation
 */
-(void)updateImageView{
    if ([_annotationImageView isAnimating]) [_annotationImageView stopAnimating];
    
    _annotationImageView.animationImages = _annotationImages;
    _annotationImageView.animationDuration = 0.5* _annotationImages.count;
    _annotationImageView.animationRepeatCount = 0;
    [_annotationImageView startAnimating];
}

@end
