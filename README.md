# WTFrequency
简单的调音器，获取声音频率，可根据声音频率判别音调。

<br>
<br>

### 如何使用

> #### 1、工具类文件在`WTFrequency`文件夹下,将项目中的WTFrequency文件拖入您的工程中。
>
> #### 2、添加相关的依赖库
> 
>> libsqlite3.dylib
>> 
>> libicucore.A.dylib
>> 
>> libz.1.dylib
>> 
>> libstdc++.6.0.9.dylib
>> 
>> AudioToolbox.framework
>> 
>> AVFoundation.framework
>> 
>
> #### 3、频率采集器的入口类是`WT_HZ`
> 
> ```
> //创建频率采集器
> [WTHZ creatWTAudio];
> 
> //频率采集器开始工作，在block中返回当前监听到的声音频率
> [WTHZ startWTAudioCallBack:^(float MAX_HZ) {
>     //do any you want todo
> }];
> 
> //停止频率采集
> [WTHZ stopWTAudio];
> 
> //销毁频率采集器
> [WTHZ destroyWTAudio];
> 
> ```
> 
> #### 4、注意事项
>> 
>> 高版本的Xcode找不到`libstdc++.6.0.9.dylib`库，可以手动下载并导入：
>> 
>> 1） 下载链接：[https://pan.baidu.com/s/1jxYTmk-F02G6jM46dwjHXA]()  密码:v6ti
>> 
>> 2） 导入方法：将下载的库拷贝到如下路径
>> 
>> ```
>> //设备
>> /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/lib/
>> 
>> //模拟器
>> /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk/usr/lib/
>> ```
>> 
>> 3） 使用导入的库：Project - Targets - Build Phases - Link Binary With Libraries - add - Add Other - 键盘点击 command + sift + G - 寻址路径中输入 /usr/lib - 找到你需要的依赖库选中添加。
>> 
>> 由于ios系统目前已经淘汰 .dylib 为后缀的库，统一改用 .tdb ，所以需要依赖 .dylib 的库，也可以按照 3）中的方法设置依赖。