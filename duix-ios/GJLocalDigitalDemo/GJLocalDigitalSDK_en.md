## Silicon Basic Edition DUIX SDK Usage Document (1.0.3)

### Development Environment
Development Tool: Xcode ios12.0 and above iphoneX and above

## Quick Start

```
          NSString *basePath =[NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] bundlePath],@"gj_dh_res"];
          NSString *digitalPath =[NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] bundlePath],@"lixin_a_540s"];
      
        //Initialize
       NSInteger result=   [[GJLDigitalManager manager] initBaseModel:basePath digitalModel:digitalPath showView:weakSelf.showView];
        if(result==1)
        {
           //Start
            [[GJLDigitalManager manager] toStart:^(BOOL isSuccess, NSString *errorMsg) {
                if(!isSuccess)
                {
                    [SVProgressHUD showInfoWithStatus:errorMsg];
                }
            }];
        }
```

```
## Calling Process
```

1. Prepare the basic configuration and model files required for the synchronous digital person before starting the service.
2. Initialize the digital person rendering service.
3. Call the toStart function to start rendering the digital person
4. Call the toSpeakWithPath function to drive the digital person to broadcast.
5. Call cancelAudioPlay to actively stop broadcasting.
6. Call toStop to end and release the digital person rendering

```
### SDK Callback
```

/*

*Digital person rendering error callback

* -1 uninitialized 50009 resource timeout or not configured

*/ 

@property (nonatomic, copy) void (^playFailed)(NSInteger code,NSString *errorMsg);

/*

*Audio playback end callback 

*/ 

@property (nonatomic, copy) void (^audioPlayEnd)(void);

/*

*Audio playback progress callback 

/

@property (nonatomic, copy) void (^audioPlayProgress)(float current,float total);

```
## Methods
```

### Initialization

```
/*
*basePath Base common model path - remains unchanged
*digitalPath Digital person model path - only need to replace this path to replace the digital person
*return 1 Success  -1 Initialization failed
*showView Display interface
*/
-(NSInteger)initBaseModel:(NSString*)basePath digitalModel:(NSString*)digitalPath showView:(UIView*)showView;
```

### Replace background

```
/*
* bbgPath Replace background
* Note: -jpg format ----Background size equals the digital person model's getDigitalSize-----------
*/
-(void)toChangeBBGWithPath:(NSString*)bbgPath;
```

### Play audio

```
/*
*wavPath Local path of audio
*1 channel ,16 bit deep,16000 sampling rate, WAV local file
*/
-(void)toSpeakWithPath:(NSString*)wavPath;
```

### Start rendering digital person

```
/*
*Start
*/
-(void)toStart:(void (^) (BOOL isSuccess, NSString *errorMsg))block;
```

### End rendering digital person and release

```
/*
*End
*/
-(void)toStop;
```

### Width and height of digital person model

```
/*
*After initializing the model, you can get it
*getDigitalSize Width of digital person model Height of digital person model
*/
-(CGSize)getDigitalSize;
```

### Cancel playing audio

```
/*
*Cancel playing audio
*/
-(void)cancelAudioPlay;
```

<br>

## Action

### Random action

```
/*
* Call before starting the action
* Random action (a piece of text contains multiple audios, it is recommended to set the random action when the first audio starts)
* return 0 Digital person model does not support random action 1 Digital person model supports random action
*/
-(NSInteger)toRandomMotion;
```

### Start action

```
/*
* Start action (a piece of text contains multiple audios, set when the first audio starts)
* return 0 Digital person model does not support starting action 1 Digital person model supports starting action
*/
-(NSInteger)toStartMotion;
```

### End action

```
/*
* End action (a piece of text contains multiple audios, set when the last audio ends)
*isQuickly YES End the action immediately NO Wait for the action to play before silencing
*return 0 Digital person model does not support ending action 1 Digital person model supports ending action
*/
-(NSInteger)toSopMotion:(BOOL)isQuickly;
```

### Start playing digital person after pause

```
/*
*Play digital person after pause
*/
-(void)toPlay;
```

### Pause digital person playback

```
/*
*Pause digital person playback
*/
-(void)toPause;
```

## Other related third-party open source projects

| Module                                                       | Description                                         |
| ------------------------------------------------------------ | --------------------------------------------------- |
| [libjpeg-turbo](https://github.com/libjpeg-turbo/libjpeg-turbo) | Image processing library                            |
| [onnx](https://github.com/onnx/onnx)                         | AI framework                                        |
| [ncnn](https://github.com/Tencent/ncnn)                      | High-performance neural network inference framework |
