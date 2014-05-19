//
//  DouOAuthViewController.m
//  DoubanObjcClient
//
//  Created by hao on 5/18/14.
//  Copyright (c) 2014 com.hao. All rights reserved.
//

#import "DouOAuthViewController.h"
#import "DouApiDefines.h"
#import "DouApiClient.h"

@interface NSString (ParseCategory)
- (NSMutableDictionary *)explodeToDictionaryInnerGlue:(NSString *)innerGlue
                                           outterGlue:(NSString *)outterGlue;
@end

@implementation NSString (ParseCategory)

- (NSMutableDictionary *)explodeToDictionaryInnerGlue:(NSString *)innerGlue
                                           outterGlue:(NSString *)outterGlue {
    // Explode based on outter glue
    NSArray *firstExplode = [self componentsSeparatedByString:outterGlue];
    NSArray *secondExplode;
    
    // Explode based on inner glue
    NSInteger count = [firstExplode count];
    NSMutableDictionary* returnDictionary = [NSMutableDictionary dictionaryWithCapacity:count];
    for (NSInteger i = 0; i < count; i++) {
        secondExplode =
        [(NSString*)[firstExplode objectAtIndex:i] componentsSeparatedByString:innerGlue];
        if ([secondExplode count] == 2) {
            [returnDictionary setObject:[secondExplode objectAtIndex:1]
                                 forKey:[secondExplode objectAtIndex:0]];
        }
    }
    return returnDictionary;
}

@end


@interface DouOAuthViewController () <DouOAuthServiceDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;

- (IBAction)cancelOAuth:(id)sender;

@end

@implementation DouOAuthViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 49)];
    self.webView.scalesPageToFit = YES;
    self.webView.delegate = self;
    
    NSURLRequest *req = [[DouApiClient sharedInstance] getOAuthRequest];
    [self.webView loadRequest:req];
    
    [self.view addSubview:self.webView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    
    if ([[url absoluteString] hasPrefix:kRedirectURL]) {
        
        NSString* query = [url query];
        NSMutableDictionary *parsedQuery = [query explodeToDictionaryInnerGlue:@"="
                                                                    outterGlue:@"&"];
        // access_denied
        NSString *error = [parsedQuery objectForKey:@"error"];
        if (error) {
            return NO;
        }
        
        // access_accepted
        NSString *code            = [parsedQuery objectForKey:@"code"];
        DouApiClient *service  = [DouApiClient sharedInstance];
        service.clientId          = kApiKey;
        service.clientSecret      = kApiSecret;
        service.redirectURL       = kRedirectURL;
        service.authorizationCode = code;
        service.delegate          = self;
        
        [service validateAuthorizationCode];
        
        return NO;
    }
    return YES;
}

#pragma mark - DouOAuthServiceDelegate

- (void)OAuthClient:(DouApiClient *)client didSuccessWithDictionary:(NSDictionary *)dic
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)OAuthClient:(DouApiClient *)client didFailWithError:(NSError *)error
{
    
}

#pragma mark - IBAction

- (IBAction)cancelOAuth:(id)sender {
    NSLog(@"");
    [self dismissViewControllerAnimated:YES completion:nil];
}












@end
