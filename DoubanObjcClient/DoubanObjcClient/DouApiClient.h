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

- (void)httpsPost:(NSString *)subPath withDict:(NSDictionary *)postDict completionBlock:(DouReqBlock)reqBlock;

/**
 *  发送带一个二进制附件（一般是图片）的 POST 请求
 *
 *  @param subPath  请求的子路径
 *  @param dict     K-V 格式的 POST 参数和值
 *  @param data     二进制数据（例如上传图片）
 *  @param paraName data 参数对应的上传参数，例如图片广播里的图片是 image
 *  @param mimeType data 参数对应的 MIME 类型，例如 PNG 图片是 image/png
 *  @param reqBlock 请求返回 200 时的回调 block
 */
- (void)httpsPost:(NSString *)subPath
   withDictionary:(NSDictionary *)dict
             data:(NSData *)data
 forParameterName:(NSString *)paraName
         mimeType:(NSString *)mimeType
  completionBlock:(DouReqBlock)reqBlock;














@end
