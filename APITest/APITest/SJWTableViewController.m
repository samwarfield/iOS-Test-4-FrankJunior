//
//  SJWTableViewController.m
//  APITest
//
//  Created by Sam Warfield on 9/2/13.
//  Copyright (c) 2013 Sam Warfield. All rights reserved.
//

#import "SJWTableViewController.h"
#import "SJWViewController.h"

@interface SJWTableViewController ()
@property (nonatomic, strong) NSMutableArray *databaseArray;
@property (nonatomic, strong) NSMutableData *databaseData;
@end

@implementation SJWTableViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self loadData];
    //[self.tableView reloadData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)loadData {
    NSURL *apiURL = [NSURL URLWithString:@"http://www.samwarfield.com/api/colors"];
    NSURLRequest *request = [NSURLRequest requestWithURL:apiURL];
    [NSURLConnection connectionWithRequest:request delegate:self];
    NSLog(@"Download started");
}

#pragma mark - NSURLConnectionDataDelegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.databaseData = [NSMutableData new];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.databaseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    NSLog(@"Download finished");
    NSError *error;
    self.databaseArray = [NSJSONSerialization JSONObjectWithData:self.databaseData options:NSJSONReadingMutableContainers error:&error];
    [self.tableView reloadData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.databaseArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *dictionary = self.databaseArray[indexPath.row];
    cell.textLabel.text = dictionary[@"name"];
    
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteRecord:self.databaseArray[indexPath.row]];
        [self loadData];
        [self.databaseArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
    }
}

- (IBAction)refreshButton:(UIBarButtonItem *)sender {
    [self loadData];
    [self.tableView reloadData];
}

-(void)deleteRecord:(NSDictionary *)dict {
    NSURL *apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.samwarfield.com/api/colors/id/%@", dict[@"id"]]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:apiURL];
    [request setHTTPMethod:@"DELETE"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                                    NSLog(@"%@",[[NSString alloc] initWithData:data
                                                                 encoding:NSUTF8StringEncoding]);
                           }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    
    if ([segue.identifier isEqualToString:@"new"]) {
        [segue.destinationViewController setTitle:@"New Record"];
    }
    if ([segue.identifier isEqualToString:@"change"]) {
        [segue.destinationViewController setTitle:@"Change Record"];
        SJWViewController *vc = segue.destinationViewController;
        vc.selectedData = self.databaseArray[indexPath.row];
    }
}

@end
