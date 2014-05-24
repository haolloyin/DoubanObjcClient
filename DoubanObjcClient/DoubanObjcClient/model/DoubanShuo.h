//
//  DoubanShuo.h
//  DoubanObjcClient
//
//  Created by hao on 5/22/14.
//  Copyright (c) 2014 com.hao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DoubanUser.h"
#import "DoubanBaseModel.h"

@interface DoubanShuo : DoubanBaseModel

@property (nonatomic, assign) NSUInteger iid;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) NSUInteger reshared_count;
@property (nonatomic, assign) NSUInteger like_count;
@property (nonatomic, assign) NSUInteger comments_count;
@property (nonatomic) BOOL can_reply;
@property (nonatomic) BOOL liked;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) DoubanSimpleUser *user;
@property (nonatomic, strong) DoubanShuo *resharedStatus; // 转播的广播对象，这个属性只有在当前广播是一条转播的条件下才会有

+ (DoubanShuo *)statuses_withId:(NSUInteger)iid;

+ (NSArray *)user_timeline_withUserIdOrName:(NSString *)user since:(NSUInteger)since until:(NSUInteger)until;

@end
