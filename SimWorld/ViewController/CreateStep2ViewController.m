//
//  CreateStep2ViewController.m
//  SimWorld
//
//  Created by Michael Rommel on 15.12.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import "CreateStep2ViewController.h"

#define kCellIdentifier @"cellIdentifierCreateStep2ViewController"

@interface CreateStep2ViewController ()

@property (nonatomic,retain) NSArray *content;
@property (nonatomic,retain) NSString *hint;

@end

@implementation CreateStep2ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"create_steps2" ofType:@"plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    self.content = [[NSArray alloc] initWithArray:[dictionary valueForKey:@"Steps"]];
    
    self.title = [dictionary valueForKey:@"Title"];
    self.hint = [dictionary valueForKey:@"Hint"];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.title;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return self.hint;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.content count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *   This is an important bit, it asks the table view if it has any available cells
     *   already created which it is not using (if they are offscreen), so that it can
     *   reuse them (saving the time of alloc/init/load from xib a new cell ).
     *   The identifier is there to differentiate between different types of cells
     *   (you can display different types of cells in the same table view)
     */
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    /**
     *   If the cell is nil it means no cell was available for reuse and that we should
     *   create a new one.
     */
    if (cell == nil) {
        /**
         *   Actually create a new cell (with an identifier so that it can be dequeued).
         */
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    /**
     *   Now that we have a cell we can configure it to display the data corresponding to
     *   this row/section
     */
    NSDictionary *item = (NSDictionary *)[self.content objectAtIndex:indexPath.row];
    cell.textLabel.text = [item objectForKey:@"Name"];
    cell.detailTextLabel.text = [item objectForKey:@"Description"];
    /*NSString *path = [[NSBundle mainBundle] pathForResource:[item objectForKey:@"imageKey"] ofType:@"png"];
    UIImage *theImage = [UIImage imageWithContentsOfFile:path];
    cell.imageView.image = theImage;*/
    
    /* Now that the cell is configured we return it to the table view so that it can display it */
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Loaded %ld", (long)indexPath.row);
    
    /*
     OpenGLViewController *viewController = [[OpenGLViewController alloc] init];
     viewController.title = mapName;
     viewController.map = map;
     [self.navigationController pushViewController:viewController animated:YES];*/
}

@end
