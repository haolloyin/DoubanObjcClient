//
//  DoubanShuo.h
//  DoubanObjcClient
//
//  Created by hao on 5/22/14.
//  Copyright (c) 2014 com.hao. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Mantle.h"
#import "DoubanUser.h"

@interface DoubanShuo : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) NSUInteger reshared_count;
@property (nonatomic, assign) NSUInteger like_count;
@property (nonatomic, assign) NSUInteger comments_count;
@property (nonatomic) BOOL can_reply;
@property (nonatomic) BOOL liked;
@property (nonatomic) NSDate *created_at;
@property (nonatomic, copy) DoubanUser *user;
@property (nonatomic, copy) DoubanShuo *reshared_status; // 转播的广播对象，这个属性只有在当前广播是一条转播的条件下才会有

+ (instancetype)statusesWithId:(NSUInteger )id;

@end
