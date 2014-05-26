//
//  DoubanUser.h
//  DoubanObjcClient
//
//  Created by hao on 5/22/14.
//  Copyright (c) 2014 com.hao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DoubanBaseModel.h"

/**
 *  用户完整版信息
 */
@interface DoubanUser : DoubanBaseModel

@property (nonatomic, assign) NSUInteger iid;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *screen_name;
@property (nonatomic, strong) NSURL *avatar;
@property (nonatomic, strong) NSURL *alt;
@property (nonatomic, copy) NSString *relation;
@property (nonatomic, copy) NSDate *created;
@property (nonatomic, copy) NSString *loc_id;
@property (nonatomic, copy) NSString *loc_name;
@property (nonatomic, copy) NSString *desc;

+ (DoubanUser *)get_user_withName:(NSString *)name;

+ (DoubanUser *)current_user;

+ (NSArray *)search_user_withText:(NSString *)text start_id:(NSUInteger)start_id count:(NSUInteger)count;

/**
 *  获取所给用户（uid）关注的用户
 *
 *  @param uid      关注者
 *  @param start_id <#start_id description#>
 *  @param count    <#count description#>
 *
 *  @return <#return value description#>
 */
+ (NSArray *)user_following_withUserId:(NSUInteger)uid start_id:(NSUInteger)start_id count:(NSUInteger)count;

/**
 *  当前用户（指已授权的用户）与指定的用户（uid）共同关注了哪些用户
 *
 *  @param uid      <#uid description#>
 *  @param start_id <#start_id description#>
 *  @param count    <#count description#>
 *
 *  @return <#return value description#>
 */
//+ (NSArray *)follow_in_common_withUserId:(NSUInteger)uid start_id:(NSUInteger)start_id count:(NSUInteger)count;

/**
 *  获取所给用户（uid）被哪些用户关注，即粉丝
 *
 *  @param uid      被关注者
 *  @param start_id <#start_id description#>
 *  @param count    <#count description#>
 *
 *  @return <#return value description#>
 */
+ (NSArray *)user_followers_withUserId:(NSUInteger)uid start_id:(NSUInteger)start_id count:(NSUInteger)count;

/**
 *  当前用户（指已授权的用户）关注了某指定用户（uid）的哪些关注者（粉丝）
 *
 *  @param uid      被关注者
 *  @param start_id <#start_id description#>
 *  @param count    <#count description#>
 *
 *  @return <#return value description#>
 */
+ (NSArray *)following_followers_of_withUserId:(NSUInteger)uid start_id:(NSUInteger)start_id count:(NSUInteger)count;

+ (BOOL)block_user_withUserId:(NSUInteger)uid;

+ (DoubanUser *)follow_user_withUserId:(NSUInteger)uid;

+ (DoubanUser *)unfollow_user_withUserId:(NSUInteger)uid;

+ (NSDictionary *)friendships_betweenSourceUid:(NSUInteger)source_uid targetUid:(NSUInteger)target_uid;

@end

/**
 *  用户简版 User
 */
@interface DoubanSimpleUser : DoubanBaseModel

@property (nonatomic, copy) NSString *description;
@property (nonatomic, assign) NSUInteger iid;
@property (nonatomic, strong) NSURL *large_avatar;
@property (nonatomic, strong) NSURL *small_avatar;
@property (nonatomic, copy) NSString *screen_name;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *uid;

@end
