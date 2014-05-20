//
//  DouOAuthViewController.h
//  DoubanObjcClient
//
//  Created by hao on 5/18/14.
//  Copyright (c) 2014 com.hao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    DouOAuthViewPresentWithPush,
    DouOAuthViewPresentWithModal
} DouOAuthViewPresentStype; // OAuthViewController 的弹出方式

@interface DouOAuthViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, assign) DouOAuthViewPresentStype presentStype;

@end
