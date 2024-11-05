//
//  AVPlayerView.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "GJLAudioPlayerView.h"
//#import "NetworkHelper.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreServices/CoreServices.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

//#import "TapProcessor.h"
@interface GJLAudioPlayerView () <NSURLSessionTaskDelegate, NSURLSessionDataDelegate,AVAssetResourceLoaderDelegate>
@property (nonatomic ,strong) NSURL                *sourceURL;              //视频路径
@property (nonatomic ,strong) NSString             *sourceScheme;           //路径Scheme
@property (nonatomic ,strong) AVURLAsset           *urlAsset;               //视频资源

@property (nonatomic ,strong) AVPlayer             *player;                 //视频播放器
@property (nonatomic ,strong) AVPlayerLayer        *playerLayer;            //视频播放器图形化载体
@property (nonatomic ,strong) id                   timeObserver;            //视频播放器周期性调用的观察者

@property (nonatomic, copy) NSString               *mimeType;               //资源格式
@property (nonatomic, assign) long long            expectedContentLength;   //资源大小
//@property (nonatomic, strong) NSMutableArray       *pendingRequests;        //存储AVAssetResourceLoadingRequest的数组

@property (nonatomic, copy) NSString               *cacheFileKey;           //缓存文件key值
@property (nonatomic, strong) NSOperation          *queryCacheOperation;    //查找本地视频缓存数据的NSOperation
@property (nonatomic, strong) dispatch_queue_t     cancelLoadingQueue;

//@property (nonatomic, strong) WebCombineOperation  *combineOperation;

@property (nonatomic, assign) BOOL                 retried;

//背景图片
@property (nonatomic, strong) UIImageView * backImageView;

/** 播放按钮 */
@property (nonatomic, strong)UIButton * playBtn;
@property (nonatomic, strong) NSMutableArray<AVPlayer *>   *playerArray;  //用于存储AVPlayer的数组
@end

@implementation GJLAudioPlayerView
//重写initWithFrame
-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        if( [AVAudioSession sharedInstance].category==AVAudioSessionCategoryPlayback)
        {
     
                AVAudioSession *audioSession = [AVAudioSession sharedInstance];
                [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
                [audioSession setActive:YES error:nil];
                
                UInt32 doChangeDefault = 1;
                AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefault), &doChangeDefault);
        
            
        }
//        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
//        [audioSession setActive:YES error:nil];
        self.isCanPLay=YES;
        self.isAddProgress=YES;
        //初始化播放器
        _player = [[AVPlayer alloc] init];
        //添加视频播放器图形化载体AVPlayerLayer
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
//        _playerLayer.frame = self.layer.bounds;
        _playerLayer.frame =CGRectMake(0, 0, frame.size.width, frame.size.height);
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _playerLayer.backgroundColor=[UIColor clearColor].CGColor;
        self.playerArray=[[NSMutableArray alloc] init];
        
        [self.layer addSublayer:_playerLayer];
        
        [self toLoadView];
       
   
        
        //初始化取消视频加载的队列
        _cancelLoadingQueue = dispatch_queue_create("com.start.cancelloadingqueue", DISPATCH_QUEUE_CONCURRENT);
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickDouble)];
//        tap.numberOfTapsRequired = 2;
//        [self addGestureRecognizer:tap];
//
        UITapGestureRecognizer *clickTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPlay)];
        [self addGestureRecognizer:clickTap];
    }
    return self;
}

- (void)clickPlay {
    

    if (self.living==NO) {
        if (self.player.rate == 0 && self.clickType == 1) {
            [self.player play];
        } else if (self.clickType == 0) {
            if(self.player.rate == 0) {
                if (self.playBlock) {
                    self.playBlock();
                }
                [self play];
            } else {
                [self pause];
                self.showPlayBtn = YES;
            }
        }
    }
}

- (void)clickDouble {
    
    if (self.living) {
        if (self.doubleClickBlock) {
            self.doubleClickBlock();
        }
    } else {

    }
}

