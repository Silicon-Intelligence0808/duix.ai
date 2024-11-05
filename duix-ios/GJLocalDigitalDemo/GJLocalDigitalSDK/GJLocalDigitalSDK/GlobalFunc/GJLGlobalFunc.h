//
//  GlobalFunc.h
//  Digital
//
//  Created by cunzhi on 2023/11/14.
//

#import <Foundation/Foundation.h>

@interface GJLGlobalFunc : NSObject

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

+ (NSString *)dataToJsonString:(id)object;

+(id)changeType:(id)myObj;


+ (NSString *)randomQaId;
@end


