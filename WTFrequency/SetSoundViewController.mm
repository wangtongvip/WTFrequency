//
//  SetSoundViewController.mm
//  WTVariator
//
//  Created by WT on 2018/10/17.
//  Copyright © 2018年 王通. All rights reserved.
//

#import "SetSoundViewController.h"
#import "WT_HZ.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "UIColor+getColorAddition.h"

#define SETSOUNDVIEWCONTROLLER_BACK_COLOR @"424242"
#define SETSOUNDVIEWCONTROLLER_GUITAR_COLOR @"71c671"

#define SHOW_CURRENT_HZ (0) //是否显示当期HZ
#define SHOW_SENSITIVITY (0) //是否显示控制灵敏度的输入框
#define CONTROLLER_HZ_AREA (0) //是否控制检测赫兹的范围
#define SET_SOUNDVIEW_LABEL_FONT(__label, __size) [__label setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:__size]]

@interface SetSoundViewController ()

@end

@implementation SetSoundViewController {
    UILabel *_ffpLabel;
    NSArray *_HZArray;
    NSDictionary *_standerd_note;
    
    NSDictionary *_correct_note;
    NSArray *_correct_HZArray;
    NSDictionary *_dic_correct_standerd;
    NSDictionary *_dic_standerd_correct;
    
    UIImageView *_animationLabel;
    NSString *_lastMidHZ;
    AVAudioRecorder *_recorder;
    BOOL _isShowing;
    
    //手动输入灵敏度的输入框
    UITextField *_sensitivity_start;
    UITextField *_sensitivity_stop;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //--------------------检测mic获取的声音分贝-------------------
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
    /* 不需要保存录音文件 */
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat: 44100.0], AVSampleRateKey, [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey, [NSNumber numberWithInt: 2], AVNumberOfChannelsKey, [NSNumber numberWithInt: AVAudioQualityMax], AVEncoderAudioQualityKey, nil];
    NSError *error;
    _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    if (_recorder) {
        [_recorder prepareToRecord];
        _recorder.meteringEnabled = YES;
        [_recorder record];
    } else {
        NSLog(@"%@", [error description]);
    }
    //---------------------------------------------------------
    
    //UI
    [self testUI];
    
    /**
     *
     *  检测声音频率的核心
     *
     *  将检测到的声音频率，通过HZArray.plist和standerd_note.plist对应的声音频率表，翻译成对应的音调
     */
    // initialize stuff
    [WTHZ creatWTAudio];
    [WTHZ startWTAudioCallBack:^(float MAX_HZ) {
        [self changeUIWithHZParmaters:MAX_HZ];
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [WTHZ destroyWTAudio];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark- UI 以下是longlongago的UI，冗余复杂小白。。。

- (void)testUI {
    [self.view setBackgroundColor:[UIColor getColor:SETSOUNDVIEWCONTROLLER_BACK_COLOR]];
    UIImageView *backImage= [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [backImage setImage:[UIImage imageNamed:@"Tuner_Metronome_Background.jpg"]];
    [self.view addSubview:backImage];
    self.title = @"调音器";
    
    _HZArray = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"HZArray" ofType:@"plist"]];
    _standerd_note = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"standerd_note" ofType:@"plist"]];
    
#if SHOW_CURRENT_HZ
    UILabel *currentHZ = [[UILabel alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height + GLOBLE_STATUBAR_HEIGHT, GLOBLE_SCREEN_WIDTH, GLOBLE_STATUBAR_HEIGHT * 2)];
    [currentHZ setBackgroundColor:[UIColor clearColor]];
    [currentHZ setTextColor:[UIColor getColor:MAIN_WHITE_COLOR]];
    [currentHZ setTag:3000];
    [self.view addSubview:currentHZ];
