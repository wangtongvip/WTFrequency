//-----------------------------------------------------------------------------
// name: WT_HZ.h
// authors: Tong Wang (Email:wangtong_vip@163.com | QQ:1165769699)
//-----------------------------------------------------------------------------

#import <Foundation/Foundation.h>

#define WTHZ [WT_HZ shareWT_HZ]
typedef void (^callBackBlock)(float MAX_HZ);
@interface WT_HZ : NSObject

@property (nonatomic, strong) callBackBlock block;

+ (WT_HZ*)shareWT_HZ;

/*
 *  创建频率监测器
 */
- (void)creatWTAudio;

/*
 *  开始监测
 */
- (void)startWTAudioCallBack:(callBackBlock)callBack;

/*
 *  停止监测
 */
- (void)stopWTAudio;

/*
 *  销毁监测器
 */
- (void)destroyWTAudio;

@end
