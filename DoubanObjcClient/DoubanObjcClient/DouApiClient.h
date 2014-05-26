//
//  DoubanObjcClient.h
//  DoubanObjcClient
//
//  Created by hao on 5/18/14.
//  Copyright (c) 2014 com.hao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DouApiDefines.h"

typedef void (^DouReqBlock)(NSData *); // 专门用于返回 API 请求响应结果

/**
 *  HTTP/HTTPS 请求的 method
 */
typedef NS_ENUM(NSUInteger, DouRequestMethod) {
    /**
     *  <#Description#>
     */
    DouRequestGET,
    /**
     *  <#Description#>
     */
    DouRequestPOST,
    /**
     *  <#Description#>
     */
    DouRequestDELETE
};

/**
 *  HTTP 与 HTTPS
 */
typedef NS_ENUM(NSUInteger, DouRequestType) {
    /**
     *  <#Description#>
     */
    DouHTTP,
    /**
     *  <#Description#>
     */
    DouHTTPS
};

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

- (void)get:(NSString *)subPath withCompletionBlock:(DouReqBlock)reqBlock;

- (void)httpsGet:(NSString *)subPath withCompletionBlock:(DouReqBlock)reqBlock;

- (void)httpsPost:(NSString *)subPath withCompletionBlock:(DouReqBlock)reqBlock;

- (void)httpsDelete:(NSString *)subPath withCompletionBlock:(DouReqBlock)reqBlock;

- (void)httpsPost:(NSString *)subPath withDict:(NSDictionary *)postDict completionBlock:(DouReqBlock)callback;
















@end
