//
//  MenuViewController.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/14/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "MenuViewController.h"
#import "CoreDataManager.h"
#import "Provider+SLExtensions.h"
#import "Constants.h"
#import "ECSlidingViewController.h"
#import "WebViewController.h"

@interface MenuViewController ()

@property (strong, nonatomic) CoreDataManager *coreDataManager;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupDataSource];
    
    [self.slidingViewController setAnchorRightRevealAmount:280.0f];
    self.slidingViewController.underLeftWidthLayout = ECFullWidth;
    
}

- (void)setupDataSource
{
    self.coreDataManager = [CoreDataManager sharedManager];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    
    self.fetchedResultsController = [self.coreDataManager fetchEntitiesWithClassName:NSStringFromClass([Provider class])
                                                                     sortDescriptors:@[sortDescriptor]
                                                                  sectionNameKeyPath:nil
                                                                           predicate:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchedResultsController.sections.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section - 1];
        return [sectionInfo numberOfObjects];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sMenuStoreCell forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sMenuStoreCell];
    }
    
    if (indexPath.section == 0 ) {
        cell.textLabel.text = sMenuHomeCellText;
    } else {
        NSIndexPath *providerIndexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:(indexPath.section - 1)];
        Provider *provider = [self.fetchedResultsController objectAtIndexPath:providerIndexPath];
        
        cell.textLabel.text = provider.commercialName;
        cell.imageView.image = [UIImage imageNamed:[Provider logoImageNameFromProviderName:provider.name]];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *newTopViewController;
    
    if (indexPath.section == 0) {
        newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"first"];
    } else {
        NSIndexPath *providerIndexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:(indexPath.section - 1)];
        newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewNavigation"];
        UINavigationController *webViewNavigation = (UINavigationController *)newTopViewController;
        ((WebViewController *)webViewNavigation.topViewController).provider = [self.fetchedResultsController objectAtIndexPath:providerIndexPath];
    }
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = newTopViewController;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        UITableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:sMenuStoreSectionCell];

        if (!headerCell) {
            UITableViewCell *header = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sMenuStoreSectionCell];
        }
        
        headerCell.textLabel.text = @"Stores";
        return headerCell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 40.0;
    }
    
    return 0;
}

@end
