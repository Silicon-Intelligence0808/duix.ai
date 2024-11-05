//
//  AVPlayerView.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

//自定义Delegate，用于进度、播放状态更新回调
//@protocol AudioPlayerUpdateDelegate <NSObject>
//
////@required
////播放进度更新回调方法
//-(void)onAudioProgressUpdate:(CGFloat)current total:(CGFloat)total;
//
////播放状态更新回调方法
//-(void)onAudioPlayItemStatusUpdate:(AVPlayerItemStatus)status;
//#pragma mark -----------------------播放结束-------------------------------
//-(void)movieAudioPlayDidEnd;
////-(void)toAudioOutAsset:(AVAsset*)asset :(NSString*)usr_str;
//@end



//封装了AVPlayerLayer的自定义View
@interface GJLAudioPlayerView : UIView
@property (nonatomic ,strong) AVPlayerItem         *playerItem;             //视频资源载体
/** 循环播放 */
@property (nonatomic, assign) BOOL playLoop;
//总时间
@property (nonatomic, assign) float duration;
//播放进度、状态更新代理
//@property(nonatomic, weak) id<AudioPlayerUpdateDelegate> delegate;
@property (nonatomic, strong)NSString * urlstr;
@property (nonatomic, strong) NSString *bgImageUrl; //背景图片url
//是否显示播放按钮
@property (nonatomic, assign)BOOL isShowPlayBtn;

@property (nonatomic, assign) BOOL showProgressView;

@property (nonatomic, assign) BOOL showPlayBtn;

@property (nonatomic, assign) BOOL showGuide;
//直播中
@property (nonatomic, assign) BOOL living;

@property (nonatomic, assign) BOOL showBackImageView;

@property (nonatomic, assign) NSInteger clickType; //0 点击暂停 1点击如果播放继续播（给直播使用）2：不可点击
//播放音量
@property (nonatomic, assign)float volume;

/** 是否正在播放*/
@property (nonatomic, assign)BOOL isPlaying;

@property (nonatomic, copy) void (^playBlock)(void);
@property (nonatomic, copy) void (^doubleClickBlock)(void);
//播放状态回调
@property (nonatomic, copy) void (^playStatus)(AVPlayerItemStatus status);

//播放状态回调
@property (nonatomic, copy) void (^playFailed)(void);
//播放结束回调
@property (nonatomic, copy) void (^playEnd)(void);
//播放进度回调
@property (nonatomic, copy) void (^playProgress)(float current,float total);

@property (nonatomic, copy) void (^durationBlock)(float duration);


// 0网络视频播放。1本地视频 播放
@property (nonatomic, assign) NSInteger videoPlayType;
//是否正在下载
@property(nonatomic,assign)BOOL isDowning;

//是否可以从后台返回播放
@property (nonatomic, assign) BOOL isCanPLay;


//是否支持后台播放
@property (nonatomic, assign) BOOL isEnterBackPLay;

@property (nonatomic, assign)BOOL isAddProgress;

-(void)toStop;

-(void)setPlayWithPath:(NSString*)path :(AVURLAsset*)audioAsset;

-(void)setPlayWithPath:(NSString*)path;

//设置AVPlayerItem
- (void)setMyPlayerItem:(AVPlayerItem *)myplayerItem;

////设置播放路径
-(void)setPlayerWithUrl:(NSString *)url_str;

//取消播放
- (void)cancelLoading;

////开始视频资源下载任务
//- (void)startDownloadTask:(NSURL *)URL isBackground:(BOOL)isBackground;

//更新AVPlayer状态，当前播放则暂停，当前暂停则播放
- (void)updatePlayerState;

//播放
- (void)play;

//暂停
- (void)pause;

- (void)pauseAll;

//重新播放
- (void)replay;

//播放速度
- (CGFloat)rate;

//重新请求
- (void)retry;

#pragma mark -------------------------移除所有-----------------------------
-(void)removeALL;

//填充模式
-(void)toSetVideoGravity:(NSInteger)type;
#pragma mark -------------------------设置时间-----------------------------
- (void)seekToTime:(CMTime)time;

-(void)toSetBGImageHidden:(BOOL)isHidden;

-(void)toSetBGImage:(UIImage*)image;

#pragma mark -------------------------指定时间播放-----------------------------
-(void)toTimeMakeWithSeconds:(float)value;
@end

