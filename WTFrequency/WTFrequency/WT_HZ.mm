//-----------------------------------------------------------------------------
// name: WT_HZ.mm
// authors: Tong Wang (Email:wangtong_vip@163.com | QQ:1165769699)
//-----------------------------------------------------------------------------

#import "WT_HZ.h"

#import "WTaudio.h" //stuff that helps set up low-level audio
#import "FFTHelper.h"


#define SAMPLE_RATE 11025  //5512 //11025 //22050 //44100
#define FRAMESIZE  512
#define NUMCHANNELS 2

#define kOutputBus 0
#define kInputBus 1

/// Nyquist Maximum Frequency
const Float32 NyquistMaxFreq = SAMPLE_RATE/2.0;

/// caculates HZ value for specified index from a FFT bins vector
Float32 frequencyHerzValue(long frequencyIndex, long fftVectorSize, Float32 nyquistFrequency ) {
    return ((Float32)frequencyIndex/(Float32)fftVectorSize) * nyquistFrequency;
}

// The Main FFT Helper
FFTHelperRef *fftConverter = NULL;

//Accumulator Buffer=====================

const UInt32 accumulatorDataLenght = 8192;  //8192; //16384; //32768; 65536; 131072;
UInt32 accumulatorFillIndex = 0;
Float32 *dataAccumulator = nil;

Float32 *mid = nil;

static void initializeAccumulator() {
    dataAccumulator = (Float32*) malloc(sizeof(Float32)*accumulatorDataLenght);
    accumulatorFillIndex = 0;
    
    mid = (Float32*) malloc(sizeof(Float32)*accumulatorDataLenght);
}
static void destroyAccumulator() {
    if (dataAccumulator!=NULL) {
        free(dataAccumulator);
        dataAccumulator = NULL;
    }
    if (mid != NULL) {
        free(mid);
        mid = NULL;
    }
    accumulatorFillIndex = 0;
}

static BOOL accumulateFrames(Float32 *frames, UInt32 lenght) { //returned YES if full, NO otherwise.
    //        float zero = 0.0;
    //        vDSP_vsmul(frames, 1, &zero, frames, 1, lenght);
    
    if (accumulatorFillIndex>=accumulatorDataLenght) { return YES; } else {
        memmove(dataAccumulator+accumulatorFillIndex, frames, sizeof(Float32)*lenght);
        accumulatorFillIndex = accumulatorFillIndex+lenght;
        if (accumulatorFillIndex>=accumulatorDataLenght) { return YES; }
    }
    return NO;
}

static void emptyAccumulator() {
    accumulatorFillIndex = accumulatorFillIndex / 2;
    
    memmove(mid, dataAccumulator + accumulatorFillIndex, sizeof(Float32)*accumulatorDataLenght / 2);
    
    memset(dataAccumulator, 0, sizeof(Float32)*accumulatorDataLenght);
    
    memmove(dataAccumulator, mid, sizeof(Float32)*accumulatorDataLenght / 2);
    
    memset(mid, 0, sizeof(Float32)*accumulatorDataLenght);
}
//=======================================


//==========================Window Buffer
const UInt32 windowLength = accumulatorDataLenght;
Float32 *windowBuffer= NULL;
//=======================================

/// max value from vector with value index (using Accelerate Framework)
static Float32 vectorMaxValueACC32_index(Float32 *vector, unsigned long size, long step, unsigned long *outIndex) {
    Float32 maxVal;
    vDSP_maxvi(vector, step, &maxVal, outIndex, size);
    return maxVal;
}

///returns HZ of the strongest frequency.
static Float32 strongestFrequencyHZ(Float32 *buffer, FFTHelperRef *fftHelper, UInt32 frameSize, Float32 *freqValue) {
    Float32 *fftData = computeFFT(fftHelper, buffer, frameSize);
    fftData[0] = 0.0;
    unsigned long length = frameSize/2.0;
    Float32 max = 0;
    unsigned long maxIndex = 0;
    max = vectorMaxValueACC32_index(fftData, length, 1, &maxIndex);
    if (freqValue!=NULL) { *freqValue = max; }
    Float32 HZ = frequencyHerzValue(maxIndex, length, NyquistMaxFreq);
    return HZ;
}

__weak WT_HZ *wt_hz = nil;

#pragma mark MAIN CALLBACK
void AudioCallback( Float32 * buffer, UInt32 frameSize, void * userData ) {
    //take only data from 1 channel
    Float32 zero = 0.0;
    vDSP_vsadd(buffer, 2, &zero, buffer, 1, frameSize*NUMCHANNELS);
    
    if (accumulateFrames(buffer, frameSize)==YES) { //if full
        //windowing the time domain data before FFT (using Blackman Window)
        if (windowBuffer==NULL) { windowBuffer = (Float32*) malloc(sizeof(Float32)*windowLength); }
        vDSP_blkman_window(windowBuffer, windowLength, 0);
        vDSP_vmul(dataAccumulator, 1, windowBuffer, 1, dataAccumulator, 1, accumulatorDataLenght);
        //=========================================
        
        Float32 maxHZValue = 0;
        Float32 maxHZ = strongestFrequencyHZ(dataAccumulator, fftConverter, accumulatorDataLenght, &maxHZValue);
        
        NSLog(@" max HZ = %0.3f ", maxHZ);
        
        dispatch_async(dispatch_get_main_queue(), ^{ //update UI only on main thread
            wt_hz.block(maxHZ);
        });
        
        emptyAccumulator(); //empty the accumulator when finished
    }
    memset(buffer, 0, sizeof(Float32)*frameSize*NUMCHANNELS);
}








static WT_HZ *shareWT_HZ = nil;

@interface WT_HZ ()

@end

@implementation WT_HZ

+ (WT_HZ*)shareWT_HZ
{
    if (shareWT_HZ == nil) {
        shareWT_HZ = [[super allocWithZone:NULL]init];
        wt_hz = shareWT_HZ;
    }
    return shareWT_HZ;
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

/*
 *  创建频率监测器
 */
- (void)creatWTAudio {
    fftConverter = FFTHelperCreate(accumulatorDataLenght);
    initializeAccumulator();
    bool result = false;
    result = MoAudio::init( SAMPLE_RATE, FRAMESIZE, NUMCHANNELS, false);
    if (!result) { NSLog(@" MoAudio init ERROR"); }
}

/*
 *  开始监测
 */
- (void)startWTAudioCallBack:(callBackBlock)callBack {
    _block = [callBack copy];
    bool result = false;
    result = MoAudio::start( AudioCallback, NULL );
    if (!result) { NSLog(@" MoAudio start ERROR"); }
}

/*
 *  停止监测
 */
- (void)stopWTAudio {
    MoAudio::stop();
}

/*
 *  销毁监测器
 */
- (void)destroyWTAudio {
    MoAudio::shutdown();
}

@end
