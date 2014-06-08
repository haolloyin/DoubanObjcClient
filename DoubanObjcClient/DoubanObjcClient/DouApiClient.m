//
//  DoubanObjcClient.m
//  DoubanObjcClient
//
//  Created by hao on 5/18/14.
//  Copyright (c) 2014 com.hao. All rights reserved.
//

#import "DouApiClient.h"
#import "STHTTPRequest.h"

@implementation DouApiClient

+ (id)sharedInstance
{
    static DouApiClient *singleInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (!singleInstance) {
            singleInstance = [[DouApiClient alloc] init];
            
            // TODO 仅用于调试 STHTTPRequest 的请求
            [USER_DEFAULTS setBool:YES forKey:@"STHTTPRequestShowCurlDescription"];
            [USER_DEFAULTS setBool:YES forKey:@"STHTTPRequestShowDebugDescription"];
            [USER_DEFAULTS synchronize];
        }
    });
    
    return singleInstance;
}


#pragma mark - OAuth

/**
 *  获取一个用于开始 OAuth 授权的 NSURLRequest 实例，用于在 WebView 中访问
 *
 *  @return <#return value description#>
 */
- (NSURLRequest *)getOAuthRequest
{
    NSString *url = [[NSString stringWithFormat:@"%@?client_id=%@&redirect_uri=%@&response_type=code&scope=%@",
                     kOAuthURL, kApiKey, kRedirectURL, kOAuthScope]
                     stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    return req;
}

/**
 *  验证用户 OAuth 授权的第一步获取到的 authorization_code 是否有效，
 *  如有效则得到 access_token 等信息并保存至本地
 */
- (void)validateAuthorizationCode
{
    NSURL *URL                   = [NSURL URLWithString:kTokenURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    NSString *body               = [NSString stringWithFormat:
                                    @"client_id=%@&client_secret=%@&redirect_uri=%@"
                                    @"&grant_type=authorization_code&code=%@",
                                    kApiKey, kApiSecret, kRedirectURL, self.authorizationCode];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSString *respString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               NSLog(@"respString:\n%@", respString);
                               
                               NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                               
                               if (!error && !dict[@"code"]) {
                                   
                                   [self saveTokens:dict];
                                   NSLog(@"tokens saved");
                                   [self.delegate OAuthClient:self didSuccessWithDictionary:dict];
                               }
                               else {
                                   
                               }
                           }];
}

/**
 *  用本地保存的 refresh_token 更新 access_token，并保存至本地
 */
- (void)validateRefreshToken
{
    NSURL *URL                   = [NSURL URLWithString:kTokenURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    NSString *body               = [NSString stringWithFormat:
                                    @"client_id=%@&client_secret=%@&redirect_uri=%@"
                                    @"&grant_type=refresh_token&refresh_token=%@",
                                    kApiKey, kApiSecret, kRedirectURL, [self refreshToken]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];

    NSURLResponse *resp;
    NSError *error;
    // 用 refreshToken 刷新 accessToken 应该使用同步请求
    NSData *data                = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&error];
    NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)resp;
    
    NSString *respString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"respString:\n%@", respString);

    if ([httpResp statusCode] == 200) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        [self saveTokens:dict];
    }
}


#pragma mark - OAuth data

/**
 *  当 OAuth 授权成功，或更新 access_token 成功时，传入 dict 保存所有 token 信息
 *
 *  @param dict 豆瓣返回的 access_token 信息
 */
- (void)saveTokens:(NSDictionary *)dict
{
    [USER_DEFAULTS setObject:dict[kAccessTokenKey] forKey:kAccessTokenKey];
    [USER_DEFAULTS setObject:dict[kRefreshTokenKey] forKey:kRefreshTokenKey];
    [USER_DEFAULTS setObject:dict[kDoubanUserIdKey] forKey:kDoubanUserIdKey];
    [USER_DEFAULTS setObject:dict[kDoubanUserNameKey] forKey:kDoubanUserNameKey];
    
    NSUInteger expiresSecond = [dict[kExpiresInKey] integerValue];
    [USER_DEFAULTS setObject:[[NSDate date] dateByAddingTimeInterval:expiresSecond] forKey:kExpiresInKey];
    
    [USER_DEFAULTS synchronize];
}

/**
 *  清空本地所有跟 OAuth 相关的 token 等
 */
