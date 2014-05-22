//
//  DoubanBaseModel.m
//  DoubanObjcClient
//
//  Created by hao on 5/23/14.
//  Copyright (c) 2014 com.hao. All rights reserved.
//

#import "DoubanBaseModel.h"

@implementation DoubanBaseModel

/**
 *  返回空字典，由具体 model 子类覆盖
 *
 *  @return <#return value description#>
 */
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ };
}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return dateFormatter;
}

@end
