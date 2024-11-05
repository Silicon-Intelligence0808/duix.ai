//
//  GJLDigitalManager.m
//  GJLocalDigitalSDK
//
//  Created by guiji on 2023/12/12.
//

#import "GJLDigitalManager.h"
#import "DigitalHumanDriven.h"
#import "DIMetalView.h"
#import "GJLAudioPlayerView.h"
#import "GJLGCDTimer.h"
#define DEBASEPATH @"DecryBasePath"
#define DEDIGITALPATH @"DecryDigitalPath"

static GJLDigitalManager * manager = nil;
@interface GJLDigitalManager ()
@property (nonatomic, strong) DIMetalView *mtkView;
@property (nonatomic, strong) NSString *digitalPath;
@property (nonatomic, strong) NSString *deDigitalPath;
@property (nonatomic, assign) NSInteger resultIndex;
@property (nonatomic, strong)GJLAudioPlayerView *auidoPlayView;
@property (nonatomic, strong) dispatch_group_t playAudioGroup;
@property (nonatomic, strong) dispatch_queue_t playAudioQueue;
@property (nonatomic, strong) dispatch_queue_t digital_timer_queue;
@property (nonatomic, strong) dispatch_queue_t playImageQueue;
@property(nonatomic,assign)BOOL isPlay;
@property (nonatomic, assign) int playImageIndex;
@property (nonatomic, assign) int curentImageIndex;
@property (nonatomic, assign) int audioIndex;
//本地路径下的图片个数
@property (nonatomic, assign)NSInteger maxCount;
@property (nonatomic, assign) BOOL playSub;
@property (nonatomic, strong) NSString * bbgPath;
//数字人主计时器
@property (nonatomic, strong) GJLGCDTimer *digitalTimer;
@property (nonatomic, strong)NSString *  appsign;
//控制并发的SessionId
@property (nonatomic, strong)NSString *signSessionId;

//数字人主计时器
@property (nonatomic, strong) GJLGCDTimer *heartTimer;
@property (nonatomic, strong) dispatch_queue_t heart_timer_queue;
//图片后缀名
@property (nonatomic, strong)NSString * pic_path_exten;
/*
 playAudioState 音频播放状态
 */
@property (nonatomic, assign) BOOL playAudioState;

@property (nonatomic, assign) BOOL isInitSuscess;


//静默区间
@property (nonatomic, strong)DigitalRangeModel * silentRangeModel;
//动作区间
@property (nonatomic, strong)DigitalRangeModel * actRangeModel;

@property (nonatomic, assign)BOOL lastAudioState;

@property (nonatomic, assign)NSInteger action_type;

@property (nonatomic, assign)NSInteger motionType;

@property (nonatomic, strong)NSMutableArray * range_act_arr;

@property (nonatomic, strong)NSMutableArray * range_silent_arr;

@property (nonatomic, strong)NSMutableArray * wavArr;
//是否正在处理音频
@property (nonatomic, assign)BOOL isWaving;
//播放中
@property (nonatomic, assign) BOOL isPlaying;
//需要继续播放
@property (nonatomic, assign) BOOL needPlay;

@property (nonatomic, strong)DigitalReverseModel * lastReverseModel;

@property (nonatomic, strong)DigitalReverseModel * lastReverseModel2;
//是否第一次随机
@property (nonatomic, assign)BOOL isFirstRandom;
//正序
@property (nonatomic, assign)NSInteger reverseRandomCount;

@property (nonatomic, assign)NSInteger reverseCount;
//0 正序 1 倒序
@property (nonatomic, assign)NSInteger sequence_type;
//uuid
@property (nonatomic, strong) NSString *uuid;
//@property (nonatomic, strong) dispatch_queue_t playImageQueue;
@end
@implementation GJLDigitalManager

+ (GJLDigitalManager *)manager
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[GJLDigitalManager alloc] init];
    });
    return manager;
}
-(id)init
{
    self=[super init];
    if(self)
    {

        [self initQueue];

        [DigitalHumanDriven manager].isStop=NO;
        self.wavArr=[[NSMutableArray alloc] init];
        // self.playImageQueue= dispatch_queue_create("com.duixsdk.playImageQueue", DISPATCH_QUEUE_CONCURRENT);
        //        self.mat_type=0;
    }
    return self;
}
- (void)initQueue {
    
    self.digital_timer_queue = dispatch_queue_create("com.digitalsdk.digital_timer_queue", DISPATCH_QUEUE_CONCURRENT);
    
    self.playImageQueue= dispatch_queue_create("com.digitalsdk.playImageQueue", DISPATCH_QUEUE_SERIAL);
    
    
    self.playAudioGroup = dispatch_group_create();
    self.playAudioQueue= dispatch_queue_create("com.digitalsdk.playAudioQueue", DISPATCH_QUEUE_CONCURRENT);
    
    self.heart_timer_queue=dispatch_queue_create("com.digitalsdk.heart_timer_queue", DISPATCH_QUEUE_CONCURRENT);
    
}


