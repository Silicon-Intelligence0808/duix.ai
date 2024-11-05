//
//  GJLDigitalManager.m
//  GJLocalDigitalSDK
//
//  Created by guiji on 2023/12/12.
//

#import "GJLDigitalManager.h"
//#import "DigitalHumanDriven.h"
//#import "DIMetalView.h"

//#define  BASEMODEL @"model"
static GJLDigitalManager * manager = nil;
//@interface GJLDigitalManager ()
////@property (nonatomic, strong) DIMetalView *mtkView;
//@property (nonatomic, strong) NSString *digitalPath;
//@property (nonatomic, assign) NSInteger resultIndex;
////@property (nonatomic, strong) dispatch_queue_t playImageQueue;
//@end
@implementation GJLDigitalManager
+ (GJLDigitalManager*)manager
{
    if (manager == nil)
    {
        @synchronized(self)
        {
            if (manager == nil)
            {
                manager = [[super alloc] init];
            }
        }
    }
    return manager;
}
//+ (GJLDigitalManager *)manager
//{
//    static dispatch_once_t once;
//    dispatch_once(&once, ^{
//        manager = [[GJLDigitalManager alloc] init];
//    });
//    return manager;
//}
-(id)init
{
    self=[super init];
    if(self)
    {
    
       // self.playImageQueue= dispatch_queue_create("com.duixsdk.playImageQueue", DISPATCH_QUEUE_CONCURRENT);
//        self.mat_type=0;
    }
    return self;
}
-(NSInteger)initBaseModel:(NSString*)basePath digitalModel:(NSString*)digitalPath
{
//    NSFileManager * filemager=[NSFileManager defaultManager];
//
//    
//    NSString * wenet_onnx_path=[NSString stringWithFormat:@"%@/wenet.onnx",basePath];
//    NSString * weight_168u_path=[NSString stringWithFormat:@"%@/weight_168u.bin",basePath];
//    
//    NSString * paramPath=[NSString stringWithFormat:@"%@/dh_model.param",digitalPath];
//    NSString * binPath=[NSString stringWithFormat:@"%@/dh_model.bin",digitalPath];
//    
//    NSString * configJson=[NSString stringWithFormat:@"%@/config.json",digitalPath];
//    
//    if(![filemager fileExistsAtPath:wenet_onnx_path])
//    {
//        self.resultIndex=-1;
//        return  self.resultIndex;
//    }
//    if(![filemager fileExistsAtPath:weight_168u_path])
//    {
//        self.resultIndex=-2;
//        return  self.resultIndex;
//    }
//    if(![filemager fileExistsAtPath:paramPath])
//    {
//        self.resultIndex=-3;
//        return self.resultIndex;
//    }
//    if(![filemager fileExistsAtPath:binPath])
//    {
//        self.resultIndex=-4;
//        return self.resultIndex;
//    }
//    if(![filemager fileExistsAtPath:configJson])
//    {
//        self.resultIndex=-5;
//        return self.resultIndex;
//    }
//
// 
//    
////    [[DigitalHumanDriven manager] initGJDigital];
//    
////    self.digitalPath=digitalPath;
////    NSString *filePath =[NSString stringWithFormat:@"%@/raw_jpgs",digitalPath];
////    self.maxCount=[self getFileCounts:filePath];
////    
////    NSData *data = [NSData dataWithContentsOfFile:configJson];
////    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
////    NSDictionary *config_dic=[self dictionaryWithJsonString:jsonString];
////    
////    DigitalHumanDriven *manager = [DigitalHumanDriven manager];
////    float width=[[config_dic valueForKey:@"width"] integerValue];
////    float height=[[config_dic valueForKey:@"height"] integerValue];
////    if(width>0&&height>0)
////    {
////        manager.width=width;
////        manager.height=height;
////    }
////
////    [manager initWenetWithPath:wenet_onnx_path];
////    [manager initMunetWithParamPath:paramPath binPath:binPath binPath2:weight_168u_path];
////
////    __weak typeof(self)weakSelf = self;
////    manager.matBlock = ^(cv::Mat mat,cv::Mat maskMat,cv::Mat bfgMat,cv::Mat bbgMat) {
////        dispatch_async(dispatch_get_main_queue(), ^{
////            if(weakSelf.mtkView!=nil)
////            {
////                [weakSelf.mtkView renderWithCVMat:mat :maskMat :bfgMat :bbgMat];
////            }
////     
////        });
////    };
//    self.resultIndex=1;
//    return  self.resultIndex;
//    
    return -1;
}
//-(void)initBaseModel:(NSString*)basePath
//{
//    [[DigitalHumanDriven manager] initWenetWithPath:basePath];
//}
//-(void)initDigitalModel:(NSString*)digitalPath
//{
//  
//}
//-(NSString *)getHistoryCachePath:(NSString*)pathName
//{
//    NSString* folderPath =[[self getFInalPath] stringByAppendingPathComponent:pathName];
//    //创建文件管理器
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    //判断temp文件夹是否存在
//    BOOL fileExists = [fileManager fileExistsAtPath:folderPath];
//    //如果不存在说创建,因为下载时,不会自动创建文件夹
//    if (!fileExists)
//    {
//        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
//    }
//    return folderPath;
//}
//
//- (NSString *)getFInalPath
//{
//    NSString* folderPath =[[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"GJWebCache"];
//    //创建文件管理器
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    //判断temp文件夹是否存在
//    BOOL fileExists = [fileManager fileExistsAtPath:folderPath];
//    //如果不存在说创建,因为下载时,不会自动创建文件夹
//    if (!fileExists) {
//        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
//    }
//    
//    return folderPath;
//}
//#pragma mark ************字符串转字典************************
//-(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
//    
//    if (jsonString == nil) {
//        return nil;
//    }
//    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
//    NSError *err;
//    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
//                                                        options:NSJSONReadingMutableContainers
//                                                          error:&err];
//    if(err)
//    {
//        NSLog(@"json解析失败：%@",err);
//        return nil;
//    }
//    return dic;
//}
////获取文件夹下的文件个数
//-(NSInteger)getFileCounts:(NSString*)filePath
//{
//    NSFileManager *fm = [NSFileManager defaultManager];
//    NSArray *filelist= [fm contentsOfDirectoryAtPath:filePath error:nil];
//    NSInteger filesCount = [filelist count];
//    return filesCount;
//}
//-(void)toShow:(UIView*)view
//{
//    self.mtkView = [[DIMetalView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
//    self.mtkView.backgroundColor = [UIColor clearColor];
//    [view addSubview:self.mtkView];
//}
//-(void)toPlayNext:(NSInteger)playImageIndex audioIndex:(NSInteger)audioIndex bbgPath:(NSString*)bbgPath
//{
//    NSString *paramPath = [NSString stringWithFormat:@"%@/raw_jpgs/%ld.jpg",   self.digitalPath,playImageIndex];
//    NSString *jsonBbox = [NSString stringWithFormat:@"%@/bbox.json",  self.digitalPath] ;
//    NSData *data = [NSData dataWithContentsOfFile:jsonBbox];
//    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSDictionary *bbox_dict=[self dictionaryWithJsonString:jsonString];
//    NSArray *bbox = [bbox_dict objectForKey:[NSString stringWithFormat:@"%ld",playImageIndex]];
//    NSString *maskkPath =[NSString stringWithFormat:@"%@/pha/%ld.jpg",self.digitalPath,playImageIndex];
//    NSString *bfgPath = [NSString stringWithFormat:@"%@/raw_sg/%ld.jpg",self.digitalPath,playImageIndex];
//    if(audioIndex>=[DigitalHumanDriven manager].wavframe)
//    {
//        audioIndex=0;
//    }
//    [[DigitalHumanDriven manager] maskrstWithPath:paramPath index:(int)audioIndex array:bbox mskPath:maskkPath bfgPath:bfgPath bbgPath:bbgPath];
//}
//-(void)toStop
//{
//    
//}
//-(void)toFree
//{
//    if(self.mtkView!=nil)
//    {
//        [self.mtkView removeFromSuperview];
//        self.mtkView=nil;
//    }
//    [DigitalHumanDriven manager].wavframe=0;
//    [[DigitalHumanDriven manager] free];
//}
//-(void)onewavWithPath:(NSString*)wavPath
//{
//    
//    [[DigitalHumanDriven manager] onewavWithPath:wavPath :YES];
//}
//-(void)toWavPlayEnd
//{
//    [DigitalHumanDriven manager].wavframe=0;
//}
///*
// getDigitalSize 数字人模型的宽度 数字人模型的高度
//*/
//-(CGSize)getDigitalSize
//{
//    return  CGSizeMake([DigitalHumanDriven manager].width, [DigitalHumanDriven manager].height);
//}

@end
