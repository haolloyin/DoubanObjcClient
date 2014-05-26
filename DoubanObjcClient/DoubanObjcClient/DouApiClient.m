//
//  DoubanObjcClient.m
//  DoubanObjcClient
//
//  Created by hao on 5/18/14.
//  Copyright (c) 2014 com.hao. All rights reserved.
//

#import "DouApiClient.h"

@implementation DouApiClient

+ (id)sharedInstance
{
    static DouApiClient *singleInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (!singleInstance) {
            singleInstance = [[DouApiClient alloc] init];
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
    
    if (!access || !expireTime) {
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
                    method:(DouRequestMethod)method
               requestType:(DouRequestType)requestType
                      data:(NSDictionary *)dict
           completionBlock:(DouReqBlock)reqBlock
{
    NSError *error               = nil;
    NSString *baseURL            = (requestType == DouHTTP) ? kHttpApiBaseUrl : kHttpsApiBaseUrl;
    NSString *methodStr          = (method == DouRequestGET) ? @"GET" : ((method == DouRequestPOST) ? @"POST" : @"DELETE");
    NSURL *url                   = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseURL, subPath]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:methodStr];
    
    if (requestType == DouHTTPS) {
        [request setAllHTTPHeaderFields:@{@"Authorization": [NSString stringWithFormat:@"Bearer %@", [self accessToken]]}];
    }
    
    if (method == DouRequestPOST && dict) {
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
    [self requestWithSubPath:subPath method:DouRequestGET requestType:DouHTTP data:nil completionBlock:reqBlock];
}

- (void)httpsGet:(NSString *)subPath withCompletionBlock:(DouReqBlock)reqBlock
{
    [self requestWithSubPath:subPath method:DouRequestGET requestType:DouHTTPS data:nil completionBlock:reqBlock];
}

- (void)httpsPost:(NSString *)subPath withCompletionBlock:(DouReqBlock)reqBlock
{
    [self requestWithSubPath:subPath method:DouRequestPOST requestType:DouHTTPS data:nil completionBlock:reqBlock];
}

- (void)httpsDelete:(NSString *)subPath withCompletionBlock:(DouReqBlock)reqBlock
{
    [self requestWithSubPath:subPath method:DouRequestDELETE requestType:DouHTTPS data:nil completionBlock:reqBlock];
}

- (void)httpsPost:(NSString *)subPath withDict:(NSDictionary *)postDict completionBlock:(DouReqBlock)reqBlock
{
    NSError *error               = nil;
    NSURL *url                   = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kHttpsApiBaseUrl, subPath]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *authHeader         = [NSString stringWithFormat:@"Bearer %@", [self accessToken]];
    
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:@{@"Authorization": authHeader, @"Content-Type": @"multipart/form-data"}];
    
    if (postDict) {
        NSData *postData = [NSKeyedArchiver archivedDataWithRootObject:postDict];
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






@end
