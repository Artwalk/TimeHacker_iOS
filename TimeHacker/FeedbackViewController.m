//
//  FeedbackViewController.m
//  TimeHacker
//
//  Created by artwalk on 8/25/14.
//  Copyright (c) 2014 artwalk. All rights reserved.
//

#import "FeedbackViewController.h"

#import <MessageUI/MFMailComposeViewController.h>

//static const NSString *serverUrl = @"http://localhost:5000/feedback";
static const NSString *serverUrl = @"http://timehackerserver.herokuapp.com/feedback";

@interface FeedbackViewController () <UITextFieldDelegate, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *feedbackTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitBarButtonItem;
@property (strong, nonatomic) NSDictionary* deviceInfo;

@end

@implementation FeedbackViewController

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
    
//    [self send2Server];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)textFieldEditingChanged:(id)sender {
    if ([self.feedbackTextField.text isEqualToString:@""]) {
        [self.submitBarButtonItem setEnabled:NO];
    } else {
        [self.submitBarButtonItem setEnabled:YES];
    }
}

- (IBAction)submitBtnAction:(id)sender {
    self.submitBarButtonItem.enabled = NO;
    self.feedbackTextField.enabled = NO;
    
    [self send2Server];
}

- (void)send2Server {
    NSURL *url = [NSURL URLWithString:[serverUrl copy]];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    
    NSString *str = self.feedbackTextField.text;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:self.deviceInfo];
    [dict setValue:str forKey:@"feedback"];
    
    if (![NSJSONSerialization isValidJSONObject:dict]) {
        return;
    }
    
    NSError *err = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&err];
    if ([jsonData length] > 0 && err == nil) {
        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSString *body = [NSString stringWithFormat:@"data=%@", jsonStr];
        [req setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
            NSLog(@"%ld", (long)[(NSHTTPURLResponse *)response statusCode]);
            if (connectionError == nil && [(NSHTTPURLResponse *)response statusCode] == 200) {
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    UIAlertView *aView = [[UIAlertView alloc] initWithTitle:nil message:@"Your feedback has been submitted." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
                    self.feedbackTextField.text = @"";
                    [aView show];
                });
                
            } else if ([data length] == 0) {
                
            } if (connectionError != nil) {
                NSLog(@"Submit faild --> %@", connectionError);
            }
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.submitBarButtonItem.enabled = YES;
                self.feedbackTextField.enabled = YES;
            });
        }];
    }
}

- (NSDictionary *)deviceInfo {
    if (_deviceInfo != nil) {
        return _deviceInfo;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:11];
    
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    [dict setValue:processInfo.hostName forKey:@"hostName"];
    //    [dict setValue:processInfo.globallyUniqueString forKey:@"globallyUniqueString"];
    [dict setValue:processInfo.operatingSystemName forKey:@"operatingSystemName"];
    [dict setValue:processInfo.operatingSystemVersionString forKey:@"operatingSystemVersionString"];
    [dict setValue:[NSString stringWithFormat:@"%lld", processInfo.physicalMemory] forKey:@"physicalMemory"];
    
    UIDevice *device = [UIDevice currentDevice];
    [dict setValue:[NSString stringWithFormat:@"%@", device.identifierForVendor] forKey:@"identifierForVendor"];
    [dict setValue:device.name forKey:@"name"];
    [dict setValue:device.systemName forKey:@"systemName"];
    [dict setValue:device.systemVersion forKey:@"systemVersion"];
    [dict setValue:device.model forKey:@"model"];
    [dict setValue:device.localizedModel forKey:@"localizedModel"];
    [dict setValue:[NSString stringWithFormat:@"%f", device.batteryLevel] forKey:@"batteryLevel"];
    
    return _deviceInfo = dict;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
