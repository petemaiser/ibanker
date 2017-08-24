//
//  LogViewController.m
//  GameCalc
//
//  Created by Pete Maiser on 3/27/16.
//  Copyright © 2016 Pete Maiser. All rights reserved.
//

#import "LogViewController.h"
#import "LogItem.h"
#import "Log.h"

@interface LogViewController ()
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@end

@implementation LogViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadLogItems];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self scrollViewToBottom];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadLogItems
{
    self.logTextView.clearsOnInsertion = YES;
    Log *sharedLog = [Log sharedLog];
    
    if (sharedLog) {
        NSArray *logItems = [sharedLog logItems];
        
        
        for (LogItem *logItem in logItems) {
            [self.logTextView insertText:logItem.text];
            [self.logTextView insertText:@"\n"];
        }
    }
}

- (void)scrollViewToBottom
{
    NSRange range = NSMakeRange(self.logTextView.text.length, 0);
    [self.logTextView scrollRangeToVisible:range];
}

@end
