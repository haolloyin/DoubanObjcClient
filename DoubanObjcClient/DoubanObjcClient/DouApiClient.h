//
//  DouOAuthService.h
//  DoubanObjcClient
//
//  Created by hao on 5/18/14.
//  Copyright (c) 2014 com.hao. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DouReqBlock)(NSData *); // 专门用于返回 API 请求响应结果

@class DouApiClient;

@protocol DouOAuthServiceDelegate <NSObject>
@required
- (void)OAuthClient:(DouApiClient *)client didSuccessWithDictionary:(NSDictionary *)dic;

- (void)OAuthClient:(DouApiClient *)client didFailWithError:(NSError *)error;
@end


@interface DouApiClient : NSObject

@property (nonatomic, strong) NSString *clientId;
@property (nonatomic, strong) NSString *clientSecret;
@property (nonatomic, strong) NSString *authorizationCode;
@property (nonatomic, strong) NSString *redirectURL;

@property (nonatomic, weak) id<DouOAuthServiceDelegate> delegate;


+ (id)sharedInstance;

- (NSURLRequest *)getOAuthRequest;

- (void)validateAuthorizationCode;

- (void)validateRefreshToken;

- (void)clearTokens;

- (BOOL)shouldOAuth;

- (NSString *)user_id;

#pragma mark - Douban API with block

- (void)httpsGet:(NSString *)subPath withCompletionBlock:(DouReqBlock)reqBlock;

- (void)get:(NSString *)subPath withCompletionBlock:(DouReqBlock)reqBlock;


@end
