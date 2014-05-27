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

/**
 *  获取一条广播，needPacked 表示是否打包 resharers 和 comments 数据
 *
 *  @param iid        <#iid description#>
 *  @param needPacked 是否打包 resharers 和 comments 数据
 *
 *  @return <#return value description#>
 */
+ (DoubanShuo *)statuses_withId:(NSUInteger)iid needPacked:(BOOL)needPacked;
{
    DouApiClient *client     = [DouApiClient sharedInstance];
    __block DoubanShuo *shuo = nil;
    
    DouReqBlock callback = ^(NSData *data) {
        NSError *error     = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:1 error:&error];
        shuo               = [MTLJSONAdapter modelOfClass:DoubanShuo.class fromJSONDictionary:dict error:&error];
    };
    
    //TODO 当 pack=true 时，返回的 JSON 包含 resharers、like、comments，更复杂了，需要更新 DoubanShuo 模型
    NSString *para = (needPacked) ? @"?pack=true" : @"";
    NSString *url = [NSString stringWithFormat:@"shuo/v2/statuses/%d%@", iid, para];
    [client get:url withCompletionBlock:callback];
    
    return shuo;
}

/**
 *  删除一条广播
 *
 *  @param iid <#iid description#>
 *
 *  @return <#return value description#>
 */
+ (DoubanShuo *)delete_statuses_withId:(NSUInteger)iid
{
    DouApiClient *client     = [DouApiClient sharedInstance];
    __block DoubanShuo *shuo = nil;
    
    DouReqBlock callback = ^(NSData *data) {
        NSError *error     = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:1 error:&error];
        shuo               = [MTLJSONAdapter modelOfClass:DoubanShuo.class fromJSONDictionary:dict error:&error];
    };
    
    NSString *url = [NSString stringWithFormat:@"shuo/v2/statuses/%d", iid];
    [client httpsDelete:url withCompletionBlock:callback];
    
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

+ (DoubanShuo *)statuses_like_withId:(NSUInteger)iid
{
    DouApiClient *client     = [DouApiClient sharedInstance];
    __block DoubanShuo *shuo = nil;
    
    DouReqBlock callback = ^(NSData *data) {
        NSError *error     = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:1 error:&error];
        shuo               = [MTLJSONAdapter modelOfClass:DoubanShuo.class fromJSONDictionary:dict error:&error];
    };
    
    NSString *url = [NSString stringWithFormat:@"shuo/v2/statuses/%d/like", iid];
    [client httpsPost:url withCompletionBlock:callback];
    
    return shuo;
}

+ (DoubanShuo *)statuses_reshare_withId:(NSUInteger)iid
{
    DouApiClient *client     = [DouApiClient sharedInstance];
    __block DoubanShuo *shuo = nil;
    
    DouReqBlock callback = ^(NSData *data) {
        NSError *error     = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:1 error:&error];
        shuo               = [MTLJSONAdapter modelOfClass:DoubanShuo.class fromJSONDictionary:dict error:&error];
    };
    
    NSString *url = [NSString stringWithFormat:@"shuo/v2/statuses/%d/reshare", iid];
    [client httpsPost:url withCompletionBlock:callback];
    
    return shuo;
}

+ (DoubanShuo *)post_statuses_withText:(NSString *)text image:(NSData *)imageData
{
    //TODO 需要判断 text 是否为空，imageData 是否超过 3MB
    DouApiClient *client     = [DouApiClient sharedInstance];
    __block DoubanShuo *shuo = nil;
    
    DouReqBlock callback = ^(NSData *data) {
        NSError *error     = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:1 error:&error];
        shuo               = [MTLJSONAdapter modelOfClass:DoubanShuo.class fromJSONDictionary:dict error:&error];
    };
    
    NSDictionary *postDict = @{@"text": text, @"source": kApiKey};
    NSString *url          = @"shuo/v2/statuses/";

    if (!imageData) {
        [client httpsPost:url withDict:postDict completionBlock:callback];
    }
    else {
        [client httpsPost:url
           withDictionary:postDict
                     data:imageData
         forParameterName:@"image"
                 mimeType:@"image/png"
          completionBlock:callback];
    }
    
    return shuo;
}

+ (DoubanShuo *)post_statuses_withText:(NSString *)text
                             rec_title:(NSString *)rec_title
                               rec_url:(NSString *)rec_url
                              rec_desc:(NSString *)rec_desc
                             rec_image:(NSString *)rec_image
{
    DouApiClient *client     = [DouApiClient sharedInstance];
    __block DoubanShuo *shuo = nil;
    
    DouReqBlock callback = ^(NSData *data) {
        NSError *error     = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:1 error:&error];
        shuo               = [MTLJSONAdapter modelOfClass:DoubanShuo.class fromJSONDictionary:dict error:&error];
    };
    
    NSDictionary *postDict = @{@"text": text, @"source": kApiKey,
                               @"rec_title": rec_title, @"rec_url": rec_url,
                               @"rec_desc": rec_desc, @"rec_image": rec_image};
    NSString *url          = @"shuo/v2/statuses/";
    
    [client httpsPost:url withDict:postDict completionBlock:callback];
    
    return shuo;
}



















@end










