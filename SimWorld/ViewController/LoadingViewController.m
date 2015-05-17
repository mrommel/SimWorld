//
//  LoadinfViewController.m
//  SimWorld
//
//  Created by Michael Rommel on 14.12.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import "LoadingViewController.h"

#import "HexagonMapManager.h"
#import "GameViewController.h"

#define kCellIdentifier @"cellIdentifierLoadingViewController"

@interface LoadingViewController ()

@property (nonatomic,retain) NSArray *content;

@end

@implementation LoadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"maps" ofType:@"plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    self.content = [[NSArray alloc] initWithArray:[dictionary valueForKey:@"Maps"]];
}

#pragma mark -
#pragma mark UITableViewDataSource

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
    HexagonMapManagerItem *hexagonMapManagerItem = [[HexagonMapManager sharedInstance] itemForMapName:[item objectForKey:@"Map"]];
    cell.textLabel.text = hexagonMapManagerItem.title;
    cell.detailTextLabel.text = hexagonMapManagerItem.text;
    cell.imageView.image = hexagonMapManagerItem.image;
    
    /* Now that the cell is configured we return it to the table view so that it can display it */
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Loaded %ld", (long)indexPath.row);
    NSDictionary *item = (NSDictionary *)[self.content objectAtIndex:indexPath.row];
    NSString *mapName = [item objectForKey:@"Map"];
    
    HexagonMap *map = [[HexagonMap alloc] initWithCiv5Map:mapName];
    
    /*OpenGLViewController *viewController = [[OpenGLViewController alloc] init];
    viewController.title = mapName;
    viewController.map = map;
    [self.navigationController pushViewController:viewController animated:YES];*/
    GameViewController *viewController = [[GameViewController alloc] init];
    viewController.map = map;
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
