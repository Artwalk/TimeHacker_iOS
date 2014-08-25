//
//  THDetailViewController.m
//  TimeHacker
//
//  Created by artwalk on 6/10/14.
//  Copyright (c) 2014 artwalk. All rights reserved.
//

#import "THPomoViewController.h"
#import "THPomo.h"
#import "PomoList.h"
#import <AudioToolbox/AudioToolbox.h>


#define MINUTE (60)
#define TESTNUM (1)

@interface THPomoViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (weak, nonatomic) IBOutlet UIButton *startStopBtn;
@property (weak, nonatomic) IBOutlet UIPickerView *pomoLeftTimePicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *giveUpBtn;
@property (weak, nonatomic) IBOutlet UISlider *pomoTimerSlider;

@property (nonatomic, strong) NSTimer *paintingTimer;
@property (nonatomic, strong) NSArray *pomoLeftTimePickerSecondsArray;

@property (nonatomic, strong) UILocalNotification *localNotification;


- (void)configureView;
@end

@implementation THPomoViewController

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
    
}

- (void)configureView
{
    // Update the user interface for the detail item.
    if (self.pomoItem) {
        self.navigationItem.title = [THPomo getInstance].title = [[self.pomoItem valueForKey:@"title"] description];
        self.pomoTimerSlider.value = [THPomo getInstance].interval;
        [self.startStopBtn setTitle: @"▶︎" forState:0];
        
        [self stopPomoLeftTimePickerView];
    }
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
    
    if (!_localNotification) {
        _localNotification = [[UILocalNotification alloc] init];
        
        _localNotification.alertBody = NSLocalizedString(@"One PomoToDo has Done!", nil);
        _localNotification.soundName = UILocalNotificationDefaultSoundName;
        _localNotification.hasAction = YES;
    }
    
    _localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:[THPomo getInstance].interval*MINUTE/TESTNUM];
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
    if ([THPomo getInstance].state == EnumStart) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Really Give Up?" delegate:self cancelButtonTitle:[self noButtonTitle] otherButtonTitles:[self yesButtonTitle], nil];
        [alertView show];
    }
}

- (NSString *) yesButtonTitle {
    return @"Yes";
}

- (NSString *) noButtonTitle {
    return @"No";
}

- (NSString *) breakButtonTitle {
    return @"Have a break!";
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:[self yesButtonTitle]]){
        [self startToStop];
        
    } else if ([buttonTitle isEqualToString:[self noButtonTitle]]){
        
    } else if ([buttonTitle isEqualToString:[self breakButtonTitle]]) {
        [THPomo getInstance].breakDate = [NSDate date];
        [self startCounting];
    }
}


#pragma mark - slider
- (IBAction)pomoTimerSliderValueChanged:(UISlider *)sender {
    int min = (int)sender.value;
    [[THPomo getInstance] setInterval:min];
    [self updatePomoLeftTimePickerView:min rowOne:min*60];
}


#pragma mark - pickerView

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row
            forComponent:(NSInteger)component{
    
    if ([pickerView isEqual:self.pomoLeftTimePicker]) {
        if (component == 0) {
            return [NSString stringWithFormat:@"%02ld", (long)row];
        } else if (component == 1) {
            return [NSString stringWithFormat:@"%02ld", (long)row%MINUTE];
        }
    }
    
    return nil;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    if ([pickerView isEqual:self.pomoLeftTimePicker]) {
        return 2;
    }
    return 0;
}

-(NSInteger) pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    if ([pickerView isEqual:self.pomoLeftTimePicker]) {
        return component==0?61:MINUTE*60+1;
    }
    return 0;
}

- (void)updatePomoLeftTimePickerView:(NSInteger)numZero rowOne:(NSInteger)numOne {
    [_pomoLeftTimePicker selectRow:numZero inComponent:0 animated:YES];
    [_pomoLeftTimePicker selectRow:numOne inComponent:1 animated:YES];
}

- (void)stopPomoLeftTimePickerView {
    [self updatePomoLeftTimePickerView:[THPomo getInstance].interval rowOne:MINUTE*[THPomo getInstance].interval];
}

#pragma mark - update time
- (IBAction)updateStartStopBtn:(id)sender {
    
    switch ([THPomo getInstance].state) {
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
    [THPomo getInstance].state = EnumStart;
    [THPomo getInstance].startDate = [NSDate date];
    
    [self fireDelayNotification];
    
    [self.startStopBtn setTitle: @"◼︎" forState:0];
    self.giveUpBtn.enabled = YES;
    
    [self startCounting];
}

- (void)startToBreak {
    [self stopCounting];
    
    [THPomo getInstance].state = EnumBreak;
    [THPomo getInstance].endDate = [NSDate date];
    
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Great!" message:@"One PomoToDo has Done!" delegate:self cancelButtonTitle:[self breakButtonTitle] otherButtonTitles:nil, nil];
    [alertView show];
    AudioServicesPlaySystemSound(1007);
    
    self.navigationItem.title = @"Break Time!";
    [self updatePomoLeftTimePickerView:5 rowOne:MINUTE*5];
    
    if (![THPomo getInstance].insertToiCal) {
        NSLog(@"insertToiCal fall!");
    }
}

- (void)breakToStop {
    [self toStop];
    
    self.giveUpBtn.enabled = NO;
    
    self.navigationItem.title = [THPomo getInstance].title;
}

- (void)startToStop {
    [self toStop];
}

- (void)toStop {
    [THPomo getInstance].state = EnumStop;
    
    [self cancelDelayNotification];
    
    [self stopPomoLeftTimePickerView];
    [self.startStopBtn setTitle: @"▶︎" forState:0];
    self.giveUpBtn.enabled = NO;
    
    [self stopCounting];
}

- (NSInteger)intervalFormatWithString:(NSString *) minites {
    return [[minites substringToIndex:2] intValue];
}

#pragma mark - counting

- (void) startCount:(NSTimer *)paramTimer {
    if (![self count:[THPomo getInstance].interval*MINUTE since:[THPomo getInstance].startDate]) {
        [self startToBreak];
    }
}

- (void) breakCount:(NSTimer *)paramTimer {
    if (![self count:5*MINUTE since:[THPomo getInstance].breakDate]) {
        [self breakToStop];
    }
}


- (BOOL)count:(NSInteger)seconds since:(NSDate*)time {
    NSInteger secondsInterval;
    
    secondsInterval = seconds - TESTNUM*(NSInteger)[[NSDate date] timeIntervalSinceDate:time];
    
    if (secondsInterval < 0.0) {
        return NO;
    }
    
    [self updatePomoLeftTimePickerView:secondsInterval/MINUTE rowOne:secondsInterval];
    
    return YES;
}


- (void) startCounting {
    
    [self.pomoTimerSlider setUserInteractionEnabled:NO];
    [self.pomoTimerSlider setAlpha:0.2];
    
    if (self.paintingTimer != nil){
        [self.paintingTimer invalidate];
    }
    switch ([THPomo getInstance].state) {
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
    
    [self.pomoTimerSlider setUserInteractionEnabled:YES];
    [self.pomoTimerSlider setAlpha:1.0];
    
    if (self.paintingTimer != nil){
        [self.paintingTimer invalidate];
    }
}

@end