#pragma mark ------------------------加载View--------------------------------
-(void)toLoadView
{


    [self addSubview:self.backImageView];
    /** 播放按钮*/
    [self addSubview:self.playBtn];

}
-(UIButton*)playBtn
{
    if(_playBtn==nil)
    {
        UIImage *playImage=[UIImage imageNamed:@"bofang_yulan"];
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setImage:playImage forState:UIControlStateNormal];
        _playBtn.frame=CGRectMake((self.frame.size.width-48)/2, (self.frame.size.height-48)/2, 48, 48);
        //    self.playBtn.backgroundColor=[UIColor redColor];
        [self addSubview:_playBtn];
        [_playBtn addTarget:self action:@selector(toSetPlaybtn) forControlEvents:UIControlEventTouchUpInside];
        _playBtn.hidden=YES;
    }
    return _playBtn;
}
-(void)toSetPlaybtn
{

    if (self.playBlock) {
        self.playBlock();
    }
    if (self.player.rate==1)
    {
        NSLog(@"暂停");

        [self pause];
   
    }
    else
    {

        [self play];
    }
}
-(void)layoutSubviews {
    [super layoutSubviews];
    //禁止隐式动画
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _playerLayer.frame =CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    [CATransaction commit];
}
-(void)setPlayWithPath:(NSString*)path :(AVURLAsset*)audioAsset
{

    self.urlstr=path;
    //初始化AVURLAsset
    if ([path hasPrefix:@"file:///"]) {
        self.sourceURL = [NSURL URLWithString:path];
        self.playerItem = [[AVPlayerItem alloc] initWithAsset:audioAsset];
        self.duration = CMTimeGetSeconds([self.playerItem.asset duration]);
     

    } else {
        //初始化AVPlayerItem
        self.sourceURL = [NSURL fileURLWithPath:path];
//        AVAsset *avasset = [AVAsset assetWithURL:self.sourceURL];
        self.playerItem = [AVPlayerItem playerItemWithAsset:audioAsset];
        self.duration = CMTimeGetSeconds([self.playerItem.asset duration]);


    }
  if(self.durationBlock)
  {
      self.durationBlock(self.duration);
  }
    
    NSLog(@"duration:%f",self.duration);
    
    self.videoPlayType = 1;

    //切换当前AVPlayer播放器的视频源

    if (!self.player)
    {
        //切换当前AVPlayer播放器的视频源
        self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
        self.playerLayer.player = self.player;
    }
    else
    {
       [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    
    }
  
    [self addObserver];
  
        //给AVPlayerLayer添加周期性调用的观察者，用于更新视频播放进度
        [self addProgressObserver];



}
-(void)setPlayWithPath:(NSString*)path
{

    self.urlstr=path;
    //初始化AVURLAsset
    if ([path hasPrefix:@"file:///"]) {
        self.sourceURL = [NSURL URLWithString:path];
        AVURLAsset * audioAsset = [AVURLAsset URLAssetWithURL:self.sourceURL options:nil];
        self.playerItem = [[AVPlayerItem alloc] initWithAsset:audioAsset];
        self.duration = CMTimeGetSeconds([self.playerItem.asset duration]);
     

    } else {
        //初始化AVPlayerItem
        self.sourceURL = [NSURL fileURLWithPath:path];
        AVAsset *avasset = [AVAsset assetWithURL:self.sourceURL];
        self.playerItem = [AVPlayerItem playerItemWithAsset:avasset];
        self.duration = CMTimeGetSeconds([self.playerItem.asset duration]);


    }
  if(self.durationBlock)
  {
      self.durationBlock(self.duration);
  }
    
    NSLog(@"duration:%f",self.duration);
    
    self.videoPlayType = 1;

    //切换当前AVPlayer播放器的视频源

    if (!self.player)
    {
        //切换当前AVPlayer播放器的视频源
        self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
        self.playerLayer.player = self.player;
    }
    else
    {
       [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    
    }
  
    [self addObserver];
  
        //给AVPlayerLayer添加周期性调用的观察者，用于更新视频播放进度
        [self addProgressObserver];



}
-(void) printInfoForTrack:(AVAssetTrack*)track{
    CMAudioFormatDescriptionRef item = (__bridge CMAudioFormatDescriptionRef)[track.formatDescriptions objectAtIndex:0];
    const AudioStreamBasicDescription* desc = CMAudioFormatDescriptionGetStreamBasicDescription(item);
    NSLog(@"Number of track channels: %d", desc->mChannelsPerFrame);
}
//设置AVPlayerItem
- (void)setMyPlayerItem:(AVPlayerItem *)myplayerItem
{
    self.videoPlayType = 1;
    
    self.playerItem=myplayerItem;
    self.duration = CMTimeGetSeconds([self.playerItem.asset duration]);
    //self.progressSlider.maximumValue =  self.duration;

    self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    
    self.playerLayer.player = self.player;

    //    [self play];
    [self addObserver];
    //给AVPlayerLayer添加周期性调用的观察者，用于更新视频播放进度
    [self addProgressObserver];
    
    
}
//设置播放路径
-(void)setPlayerWithUrl:(NSString *)url_str {
    

  //  NSLog(@"DRELive url_str=====%@",url_str);
    if (url_str==nil || [url_str isKindOfClass:[NSNull class]] ||  [url_str isEqualToString:@""] || [url_str isEqualToString:@"(null)"] ) {
      //  [GlobalFunc showMsg:@"播放地址有误，请检查后播放"];
        return;
    }
//    NSString *charactersToEscape = @"`#%^{}\"[]|\\<>";
//    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
//    url_str = [url_str stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
   // url_str = [url_str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    url_str= [url_str stringByAddingPercentEncodingWithAllowedCharacters:[[NSCharacterSet characterSetWithCharactersInString:@" "] invertedSet]];
//    NSLog(@"url_str:%@",url_str);
    self.urlstr=url_str;

    //播放路径
    self.sourceURL = [NSURL URLWithString:url_str];

    if(self.sourceURL==nil)
    {
        NSLog(@"self.sourceURL:%@",self.sourceURL);
        return;
    }
//    //设置背景图片
  

    //获取路径schema
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:self.sourceURL resolvingAgainstBaseURL:NO];
    self.sourceScheme = components.scheme;
    
    //路径作为视频缓存key
    _cacheFileKey = self.sourceURL.absoluteString;
   
    __weak __typeof(self) wself = self;

   // NSString * extension=[url_str pathExtension]?:@"mp4";
    //查找本地视频缓存数据
//    _queryCacheOperation = [[WebCacheHelpler sharedWebCache] queryURLFromDiskMemory:_cacheFileKey cacheQueryCompletedBlock:^(id data, BOOL hasCache) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //hasCache是否有缓存，data为本地缓存路径
//            if(!hasCache) {
                wself.videoPlayType = 0;
//                [wself toShowBackPicture:url_str];
                //当前路径无缓存，则将视频的网络路径的scheme改为其他自定义的scheme类型，http、https这类预留的scheme类型不能使AVAssetResourceLoaderDelegate中的方法回调
//                wself.sourceURL = [wself.sourceURL.absoluteString urlScheme:@"streaming"];
//            }else {
//                //当前路径有缓存，则使用本地路径作为播放源
//                wself.videoPlayType = 1;
//                wself.sourceURL = [NSURL fileURLWithPath:data];
//           //wself.sourceURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"48K.mp4" ofType:nil]];
//            }
       
            //初始化AVURLAsset
         //   NSDictionary *dic = @{AVURLAssetPreferPreciseDurationAndTimingKey:@(YES)};
            wself.urlAsset = [AVURLAsset URLAssetWithURL:wself.sourceURL options:nil];
            //初始化AVPlayerItem
            wself.playerItem = [AVPlayerItem playerItemWithAsset:wself.urlAsset];
            wself.duration = CMTimeGetSeconds(wself.urlAsset.duration);
//            NSLog(@" wself.duration:%f", wself.duration);
        
            if (!wself.player)
            {
                //切换当前AVPlayer播放器的视频源
               wself.player = [[AVPlayer alloc] initWithPlayerItem:wself.playerItem];
               wself.playerLayer.player = wself.player;
            }
            else
            {
               [wself.player replaceCurrentItemWithPlayerItem:wself.playerItem];
//                [wself removeObserver];
//                [wself removeProgressObserver];
            }
            //给AVPlayerLayer添加周期性调用的观察者，用于更新视频播放进度

            [wself addObserver];
            [wself addProgressObserver];

        });
    //} extension:extension watermark:NO];
}


