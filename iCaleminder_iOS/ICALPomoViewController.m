//
//  ICALDetailViewController.m
//  iCaleminder_iOS
//
//  Created by artwalk on 6/10/14.
//  Copyright (c) 2014 artwalk. All rights reserved.
//

#import "ICALPomoViewController.h"
#import "ICALPomo.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ICALPomoViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UINavigationItem *pomoNavigationItem;

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (weak, nonatomic) IBOutlet UIButton *startStopBtn;
@property (weak, nonatomic) IBOutlet UIPickerView *pomoIntervalPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *pomoLeftTimePicker;

@property (nonatomic, strong) NSTimer *paintingTimer;

@property (nonatomic) ICALPomo *currentPomo;

@property (nonatomic, strong) NSArray *pomoIntervalPickerArray;

@property (nonatomic, strong) NSArray *pomoLeftTimePickerSecondsArray;

@property (nonatomic, strong) UILocalNotification *localNotification;

- (void)configureView;
@end

@implementation ICALPomoViewController

#pragma mark - Managing the detail item


- (void)setPomoItem:(id)newPomoItem
{
    if (_pomoItem != newPomoItem) {
        _pomoItem = newPomoItem;
        
        // Update the view.
        [self configureView];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
    
    // new Pomo
    self.currentPomo = [[ICALPomo alloc] init];
    
    
}

- (void)configureView
{
    // Update the user interface for the detail item.
    if (self.pomoItem) {
        self.pomoNavigationItem.title = [self.pomoItem description];
        
        [self.startStopBtn setTitle: @"▶︎" forState:0];
        
        self.pomoIntervalPicker.delegate = self;
        self.pomoIntervalPickerArray = @[@"25 min", @"20 min", @"15 min"];
        
        [self stopLeftTimePicker];
        
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - localNotification

- (void) fireDelayNotification {
    
    // background
    if (!_localNotification) {
        _localNotification = [[UILocalNotification alloc] init];
        
        _localNotification.alertBody = NSLocalizedString(@"One PomoToDo has Done!", nil);
        _localNotification.soundName = UILocalNotificationDefaultSoundName;
        _localNotification.hasAction = YES;
    }
    
    _localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:_currentPomo.interval*60];
    _localNotification.timeZone = [[NSCalendar currentCalendar] timeZone];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:_localNotification];
}

- (void) cancelDelayNotification {
    if (_localNotification) {
        [[UIApplication sharedApplication] cancelLocalNotification:_localNotification];
    }
}

#pragma mark - alertView

- (IBAction)giveUp:(id)sender {
    if (self.currentPomo.state == EnumStart) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Really Give Up?" delegate:self cancelButtonTitle:[self noButtonTitle] otherButtonTitles:[self yesButtonTitle], nil];
        [alertView show];
    } else {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSString *) yesButtonTitle {
    return @"Yes";
}

- (NSString *) noButtonTitle{
    return @"No";
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:[self yesButtonTitle]]){
        //        NSLog(@"User pressed the Yes button.");
        [self stopCounting];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        
    } else if ([buttonTitle isEqualToString:[self noButtonTitle]]){
        //        NSLog(@"User pressed the No button.");
    }
}

#pragma mark - pickerView

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row
            forComponent:(NSInteger)component{
    if ([pickerView isEqual:self.pomoIntervalPicker]){
        
        return self.pomoIntervalPickerArray[row];
    }
    
    if ([pickerView isEqual:self.pomoLeftTimePicker]) {
        if (component == 0) {
            return [NSString stringWithFormat:@"%02ld", (long)row];
        } else if (component == 1) {
            return [NSString stringWithFormat:@"%02ld", (long)row%60];
        }
    }
    
    return nil;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    if ([pickerView isEqual:self.pomoIntervalPicker]){
        return 1;
    }
    
    if ([pickerView isEqual:self.pomoLeftTimePicker]) {
        return 2;
    }
    return 0;
}

