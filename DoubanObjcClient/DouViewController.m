//
//  DouViewController.m
//  DoubanObjcClient
//
//  Created by hao on 5/18/14.
//  Copyright (c) 2014 com.hao. All rights reserved.
//

#import "DouViewController.h"
#import "DoubanObjcClient/DouObjcClient.h"
#import "DoubanObjcClient/model/DoubanShuo.h"

@interface DouViewController ()

@property (strong, nonatomic) IBOutlet UITextView *respView;
@property (strong, nonatomic) IBOutlet UITextView *requestTextView;

@end

@implementation DouViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


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


#pragma mark - IBAction

- (void)showAlertView:(NSString *)msg
{
    UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil)
                                                     message:NSLocalizedString(msg, nil)
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"取消", nil)
                                           otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
    [alert show];
}

- (IBAction)beginOAuth:(id)sender {
    
    DouApiClient *service = [DouApiClient sharedInstance];
    if ([service shouldOAuth]) {
        [self performSegueWithIdentifier:@"BeginDoubanOAuth" sender:nil];
    }
    else {
        [self showAlertView:@"无需重新授权"];
    }
}

- (IBAction)refrechToken:(id)sender {
}

- (IBAction)clearTokens:(id)sender {
    DouApiClient *client = [DouApiClient sharedInstance];
    [client clearTokens];
    
    [self showAlertView:@"Tokens 已清空，需要重新授权"];
}

- (IBAction)testGetRequest:(id)sender {
//    DouApiClient *client = [DouApiClient sharedInstance];
//    DouReqBlock callbackBlock = ^(NSData * data){
//        NSString *respString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"respString:\n%@", respString);
//        self.respView.text = respString;
//    };
    
//    NSString *url = [NSString stringWithFormat:@"shuo/v2/statuses/user_timeline/%@", [service user_id]];
//    [client get:url withCompletionBlock:callbackBlock];
    
//    NSString *url = [NSString stringWithFormat:@"shuo/v2/statuses/home_timeline", nil];
//    [client httpsGet:url withCompletionBlock:callbackBlock];
    
//    [DoubanShuo statuses_withId:1402641133 needPacked:YES];
//    [DoubanShuo statusesWithId:1403330980]; // 获取一条转播
    [DoubanShuo user_timeline_withUserIdOrName:@"ahbei" since:0 until:0];
//    [DoubanShuo home_timeline_withSince:1397704049 until:0 count:4 start:0];
//    [DoubanShuo statuses_comments_withId:1402640365 start:1390823405 count:2];
    
//    [DoubanShuo statuses_like_withId:1402640365];
//    [DoubanShuo statuses_reshare_withId:1402640365];
//    [DoubanShuo delete_statuses_withId:1404392507];
    
//    NSString *text = [NSString stringWithFormat:@"测试发送带图片的广播，成功啦！！！ --%@", [NSDate date]];
//    [DoubanShuo post_statuses_withText:text image:nil]; // 纯文字

    // 推荐网址
//    [DoubanShuo post_statuses_withText:@"测试推荐网址"
//                             rec_title:@"豆瓣广播 Api V2"
//                               rec_url:@"http://developers.douban.com/wiki/?title=shuo_v2"
//                              rec_desc:@"描述啦" rec_image:@"http://img3.douban.com/icon/u45742059-2.jpg"];
    
//    NSString *text = [NSString stringWithFormat:@"测试发送带图片的广播，成功啦！！！--%@", [NSDate date]];
//    UIImage *image = [UIImage imageNamed:@"image.png"];
//    NSData *data = UIImagePNGRepresentation(image);
//    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"about_coder" ofType:@"jpg"]];
//    [DoubanShuo post_statuses_withText:text image:data];
    
//    [DoubanUser get_user_withName:@"ahbei"];
//    [DoubanUser current_user];
//    [DoubanUser search_user_withText:@"hao" start_id:0 count:3];
//    [DoubanUser user_following_withUserId:1000001 start_id:0 count:100];
//    [DoubanUser user_followers_withUserId:1000001 start_id:1 count:33];
//    [DoubanUser follow_in_common_withUserId:1000001 start_id:0 count:10]; // error
//    [DoubanUser following_followers_of_withUserId:1000001 start_id:0 count:10];
    
//    [DoubanUser block_user_withUserId:1000001]; // error
}













@end