#endif
    
    float midW = (GLOBLE_SCREEN_WIDTH - 30) / 4;
    float stayW = midW * .8f;
    float boarderW = stayW * .8f;
    
    float mCX = GLOBLE_SCREEN_WIDTH / 2;
    float lsCX = GLOBLE_SCREEN_WIDTH / 2 - midW / 2 - stayW / 2;
    float rsCX = GLOBLE_SCREEN_WIDTH / 2 + midW / 2 + stayW / 2;
    float lbCX = lsCX - stayW / 2 - boarderW / 2;
    float rbCX = rsCX + stayW / 2 + boarderW / 2;
    
    for (int i = 0; i < 5; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((GLOBLE_SCREEN_WIDTH - 30) / 4 * i + 15, i == 2 ? GLOBLE_SCREEN_HEIGHT / 5 : GLOBLE_SCREEN_HEIGHT / 5 + GLOBLE_STATUBAR_HEIGHT * 1.5, 1, i == 2 ? GLOBLE_SCREEN_HEIGHT / 3 : GLOBLE_SCREEN_HEIGHT / 3 - GLOBLE_STATUBAR_HEIGHT * 1.5)];
        [label setBackgroundColor:[UIColor getColor:MAIN_WHITE_COLOR]];
        [self.view addSubview:label];
        [label setCenter:CGPointMake((GLOBLE_SCREEN_WIDTH - 30) / 4 * i + 15, label.center.y)];
        
        //draw sub line
        if (i < 4) {
            for (int j = 0; j < 9; j++) {
                UILabel *subLine = [[UILabel alloc] initWithFrame:CGRectMake((GLOBLE_SCREEN_WIDTH - 30) / 4 / 10 * (j + 1), GLOBLE_SCREEN_HEIGHT / 5 + self.navigationController.navigationBar.frame.size.height + GLOBLE_STATUBAR_HEIGHT, 1, GLOBLE_SCREEN_HEIGHT / 3 - self.navigationController.navigationBar.frame.size.height - GLOBLE_STATUBAR_HEIGHT)];
                [subLine setBackgroundColor:[UIColor getColor:MAIN_WHITE_COLOR]];
                [subLine setAlpha:.6f];
                [subLine setCenter:CGPointMake((GLOBLE_SCREEN_WIDTH - 30) / 4 / 10 * (j + 1) + label.center.x, subLine.center.y)];
                [self.view addSubview:subLine];
            }
        }
        
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(GLOBLE_SCREEN_WIDTH / 3 * (i / 2), CGRectGetMaxY(label.frame) + self.navigationController.navigationBar.frame.size.height * 1.5, GLOBLE_SCREEN_WIDTH / 3, GLOBLE_STATUBAR_HEIGHT * 2)];
        [l setBackgroundColor:[UIColor clearColor]];
        [l setTextAlignment:NSTextAlignmentCenter];
        [l setTag:2000 + i];
        [l setTextColor:[UIColor getColor:MAIN_WHITE_COLOR]];
        if (i == 2) {
            l.layer.cornerRadius = 3.f;
            l.layer.masksToBounds = YES;
            l.layer.borderColor = [UIColor getColor:MAIN_LIGHT_WHITE_COLOR].CGColor;
            l.layer.borderWidth = 0;
        }
        [self.view addSubview:l];
        
        switch (i) {
            case 0:{
                SET_SOUNDVIEW_LABEL_FONT(l, 25);
                [l setAlpha:.6];
                [l setFrame:CGRectMake(0, 0, boarderW, boarderW)];
                [l setCenter:CGPointMake(lbCX, CGRectGetMaxY(label.frame) + self.navigationController.navigationBar.frame.size.height * 1.5)];
                break;
            }
            case 1:{
                SET_SOUNDVIEW_LABEL_FONT(l, 35);
                [l setAlpha:.8];
                [l setFrame:CGRectMake(0, 0, stayW, stayW)];
                [l setCenter:CGPointMake(lsCX, CGRectGetMaxY(label.frame) + self.navigationController.navigationBar.frame.size.height * 1.5)];
                break;
            }
            case 2:{
                SET_SOUNDVIEW_LABEL_FONT(l, 45);
                [l setFrame:CGRectMake(0, 0, midW, midW)];
                [l setCenter:CGPointMake(mCX, CGRectGetMaxY(label.frame) + self.navigationController.navigationBar.frame.size.height * 1.5)];
                break;
            }
            case 3:{
                SET_SOUNDVIEW_LABEL_FONT(l, 35);
                [l setAlpha:.8];
                [l setFrame:CGRectMake(0, 0, stayW, stayW)];
                [l setCenter:CGPointMake(rsCX, CGRectGetMaxY(label.frame) + self.navigationController.navigationBar.frame.size.height * 1.5)];
                break;
            }
            case 4:{
                SET_SOUNDVIEW_LABEL_FONT(l, 25);
                [l setAlpha:.6];
                [l setFrame:CGRectMake(0, 0, boarderW, boarderW)];
                [l setCenter:CGPointMake(rbCX, CGRectGetMaxY(label.frame) + self.navigationController.navigationBar.frame.size.height * 1.5)];
                break;
            }
            default:
                break;
        }
    }
    
    UIImage *pin = [UIImage imageNamed:@"tools_soundSetting_pin.png"];
    _animationLabel = [[UIImageView alloc] initWithFrame:CGRectMake(GLOBLE_SCREEN_WIDTH / 2, GLOBLE_SCREEN_HEIGHT / 5 - 3, 8, GLOBLE_SCREEN_HEIGHT / 3 + 6)];
    [_animationLabel setImage:pin];
    [_animationLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_animationLabel];
    [_animationLabel setCenter:CGPointMake(GLOBLE_SCREEN_WIDTH / 2, _animationLabel.center.y)];
    