-(void)enterBack
{

    if(!self.isEnterBackPLay)
    {
        [self pause];
    }
    

    
}
-(void)resignActive
{
    if(!self.isEnterBackPLay)
    {
        [self pause];
    }
   

    
}
-(void)becomeActive
{
    CGFloat second = CMTimeGetSeconds([_player currentTime]);
    if (second > 0) {
        if(self.isCanPLay)
        {
            if(!self.isPlaying ||!self.isEnterBackPLay)
            {
                [self play];
                NSLog(@"播放");
            }
       
          
        }
     
    }
}
#pragma mark -----------------------播放结束-------------------------------
-(void)moviePlayDidEnd
{
//    self.backImageView.hidden=NO;
    [self pause];
    [self.player seekToTime:kCMTimeZero];
    if (self.playLoop)
    {

        [self play];
    }
    else
    {
        if (self.playEnd)
        {
            self.playEnd();
        }
    }

}

//取消播放
-(void)cancelLoading {
    //暂停视频播放
//    [self pause];
//    //隐藏playerLayer
//    [_playerLayer setHidden:YES];
    [self pauseAll];
 
//    //取消下载任务
//    if(_combineOperation) {
//        [_combineOperation cancel];
//        _combineOperation = nil;
//    }
    if (_queryCacheOperation!=nil) {
        [_queryCacheOperation cancel];
        _queryCacheOperation=nil;
    }
    [self removeObserver];
     [self removeProgressObserver];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    __weak __typeof(self) wself = self;
    dispatch_async(self.cancelLoadingQueue, ^{
        //取消AVURLAsset加载，这一步很重要，及时取消到AVAssetResourceLoaderDelegate视频源的加载，避免AVPlayer视频源切换时发生的错位现象
        if (wself.urlAsset!=nil) {
            [wself.urlAsset cancelLoading];
            wself.urlAsset=nil;
        }
        //暂停视频播放
        if (wself.playerItem!=nil) {
            [wself.playerItem cancelPendingSeeks];
            [wself.playerItem.asset cancelLoading];
        }
        
    
        
//        //结束所有视频数据加载请求
//        [wself.pendingRequests enumerateObjectsUsingBlock:^(id loadingRequest, NSUInteger idx, BOOL * stop) {
//            if(![loadingRequest isFinished]) {
//                [loadingRequest finishLoading];
//            }
//        }];
//        [wself.pendingRequests removeAllObjects];
    });
    
    _retried = NO;
    
}


