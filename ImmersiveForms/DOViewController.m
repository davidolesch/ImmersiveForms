//
//  DOViewController.m
//  ImmersiveForms
//
//  Created by David Olesch on 3/24/14.
//  Copyright (c) 2014 David Olesch. All rights reserved.
//

#import "DOViewController.h"
#import "DOImmersiveFormViewController.h"

@interface DOViewController ()

@end

@implementation DOViewController

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

#pragma mark IBAction

- (IBAction)touchedAddButton:(id)sender {
    NSArray *questions = @[@{@"text":@"Quest name"},
                           @{@"text":@"Start message"},
                           @{@"text":@"Number of hints"},
                           @{@"text":@"Prize message"}];
    
    DOImmersiveFormViewController *formViewController = [[DOImmersiveFormViewController alloc] initWithTitle:@"Create a Quest" Questions:questions andCompletionHandler:^(NSArray *answers) {
        NSLog(@"answers are %@",answers);
    }];
    
    [self presentViewController:formViewController animated:YES completion:nil];
}

#pragma mark TableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = [NSString stringWithFormat:@"Quest %li",(long)indexPath.row];
    return cell;
}

@end