#if SHOW_SENSITIVITY
    _sensitivity_start = [[UITextField alloc] initWithFrame:CGRectMake(10, 64 + 5, (GLOBLE_SCREEN_WIDTH - 30) / 2, 25)];
    [_sensitivity_start setBackgroundColor:[UIColor clearColor]];
    _sensitivity_start.layer.borderColor = [UIColor getColor:MAIN_WHITE_COLOR].CGColor;
    _sensitivity_start.layer.borderWidth = 1;
    _sensitivity_start.layer.cornerRadius = 5;
    _sensitivity_start.textColor = [UIColor getColor:MAIN_WHITE_COLOR];
    _sensitivity_start.font = [UIFont systemFontOfSize:12];
    _sensitivity_start.keyboardType = UIKeyboardTypeDecimalPad;
    _sensitivity_start.delegate = self;
    _sensitivity_start.placeholder = @"触发参数0~120（默认25）";
    [self.view addSubview:_sensitivity_start];
    
    _sensitivity_stop = [[UITextField alloc] initWithFrame:CGRectMake((GLOBLE_SCREEN_WIDTH - 30) / 2 + 20, 64 + 5, (GLOBLE_SCREEN_WIDTH - 30) / 2, 25)];
    [_sensitivity_stop setBackgroundColor:[UIColor clearColor]];
    _sensitivity_stop.layer.borderColor = [UIColor getColor:MAIN_WHITE_COLOR].CGColor;
    _sensitivity_stop.layer.borderWidth = 1;
    _sensitivity_stop.layer.cornerRadius = 5;
    _sensitivity_stop.textColor = [UIColor getColor:MAIN_WHITE_COLOR];
    _sensitivity_stop.font = [UIFont systemFontOfSize:12];
    _sensitivity_stop.keyboardType = UIKeyboardTypeDecimalPad;
    _sensitivity_stop.delegate = self;
    _sensitivity_stop.placeholder = @"停止参数0~120（默认10）";
    [self.view addSubview:_sensitivity_stop];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardResignFirst:)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
#endif
}