-(void)toStop
{
    [self cancelLoading];
    self.isCanPLay=NO;
}

//播放
-(void)play {
    [_playerArray enumerateObjectsUsingBlock:^(AVPlayer * obj, NSUInteger idx, BOOL *stop) {
        [obj pause];
    }];
    if(![_playerArray containsObject:_player]&&_player!=nil) {
        [_playerArray addObject:_player];
    }
    self.isPlaying=YES;
    [_player play];
    self.playBtn.hidden=YES;
}

//暂停
-(void)pause
{
    self.isPlaying=NO;
    if([_playerArray containsObject:_player]) {
        [_player pause];
    }
//    [[AVPlayerManager shareManager] pause:_player];
    if (self.isShowPlayBtn) {
        self.playBtn.hidden=NO;
    }
//
}
- (void)pauseAll {
    [_playerArray enumerateObjectsUsingBlock:^(AVPlayer * obj, NSUInteger idx, BOOL *stop) {
        [obj pause];
    }];
}

//重新播放
-(void)replay {
    [_playerArray enumerateObjectsUsingBlock:^(AVPlayer * obj, NSUInteger idx, BOOL *stop) {
        [obj pause];
    }];
    if([_playerArray containsObject:_player]) {
        [_player seekToTime:kCMTimeZero];
        [self play];
    }else {
        [_playerArray addObject:_player];
        [self play];
    }
}
- (void)removeAllPlayers {
    [_playerArray removeAllObjects];
}

//播放速度
-(CGFloat)rate {
    return [_player rate];
}

