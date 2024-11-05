//
//  GJLDigitalManager.h
//  GJLocalDigitalSDK
//
//  Created by guiji on 2023/12/12.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//#import "GJLDigitalAnswerModel.h"
@interface GJLDigitalManager : NSObject

/*
 modeType 0 默认生产  1测试  2开发
 */
@property (nonatomic, assign) NSInteger modeType;

/*
 backType 0 背景透明   1 使用背景渲染
 */
@property (nonatomic, assign) NSInteger backType;





/*
*数字人渲染报错回调
*0 未授权 -1未初始化 50009资源超时或未配置
*/
@property (nonatomic, copy) void (^playFailed)(NSInteger code,NSString *errorMsg);

/*
*音频播放结束回调
*/
@property (nonatomic, copy) void (^audioPlayEnd)(void);

/*
*播放进度回调
*/
@property (nonatomic, copy) void (^audioPlayProgress)(float current,float total);


+ (GJLDigitalManager*)manager;



/*
 *basePath 底层通用模型路径-保持不变
 *digitalPath 数字人模型路径- 替换数字人只需要替换这个路径
 *return 1 返回成功 0未授权 -1 初始化失败
 *showView 显示界面
 */
-(NSInteger)initBaseModel:(NSString*)basePath digitalModel:(NSString*)digitalPath showView:(UIView*)showView;


/*
 *bbgPath  替换背景 -jpg格式 --- ----背景size等于数字人模型的getDigitalSize-----------
 *默认backType=0时背景透明，自己在外面设置背景 。当backType=1 时调用此方法设置背景渲染
 */
-(void)toChangeBBGWithPath:(NSString*)bbgPath;

/*
 wavPath 音频的本地路径 
 */
-(void)toSpeakWithPath:(NSString*)wavPath;



/*
*开始渲染数字人
*/
-(void)toStart:(void (^) (BOOL isSuccess, NSString *errorMsg))block;

/*
*结束
*/
-(void)toStop;

/*
*初始化模型过后才能获取
*getDigitalSize 数字人模型的宽度 数字人模型的高度
*/
-(CGSize)getDigitalSize;

/*
*取消播放音频
*/
-(void)cancelAudioPlay;


/*
* 开始动作前调用
* 随机动作（一段文字包含多个音频，建议第一个音频开始时设置随机动作）
* return 0 数字人模型不支持随机动作 1 数字人模型支持随机动作
*/
-(NSInteger)toRandomMotion;

/*
* 开始动作 （一段文字包含多个音频，第一个音频开始时设置）
* return 0  数字人模型不支持开始动作 1  数字人模型支持开始动作
*/
-(NSInteger)toStartMotion;


/*
* 结束动作 （一段文字包含多个音频，最后一个音频播放结束时设置）
*isQuickly YES 立即结束动作   NO 等待动作播放完成再静默
*return 0 数字人模型不支持结束动作  1 数字人模型支持结束动作
*/
-(NSInteger)toSopMotion:(BOOL)isQuickly;



/*
*暂停后才需执行播放数字人
*/
-(void)toPlay;

/*
*暂停数字人播放
*/
-(void)toPause;
@end


