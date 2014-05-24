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
    
//    [DoubanShuo statusesWithId:1369251451]; // 测试获取一条广播
//    [DoubanShuo statusesWithId:1403330980]; // 获取一条转播
    [DoubanShuo user_timeline_withUserIdOrName:@"haolloyin" since:0 until:0];
}

- (IBAction)testDeleteRequest:(id)sender {
}














@end
