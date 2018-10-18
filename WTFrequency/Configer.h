//
//  Configer.h
//  WTVariator
//
//  Created by WT on 2018/10/17.
//  Copyright © 2018年 王通. All rights reserved.
//

#ifndef Configer_h
#define Configer_h

/**
 *  手机屏幕尺寸及坐标值
 */
#define GLOBLE_SCREEN_SIZE [[UIScreen mainScreen] bounds].size
#define GLOBLE_SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define GLOBLE_SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define GLOBLE_STATUBAR_HEIGHT [[UIApplication sharedApplication] statusBarFrame].size.height

#define MAIN_LIGHT_WHITE_COLOR @"ebf2ef" //主色调-浅白
#define MAIN_WHITE_COLOR    @"ffffff"   //纯白色

#endif /* Configer_h */
