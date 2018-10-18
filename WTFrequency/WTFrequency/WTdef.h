//-----------------------------------------------------------------------------
// name: WTdef.h
// authors: Tong Wang (Email:wangtong_vip@163.com | QQ:1165769699)
//-----------------------------------------------------------------------------

#ifndef __WT_DEF_H__
#define __WT_DEF_H__

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

// pi
#define ONE_PI (3.14159265358979323846)
#define TWO_PI (2.0 * ONE_PI)
#define SQRT2  (1.41421356237309504880)
#define PI_OVER_180 (ONE_PI / 180.0)

// safe object deletion
#define SAFE_DELETE(x) { delete x; x = NULL; }
#define SAFE_DELETE_ARRAY(x) { delete [] x; x = NULL; }

// mo stuff
#ifndef SAMPLE
#define SAMPLE Float32
#endif


#endif