//重新请求
-(void)retry {
    [self cancelLoading];
    _sourceURL =[self urlScheme:_sourceScheme :_sourceURL.absoluteString];
    NSLog(@"重试:%@",_sourceURL.absoluteString);
    [self setPlayerWithUrl:_sourceURL.absoluteString];
    _retried = YES;
}
- (NSURL *)urlScheme:(NSString *)scheme :(NSString*)url_str {
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:[NSURL URLWithString:url_str] resolvingAgainstBaseURL:NO];
    components.scheme = scheme;
    return [components URL];
}
#pragma mark ------------------下载视频-------------------------------------
-(void)toDownMyVideo
{

    if ( self.isDowning==NO)
    {
       // [self startDownloadTask:[NSURL URLWithString:self.urlstr] isBackground:YES];
    }
   
   
}

#pragma kvo
#pragma mark - add/remove Observer
- (void)addObserver
{
    
    [[self.player currentItem] addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBack) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // 添加视频播放结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    
}

#pragma mark -------------------------给AVPlayerLayer添加周期性调用的观察者，用于更新视频播放进度-----------------------------
-(void)addProgressObserver{
    if(self.isAddProgress)
    {
        __weak __typeof(self) weakSelf = self;
        //AVPlayer添加周期性回调观察者，一秒调用一次block，用于更新视频播放进度
        CMTime interval =CMTimeMake(1, 25);
        _timeObserver = [_player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            if(weakSelf.playerItem.status == AVPlayerItemStatusReadyToPlay) {
                //获取当前播放时间
                float current = CMTimeGetSeconds(time);


                if(![weakSelf.urlstr containsString:@"http"])
                {
    //                NSLog(@"current:%f",current);
                }
         

                //获取视频播放总时间
    //            float total = CMTimeGetSeconds([weakSelf.playerItem duration]);
                //重新播放视频
                if(weakSelf.duration == current) {
                  //  [weakSelf replay];

                }
                current = MIN(current, weakSelf.duration);

                //更新视频播放进度方法回调
                if(weakSelf.playProgress) {
                    weakSelf.playProgress(current, weakSelf.duration);
                }
            }
        }];
    }
  
}
#pragma mark -------------------------响应KVO值变化的方法-----------------------------

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //AVPlayerItem.status
    if([keyPath isEqualToString:@"status"]) {
        if(_playerItem.status == AVPlayerItemStatusFailed) {
            NSLog(@"播放错误:%@",self.urlstr);
        
            if (_player!=nil)
            {
                [_player pause];
                _player = nil;
            }
            if(!_retried&&self.videoPlayType==0) {

                [self retry];
            }
            else
            {
                [self cancelLoading];
                if(self.playFailed)
                {
                    self.playFailed();
                }
            }
        }
        //视频源装备完毕，则显示playerLayer
       else if(_playerItem.status == AVPlayerItemStatusReadyToPlay) {
            
           NSLog(@"准备播放:%@",self.urlstr);
           [self.playerLayer setHidden:NO];
     
     
//            [self performSelector:@selector(toHiddenBack) withObject:self afterDelay:0.5];
            if (self.videoPlayType == 0) { // 网络视频且无缓存
                //                [self toDownMyVideo];
           //   [self performSelector:@selector(toDownMyVideo) withObject:self afterDelay:1.0];
            }
            NSLog(@"DRELive === AVPlayerItemStatusReadyToPlay");
          
        }
         else if(_playerItem.status == AVPlayerItemStatusUnknown)
        {
            NSLog(@"播放未知:%@",self.urlstr);
        
         
//
//            if (_player!=nil)
//            {
//                [_player pause];
//                _player = nil;
//            }
//            if(!_retried&&self.videoPlayType==0) {
//
//                [self retry];
//            }
//            else
//            {
//                [self cancelLoading];
//                if(self.playFailed)
//                {
//                    self.playFailed();
//                }
//            }
        }
        //视频播放状体更新方法回调
        if(self.playStatus) {
            self.playStatus(_playerItem.status);
            
        }
      
     
   
    }
    else {
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark -------------------------移除所有-----------------------------
-(void)removeALL
{
    self.isCanPLay=NO;
    [self removeObserver];
    [self removeProgressObserver];

    if (_playerLayer!=nil) {
        [self.playerLayer removeFromSuperlayer];
        _playerLayer = nil;
    }
    
    [self removeAllPlayers];
    
    if (_playerItem!=nil) {
        _playerItem = nil;
    }
    if (_player!=nil)
    {
        [_player pause];
        _player = nil;
    }
    
    

    
}

#pragma mark -------------------------移除statusOB-----------------------------
- (void)removeObserver
{
    if (self.player!=nil)
    {
        @try {
            [[self.player currentItem] removeObserver:self forKeyPath:@"status"];
          //  [[self.player currentItem] removeObserver:self forKeyPath:@"playbackLikelyToKeepUp" context:nil];
        }
        @catch (NSException *exception) {
            //  NSLog(@"多次删除了");

        }
        
    }
    if(self.playerItem!=nil)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    }
    

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
#pragma mark -------------------------移除时间OB-----------------------------
- (void)removeProgressObserver
{
    if (self.timeObserver && self.player!=nil)
    {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
        
    }
}
- (void)dealloc
{
  
    [self removeALL];
 
    
}
//视频填充模式
-(void)toSetVideoGravity:(NSInteger)type
{
    [CATransaction begin];
  //  [CATransaction setAnimationDuration:0];
    [CATransaction setDisableActions:YES];
    if (type==0) {
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//视频填充模式

    } else if (type == 2) {
        _playerLayer.videoGravity = AVLayerVideoGravityResize;

    } else {
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;//视频填充模式
//        [self.layer addSublayer:_playerLayer];

    }
    [CATransaction commit];
}

#pragma mark -------------------------指定时间播放-----------------------------
-(void)toTimeMakeWithSeconds:(float)value
{
    [self.player seekToTime:CMTimeMakeWithSeconds(value*_duration, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    //[self removeProgressObserver];
    [self addProgressObserver];
    [self play];
}
#pragma mark -------------------------播放音量-----------------------------
-(void)setVolume:(float)volume
{
    _player.volume=volume;
}
#pragma mark -------------------------设置时间-----------------------------
///设置时间
- (void)seekToTime:(CMTime)time
{
    
    [self.player seekToTime:time];
}
#pragma mark -------------------------准备播放背景图-----------------------------
-(UIImageView*)backImageView
{
    if (_backImageView==nil)
    {
        _backImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _backImageView.backgroundColor=[UIColor clearColor];
        _backImageView.contentMode=UIViewContentModeScaleAspectFill;
//        _backImageView.contentMode=UIViewContentModeScaleAspectFill;
        _backImageView.hidden=YES;
    }
    return _backImageView;
}
-(void)toSetBGImageHidden:(BOOL)isHidden
{
    _backImageView.hidden=isHidden;
}
-(void)toSetBGImage:(UIImage*)image
{
    _backImageView.image=image;
}
////开始视频资源下载任务
//- (void)startDownloadTask:(NSURL *)URL isBackground:(BOOL)isBackground {
//    self.isDowning=YES;
//    __weak __typeof(self) wself = self;
//    _queryCacheOperation = [[WebCacheHelpler sharedWebCache] queryURLFromDiskMemory:_cacheFileKey cacheQueryCompletedBlock:^(id data, BOOL hasCache) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if(hasCache) {
//                wself.isDowning=NO;
//                return;
//            }
//            
//            if(wself.combineOperation != nil) {
//                [wself.combineOperation cancel];
//            }
//            
//            wself.combineOperation = [[WebDownloader sharedDownloader] downloadWithURL:URL responseBlock:^(NSHTTPURLResponse *response) {
//                
//                wself.mimeType = response.MIMEType;
//                wself.expectedContentLength = response.expectedContentLength;
////                [wself processPendingRequests];
//            } progressBlock:^(NSInteger receivedSize, NSInteger expectedSize, NSData *data) {
//                wself.isDowning=YES;
//                //处理视频数据加载请求
////                [wself processPendingRequests];
//            } completedBlock:^(NSData *data, NSError *error, BOOL finished) {
//                if(!error && finished) {
//                    wself.isDowning=NO;
//                    //下载完毕，将缓存数据保存到本地
//                    NSString * extension=[self.urlstr pathExtension]?:@"mp4";
////                    [[WebCacheHelpler sharedWebCache] storeDataToDiskCache:wself.data key:wself.cacheFileKey extension:extension];
//                }
//            } cancelBlock:^{
//                wself.isDowning=NO;
//                
//            } isBackground:isBackground watermark:NO];
//        });
//    } watermark:NO];
//}

@end
