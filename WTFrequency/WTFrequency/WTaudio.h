//-----------------------------------------------------------------------------
// name: WTaudio.h
// authors: Tong Wang (Email:wangtong_vip@163.com | QQ:1165769699)
//-----------------------------------------------------------------------------

#ifndef __WT_AUDIO_H__
#define __WT_AUDIO_H__

// headers
#include "WTdef.h"
#include <AudioUnit/AudioUnit.h>

// type definition for audio callback function
typedef void (* MoCallback)( Float32 * buffer, UInt32 numFrames, void * userData );


//-----------------------------------------------------------------------------
// name: struct MoAudioUnitInfo (was: SMuleAudioUnitInfo)
// desc: a data structure to manage information needed by audio unit
//-----------------------------------------------------------------------------
struct MoAudioUnitInfo
{
    AudioStreamBasicDescription     m_dataFormat;
    UInt32                          m_bufferSize; // # of frames
    UInt32                          m_bufferByteSize;
    Float32 *                       m_ioBuffer;
    bool                            m_done;
    
    // constructor
    MoAudioUnitInfo()
    {
        m_bufferSize = 4096; // max
        m_bufferByteSize = 0;
        m_ioBuffer = NULL;
        m_done = false;
    }
    
    // desctructor
    ~MoAudioUnitInfo()
    {
        m_bufferSize = 4096;
        m_bufferByteSize = 0;
        SAFE_DELETE_ARRAY( m_ioBuffer );
    }
};




//-----------------------------------------------------------------------------
// name: class MoAudicle (was: SMALL)
// desc: MoPhO Audio API (was: SMule Audio Layer & Library)
//-----------------------------------------------------------------------------
class MoAudio
{
public:
    static bool init( Float64 srate, UInt32 frameSize, UInt32 numChannels, bool enableBuiltInAEC );
//    static bool init( Float64 srate, UInt32 frameSize, UInt32 numChannels );
    static bool start( MoCallback callback, void * bindle );
    static void stop();
    static void shutdown();
    static Float64 getSampleRate() { return m_srate; }
    static void vibrate();
    
public: // sketchy public
    static void checkInput();

protected:
    static bool initOut();
    static bool initIn();
    
protected:
    static bool m_hasInit;
    static bool m_isRunning;

public: // ge: making this public was a hack
    static MoAudioUnitInfo * m_info;
    static MoCallback m_callback;
    // static Float32 * m_buffer;
    // static UInt32 m_bufferFrames;
    static AudioUnit m_au;
    static bool m_isMute;
    static bool m_handleInput;
    static Float64 m_hwSampleRate;
    static Float64 m_srate;
    static UInt32 m_frameSize;
    static UInt32 m_numChannels;
    static void * m_bindle;
    
    static bool builtIntAEC_Enabled;
    static bool isRunning();
    
    // audio unit remote I/O
    static AURenderCallbackStruct m_renderProc;
};


#endif
