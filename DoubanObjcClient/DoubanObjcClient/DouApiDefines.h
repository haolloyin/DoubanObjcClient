//
//  DouApiDefines.h
//  DoubanObjcClient
//
//  Created by hao on 5/18/14.
//  Copyright (c) 2014 com.hao. All rights reserved.
//

#ifndef DoubanObjcClient_DouApiDefines_h
#define DoubanObjcClient_DouApiDefines_h


#pragma mark - official urls

#define kHttpsApiBaseUrl            @"https://api.douban.com/"
#define kHttpApiBaseUrl             @"http://api.douban.com/"
#define kOAuthURL                   @"https://www.douban.com/service/auth2/auth"
#define kTokenURL                   @"https://www.douban.com/service/auth2/token"


#pragma mark - User MUST change bellow configs according to your case

#define kApiKey                     @"00b92b2386aaa415022b816a93ffec3f"
#define kApiSecret                  @"e2d30b80812cf232"
#define kRedirectURL                @"https://github.com/haolloyin"
#define kOAuthScope                 @"douban_basic_common,shuo_basic_r,shuo_basic_w"


#pragma mark - 用于保存各种 token

#define kDoubanUserIdKey            @"douban_user_id"
#define kDoubanUserNameKey          @"douban_user_name"
#define kAccessTokenKey             @"access_token"
#define kRefreshTokenKey            @"refresh_token"
#define kExpiresInKey               @"expires_in"



#endif