-(NSInteger)initBaseModel:(NSString*)basePath digitalModel:(NSString*)digitalPath showView:(UIView*)showView
{

    [self.auidoPlayView cancelLoading];
    
    NSFileManager * filemager=[NSFileManager defaultManager];
    NSString * encry_wenet_onnx_path=[NSString stringWithFormat:@"%@/wenet.o",basePath];
    NSString * encry_weight_168u_path=[NSString stringWithFormat:@"%@/weight_168u.b",basePath];
    
    NSString * encry_paramPath=[NSString stringWithFormat:@"%@/dh_model.p",digitalPath];
    NSString * encry_binPath=[NSString stringWithFormat:@"%@/dh_model.b",digitalPath];
    NSString * encry_configJson=[NSString stringWithFormat:@"%@/config.j",digitalPath];
    NSString * encry_bboxPath=[NSString stringWithFormat:@"%@/bbox.j",digitalPath];
    
    
    
    NSString * baseName=[NSString stringWithFormat:@"%@_%@",DEBASEPATH,[[basePath lastPathComponent] stringByDeletingPathExtension]];
    NSString *decryBasePath = [self getHistoryCachePath:baseName];
 
    
    
    
    
    NSString * digitalName=[NSString stringWithFormat:@"%@_%@",DEDIGITALPATH,[[digitalPath lastPathComponent] stringByDeletingPathExtension]];
    NSString *decryDigitalPath = [self getHistoryCachePath:digitalName];
    
    
    
    NSString * wenet_onnx_path=[NSString stringWithFormat:@"%@/wenet.onnx",decryBasePath];
    NSString * weight_168u_path=[NSString stringWithFormat:@"%@/weight_168u.bin",decryBasePath];
    

    
    NSString * paramPath=[NSString stringWithFormat:@"%@/dh_model.param",decryDigitalPath];
    NSString * binPath=[NSString stringWithFormat:@"%@/dh_model.bin",decryDigitalPath];
    NSString * configJson=[NSString stringWithFormat:@"%@/config.json",decryDigitalPath];
    NSString * bboxPath=[NSString stringWithFormat:@"%@/bbox.json",decryDigitalPath];
    
    //数字人模型包含的基础模型
    NSString * encry_weight_digital_168u_path=[NSString stringWithFormat:@"%@/weight_168u.b",digitalPath];
    if([filemager fileExistsAtPath:encry_weight_digital_168u_path])
    {
        encry_weight_168u_path=encry_weight_digital_168u_path;
        weight_168u_path=[NSString stringWithFormat:@"%@/weight_168u.bin",decryDigitalPath];
    
    }
    
    if(![filemager fileExistsAtPath:encry_wenet_onnx_path])
    {
        self.resultIndex=-1;
        return  self.resultIndex;
    }
    if(![filemager fileExistsAtPath:encry_weight_168u_path])
    {
        self.resultIndex=-1;
        return  self.resultIndex;
    }
    if(![filemager fileExistsAtPath:encry_paramPath])
    {
        self.resultIndex=-1;
        return self.resultIndex;
    }
    if(![filemager fileExistsAtPath:encry_binPath])
    {
        self.resultIndex=-1;
        return self.resultIndex;
    }
    if(![filemager fileExistsAtPath:encry_configJson])
    {
        self.resultIndex=-1;
        return self.resultIndex;
    }
    if(![filemager fileExistsAtPath:encry_bboxPath])
    {
        self.resultIndex=-1;
        return self.resultIndex;
    }
    
    if(![filemager fileExistsAtPath:wenet_onnx_path])
    {
        [[DigitalHumanDriven manager] processmd5WithPath:encry_wenet_onnx_path outPath:wenet_onnx_path];
    }
    
    if(![filemager fileExistsAtPath:weight_168u_path])
    {
        [[DigitalHumanDriven manager] processmd5WithPath:encry_weight_168u_path outPath:weight_168u_path];
    }
    
    if(![filemager fileExistsAtPath:paramPath])
    {
        [[DigitalHumanDriven manager] processmd5WithPath:encry_paramPath outPath:paramPath];
    }
    
    if(![filemager fileExistsAtPath:binPath])
    {
        [[DigitalHumanDriven manager] processmd5WithPath:encry_binPath outPath:binPath];
    }
    if(![filemager fileExistsAtPath:configJson])
    {
        [[DigitalHumanDriven manager] processmd5WithPath:encry_configJson outPath:configJson];
    }
    
    if(![filemager fileExistsAtPath:bboxPath])
    {
        [[DigitalHumanDriven manager] processmd5WithPath:encry_bboxPath outPath:bboxPath];
    }
    
    
    
    
    //原始路径
    self.digitalPath=digitalPath;
    //解密之后路径
    self.deDigitalPath=decryDigitalPath;
    
    NSString *filePath =[NSString stringWithFormat:@"%@/raw_jpgs",self.digitalPath];
    NSArray *filelist= [filemager contentsOfDirectoryAtPath:filePath error:nil];
    
    NSInteger filesCount = [filelist count];
    self.maxCount=filesCount;
    if(self.maxCount<=0)
    {
        self.resultIndex=-1;
        return self.resultIndex;
    }
    
    
    self.playImageIndex=1;
    self.motionType=0;
    
    
    self.pic_path_exten=[[filelist.firstObject lastPathComponent] pathExtension];
    [self toStopHeartTimer];
    [self toStopDigitalTime];
    [[DigitalHumanDriven manager] free];
    [[DigitalHumanDriven manager] initGJDigital];
    
    
    self.isInitSuscess=YES;
    
    [DigitalHumanDriven manager].isStop=NO;
    
    [self.wavArr removeAllObjects];
    
    self.isWaving=NO;
    DigitalHumanDriven *manager = [DigitalHumanDriven manager];
    
    [self toJarphJson:configJson];
    
    
    
    [manager initWenetWithPath:wenet_onnx_path];
    [manager initMunetWithParamPath:paramPath binPath:binPath binPath2:weight_168u_path];
    
    
    
    
    [self toShow:showView];

    __weak typeof(self)weakSelf = self;
    if([DigitalHumanDriven manager].metal_type==1)
    {
        if([DigitalHumanDriven manager].need_png==0)
        {
            manager.uint8Block = ^(UInt8 *mat_uint8, UInt8 *maskMat_uint8, UInt8 *bfgMat_uint8, UInt8 *bbgMat_unit8, int width, int height) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(weakSelf.mtkView!=nil &&[DigitalHumanDriven manager].isStartSuscess)
                    {
                        [weakSelf.mtkView renderWithUInt8:mat_uint8 :maskMat_uint8 :bfgMat_uint8 :bbgMat_unit8 :width :height];
                      
                    }
                    
                });
            };
        }
        else
        {
            manager.uint8Block2 = ^(UInt8 *mat_uint8,int width, int height) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(weakSelf.mtkView!=nil &&[DigitalHumanDriven manager].isStartSuscess)
                    {
                  
                        [weakSelf.mtkView renderWithMatUInt8:mat_uint8 :width :height];
                      
                    }
                    
                });
            };
        }
      
    }
    else
    {
        if([DigitalHumanDriven manager].need_png==0)
        {
            manager.matBlock = ^(cv::Mat mat,cv::Mat maskMat,cv::Mat bfgMat,cv::Mat bbgMat) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(weakSelf.mtkView!=nil &&[DigitalHumanDriven manager].isStartSuscess)
                    {
                        [weakSelf.mtkView renderWithCVMat:mat :maskMat :bfgMat :bbgMat];
                    }
                    
                });
            };
        }
        else
        {
            manager.matBlock2 = ^(cv::Mat mat) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(weakSelf.mtkView!=nil &&[DigitalHumanDriven manager].isStartSuscess)
                    {
                        [weakSelf.mtkView renderWithSimCVMat:mat];
                    }
                    
                });
            };
        }
    
    }
    
    
    self.resultIndex=1;
    return  self.resultIndex;
    
}
#pragma mark------------解析configJson文件-------------------------------
-(void)toJarphJson:(NSString*)configJson
{
    NSData *data = [NSData dataWithContentsOfFile:configJson];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *config_dic=[self dictionaryWithJsonString:jsonString];
    
    
    
    float width=[[config_dic valueForKey:@"width"] integerValue];
    float height=[[config_dic valueForKey:@"height"] integerValue];
    NSLog(@"config_dic:%@",config_dic);
    [DigitalHumanDriven manager].configModel.width=width>0?width:540;
    [DigitalHumanDriven manager].configModel.height=height>0?height:960;
    [DigitalHumanDriven manager].need_png=[[config_dic valueForKey:@"need_png"]?:@"" integerValue];
    //NSDictionary *mydic=    @{@"ranges":@[@{ @"min": @"1",@"max": @"64", @"type": @"0"}, @{@"min": @"65",@"max": @"125", @"type": @"1"}]};
    
    [[DigitalHumanDriven manager].configModel.ranges removeAllObjects];
    NSArray * rangesArr=config_dic[@"ranges"];
//    NSArray * rangesArr=mydic[@"ranges"];
    if([rangesArr isKindOfClass:[NSArray class]])
    {
   
        NSMutableArray * range_mutal_arr=[[NSMutableArray alloc] init];
        self.range_silent_arr=[[NSMutableArray alloc] init];
        self.range_act_arr=[[NSMutableArray alloc] init];
        for (int i=0; i<rangesArr.count; i++) {
            NSDictionary * dic=rangesArr[i];
            DigitalRangeModel * rangeModel=[[DigitalRangeModel alloc] init];
            rangeModel.min=[dic[@"min"]?:@"" integerValue];
            rangeModel.max=[dic[@"max"]?:@"" integerValue];
            rangeModel.type=[dic[@"type"]?:@"" integerValue];
            [range_mutal_arr addObject:rangeModel];
            if(rangeModel.type==0)
            {
                [self.range_silent_arr addObject:rangeModel];
            }
            else
            {
                [self.range_act_arr addObject:rangeModel];
            }
            
            
        }
        
        if(self.range_silent_arr.count>0 &&self.range_act_arr.count>0&&range_mutal_arr.count>0)
        {
            self.silentRangeModel=[[DigitalRangeModel alloc] init];
            self.actRangeModel=[[DigitalRangeModel alloc] init];
            int silent_random=arc4random()%self.range_silent_arr.count;
            self.silentRangeModel=self.range_silent_arr[silent_random];
            
            int act_random=arc4random()%self.range_act_arr.count;
            self.actRangeModel=self.range_act_arr[act_random];
            
            [DigitalHumanDriven manager].configModel.ranges=range_mutal_arr;
        }
        
        
    }
    [[DigitalHumanDriven manager].configModel.reverses removeAllObjects];
    //可逆 不可逆
    NSArray * reverseArr=config_dic[@"reverse"];
    if([reverseArr isKindOfClass:[NSArray class]])
    {
        self.lastReverseModel=[[DigitalReverseModel alloc] init];
        self.lastReverseModel2=[[DigitalReverseModel alloc] init];
     
        NSMutableArray * reverse_mutal_arr=[[NSMutableArray alloc] init];
        for (int i=0; i<reverseArr.count; i++) {
            NSDictionary * dic=reverseArr[i];
            DigitalReverseModel * reverseModel=[[DigitalReverseModel alloc] init];
            reverseModel.min=[dic[@"min"]?:@"" integerValue];
            reverseModel.max=[dic[@"max"]?:@"" integerValue];
            reverseModel.type=[dic[@"type"]?:@"" integerValue];
            [reverse_mutal_arr addObject:reverseModel];
            
            
        }
        [DigitalHumanDriven manager].configModel.reverses=reverse_mutal_arr;
    }
    
}
-(void)initBaseModel:(NSString*)basePath
{
    [[DigitalHumanDriven manager] initWenetWithPath:basePath];
}
-(void)initDigitalModel:(NSString*)digitalPath
{
    
}
-(NSString *)getHistoryCachePath:(NSString*)pathName
{
    NSString* folderPath =[[self getFInalPath] stringByAppendingPathComponent:pathName];
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //判断temp文件夹是否存在
    BOOL fileExists = [fileManager fileExistsAtPath:folderPath];
    //如果不存在说创建,因为下载时,不会自动创建文件夹
    if (!fileExists)
    {
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return folderPath;
}

- (NSString *)getFInalPath
{
    NSString* folderPath =[[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"Cache"];
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //判断temp文件夹是否存在
    BOOL fileExists = [fileManager fileExistsAtPath:folderPath];
    //如果不存在说创建,因为下载时,不会自动创建文件夹
    if (!fileExists) {
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return folderPath;
}
-(NSInteger)getFileCounts:(NSString*)filePath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *filelist= [fm contentsOfDirectoryAtPath:filePath error:nil];
    NSInteger filesCount = [filelist count];
    return filesCount;
}

#pragma mark ************字符串转字典************************
-(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
-(void)toShow:(UIView*)view
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self toRemoveMtkView];
        self.mtkView = [[DIMetalView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
        self.mtkView.backgroundColor = [UIColor clearColor];
        [view addSubview:self.mtkView];
    });
    
}
-(void)toPlayNext:(NSInteger)playImageIndex audioIndex:(NSInteger)audioIndex bbgPath:(NSString*)bbgPath
{
    if (!self.isPlaying) {
        return;
    }
    if(playImageIndex==0)
    {
        return;
    }
    NSString *paramPath = [NSString stringWithFormat:@"%@/raw_jpgs/%ld.%@",   self.digitalPath,playImageIndex,self.pic_path_exten];
    NSString *jsonBbox = [NSString stringWithFormat:@"%@/bbox.json",  self.deDigitalPath] ;
    NSData *data = [NSData dataWithContentsOfFile:jsonBbox];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *bbox_dict=[self dictionaryWithJsonString:jsonString];
    NSArray *bbox = [bbox_dict objectForKey:[NSString stringWithFormat:@"%ld",playImageIndex]];
    NSString *maskkPath =[NSString stringWithFormat:@"%@/pha/%ld.%@",self.digitalPath,playImageIndex,self.pic_path_exten];
    NSString *bfgPath = [NSString stringWithFormat:@"%@/raw_sg/%ld.%@",self.digitalPath,playImageIndex,self.pic_path_exten];
    if(audioIndex>=[DigitalHumanDriven manager].wavframe)
    {
        audioIndex=0;
        self.audioIndex=0;
    }
    //    NSLog(@"audioIndex:%ld",audioIndex);
    if([DigitalHumanDriven manager].need_png==0)
    {
        [[DigitalHumanDriven manager] maskrstWithPath:paramPath index:(int)audioIndex array:bbox mskPath:maskkPath bfgPath:bfgPath bbgPath:bbgPath];
    }
    else
    {
        [[DigitalHumanDriven manager] simprstWithPath:paramPath index:(int)audioIndex array:bbox];
    }
}
-(void)toStop
{
    self.isPlaying = NO;
    [self toStopDigitalTime];
    [self toStopHeartTimer];
    self.isPlay=NO;
    [DigitalHumanDriven manager].isStop=YES;
    self.audioIndex=0;
    self.playImageIndex=0;
    self.isInitSuscess=NO;

    self.motionType=0;
    [DigitalHumanDriven manager].isStartSuscess=NO;
    
    [self.auidoPlayView cancelLoading];
    
    self.isWaving=NO;
    [self.wavArr removeAllObjects];
    [DigitalHumanDriven manager].wavframe=0;
    [self toFree];
    
    [[DigitalHumanDriven manager].configModel.ranges removeAllObjects];
    //__weak typeof(self)weakSelf = self;
 
    
    
}

/*
*播放
*/
-(void)toPlay {
    self.isPlaying = YES;
    if (self.needPlay) {
        [self.auidoPlayView play];
    }
}

/*
*暂停
*/
-(void)toPause {
    self.isPlaying = NO;
    if (self.auidoPlayView.isPlaying) {
        self.needPlay = YES;
        [self.auidoPlayView pause];
    }
}

-(void)toFree
{
    
    dispatch_barrier_async(self.playImageQueue, ^{
          [[DigitalHumanDriven manager] free];
       });
    [self toRemoveMtkView];

}
-(void)toRemoveMtkView
{

        if(self.mtkView!=nil)
        {
            [self.mtkView removeFromSuperview];
            self.mtkView=nil;
        }
   
}


/*
 getDigitalSize 数字人模型的宽度 数字人模型的高度
 */
-(CGSize)getDigitalSize
{
    return  CGSizeMake([DigitalHumanDriven manager].configModel.width, [DigitalHumanDriven manager].configModel.height);
}
#pragma mark ----------------------GPT播放音乐界面--------------------
-(GJLAudioPlayerView*)auidoPlayView
{
    if(_auidoPlayView==nil)
    {
        
        _auidoPlayView=[[GJLAudioPlayerView alloc] initWithFrame:CGRectZero];
        _auidoPlayView.isEnterBackPLay=NO;
        _auidoPlayView.volume=1.0;
        _auidoPlayView.isAddProgress=YES;
        //        _gptPlayView.hidden=YES;
        __weak typeof(self)weakSelf = self;
        _auidoPlayView.playStatus = ^(AVPlayerItemStatus status) {
            if(status==AVPlayerItemStatusReadyToPlay)
            {
                
                
                //                NSLog(@"开始播放:%@",weakSelf.auidoPlayView.urlstr);
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                if(strongSelf.isPlay)
                {
                    
                    [strongSelf.auidoPlayView play];
                }
                
            }
        };
        _auidoPlayView.playFailed = ^{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            if(strongSelf.isPlay)
            {
                
                [strongSelf toPlayAudioEnd];
            }
        };
        _auidoPlayView.playEnd = ^{
            
            
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            if(strongSelf.isPlay)
            {
                NSLog(@"播放结束:%@",weakSelf.auidoPlayView.urlstr);
                [strongSelf toPlayAudioEnd];
            }
            
            
        };
        _auidoPlayView.playProgress = ^(float current, float total) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            
            
            [strongSelf onProgressUpdate:current total:total];
            
        };
        
        
    }
    return _auidoPlayView;
}
- (void)onProgressUpdate:(CGFloat)current total:(CGFloat)total
{
    if(self.audioPlayProgress)
    {
        self.audioPlayProgress(current, total);
    }
    if(current>=total&&current>0)
    {
        self.playAudioState = NO;
        //        self.audioIndex=0;
        //        [self playNext];
    }
    
    if (!self.playAudioState) {
        return;
    }
    int index = (int)(current/total*[DigitalHumanDriven manager].wavframe);
    //    NSLog(@"音频帧index:%d",index);
    if (index <= self.audioIndex) {
        return;
    }
    
    self.audioIndex = index;
}
-(void)toPlayAudioEnd
{
    //    [self.audi]
    
    [self cancelAudioPlay];
    if(self.audioPlayEnd)
    {
        self.audioPlayEnd();
    }

}