- (void)clearTokens
{
    [USER_DEFAULTS removeObjectForKey:kAccessTokenKey];
    [USER_DEFAULTS removeObjectForKey:kRefreshTokenKey];
    [USER_DEFAULTS removeObjectForKey:kDoubanUserIdKey];
    [USER_DEFAULTS removeObjectForKey:kDoubanUserNameKey];
    [USER_DEFAULTS removeObjectForKey:kExpiresInKey];
    [USER_DEFAULTS synchronize];
}

- (NSString *)accessToken
{
    NSString *token = [USER_DEFAULTS objectForKey:kAccessTokenKey];
    return token;
}

- (NSString *)refreshToken
{
    NSString *token = [USER_DEFAULTS objectForKey:kRefreshTokenKey];
    return token;
}

- (NSString *)user_id
{
    NSString *user = [USER_DEFAULTS objectForKey:kDoubanUserIdKey];
    return user;
}

/**
 *  本地保存的 access_token 是否已过期
 *
 *  @return <#return value description#>
 */
- (BOOL)hasExpired
{
    NSDate *expireTime = [USER_DEFAULTS objectForKey:kExpiresInKey];
    NSLog(@"expireTime: %@", expireTime);
    
    if ([[NSDate date] compare:expireTime] == NSOrderedDescending) {
        return YES;
    }
    else {
        return NO;
    }
}

/**
 *  是否应该进行 OAuth 授权，当本地没有 access_token 或过期时间，需要重新授权
 *
 *  @return <#return value description#>
 */
- (BOOL)shouldOAuth
{
    NSString *access     = [USER_DEFAULTS objectForKey:kAccessTokenKey];
    NSString *expireTime = [USER_DEFAULTS objectForKey:kExpiresInKey];
    NSLog(@"accessToken: %@, expireTime: %@", access, expireTime);
    
    if (!access || !expireTime || [self hasExpired]) {
        return YES; // 如果没有 accessToken 或过期时间，需要重新授权
    }
    return NO;
}

/**
 *  是否需要更新 access_token，如果不需要 OAuth 但是已经过期时，需要更新 access_token
 *
 *  @return <#return value description#>
 */
- (BOOL)shouldRefreshToken
{
    if (![self shouldOAuth] && [self hasExpired]) {
        return YES; // 如果不需要 OAuth 但是已经过期
    }
    return NO;
}


#pragma mark - Douban API with block

/**
 *  简单封装通用的请求
 *
 *  @param subPath <#subPath description#>
 *  @param method  <#method description#>
 *  @param type    <#type description#>
 */
- (void)requestWithSubPath:(NSString *)subPath
                    method:(NSString *)method
               requestType:(NSString *)requestType
                      data:(NSDictionary *)dict
           completionBlock:(DouReqBlock)reqBlock
{
    NSError *error               = nil;
    NSString *baseURL            = ([requestType isEqualToString:@"HTTP"]) ? kHttpApiBaseUrl : kHttpsApiBaseUrl;
    NSURL *url                   = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseURL, subPath]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:method];
    
    if ([requestType isEqualToString:@"HTTPS"]) {
        [request setAllHTTPHeaderFields:@{@"Authorization": [NSString stringWithFormat:@"Bearer %@", [self accessToken]]}];
    }
    
    if ([method isEqualToString:@"POST"] && dict) {
        NSData *postData = [NSKeyedArchiver archivedDataWithRootObject:dict];
        [request setHTTPBody:postData];
    }
    
    NSHTTPURLResponse *resp         = nil;
    NSData *respData            = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&error];
    
    NSString *respString = [[NSString alloc] initWithData:respData encoding:NSUTF8StringEncoding];
    NSLog(@"\n\nrespString:\n%@\n\n", respString);
    
    if ([resp statusCode] == 200) {
        reqBlock(respData); // 回调
    }
}

- (void)get:(NSString *)subPath withCompletionBlock:(DouReqBlock)reqBlock
{
    [self requestWithSubPath:subPath method:@"GET" requestType:@"HTTP" data:nil completionBlock:reqBlock];
}

- (void)httpsGet:(NSString *)subPath withCompletionBlock:(DouReqBlock)reqBlock
{
    [self requestWithSubPath:subPath method:@"GET" requestType:@"HTTPS" data:nil completionBlock:reqBlock];
}

