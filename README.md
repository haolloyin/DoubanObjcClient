
### DoubanObjcClient

简单的第三方豆瓣 API Objc 客户端，目前已简单封装了[豆瓣 OAuth 2](http://developers.douban.com/wiki/?title=oauth2) 认证流程，和[豆瓣用户](http://developers.douban.com/wiki/?title=user_v2)、[豆瓣广播](http://developers.douban.com/wiki/?title=shuo_v2)两个 Model 和 API 并测试通过。


### 缘起

官方的 [douban-objc-client](https://github.com/douban/douban-objc-client) 看起来年久失修（吐槽一下，为什么就不能像 [Python 版](https://github.com/douban/douban-client)那么简洁呢？），里面还有 `GData` 和 `ASIHTTPRequest` 两个老东西，使用前还要引用好几个库，使用时也感觉不是很方便。

最重要的是我用起来不成功，`OAuth` 认证没问题，但卡在调其他具体 API 那里，估计跟 `ASIHTTPRequest` 的封装有关。花了点时间没找到问题，于是自己纯用 `NSMutableRequest` 简单封装了网络处理。


### 特点

1. 所有网络请求有关的都封装在一个单例对象 `DouApiClient.m` 里面，看起来简单；
2. 用了 Github 出品的 [Mantle](https://github.com/Mantle/Mantle)，方便扩展豆瓣的其他 Model；
3. `DouApiClient.m` 内有通用的 `GET` `POST` `DELETE` 等实现，便于实现其他 Model 的 API 接口；
4. 提供 OAuth 授权时弹出的 `DouOAuthViewController`，无须折腾 `UIWebView` 发起 OAuth 请求并回调处理的那一套；
5. 内置 Demo，自己运行看看呗；
6. 除了 `Mantle`，不依赖其他第三方库，纯 Objc；


### 介绍

#### 1.网络请求

`DoubanObjcClient` 纯用 `NSMutableRequest` 封装网络请求和响应，`**目前所有 API 全部用了同步请求**`。起初想用一个封装很简洁又较轻量级的 [STHTTPRequest](https://github.com/nst/STHTTPRequest)，但考虑到豆瓣 API 没有复杂的处理，没必要封装那么多对象到每一个网络请求去。

而且在发带图片广播时用 `STHTTPRequest` 也失败了，只得自己看 [RFC 1867](http://www.ietf.org/rfc/rfc1867.txt) 和其中的例子自己简单构造 `multipart/form-data` 请求。当然也参考了 [ASIFormDataRequest.m](https://github.com/pokeb/asi-http-request/blob/master/Classes/ASIFormDataRequest.m#L217) 和 [STHTTPRequest.m](https://github.com/nst/STHTTPRequest/blob/master/STHTTPRequest.m#L324) 在这方面的代码处理。

```objc
// DouApiClient.m

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
```

#### 2.Model 封装

目前仅使用 Github 出品的 [Mantle](https://github.com/Mantle/Mantle) 封装 server 返回的 JSON 串到 Model Object 的自动转换。不得不说，用 `Mantle` 对付这种写枯燥重复的映射代码是太好了。

因为目前只申请了豆瓣用户、豆瓣广播的权限，例如豆瓣广播只需要写下面这点映射代码就搞定了。

```objc
// model/DoubanShuo.h

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"iid": @"id",
        @"title": @"title",
        @"text": @"text",
        @"reshared_count": @"reshared_count",
        @"like_count": @"like_count",
        @"comments_count": @"comments_count",
        @"can_reply": @"can_reply",
        @"liked": @"liked",
        @"createdAt": @"created_at",
        @"user": @"user",
        @"resharedStatus": @"reshared_status"
    };
}

+ (NSValueTransformer *)createdAtJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [self.dateFormatter dateFromString:str];
    } reverseBlock:^(NSDate *date) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

+ (NSValueTransformer *)userJSONTransformer {
    return [MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[DoubanSimpleUser class]];
}

+ (NSValueTransformer *)resharedStatusJSONTransformer {
    return [MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[DoubanShuo class]];
}
```

#### 3.如何使用

- 拖拽 `DoubanObjcClient/DoubanObjcClient` 源代码目录到你的工程去，里面应该包含如下：

```shell
cd DoubanObjcClient/DoubanObjcClient
.
|____about_coder.jpg
|____DouApiClient.h
|____DouApiClient.m
|____DouApiDefines.h
|____douban-favicon.png
|____DouOAuthViewController.h
|____DouOAuthViewController.m
|____DouObjcClient.h
|
|____model
| |____DoubanBaseModel.h
| |____DoubanBaseModel.m
| |____DoubanShuo.h
| |____DoubanShuo.m
| |____DoubanUser.h
| |____DoubanUser.m
|
|____vendor
| |____Mantle
| |____STHTTPRequest
```

- 修改 `DouApiDefines.h` 中的 `API_Key` `API_Secret` 等信息。

**注意：豆瓣用户的 API 文档大部分出现在豆瓣广播那里，经实际测试的调用 URL 的确是以 shuo/v2/users/ 开头**，详见[官方文档](http://developers.douban.com/wiki/?title=shuo_v2#user_following)，所以下面单独一个 `douban_basic_common` 可能还不包含用户完整的 API 权限。

```objc
#pragma mark - Developers MUST change bellow configs according to your case

#define kApiKey                     @"Your_API_Key"
#define kApiSecret                  @"Your_API_Secret"
#define kRedirectURL                @"Your_Redirect_URL"
#define kOAuthScope                 @"douban_basic_common,shuo_basic_r,shuo_basic_w"
```

- OAuth 授权，用 StoryBoard 拖拽一个 ViewController，将其 Custom Class 改为 `DouOAuthViewController`，这个 ViewController 已经实现了 OAuth 2 授权的 UI 和处理逻辑，可以直接用。

```objc
#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *identifier = segue.identifier;
    
    NSLog(@"identifier: %@", identifier);
    
    if ([segue.identifier isEqualToString:@"BeginDoubanOAuth"]) {
        
        // 如果确定用 modal 方式，要先取出 NavagationController 的 topViewController 再赋值
        UINavigationController *navController = segue.destinationViewController;
        DouOAuthViewController *controller = (DouOAuthViewController *)navController.topViewController;
        controller.presentStype = DouOAuthViewPresentWithModal;
        
        // 如果用 push 方式，直接修改 DouOAuthViewController.presentStype 属性为 DouOAuthViewPresentWithPush
//        DouOAuthViewController *controller = segue.destinationViewController;
//        controller.presentStype = DouOAuthViewPresentWithPush;
    }
}
```

- 如果是使用现有的豆瓣用户、豆瓣广播的 API，那么可以直接使用 `DoubanUser`（或 `DoubanSimpleUser`）和 `DoubanShuo` 两个 Model 类，里面已经封装了文档中能用的 API 接口。

**注意：`follow_in_common` 和 `block_user` 等 API 按文档实现后调用失败，不知何故。**

例如：
```objc
// 推荐网址
[DoubanShuo post_statuses_withText:@"测试推荐网址"
                         rec_title:@"豆瓣广播 Api V2"
                           rec_url:@"http://developers.douban.com/wiki/?title=shuo_v2"
                          rec_desc:@"这里填描述啦" rec_image:@"要引用的图片URL"];

// 发送带图片的广播
NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"about_coder" ofType:@"jpg"]];
[DoubanShuo post_statuses_withText:@"文本信息" image:data];
```

或者直接看 `DoubanObjcClient/DouViewController.m` 下的那些测试代码。

- 如果要扩展其他接口（如豆瓣日记等），可以模仿 `DoubanShuo.m` 完成 Model 的映射并实现它的接口，在 `DoubanObjcClient/DoubanObjcClient/DouApiClient.m` 已经实现了 `GET` `DELETE` `POST` 等通用请求方法。

```objc
//DouApiClient.m

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
```

例如 `DoubanShuo.m` 中获取一条广播的实现：
```objc
// DoubanShuo.m

/**
 *  获取一条广播，needPacked 表示是否打包 resharers 和 comments 数据
 *
 *  @param iid        <#iid description#>
 *  @param needPacked 是否打包 resharers 和 comments 数据
 *
 *  @return <#return value description#>
 */
+ (DoubanShuo *)statuses_withId:(NSUInteger)iid needPacked:(BOOL)needPacked;
{
    DouApiClient *client     = [DouApiClient sharedInstance];
    __block DoubanShuo *shuo = nil;
    
    DouReqBlock callback = ^(NSData *data) {
        NSError *error     = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:1 error:&error];
        shuo               = [MTLJSONAdapter modelOfClass:DoubanShuo.class fromJSONDictionary:dict error:&error];
    };
    
    //TODO 当 pack=true 时，返回的 JSON 包含 resharers、like、comments，更复杂了，需要更新 DoubanShuo 模型
    NSString *para = (needPacked) ? @"?pack=true" : @"";
    NSString *url = [NSString stringWithFormat:@"shuo/v2/statuses/%d%@", iid, para];
    [client get:url withCompletionBlock:callback];
    
    return shuo;
}
```


### 注意 & TODO

1. 所有网络请求的代码都没有异常处理，按返回 status=200 的情况来处理了；-_-||
2. 所有网络请求都是同步方式；
3. 只有豆瓣用户、豆瓣广播两个接口。








