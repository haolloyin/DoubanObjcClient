//
//  DoubanBaseModel.h
//  DoubanObjcClient
//
//  Created by hao on 5/23/14.
//  Copyright (c) 2014 com.hao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mantle.h"

@interface DoubanBaseModel : MTLModel<MTLJSONSerializing>

+ (NSDateFormatter *)dateFormatter;

@end
