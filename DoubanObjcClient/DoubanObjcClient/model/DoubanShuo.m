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

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"iid": @"id",
        @"title": @"title",
        @"text": @"text",
        @"reshared_count": @"reshared_count",
        @"like_count": @"like_count",
        @"comments_count": @"comments_count",
        @"can_reply": @"can_reply",
        @"liked": @"liked",
        @"createdAt": @"created_at",
        @"user": @"user",
        @"resharedStatus": @"reshared_status"
    };
}

+ (NSValueTransformer *)createdAtJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [self.dateFormatter dateFromString:str];
    } reverseBlock:^(NSDate *date) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

+ (NSValueTransformer *)userJSONTransformer {
    return [MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[DoubanSimpleUser class]];
}

+ (NSValueTransformer *)resharedStatusJSONTransformer {
    return [MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[DoubanShuo class]];
}


#pragma mark - Douban API

+ (DoubanShuo *)statuses_withId:(NSUInteger)iid;
{
    DouApiClient *client     = [DouApiClient sharedInstance];
    __block DoubanShuo *shuo = nil;
    
    DouReqBlock callback = ^(NSData *data) {
        NSError *error     = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:1 error:nil];
        shuo               = [MTLJSONAdapter modelOfClass:DoubanShuo.class fromJSONDictionary:dict error:&error];
        
        NSLog(@"shuo: %@", shuo);
    };
    
    NSString *url = [NSString stringWithFormat:@"shuo/v2/statuses/%d", iid];
    [client get:url withCompletionBlock:callback];
    
    return shuo;
}

+ (NSArray *)user_timeline_withUserIdOrName:(NSString *)user since:(NSUInteger)since until:(NSUInteger)until
{
    DouApiClient *client              = [DouApiClient sharedInstance];
    __block NSMutableArray *timelines = [[NSMutableArray alloc] init];
    
    DouReqBlock callback = ^(NSData *data) {
        NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:1 error:nil];
        
        [arr enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
            NSError *error   = nil;
            DoubanShuo *shuo = [MTLJSONAdapter modelOfClass:DoubanShuo.class fromJSONDictionary:dict error:&error];
            [timelines addObject:shuo];
        }];
    };
    
    NSUInteger min_id   = (since > 0) ? since : 0;
    NSUInteger max_id   = (until > 0) ? until : INT_MAX;
    
    NSMutableString *url = [NSMutableString
                            stringWithFormat:@"shuo/v2/statuses/user_timeline/%@?since_id=%d&until_id=%d",
                            user, min_id, max_id];
    [client get:url withCompletionBlock:callback];
    
    return [timelines copy];
}

+ (NSArray *)home_timeline_withSince:(NSUInteger)since until:(NSUInteger)until count:(NSUInteger)count start:(NSUInteger)start
{
    DouApiClient *client              = [DouApiClient sharedInstance];
    __block NSMutableArray *timelines = [[NSMutableArray alloc] init];
    
    DouReqBlock callback = ^(NSData *data) {
        NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:1 error:nil];
        
        [arr enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
            NSError *error   = nil;
            DoubanShuo *shuo = [MTLJSONAdapter modelOfClass:DoubanShuo.class fromJSONDictionary:dict error:&error];
            [timelines addObject:shuo];
        }];
    };
    
    NSUInteger min_id   = (since > 0) ? since : 0;
    NSUInteger max_id   = (until > 0) ? until : INT_MAX;
    NSUInteger start_id = (start > 0) ? start : 0;
    NSUInteger icount   = (count > 0) ? count : 20;

    NSMutableString *url = [NSMutableString
                            stringWithFormat:@"shuo/v2/statuses/home_timeline?since_id=%d&until_id=%d&count=%d&start=%d",
                            min_id, max_id, icount, start_id];
    [client httpsGet:url withCompletionBlock:callback];
    
    return [timelines copy];
}

+ (NSArray *)statuses_comments_withId:(NSUInteger)iid start:(NSUInteger)start count:(NSUInteger)count
{
    DouApiClient *client     = [DouApiClient sharedInstance];
    __block NSMutableArray *comments = [[NSMutableArray alloc] init];
    
    DouReqBlock callback = ^(NSData *data) {
        NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:1 error:nil];
        
        [arr enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
            NSError *error   = nil;
            DoubanShuo *shuo = [MTLJSONAdapter modelOfClass:DoubanShuo.class fromJSONDictionary:dict error:&error];
            [comments addObject:shuo];
        }];
    };
    
    NSUInteger start_id = (start > 0) ? start : 0;
    NSUInteger icount   = (count > 0) ? count : 20;
    
    NSString *url = [NSString stringWithFormat:@"shuo/v2/statuses/%d/comments?start=%d&count=%d", iid, start_id, icount];
    [client get:url withCompletionBlock:callback];
    
    return [comments copy];
}




























@end










