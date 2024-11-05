//
//  DigitalConfigModel.m
//  GJLocalDigitalSDK
//
//  Created by guiji on 2023/12/19.
//

#import "DigitalConfigModel.h"

@implementation DigitalConfigModel
-(id)init
{
    self=[super init];
    if(self)
    {
        self.width=540;
        self.height=960;
        self.res_fmt=@"";
        self.ranges=[[NSMutableArray alloc] init];
        self.reverses=[[NSMutableArray alloc] init];
//        self.mat_type=0;
    }
    return self;
}
@end

@implementation DigitalRangeModel
-(id)init
{
    self=[super init];
    if(self)
    {
        self.min=0;
        self.max=0;
        self.type=0;

//        self.mat_type=0;
    }
    return self;
}
@end

@implementation DigitalReverseModel
-(id)init
{
    self=[super init];
    if(self)
    {
        self.min=0;
        self.max=0;
        self.type=0;

//        self.mat_type=0;
    }
    return self;
}
@end
