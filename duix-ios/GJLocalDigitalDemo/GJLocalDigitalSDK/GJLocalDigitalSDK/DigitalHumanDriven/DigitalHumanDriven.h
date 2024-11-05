//
//  DigitalHumanDriven.h
//  Digital
//
//  Created by cunzhi on 2023/11/9.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>
#import <AVFoundation/AVFoundation.h>
#import "DigitalConfigModel.h"
@interface DigitalHumanDriven : NSObject

+ (instancetype)manager;
@property (nonatomic, assign) NSInteger metal_type;
//0 透明 1有背景
@property (nonatomic, assign) NSInteger back_type;
@property (nonatomic, assign) int wavframe;
@property (nonatomic, strong) DigitalConfigModel * configModel;
//@property (nonatomic, assign) NSInteger width;
//@property (nonatomic, assign) NSInteger height;

@property (nonatomic, assign) BOOL isStartSuscess;

//客户端创建的会话SessionId
@property (nonatomic, strong) NSString *chatSessionId;
//是否结束
@property (nonatomic, assign) BOOL isStop;

@property (nonatomic, assign)NSInteger need_png;
//@property (nonatomic, assign) int mat_type;
//@property (nonatomic, assign)BOOL isStop;

@property (nonatomic, copy) void (^imageBlock)(UIImage *image);
@property (nonatomic, copy) void (^pixerBlock)(CVPixelBufferRef cvPixelBuffer);
@property (nonatomic, copy) void (^uint8Block)(UInt8*mat_uint8,UInt8*maskMat_uint8 ,UInt8*bfgMat_uint8,UInt8*bbgMat_unit8,int width ,int height);
@property (nonatomic, copy) void (^matBlock)(cv::Mat mat,cv::Mat maskMat,cv::Mat bfgMat,cv::Mat bbgMat);
//非绿幕
@property (nonatomic, copy) void (^uint8Block2)(UInt8*mat_uint8,int width ,int height);
@property (nonatomic, copy) void (^matBlock2)(cv::Mat mat);
@property (nonatomic, strong)AVURLAsset *audioAsset;
- (int)initWenetWithPath:(NSString*)path;
- (int)initMunetWithParamPath:(NSString*)paramPath binPath:(NSString*)binPath binPath2:(NSString*)binPath2;
- (int)initAlphaWithParamPath:(NSString*)paramPath binPath:(NSString*)binPath;

- (AVURLAsset*)onewavWithPath:(NSString*)path;

- (int)matrstWithData:(uint8_t*)data width:(int)width height:(int)height boxs: (int*)boxs index: (int)index;
- (void)matrstWithPath:(NSString *)imagePath index:(int)index array:(NSArray *)array;

- (void)maskrstWithPath:(NSString *)imagePath index:(int)index array:(NSArray *)array mskPath:(NSString*)maskPath bfgPath:(NSString*)bfgPath bbgPath:(NSString*)bbgPath ;
- (void)simprstWithPath:(NSString *)imagePath index:(int)index array:(NSArray *)array;
- (int)initGJDigital  ;
-(int)processmd5WithPath:(NSString*)inputPath outPath:(NSString*)outPath;

- (void)free;


@end