-(void)toStart:(void (^) (BOOL isSuccess, NSString *errorMsg))block
{
    __weak typeof(self)weakSelf = self;
    __strong typeof(weakSelf) strongSelf = weakSelf;
    self.isPlaying = YES;
    [DigitalHumanDriven manager].isStartSuscess=YES;
    self.playImageIndex=1;
    [self toStopDigitalTime];
    [self playNext];
    self.digitalTimer =[GJLGCDTimer scheduledTimerWithTimeInterval:0.04 repeats:YES queue:strongSelf.digital_timer_queue block:^{
        [strongSelf playNext];
    }];
    
}
-(void)toStopHeartTimer
{
    if(self.heartTimer!=nil) {
        [self.heartTimer invalidate];
        self.heartTimer = nil;
    }
}
- (void)toStopDigitalTime {
    
    if(self.digitalTimer!=nil) {
        [self.digitalTimer invalidate];
        self.digitalTimer = nil;
    }
}
- (void)playNext {
    //    NSString *localPath = [filePath.absoluteString stringByReplacingOccurrencesOfString:@"file://" withString:@""];
//    if(!self.isAuth)
//    {
//        return;
//    }
    if(!self.isInitSuscess)
    {
        return;
    }
    if(![DigitalHumanDriven manager].isStartSuscess)
    {
        
        return;
    }
    if([DigitalHumanDriven manager].isStop)
    {
        return;
    }
    __weak typeof(self)weakSelf = self;
    dispatch_async(self.playImageQueue, ^{
        if([DigitalHumanDriven manager].configModel.ranges.count>0&&[DigitalHumanDriven manager].configModel.reverses.count==0)
        {
            
            [weakSelf toPlayNextByRanges];
        }
        else if([DigitalHumanDriven manager].configModel.reverses.count>0)
        {
            [weakSelf toPlayNextByReverses];
        }
        else
        {
            [weakSelf toPlayNextDefaults];
        }
        
    });
    
}
-(NSInteger)isGetAuth
{
    if([DigitalHumanDriven manager].isStop)
    {
        return 0;
    }

    if(!self.isInitSuscess)
    {
        if(self.playFailed)
        {
            self.playFailed(-1, @"未初始化");
        }
        return 0;
    }
    if(![DigitalHumanDriven manager].isStartSuscess)
    {
     
        return 0;
    }
    return 1;
}
#pragma mark ------------根据动作区间播放静默和动作---------------------
-(void)toPlayNextByRanges
{
    
    if([DigitalHumanDriven manager].isStop)
    {
        return;
    }
   // NSLog(@"playImageIndex:%d",  self.playImageIndex);
    //    NSLog(@"音频帧图片index:%d",self.audioIndex);
    [self toPlayNext:self.playImageIndex audioIndex:self.audioIndex bbgPath:self.bbgPath];
    if(self.motionType==1)
    {
        //动作
        self.action_type=1;
        [self toGetPlayImageIndex:self.actRangeModel.min :self.actRangeModel.max];
    }
    else  if(self.motionType==2)
    {
        int distance1=(int)abs(self.playImageIndex-self.actRangeModel.min);
        int distance2=(int)abs(self.playImageIndex-self.actRangeModel.max);
        if(distance1<=distance2)
        {
            
            if(self.actRangeModel.min==self.playImageIndex)
            {
                self.action_type=0;
                self.motionType=0;
                [self toGetPlayImageIndex:self.silentRangeModel.min  :self.silentRangeModel.max];
                
            }
            else
            {
                self.playSub=YES;
                [self toGetPlayImageIndex:self.actRangeModel.min :self.playImageIndex];
            }
        }
        else
        {
            
            if(self.actRangeModel.max==self.playImageIndex)
            {
                self.action_type=0;
                self.motionType=0;
                [self toGetPlayImageIndex:self.silentRangeModel.min  :self.silentRangeModel.max];
            }
            else
            {
                self.playSub=NO;
                [self toGetPlayImageIndex:self.actRangeModel.min :self.actRangeModel.max];
            }
            
            
        }
    }
    else
    {
    
        
        [self toGetPlayImageIndex:self.silentRangeModel.min  :self.silentRangeModel.max];
        
        
        
        
    }
    self.lastAudioState=self.playAudioState;
    
    
}
-(void)toGetPlayImageIndex:(NSInteger)minImageCount :(NSInteger)maxImageCount
{
    if (self.playImageIndex == maxImageCount)
    {
        self.playSub = YES;
        
    } else if (self.playImageIndex == minImageCount)
    {
        self.playSub = NO;
    }
    if (self.playSub) {
//        if(self.motionType==2)
//        {
//            self.playImageIndex =self.playImageIndex-2;
//        }
//        else
//        {
            self.playImageIndex --;
//        }

    } else {
//        if(self.motionType==2)
//        {
//            self.playImageIndex =self.playImageIndex+2;
//        }
//        else
//        {
            self.playImageIndex ++;
//        }
    
    }
    
    if(self.playImageIndex<minImageCount)
    {
        self.playImageIndex=(int)minImageCount;
        self.playSub = NO;
    }
    else if(self.playImageIndex>maxImageCount)
    {
        self.playImageIndex=(int)maxImageCount;
        self.playSub = YES;
    }
}
#pragma mark ---------------------播放可逆不可逆-------------------------------
-(void)toPlayNextByReverses
{
    //NSLog(@"playImageIndex:%d",  self.playImageIndex);
    //   NSLog(@"音频帧图片index:%d",self.audioIndex);
    [self toPlayNext:self.playImageIndex audioIndex:self.audioIndex bbgPath:self.bbgPath];
    if([DigitalHumanDriven manager].configModel.reverses.count>0)
    {
        for (DigitalReverseModel * reverseModel in [DigitalHumanDriven manager].configModel.reverses)
        {
            if(self.playImageIndex>=reverseModel.min&&self.playImageIndex<=reverseModel.max)
            {
            
                self.lastReverseModel=reverseModel;
              //  NSLog(@"type:%ld",self.lastReverseModel.type);
                break;
            }
            
            
        }
      
        if(self.lastReverseModel!= self.lastReverseModel2)
        {
            self.isFirstRandom=NO;
            self.reverseCount=0;
        }
        self.lastReverseModel2=self.lastReverseModel;
     
        if(self.lastReverseModel.type==1)
        {
            if(!self.isFirstRandom)
            {
                self.reverseRandomCount=arc4random()%5+1;

                self.isFirstRandom=YES;
            }
            if(self.lastReverseModel.min==self.playImageIndex)
            {
              

                if(self.reverseCount<self.reverseRandomCount)
                {
               
                 
                   [self toGetPlayImageIndex:self.lastReverseModel.min :self.lastReverseModel.max];
                  
                 
                }
                else
                {
                    if(self.playImageIndex<=1)
                    {
                        self.sequence_type=0;
    
                    }
                    if(self.sequence_type==0)
                    {
                        self.playSub=NO;
                    }
                
                
//                    self.reverseCount=0;
                    [self toGetPlayImageIndex:1 :self.maxCount];
                   
                
                }
                
            }
            else if(self.lastReverseModel.max==self.playImageIndex)
            {
                
            
                self.reverseCount++;
                if(self.reverseCount<self.reverseRandomCount)
                {
               
                 
                   [self toGetPlayImageIndex:self.lastReverseModel.min :self.lastReverseModel.max];
                  
                 
                }
                else
                {
//                    self.playSub=NO;
                    if(self.playImageIndex>=self.maxCount)
                    {
                        self.sequence_type=1;
                       
                    }
                    if(self.sequence_type==1)
                    {
                        self.playSub=YES;
                    }
              
         
//                    self.reverseCount=0;
                    [self toGetPlayImageIndex:1 :self.maxCount];
                   
                
                }
         
            
            }
            else
            {
                [self toGetPlayImageIndex:1 :self.maxCount];
            }
        }
        else
        {
//            self.playSub=NO;
            self.isFirstRandom=NO;
            self.reverseCount=0;
            if(self.playImageIndex<=1)
            {
                self.sequence_type=0;
                self.playSub=NO;
            }
       
            [self toGetPlayImageIndex:1 :self.maxCount];
        
          
        }
       
        
    }
    else
    {
        self.isFirstRandom=NO;
        [self toGetPlayImageIndex:1 :self.maxCount];
     
    }

//    NSLog(@"reverseRandomCount:%ld,playImageIndex:%d,type:%ld,sequence_type:%ld",self.reverseRandomCount,self.playImageIndex,self.lastReverseModel.type,self.sequence_type);
//    [self toGetPlayImageIndex:1 :self.maxCount];
}
#pragma mark ---------------------播放默认不带动作区间-------------------------------
-(void)toPlayNextDefaults
{
    //NSLog(@"playImageIndex:%d",  self.playImageIndex);
    //   NSLog(@"音频帧图片index:%d",self.audioIndex);
    [self toPlayNext:self.playImageIndex audioIndex:self.audioIndex bbgPath:self.bbgPath];
    [self toGetPlayImageIndex:1 :self.maxCount];
}