-(NSInteger) pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component{
    if ([pickerView isEqual:self.pomoIntervalPicker]){
        return 3;
    }
    
    if ([pickerView isEqual:self.pomoLeftTimePicker]) {
        return component==0?26:60*26;
    }
    return 0;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if ([pickerView isEqual:self.pomoIntervalPicker]){
        
        self.currentPomo.interval = [self intervalFormatWithString:self.pomoIntervalPickerArray[row]];
        //        NSLog(@"%ld", (long)self.currentPomo.interval);
        [self.pomoLeftTimePicker selectRow:self.currentPomo.interval inComponent:0 animated:YES];
        [self.pomoLeftTimePicker selectRow:self.currentPomo.interval*60 inComponent:1 animated:YES];
    }
}

#pragma mark - update time
- (IBAction)updateStartStopBtn:(id)sender {
    
    switch (self.currentPomo.state) {
        case EnumStop:
            [self stopToStart];
            break;
        case EnumBreak:
            [self breakToStop];
            break;
        case EnumStart:
            [self startToStop];
            break;
            
        default:
            break;
    }
}

- (void)stopToStart {
    self.currentPomo.state = EnumStart;
    
    [self startCounting];
    [self.startStopBtn setTitle: @"◼︎" forState:0];
}

- (void)startToBreak {
    self.currentPomo.state = EnumBreak;
    
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Great!" message:@"One PomoToDo has Done!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
    AudioServicesPlaySystemSound(1007);
    
    [self startCounting];
}

- (void)breakToStop {
    [self toStop];
}

- (void)startToStop {
    [self toStop];
}

- (void)toStop {
    self.currentPomo.state = EnumStop;
    
    [self stopCounting];
    [self.startStopBtn setTitle: @"▶︎" forState:0];
    
}

- (NSInteger)intervalFormatWithString:(NSString *) minites {
    return [[minites substringToIndex:2] intValue];
}

#pragma mark - counting

- (void) startCount:(NSTimer *)paramTimer {
    if (![self count:self.currentPomo.interval*60]) {
        [self startToBreak];
    }
    
}

- (void) breakCount:(NSTimer *)paramTimer {
    if (![self count:5*60]) {
        [self breakToStop];
    }
}


- (BOOL)count:(NSInteger)seconds {
    NSInteger iSeconds, iMinutes, secondsInterval;
    
    secondsInterval = seconds - (NSInteger)[[NSDate date] timeIntervalSinceDate:self.currentPomo.startTime];
    
    if (secondsInterval < 0.0) {
        return NO;
    }
    
    iSeconds = secondsInterval;
    iMinutes = secondsInterval /60;
    
    //    NSLog(@"%02d:%02d", iMinutes, iSeconds);
    
    [self.pomoLeftTimePicker selectRow:iMinutes inComponent:0 animated:YES];
    [self.pomoLeftTimePicker selectRow:iSeconds inComponent:1 animated:YES];
    
    return YES;
}


- (void) startCounting {
    self.currentPomo.startTime = [NSDate date];
    
    [self.pomoIntervalPicker setUserInteractionEnabled:NO];
    [self.pomoIntervalPicker setAlpha:0.2];
    
    [self fireDelayNotification];
    
    if (self.paintingTimer != nil){
        [self.paintingTimer invalidate];
    }
    switch (self.currentPomo.state) {
        case EnumStart:
            self.paintingTimer = [NSTimer
                                  scheduledTimerWithTimeInterval:1
                                  target:self selector:@selector(startCount:) userInfo:nil repeats:YES];
            break;
        case EnumBreak:
            self.paintingTimer = [NSTimer
                                  scheduledTimerWithTimeInterval:1
                                  target:self selector:@selector(breakCount:) userInfo:nil repeats:YES];
            break;
        default:
            break;
    }
    
    
}

- (void) stopCounting {
    [self cancelDelayNotification];
    
    self.currentPomo.endTime = [NSDate date];
    
    [self.pomoIntervalPicker setUserInteractionEnabled:YES];
    [self.pomoIntervalPicker setAlpha:1.0];
    [self stopLeftTimePicker];
    
    if (self.paintingTimer != nil){
        [self.paintingTimer invalidate];
    }
}

- (void) stopLeftTimePicker {
    [self.pomoLeftTimePicker selectRow:(self.currentPomo.interval) inComponent:0 animated:NO];
    [self.pomoLeftTimePicker selectRow:60*(self.currentPomo.interval) inComponent:1 animated:NO];
    
    [self.pomoIntervalPicker setNeedsDisplay];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
