//
//  UIColor+ColorAddition.m
//  Develop
//
//  Created by bjyb079 on 14-7-24.
//  Copyright (c) 2014年 Duzexu. All rights reserved.
//

#import "UIColor+getColorAddition.h"

@implementation UIColor (getColorAddition)

/**
 *  16进制颜色转RGB
 *
 *  @param hexColor 16进制颜色
 *
 *  @return color
 */
+ (UIColor *)getColor:(NSString *)hexColor
{
    unsigned int red, green, blue;
    NSRange range;
    range.length = 2;
    
    range.location = 0;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
    
    range.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
    
    range.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
    
    //NSLog(@"%d %d %d",red,green,blue);
    
    return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green / 255.0f) blue:(float)(blue / 255.0f) alpha:1.0f];
}

@end
