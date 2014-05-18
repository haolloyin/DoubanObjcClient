//
//  DouViewController.m
//  DoubanObjcClient
//
//  Created by hao on 5/18/14.
//  Copyright (c) 2014 com.hao. All rights reserved.
//

#import "DouViewController.h"
#import "DoubanObjcClient/DouOAuthService.h"

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
    
    DouOAuthService *service = [DouOAuthService sharedInstance];
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
    DouOAuthService *service = [DouOAuthService sharedInstance];
    [service clearTokens];
    
    [self showAlertView:@"Tokens 已清空，需要重新授权"];
}

- (IBAction)testGetRequest:(id)sender {
    DouOAuthService *service = [DouOAuthService sharedInstance];
    
    DouReqBlock callbackBlock = ^(NSData * data){

        NSString *respString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"respString:\n%@", respString);
        self.respView.text = respString;
    };
    
//    NSString *url = [NSString stringWithFormat:@"shuo/v2/statuses/user_timeline/%@", [service user_id]];
//    [service get:url withCompletionBlock:callbackBlock];
    
    NSString *url = [NSString stringWithFormat:@"v2/user/~me", nil];
    [service httpsGet:url withCompletionBlock:callbackBlock];
}

- (IBAction)testDeleteRequest:(id)sender {
}














@end