#pragma mark-----------播放本地音频----------------------
-(void)toSpeakWithPath:(NSString*)wavPath
{
   
    
    if([self isGetAuth]==0)
    {
       return;
    }
    [self.wavArr addObject:wavPath];
    if(self.wavArr.count>0&&self.isWaving==NO)
    {
        NSString* last_wav_path=self.wavArr.firstObject;
        [self toPlayWav:last_wav_path];
    }
    
  
    
}
#pragma mark-----------播放本地音频----------------------
-(void)toPlayWav:(NSString*)wavPath
{
    if([self isGetAuth]==0)
    {
       return;
    }
    self.audioIndex=0;
    
    [self.auidoPlayView cancelLoading];
//    dispatch_group_enter(self.playAudioGroup);
    __weak typeof(self)weakSelf = self;
    dispatch_async(self.playAudioQueue, ^{
        weakSelf.playAudioState = YES;
        weakSelf.isWaving=YES;
        if([DigitalHumanDriven manager].configModel.ranges.count>0&&self.range_act_arr.count>0&&[DigitalHumanDriven manager].configModel.reverses.count==0)
        {
            if( weakSelf.playImageIndex<weakSelf.actRangeModel.min || weakSelf.playImageIndex>weakSelf.actRangeModel.max)
            {
                weakSelf.playImageIndex=(int)weakSelf.actRangeModel.min;
            }
        }
     
     
      
      
        NSString *localPath = [wavPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        AVURLAsset *audioAsset=  [[DigitalHumanDriven manager] onewavWithPath:localPath];
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            dispatch_group_leave(self.playAudioGroup);
           
            weakSelf.isPlay=YES;
                [weakSelf.auidoPlayView setPlayWithPath:localPath :audioAsset];
                 weakSelf.isWaving=NO;
                if(weakSelf.wavArr.count>0)
                {
                    [weakSelf.wavArr removeObject:weakSelf.wavArr.firstObject];
                    if(weakSelf.wavArr.count>0)
                    {
                        NSString* last_wav_path=weakSelf.wavArr.firstObject;
                        [weakSelf toPlayWav:last_wav_path];
                    }
                }
     
      
            
            
        });
    });
}