- (void)changeUIWithHZParmaters:(float)MAX_HZ {
    float CURRENT_MAX_HZ = MAX_HZ;
    
    if (_isShowing) {
        [(UILabel *)[self.view viewWithTag:3000] setText:[NSString stringWithFormat:@"current HZ :   %0.3f HZ",CURRENT_MAX_HZ]];
    } else {
        [(UILabel *)[self.view viewWithTag:3000] setText:@"current HZ :"];
    }
    
    float standerdStartDB = 25;
    float standerdStopDB = 10;
#if SHOW_SENSITIVITY
    if (_sensitivity_start.text.length > 0) {
        standerdStartDB = [_sensitivity_start.text floatValue];
    }
    
    if (_sensitivity_stop.text.length > 0) {
        standerdStopDB = [_sensitivity_stop.text floatValue];
    }
#endif
    NSLog(@"standerdStartDB :%f", standerdStartDB);
    NSLog(@"standerdStopDB :%f", standerdStopDB);
    
    float currentDB = [self chickMicDB];
    //超过standerdStartDB分贝开始显示频率，在显示的过程中分贝低于standerdStopDB，就停止
    if (_isShowing) {
        if (currentDB < standerdStopDB) {
            _isShowing = NO;
            
            [self formatMusicalNote:(UILabel *)[self.view viewWithTag:2000] andText:@""];
            [self formatMusicalNote:(UILabel *)[self.view viewWithTag:2001] andText:@""];
            [self formatMusicalNote:(UILabel *)[self.view viewWithTag:2002] andText:@""];
            [self formatMusicalNote:(UILabel *)[self.view viewWithTag:2003] andText:@""];
            [self formatMusicalNote:(UILabel *)[self.view viewWithTag:2004] andText:@""];
            
            [(UILabel *)[self.view viewWithTag:3000] setText:@""];
            
            [_animationLabel setCenter:CGPointMake(GLOBLE_SCREEN_WIDTH / 2, _animationLabel.center.y)];
        }
    } else {
        if (currentDB >= standerdStartDB) {
            _isShowing = YES;
        }
    }
    
    if (!_isShowing) {
        /**
         *  如果没有声音，默认停留在A3
         *  将注释return打开，就不默认停留
         */
        //return;
        CURRENT_MAX_HZ = 219.8;
    }
    
#if CONTROLLER_HZ_AREA
    NSLog(@"当前声音的HZ ： %f",CURRENT_MAX_HZ);
    //暂时控制的赫兹范围
    if (CURRENT_MAX_HZ < 128 || CURRENT_MAX_HZ > 1000) {
        [self formatMusicalNote:(UILabel *)[self.view viewWithTag:2000] andText:@""];
        [self formatMusicalNote:(UILabel *)[self.view viewWithTag:2001] andText:@""];
        [self formatMusicalNote:(UILabel *)[self.view viewWithTag:2002] andText:@""];
        [self formatMusicalNote:(UILabel *)[self.view viewWithTag:2003] andText:@""];
        [self formatMusicalNote:(UILabel *)[self.view viewWithTag:2004] andText:@""];
        
        [(UILabel *)[self.view viewWithTag:3000] setText:@""];
        
        [_animationLabel setCenter:CGPointMake(GLOBLE_SCREEN_WIDTH / 2, _animationLabel.center.y)];
        return;
    }
#endif

    NSString *leftNoteHZ = @"";
    NSString *rightNoteHZ = @"";
    NSString * midNoteHZ = @"";
    
    NSString *minNoteHZ = @"";
    NSString *maxNoteHZ = @"";
    for (int i = 0; i < [_HZArray count]; i++) {
        if (CURRENT_MAX_HZ < [_HZArray[i] floatValue]) {
            if (i - 3 < 0 || i + 2 >= [_HZArray count]) {
                return;
            }
            float midF = ([_HZArray[i - 1] floatValue] + [_HZArray[i] floatValue]) / 2;
            if (CURRENT_MAX_HZ >= midF) {
                minNoteHZ = _HZArray[i - 2];
                midNoteHZ = _HZArray[i];
                leftNoteHZ = _HZArray[i - 1];
                rightNoteHZ = _HZArray[i + 1];
                maxNoteHZ = _HZArray[i + 2];
            } else {
                minNoteHZ = _HZArray[i - 3];
                midNoteHZ = _HZArray[i - 1];
                leftNoteHZ = _HZArray[i - 2];
                rightNoteHZ = _HZArray[i];
                maxNoteHZ = _HZArray[i + 1];
            }
            break;
        }
    }
    
    if ([leftNoteHZ isEqualToString:@""] ||
        [midNoteHZ isEqualToString:@""] ||
        [rightNoteHZ isEqualToString:@""]) {
        return;
    }
    
    /*
     NSLog(@"\n leftNoteHZ:%@\n midNoteHZ:%@\n rightNoteHZ:%@",leftNoteHZ, midNoteHZ, rightNoteHZ);
     */
    
    float rightCenter = ([rightNoteHZ floatValue] + [midNoteHZ floatValue]) / 2;
    float leftCenter = ([midNoteHZ floatValue] + [leftNoteHZ floatValue]) / 2;
    float distance = rightCenter - leftCenter;
    float centerX = (GLOBLE_SCREEN_WIDTH - 20) / 4 + 15 + (GLOBLE_SCREEN_WIDTH - 20) / 2 * (CURRENT_MAX_HZ - leftCenter) / distance;
    if ([_lastMidHZ isEqualToString:midNoteHZ]) {
        [UIView animateWithDuration:.8f animations:^{
            [self->_animationLabel setCenter:CGPointMake(centerX, self->_animationLabel.center.y)];
        } completion:^(BOOL finished) {
        }];
    } else if ([_lastMidHZ floatValue] < [midNoteHZ floatValue]){
        //  减弱动画
        [UIView animateWithDuration:.8f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            [self->_animationLabel setCenter:CGPointMake(centerX, self->_animationLabel.center.y)];
        } completion:^(BOOL finished) {
        }];
        
        /*
        [UIView animateWithDuration:.2f animations:^{
            [_animationLabel setCenter:CGPointMake(GLOBLE_SCREEN_WIDTH, _animationLabel.center.y)];
        } completion:^(BOOL finished) {
            [_animationLabel setCenter:CGPointMake(0, _animationLabel.center.y)];
            [UIView animateWithDuration:.2f animations:^{
                [_animationLabel setCenter:CGPointMake(centerX, _animationLabel.center.y)];
            } completion:^(BOOL finished) {
            }];
        }];
        */
    } else {
        //  减弱动画
        [UIView animateWithDuration:.8f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            [self->_animationLabel setCenter:CGPointMake(centerX, self->_animationLabel.center.y)];
        } completion:^(BOOL finished) {
        }];
        
        /*
        [UIView animateWithDuration:.2f animations:^{
            [_animationLabel setCenter:CGPointMake(0, _animationLabel.center.y)];
        } completion:^(BOOL finished) {
            [_animationLabel setCenter:CGPointMake(GLOBLE_SCREEN_WIDTH, _animationLabel.center.y)];
            [UIView animateWithDuration:.2f animations:^{
                [_animationLabel setCenter:CGPointMake(centerX, _animationLabel.center.y)];
            } completion:^(BOOL finished) {
            }];
        }];
        */
    }
    
    _lastMidHZ = midNoteHZ;
    
    [self formatMusicalNote:(UILabel *)[self.view viewWithTag:2000] andText:_standerd_note[minNoteHZ]];
    [self formatMusicalNote:(UILabel *)[self.view viewWithTag:2001] andText:_standerd_note[leftNoteHZ]];
    [self formatMusicalNote:(UILabel *)[self.view viewWithTag:2002] andText:_standerd_note[midNoteHZ]];
    [self formatMusicalNote:(UILabel *)[self.view viewWithTag:2003] andText:_standerd_note[rightNoteHZ]];
    [self formatMusicalNote:(UILabel *)[self.view viewWithTag:2004] andText:_standerd_note[maxNoteHZ]];
}

