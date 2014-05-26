//
//  DoubanUser.m
//  DoubanObjcClient
//
//  Created by hao on 5/22/14.
//  Copyright (c) 2014 com.hao. All rights reserved.
//

#import "DoubanUser.h"
#import "DouApiClient.h"

@implementation DoubanUser

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"iid": @"id",
        @"uid": @"uid",
        @"name": @"name",
        @"screen_name": @"screen_name",
        @"avatar": @"avatar",
        @"alt": @"alt",
        @"relation": @"relation",
        @"created": @"created",
        @"loc_id": @"loc_id",
        @"loc_name": @"loc_name",
        @"desc": @"desc"
    };
}

+ (NSValueTransformer *)createdJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [self.dateFormatter dateFromString:str];
    } reverseBlock:^(NSDate *date) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

+ (NSValueTransformer *)avatarJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)altJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

#pragma mark - Douban API

+ (DoubanUser *)get_user_withName:(NSString *)name
{
    DouApiClient *client     = [DouApiClient sharedInstance];
    __block DoubanUser *user = nil;
    
    DouReqBlock callback = ^(NSData *data) {
        NSError *error     = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:1 error:&error];
        user               = [MTLJSONAdapter modelOfClass:DoubanUser.class fromJSONDictionary:dict error:&error];
    };
    
    NSString *url = [NSString stringWithFormat:@"v2/user/%@", name];
    [client httpsGet:url withCompletionBlock:callback];
    
    return user;
}

+ (DoubanUser *)current_user
{
    DouApiClient *client     = [DouApiClient sharedInstance];
    __block DoubanUser *user = nil;
    
    DouReqBlock callback = ^(NSData *data) {
        NSError *error     = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:1 error:&error];
        user               = [MTLJSONAdapter modelOfClass:DoubanUser.class fromJSONDictionary:dict error:&error];
    };
    
    NSString *url = @"v2/user/~me";
    [client httpsGet:url withCompletionBlock:callback];
    
    return user;
}

+ (NSArray *)search_user_withText:(NSString *)text start_id:(NSUInteger)start_id count:(NSUInteger)count
{
    DouApiClient *client          = [DouApiClient sharedInstance];
    __block NSMutableArray *users = [[NSMutableArray alloc] init];
    
    DouReqBlock callback = ^(NSData *data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:1 error:nil];
        NSArray      *arr  = dict[@"users"];
        
        [arr enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL *stop) {
            NSError *error   = nil;
            DoubanUser *user = [MTLJSONAdapter modelOfClass:DoubanUser.class fromJSONDictionary:dic error:&error];
            [users addObject:user];
        }];
    };
    
    NSUInteger start  = (start_id > 0) ? start_id : 0;
    NSUInteger icount = (count > 0) ? count : 20;
    
    NSString *url = [NSString stringWithFormat:@"v2/user?q=%@&start=%d&count=%d", text, start, icount];
    [client httpsGet:url withCompletionBlock:callback];
    
    return [users copy];
}

/**
 *  获取所给用户（uid）关注的用户
 *
 *  @param uid      关注者
 *  @param start_id <#start_id description#>
 *  @param count    <#count description#>
 *
 *  @return <#return value description#>
 */
+ (NSArray *)user_following_withUserId:(NSUInteger)uid start_id:(NSUInteger)start_id count:(NSUInteger)count
{
    DouApiClient *client          = [DouApiClient sharedInstance];
    __block NSMutableArray *users = [[NSMutableArray alloc] init];
    
    DouReqBlock callback = ^(NSData *data) {
        NSArray *arr  = [NSJSONSerialization JSONObjectWithData:data options:1 error:nil];
        
        [arr enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL *stop) {
            NSError *error   = nil;
            DoubanUser *user = [MTLJSONAdapter modelOfClass:DoubanUser.class fromJSONDictionary:dic error:&error];
            [users addObject:user];
        }];
    };
    
    NSUInteger start  = (start_id > 0) ? start_id : 0;
    NSUInteger icount = (count > 0) ? count : 20;
    
    NSString *url = [NSString stringWithFormat:@"shuo/v2/users/%d/following?start=%d&count=%d", uid, start, icount];
    [client get:url withCompletionBlock:callback];
    
    return [users copy];
}

