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

+ (DoubanUser *)current_user_withName:(NSString *)name;

+ (NSArray *)search_user_withText:(NSString *)text start_id:(NSUInteger)start_id count:(NSUInteger)count;

+ (NSArray *)user_following_withUserId:(NSString *)uid start_id:(NSUInteger)start_id count:(NSUInteger)count;

+ (NSArray *)user_followers_withUserId:(NSString *)uid start_id:(NSUInteger)start_id count:(NSUInteger)count;

+ (NSArray *)following_followers_of_withUserId:(NSString *)uid start_id:(NSUInteger)start_id count:(NSUInteger)count;

+ (BOOL)block_user_withUserId:(NSString *)uid;

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
