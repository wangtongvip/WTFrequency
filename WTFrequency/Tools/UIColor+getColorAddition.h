//
//  UIColor+ColorAddition.h
//  Develop
//
//  Created by bjyb079 on 14-7-24.
//  Copyright (c) 2014年 Duzexu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (getColorAddition)

/**
 *  16进制颜色转RGB
 *
 *  @param hexColor 16进制颜色
 *
 *  @return color
 */
+ (UIColor *)getColor:(NSString *)hexColor;

@end
