//
//  DigitalConfigModel.h
//  GJLocalDigitalSDK
//
//  Created by guiji on 2023/12/19.
//

#import <Foundation/Foundation.h>



@interface DigitalConfigModel : NSObject
//宽度
@property (nonatomic, assign) NSInteger width;
//长度
@property (nonatomic, assign) NSInteger height;
//格式
@property(nonatomic,strong)   NSString * res_fmt;
//动作范围或静默范围
@property(nonatomic,strong) NSMutableArray * ranges;

//可逆范围和不可逆范围
@property(nonatomic,strong) NSMutableArray * reverses;
@end

@interface DigitalRangeModel : NSObject
//最小帧
@property (nonatomic, assign) NSInteger min;
//最大帧
@property (nonatomic, assign) NSInteger max;
//0 静默 1 动作
@property (nonatomic, assign) NSInteger type;
@end

@interface DigitalReverseModel : NSObject
//最小帧
@property (nonatomic, assign) NSInteger min;
//最大帧
@property (nonatomic, assign) NSInteger max;
//0 静默 1 动作
@property (nonatomic, assign) NSInteger type;
@end


