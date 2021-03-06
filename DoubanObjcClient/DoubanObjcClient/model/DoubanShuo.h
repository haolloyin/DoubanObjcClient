//
//  DoubanShuo.h
//  DoubanObjcClient
//
//  Created by hao on 5/22/14.
//  Copyright (c) 2014 com.hao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DoubanUser.h"
#import "DoubanBaseModel.h"

/**
 *  广播附件里的多媒体信息
 */
@interface DoubanShuoMedia : DoubanBaseModel

@property (nonatomic, strong) NSURL *href;
@property (nonatomic, strong) NSURL *src;
@property (nonatomic, copy) NSString *original_src;
@property (nonatomic, copy) NSString *secret_pid;
@property (nonatomic, copy) NSString *type;

@end

/**
 *  广播里的附件
 */
@interface DoubanShuoAttachment : DoubanBaseModel

@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *caption;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong) NSURL *href;
@property (nonatomic, strong) DoubanShuoMedia *media; // 保存 DoubanShuoMedia 实例
@property (nonatomic, strong) NSDictionary *properties;

@end

@interface DoubanShuo : DoubanBaseModel

@property (nonatomic, assign) NSUInteger iid;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) NSUInteger reshared_count;
@property (nonatomic, assign) NSUInteger like_count;
@property (nonatomic, assign) NSUInteger comments_count;
@property (nonatomic) BOOL can_reply;
@property (nonatomic) BOOL liked;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) DoubanSimpleUser *user;
@property (nonatomic, strong) DoubanShuo *resharedStatus; // 转播的广播对象，这个属性只有在当前广播是一条转播的条件下才会有
@property (nonatomic, strong) DoubanShuoAttachment *attachments; // 保存 DoubanShuoAttachment 实例

+ (DoubanShuo *)statuses_withId:(NSUInteger)iid needPacked:(BOOL)needPacked;

/**
 *  删除一条广播
 *
 *  @param iid <#iid description#>
 *
 *  @return <#return value description#>
 */
+ (DoubanShuo *)delete_statuses_withId:(NSUInteger)iid;

+ (NSArray *)user_timeline_withUserIdOrName:(NSString *)user since:(NSUInteger)since until:(NSUInteger)until;

+ (NSArray *)home_timeline_withSince:(NSUInteger)since
                               until:(NSUInteger)until
                               count:(NSUInteger)count
                               start:(NSUInteger)start
                     completionBlock:(void (^)(NSData *data))completionBlock;

/**
 *  获取指定一条广播的评论列表
 *
 *  @param iid   广播的 id
 *  @param start 从 0 逐渐增大，越小表示评论得越早（文档没指明，通过测试验证的）
 *  @param count 指获取的评论条数，官方默认是 20条
 *
 *  @return 多条评论的集合，和广播是一样的结构体
 */
+ (NSArray *)statuses_comments_withId:(NSUInteger)iid start:(NSUInteger)start count:(NSUInteger)count;

/**
 *  赞一条广播
 *
 *  @param idd <#idd description#>
 */
+ (DoubanShuo *)statuses_like_withId:(NSUInteger)iid;

/**
 *  转播一条广播
 *
 *  @param iid <#iid description#>
 *
 *  @return <#return value description#>
 */
+ (DoubanShuo *)statuses_reshare_withId:(NSUInteger)iid;

/**
 *  发送一条广播
 *
 *  @param text      文字描述
 *  @param imageData 如果广播带图片，该参数不为 nil，否则为 nil，表示不上传图片
 *
 *  @return <#return value description#>
 */
+ (DoubanShuo *)post_statuses_withText:(NSString *)text image:(NSData *)imageData;

/**
 *  发送一条推荐网址的广播
 *
 *  @param text      <#text description#>
 *  @param rec_title 推荐网址的标题
 *  @param rec_url   推荐网址的href
 *  @param rec_desc  推荐网址的描述
 *  @param rec_image 推荐网址的附图url
 *
 *  @return <#return value description#>
 */
+ (DoubanShuo *)post_statuses_withText:(NSString *)text
                             rec_title:(NSString *)rec_title
                               rec_url:(NSString *)rec_url
                              rec_desc:(NSString *)rec_desc
                             rec_image:(NSString *)rec_image;












@end
