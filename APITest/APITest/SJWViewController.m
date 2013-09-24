//
//  SJWViewController.m
//  APITest
//
//  Created by Sam Warfield on 9/2/13.
//  Copyright (c) 2013 Sam Warfield. All rights reserved.
//

#import "SJWViewController.h"
#import "SJWTableViewController.h"

@interface SJWViewController ()
@property (strong, nonatomic) IBOutlet UILabel *firstLabel;
@property (strong, nonatomic) IBOutlet UILabel *secondLabel;
@property (strong, nonatomic) IBOutlet UILabel *thirdLabel;
@property (strong, nonatomic) IBOutlet UILabel *fourthLabel;
@property (strong, nonatomic) IBOutlet UITextField *firstTextField;
@property (strong, nonatomic) IBOutlet UITextField *secondTextField;
@property (strong, nonatomic) IBOutlet UITextField *thirdTextField;
@property (strong, nonatomic) IBOutlet UITextField *fourthTextField;

@end

@implementation SJWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.firstLabel.text = @"id:";
    self.secondLabel.text = @"name:";
    self.thirdLabel.text = @"favcolor:";
    self.fourthLabel.text = @"time:";
    
    if ([self.title isEqualToString:@"Change Record"]) {
        self.firstTextField.text = self.selectedData[@"id"];
        self.secondTextField.text = self.selectedData[@"name"];
        self.thirdTextField.text = self.selectedData[@"favcolor"];
        self.fourthTextField.text = self.selectedData[@"time"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)button:(UIButton *)sender {
    NSURL *apiURL;
    if ([self.title isEqualToString:@"New Record"]) {
        apiURL = [NSURL URLWithString:@"http://www.samwarfield.com/api/color"];
    }
    
    if ([self.title isEqualToString:@"Change Record"]) {
        apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.samwarfield.com/api/colors/id/%@", self.firstTextField.text]];
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:apiURL];
    
    NSDictionary *newRecord;
    if ([self.title isEqualToString:@"New Record"]) {
        [request setHTTPMethod:@"POST"];
        newRecord = @{ @"name" : self.secondTextField.text,
                      @"favcolor" : self.thirdTextField.text };
    } else if ([self.title isEqualToString:@"Change Record"]) {
        [request setHTTPMethod:@"PUT"];
        newRecord = @{ @"id" : self.firstTextField.text,
                      @"name" : self.secondTextField.text,
                      @"favcolor" : self.thirdTextField.text };
    }
    
    
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:newRecord
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    
    [request setHTTPBody:JSONData];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               NSLog(@"%@",[[NSString alloc] initWithData:data
                                                                 encoding:NSUTF8StringEncoding]);
                           }];

    [self.navigationController popViewControllerAnimated:YES];
}

@end
