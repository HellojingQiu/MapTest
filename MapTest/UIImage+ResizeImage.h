//
//  UIImage+ResizeImage.h
//  MapTest
//
//  Created by JokerV on 15/6/8.
//  Copyright (c) 2015年 JokerV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ResizeImage)

+ (UIImage*)resizeImage:(UIImage*)image withWidth:(CGFloat)width withHeight:(CGFloat)height;

-(UIImage *)imageWithColor:(UIColor *)color;

-(UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

@end

@interface UIColor (ConvertToRGBA)

-(NSMutableArray *)convertUIColorToRGBA;

@end

@interface OptionPublic : NSObject

+(NSString *)getDataSizeString:(int)nSize;

+(NSString *) getFilepathWithName:(NSString *)filename WithBundlePath:(NSString *) bundlepath;
@end