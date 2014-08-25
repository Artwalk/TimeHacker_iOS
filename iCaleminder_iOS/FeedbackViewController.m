//
//  FeedbackViewController.m
//  TimeHacker
//
//  Created by artwalk on 8/25/14.
//  Copyright (c) 2014 artwalk. All rights reserved.
//

#import "FeedbackViewController.h"

#import <MessageUI/MFMailComposeViewController.h>

@interface FeedbackViewController () <UITextFieldDelegate, MFMailComposeViewControllerDelegate>

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitBtnAction:(id)sender {
    // send me an Email
    [self sendEmail];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - Email
- (void)sendEmail
{
    MFMailComposeViewController *sendMailViewController = [[MFMailComposeViewController alloc] init];
    sendMailViewController.mailComposeDelegate = self;
    
    // 设置邮件主题
    [sendMailViewController setSubject:@"Feedback"];
    
    /*
     * 设置收件人，收件人有三种
     */
    // 设置主收件人
    [sendMailViewController setToRecipients:[NSArray arrayWithObject:@"example@163.com"]];
    // 设置CC
//    [sendMailViewController setCcRecipients:[NSArray arrayWithObject:@"example@hotmail.com"]];
    // 设置BCC
//    [sendMailViewController setBccRecipients:[NSArray arrayWithObject:@"example@gmail.com"]];
    
    /*
     * 设置邮件主体，有两种格式
     */
    // 一种是纯文本
//    [sendMailViewController setMessageBody:@"Any problem?\n\n" isHTML:NO];
    // 一种是HTML格式（HTML和纯文本两种格式按需求选择一种即可）
    //[mailVC setMessageBody:@"<HTML><B>Hello World!</B><BR/>Is everything OK?</HTML>" isHTML:YES];
    
    // 添加附件
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"feedback" ofType:@"png"];
//    NSData *data = [NSData dataWithContentsOfFile:path];
//    [sendMailViewController addAttachmentData:data mimeType:@"image/png" fileName:@"feedback"];
    
    // 视图呈现
    [self presentViewController:sendMailViewController animated:YES completion:nil];
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