/**
 *  获取所给用户（uid）被哪些用户关注，即粉丝
 *
 *  @param uid      被关注者
 *  @param start_id <#start_id description#>
 *  @param count    <#count description#>
 *
 *  @return <#return value description#>
 */
+ (NSArray *)user_followers_withUserId:(NSUInteger)uid start_id:(NSUInteger)start_id count:(NSUInteger)count
{
    DouApiClient *client          = [DouApiClient sharedInstance];
    __block NSMutableArray *users = [[NSMutableArray alloc] init];
    
    DouReqBlock callback = ^(NSData *data) {
        NSArray *arr   = [NSJSONSerialization JSONObjectWithData:data options:1 error:nil];
        
        [arr enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL *stop) {
            NSError *error = nil;
            DoubanUser *user = [MTLJSONAdapter modelOfClass:DoubanUser.class fromJSONDictionary:dic error:&error];
            [users addObject:user];
        }];
    };
    
    NSUInteger start  = (start_id > 0) ? start_id : 0;
    NSUInteger icount = (count > 0) ? count : 20;
    
    NSString *url = [NSString stringWithFormat:@"shuo/v2/users/%d/followers?start=%d&count=%d", uid, start, icount];
    [client get:url withCompletionBlock:callback];
    
    return [users copy];
}

/**
 *  当前用户（指已授权的用户）与指定的用户（uid）共同关注了哪些用户
 *
 *  @param uid      <#uid description#>
 *  @param start_id <#start_id description#>
 *  @param count    <#count description#>
 *
 *  @return <#return value description#>
 */
//+ (NSArray *)follow_in_common_withUserId:(NSUInteger)uid start_id:(NSUInteger)start_id count:(NSUInteger)count
//{
//    DouApiClient *client          = [DouApiClient sharedInstance];
//    __block NSMutableArray *users = [[NSMutableArray alloc] init];
//    
//    DouReqBlock callback = ^(NSData *data) {
//        NSArray *arr   = [NSJSONSerialization JSONObjectWithData:data options:1 error:nil];
//        
//        [arr enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL *stop) {
//            NSError *error   = nil;
//            DoubanUser *user = [MTLJSONAdapter modelOfClass:DoubanUser.class fromJSONDictionary:dic error:&error];
//            [users addObject:user];
//        }];
//    };
//    
//    NSUInteger start  = (start_id > 0) ? start_id : 0;
//    NSUInteger icount = (count > 0) ? count : 20;
//    
//    NSString *url = [NSString stringWithFormat:@"shuo/v2/users/%d/follow_in_common?start=%d&count=%d", uid, start, icount];
//    [client httpsGet:url withCompletionBlock:callback];
//    
//    return [users copy];
//}

/**
 *  当前用户（指已授权的用户）关注了某指定用户（uid）的哪些关注者（粉丝）
 *
 *  @param uid      被关注者
 *  @param start_id <#start_id description#>
 *  @param count    <#count description#>
 *
 *  @return <#return value description#>
 */
+ (NSArray *)following_followers_of_withUserId:(NSUInteger)uid start_id:(NSUInteger)start_id count:(NSUInteger)count
{
    DouApiClient *client          = [DouApiClient sharedInstance];
    __block NSMutableArray *users = [[NSMutableArray alloc] init];
    
    DouReqBlock callback = ^(NSData *data) {
        NSArray *arr   = [NSJSONSerialization JSONObjectWithData:data options:1 error:nil];
        
        [arr enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL *stop) {
            NSError *error   = nil;
            DoubanUser *user = [MTLJSONAdapter modelOfClass:DoubanUser.class fromJSONDictionary:dic error:&error];
            [users addObject:user];
        }];
    };
    
    NSUInteger start  = (start_id > 0) ? start_id : 0;
    NSUInteger icount = (count > 0) ? count : 20;
    
    NSString *url = [NSString stringWithFormat:@"shuo/v2/users/%d/following_followers_of?start=%d&count=%d", uid, start, icount];
    [client httpsGet:url withCompletionBlock:callback];
    
    return [users copy];
}