-(void)setBackType:(NSInteger)backType
{
    _backType=backType;
    [DigitalHumanDriven manager].back_type=backType;
}
/*
 bbgPath 替换背景
 */
-(void)toChangeBBGWithPath:(NSString*)bbgPath
{
   
    self.bbgPath=bbgPath;
    [self playNext];
}
/*
 取消播放音频
 */
-(void)cancelAudioPlay
{
    self.playAudioState = NO;
    self.audioIndex=0;
    //    self.audi

    [self.auidoPlayView cancelLoading];
    [DigitalHumanDriven manager].wavframe=0;
}



/*
* 开始动作 （一段文字包含多个音频，第一个音频开始时设置）
* return 0  数字人模型不支持开始动作 1  数字人模型支持开始动作
*/
-(NSInteger)toStartMotion
{
    if([DigitalHumanDriven manager].configModel.ranges.count>0&&[DigitalHumanDriven manager].configModel.reverses.count==0)
    {
        if(self.range_silent_arr.count>1)
        {
            int silent_random=arc4random()%self.range_silent_arr.count;
            self.silentRangeModel=self.range_silent_arr[silent_random];
            NSLog(@"min:%ld,max:%ld", self.silentRangeModel.min,self.silentRangeModel.max);
        }
        [self toMotionType:1];
        return 1;
    }
    
    return 0;

}