- (float)chickMicDB {
    [_recorder updateMeters];
    float level; // The linear 0.0 .. 1.0 value we need.
    float minDecibels = -80.0f; // Or use -60dB, which I measured in a silent room.
    float decibels = [_recorder averagePowerForChannel:0];
    if (decibels < minDecibels) {
        level = 0.0f * 120;
        return level;
    } else if (decibels >= 0.0f) {
        level = 1.0f * 120;
        return level;
    } else {
        float root = 2.0f;
        float minAmp = powf(10.0f, 0.05f * minDecibels);
        float inverseAmpRange = 1.0f / (1.0f - minAmp);
        float amp = powf(10.0f, 0.05f * decibels);
        float adjAmp = (amp - minAmp) * inverseAmpRange;
        level = powf(adjAmp, 1.0f / root) * 120;/* level 范围[0 ~ 1], 转为[0 ~120] 之间 */
        NSLog(@"level  :    %f",level);
        return level;
    }
}

- (void)formatMusicalNote:(UILabel *)label andText:(NSString *)text {
    if (text == nil || text.length <= 0 || [text isEqualToString:@""]) {
        for (UILabel *l in label.subviews) {
            [l removeFromSuperview];
        }
        label.layer.borderWidth = 0;
        [label setText:@""];
        return;
    }
    NSString *mineNote = [[text componentsSeparatedByString:@"-"][0] stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSString *upNote = [text componentsSeparatedByString:@"-"][0];
    if ([upNote rangeOfString:@"#"].location !=NSNotFound) {
        upNote = @"#";
    } else {
        upNote = @"";
    }
    NSString *downNote = [text componentsSeparatedByString:@"-"][1];
    
    //  设置标签文字的属性
    NSMutableAttributedString *attrituteString = [[NSMutableAttributedString alloc] initWithString:[mineNote stringByAppendingString:@"*"]];
    for (int i = 0; i < [mineNote stringByAppendingString:@"*"].length; i++) {
        char v = [[mineNote stringByAppendingString:@"*"] characterAtIndex:i];
        if (v == '*') {
            [attrituteString setAttributes: @{ NSForegroundColorAttributeName : [UIColor clearColor]}  range:NSMakeRange(i, 1)];
        }
    }
    [label setAttributedText:attrituteString];
    if (label.tag == 2002) {
        label.layer.borderWidth = 1;
    }
    
    for (UILabel *l in label.subviews) {
        [l removeFromSuperview];
    }
    UILabel *upLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(label.frame) / 2, 0, CGRectGetWidth(label.frame) / 2, CGRectGetWidth(label.frame) / 2)];
    [upLabel setBackgroundColor:[UIColor clearColor]];
    [upLabel setText:upNote];
    [upLabel setTextAlignment:NSTextAlignmentCenter];
    SET_SOUNDVIEW_LABEL_FONT(upLabel, label.font.pointSize * .5);
    [upLabel setTextColor:[UIColor getColor:MAIN_WHITE_COLOR]];
    [label addSubview:upLabel];
    UILabel *downLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(label.frame) / 2, CGRectGetWidth(label.frame) / 2, CGRectGetWidth(label.frame) / 2, CGRectGetWidth(label.frame) / 2)];
    [downLabel setBackgroundColor:[UIColor clearColor]];
    [downLabel setText:downNote];
    [downLabel setTextAlignment:NSTextAlignmentCenter];
    SET_SOUNDVIEW_LABEL_FONT(downLabel, label.font.pointSize * .5);
    [downLabel setTextColor:[UIColor getColor:MAIN_WHITE_COLOR]];
    [label addSubview:downLabel];
}

#pragma mark- UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [WTHZ stopWTAudio];
    return YES;
}

//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    [_sensitivity resignFirstResponder];
//    [WTHZ startWTAudioCallBack:^(float MAX_HZ) {
//        [self changeUIWithHZParmaters:MAX_HZ];
//    }];
//    
//    return YES;
//}

- (void)keyboardResignFirst:(UIGestureRecognizer *)sender {
    if ([_sensitivity_start isFirstResponder] || [_sensitivity_stop isFirstResponder]) {
        [_sensitivity_start resignFirstResponder];
        [_sensitivity_stop resignFirstResponder];
        [WTHZ startWTAudioCallBack:^(float MAX_HZ) {
            [self changeUIWithHZParmaters:MAX_HZ];
        }];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
