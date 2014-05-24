//
//  DoubanUser.m
//  DoubanObjcClient
//
//  Created by hao on 5/22/14.
//  Copyright (c) 2014 com.hao. All rights reserved.
//

#import "DoubanUser.h"

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