- (void)httpsPost:(NSString *)subPath withCompletionBlock:(DouReqBlock)reqBlock
{
    [self requestWithSubPath:subPath method:@"POST" requestType:@"HTTPS" data:nil completionBlock:reqBlock];
}

- (void)httpsDelete:(NSString *)subPath withCompletionBlock:(DouReqBlock)reqBlock
{
    [self requestWithSubPath:subPath method:@"DELETE" requestType:@"HTTPS" data:nil completionBlock:reqBlock];
}

- (void)httpsPost:(NSString *)subPath withDict:(NSDictionary *)postDict completionBlock:(DouReqBlock)reqBlock
{
    NSError *error               = nil;
    NSURL *url                   = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kHttpsApiBaseUrl, subPath]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *authHeader         = [NSString stringWithFormat:@"Bearer %@", [self accessToken]];
    
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:@{@"Authorization": authHeader}];
    
    if (postDict) {
        NSMutableString *bodyString = [[NSMutableString alloc] init];
        NSUInteger idx = 0;
        for (NSString *key in postDict) {
            NSString *value = postDict[key];
            if (0 == idx) {
                [bodyString appendFormat:@"%@=%@", key, value];
            }
            else {
                [bodyString appendFormat:@"&%@=%@", key, value];
            }
            idx += 1;
        }
        
        [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    }

    NSHTTPURLResponse *resp = nil;
    NSData *respData        = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&error];
    NSString *respString    = [[NSString alloc] initWithData:respData encoding:NSUTF8StringEncoding];
    NSLog(@"\n\nresp body:\n%@\n\n", request.HTTPBody);
    NSLog(@"\n\nrespString:\n%@\n\n", respString);
    
    if ([resp statusCode] == 200) {
        reqBlock(respData); // 回调
    }
}

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
  completionBlock:(DouReqBlock)reqBlock
{
    NSString *url                  = [NSString stringWithFormat:@"%@%@", kHttpsApiBaseUrl, subPath];
    NSString *authHeader           = [NSString stringWithFormat:@"Bearer %@", [self accessToken]];
    NSString *boundary             = @"_0xDoubanObjcClient-BoUnDaRy_";
    NSString *headerContentType    = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    NSMutableDictionary * postDict = [[NSMutableDictionary alloc] init];
    NSMutableURLRequest *request   = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    __block NSMutableString *kvBody = [[NSMutableString alloc] init];// k-v 格式的参数
    NSMutableString *dataBody       = [[NSMutableString alloc] init];// 二进制的参数，如图片
    NSMutableData *bodyData         = [[NSMutableData alloc] init];// 完整的 POST body
    
    // 遍历所有 k-v 文本的提交参数
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *k, NSString *v, BOOL *stop) {
        [kvBody appendFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n", boundary, k, v];
    }];
    [bodyData appendData:[kvBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 处理二进制的提交参数
    [dataBody appendFormat:@"--%@\r\nContent-Disposition: form-data; name=\"image\"; filename=\"filename\"\r\n", boundary];
    [dataBody appendFormat:@"Content-Type: %@\r\nContent-Transfer-Encoding: binary\r\n\r\n", mimeType];
    
    [bodyData appendData:[dataBody dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:data]; // 添加原始的二进制
    
    NSString *endBoundary = [NSString stringWithFormat:@"\r\n--%@--\r\n", boundary];
    [bodyData appendData:[endBoundary dataUsingEncoding:NSUTF8StringEncoding]];

    // 添加头部信息
    [postDict setValue:authHeader forKeyPath:@"Authorization"];
    [postDict setObject:headerContentType forKey:@"Content-Type"];
    [postDict setObject:@"Content-Length" forKey:[NSString stringWithFormat:@"%u", [bodyData length]]];
    
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:postDict];
    [request setHTTPBody:bodyData];
 
    NSHTTPURLResponse *resp = nil;
    NSError *error          = nil;
    NSData *respData        = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&error]; // 同步请求
    NSString *respString    = [[NSString alloc] initWithData:respData encoding:NSUTF8StringEncoding];

    NSLog(@"\n\nhttp header:\n%@\n\n", request.allHTTPHeaderFields);
    NSLog(@"\n\nhttp body:\n%@\n\n", [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
    NSLog(@"\n\nresp:\n%@\n\n", respString);
    
    if ([resp statusCode] == 200) {
        reqBlock(respData); // 回调
    }
}













@end