/*
* 结束动作 （一段文字包含多个音频，最后一个音频播放结束时设置）
*isQuickly YES 立即结束动作   NO 等待动作播放完成再静默
*return 0 数字人模型不支持结束动作  1 数字人模型支持结束动作
*/
-(NSInteger)toSopMotion:(BOOL)isQuickly
{
    if([DigitalHumanDriven manager].configModel.ranges.count>0&&[DigitalHumanDriven manager].configModel.reverses.count==0)
    {
      
  
        if(isQuickly)
        {
            [self toMotionType:0];
            
        }
        else
        {
            [self toMotionType:2];
        }
        return 1;
    }
    return 0;
   
}

/*
* motion_type 0 静默或语音播放完成立即结束动作  1 保持动作  2 一段文字包含多个音频，最后一句音频播放完成后等待动作播放完成再静默
* 默认为0
*/
-(void)toMotionType:(NSInteger)motion_type
{
    
    self.motionType=motion_type;
}

/*
* 随机动作（一段文字包含多个音频，第一个音频开始时设置）
* 1 数字人模型支持随机动作 0 数字人模型不支持随机动作
*/
-(NSInteger)toRandomMotion
{
    if(self.range_act_arr.count>1&&[DigitalHumanDriven manager].configModel.reverses.count==0)
    {
        int act_random=arc4random()%self.range_act_arr.count;
        self.actRangeModel=self.range_act_arr[act_random];
        return 1;
    }
    else
    {
        return 0;
    }
    

}


@end