+ (BOOL)block_user_withUserId:(NSUInteger)uid
{
    DouApiClient *client = [DouApiClient sharedInstance];
    __block BOOL success;
    
    DouReqBlock callback = ^(NSData *data) {
        NSError *error     = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:1 error:&error];
        
        NSUInteger result = (NSUInteger)dict[@"r"];
        success = (1 == result) ? YES : NO;
    };
    
    NSDictionary *postDict = @{@"user_id": [NSString stringWithFormat:@"%d", uid]};
    
    NSString *url = [NSString stringWithFormat:@"shuo/v2/users/%d/block", uid];
    [client httpsPost:url withDict:postDict completionBlock:callback];
    
    return success;
}

+ (DoubanUser *)follow_user_withUserId:(NSUInteger)uid
{
    DouApiClient *client     = [DouApiClient sharedInstance];
    __block DoubanUser *user = nil;
    
    DouReqBlock callback = ^(NSData *data) {
        NSError *error     = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:1 error:&error];
        user               = [MTLJSONAdapter modelOfClass:DoubanUser.class fromJSONDictionary:dict error:&error];
    };
    
    NSString *user_id      = [NSString stringWithFormat:@"%d", uid];
    NSDictionary *postDict = @{@"source": kApiKey, @"user_id": user_id};
    
    NSString *url = @"shuo/v2/friendships/create";
    [client httpsPost:url withDict:postDict completionBlock:callback];
    
    return user;
}

+ (DoubanUser *)unfollow_user_withUserId:(NSUInteger)uid
{
    DouApiClient *client     = [DouApiClient sharedInstance];
    __block DoubanUser *user = nil;
    
    DouReqBlock callback = ^(NSData *data) {
        NSError *error     = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:1 error:&error];
        user               = [MTLJSONAdapter modelOfClass:DoubanUser.class fromJSONDictionary:dict error:&error];
    };
    
    NSString *user_id      = [NSString stringWithFormat:@"%d", uid];
    NSDictionary *postDict = @{@"source": kApiKey, @"user_id": user_id};
    
    NSString *url = @"shuo/v2/friendships/destroy";
    [client httpsPost:url withDict:postDict completionBlock:callback];
    
    return user;
}

+ (NSDictionary *)friendships_betweenSourceUid:(NSUInteger)source_uid targetUid:(NSUInteger)target_uid
{
    DouApiClient *client             = [DouApiClient sharedInstance];
    __block NSDictionary *resultDict = nil;
    
    DouReqBlock callback = ^(NSData *data) {
        NSError *error = nil;
        resultDict     = [NSJSONSerialization JSONObjectWithData:data options:1 error:&error];
    };
    
    NSString *source_id    = [NSString stringWithFormat:@"%d", source_uid];
    NSString *target_id    = [NSString stringWithFormat:@"%d", target_uid];
    NSDictionary *postDict = @{@"source": kApiKey, @"source_id": source_id, @"target_id": target_id};
    
    NSString *url = @"shuo/v2/friendships/show";
    [client httpsPost:url withDict:postDict completionBlock:callback];
    
    return resultDict;
}

@end





@implementation DoubanSimpleUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"iid": @"id",
        @"description": @"description",
        @"large_avatar": @"large_avatar",
        @"small_avatar": @"small_avatar",
        @"screen_name": @"screen_name",
        @"type": @"type",
        @"uid": @"uid"
    };
}

+ (NSValueTransformer *)createdJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [self.dateFormatter dateFromString:str];
    } reverseBlock:^(NSDate *date) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

+ (NSValueTransformer *)large_avatarJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)small_avatarJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
