//
//  TodayViewController.m
//  Device Space Manager
//
//  Created by Francis on 8/9/19.
//  Copyright © 2019 Xi Apps. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

// Macro for NSUserDefaults key
#define RATE_KEY @"kUDRateUsed"
#define kWClosedHeight   37.0
#define kWExpandedHeight 106.0

@interface TodayViewController () <NCWidgetProviding>
//storyboard elements
@property (weak, nonatomic) IBOutlet UILabel *percentLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *barView;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *usedLabel;
@property (weak, nonatomic) IBOutlet UILabel *freeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;




//other elements
@property (nonatomic, assign) unsigned long long fileSystemSize;
@property (nonatomic, assign) unsigned long long freeSize;
@property (nonatomic, assign) unsigned long long usedSize;
@property (nonatomic, assign) double usedRate;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateInterface];
    [self setPreferredContentSize:CGSizeMake(0.0, kWClosedHeight)];
    [self.detailsLabel setAlpha:0.0];
}

// @implementation for update details
- (void)updateInterface
{
    double rate = self.usedRate; // retrieve the cached value
    self.percentLabel.text =
    [NSString stringWithFormat:@"%.1f%%", (rate * 100)];
    self.barView.progress = rate;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self updateDetailsLabel];
    [self setPreferredContentSize:
     CGSizeMake(0.0, kWExpandedHeight)];
}

// @implementation for percentLabel and barView
- (double)usedRate
{
    return [[[NSUserDefaults standardUserDefaults]
             valueForKey:RATE_KEY] doubleValue];
}

-(void)updateDetailsLabel
{
    NSByteCountFormatter *formatter =
    [[NSByteCountFormatter alloc] init];
    [formatter setCountStyle:NSByteCountFormatterCountStyleFile];
    
    self.usedLabel.text =
    [NSString stringWithFormat:
     @"Used:\t%@\nFree:\t%@\nTotal:\t%@",
     [formatter stringFromByteCount:self.usedSize],
     [formatter stringFromByteCount:self.freeSize],
     [formatter stringFromByteCount:self.fileSystemSize]];
}

- (void)setUsedRate:(double)usedRate
{
    NSUserDefaults *defaults =
    [NSUserDefaults standardUserDefaults];
    [defaults setValue:[NSNumber numberWithDouble:usedRate]
                forKey:RATE_KEY];
    [defaults synchronize];
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)margins
{
    margins.bottom = 10.0;
    return margins;
}

- (void)updateSizes
{
    // Retrieve the attributes from NSFileManager
    NSDictionary *dict = [[NSFileManager defaultManager]
                          attributesOfFileSystemForPath:NSHomeDirectory()
                          error:nil];
    
    // Set the values
    self.fileSystemSize = [[dict valueForKey:NSFileSystemSize]
                           unsignedLongLongValue];
    self.freeSize       = [[dict valueForKey:NSFileSystemFreeSize]
                           unsignedLongLongValue];
    self.usedSize       = self.fileSystemSize - self.freeSize;
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    [self updateSizes];
    
    double newRate = (double)self.usedSize / (double)self.fileSystemSize;
    
    if (newRate - self.usedRate < 0.0001) {
        completionHandler(NCUpdateResultNoData);
    } else {
        [self setUsedRate:newRate];
        [self updateInterface];
        completionHandler(NCUpdateResultNewData);
    }
}

@end
