//
//  DoubanShuo.m
//  DoubanObjcClient
//
//  Created by hao on 5/22/14.
//  Copyright (c) 2014 com.hao. All rights reserved.
//

#import "DoubanShuo.h"
#import "DouApiClient.h"

@implementation DoubanShuo

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"id": @"id",
             @"title": @"title",
             @"text": @"text",
             @"reshared_count": @"reshared_count",
             @"like_count": @"like_count",
             @"comments_count": @"comments_count",
             @"can_reply": @"can_reply",
             @"liked": @"liked",
             @"created_at": @"created_at",
             @"user": @"user",
             @"reshared_status": @"reshared_status"
             };
}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    return dateFormatter;
}

+ (NSValueTransformer *)created_atJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [self.dateFormatter dateFromString:str];
    } reverseBlock:^(NSDate *date) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

+ (instancetype)statusesWithId:(NSUInteger )id
{
    DouApiClient *client     = [DouApiClient sharedInstance];
    __block DoubanShuo *shuo = nil;
    
    DouReqBlock callback = ^(NSData *data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:1 error:nil];
        
        NSError *error = nil;
        shuo = [MTLJSONAdapter modelOfClass:DoubanShuo.class fromJSONDictionary:dict error:&error];
        
        NSLog(@"shuo: %@", shuo);
    };
    
    NSString *url = [NSString stringWithFormat:@"shuo/v2/statuses/%d", id];
    [client get:url withCompletionBlock:callback];
    return shuo;
}

@end
