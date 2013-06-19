//
//  MenuViewController.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/14/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "MenuViewController.h"
#import "CoreDataManager.h"
#import "Constants.h"
#import "ECSlidingViewController.h"
#import "WebViewController.h"

@interface MenuViewController ()

@property (strong, nonatomic) CoreDataManager *coreDataManager;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation MenuViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        self.coreDataManager = [CoreDataManager sharedManager];
        
        [self fetchProviders];
        
        if (self.fetchedResultsController.fetchedObjects.count == 0) {
            [self createProviders];
        }
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.slidingViewController setAnchorRightRevealAmount:sMenuAnchorRevealAmount];
    self.slidingViewController.underLeftWidthLayout = ECFullWidth;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    NSIndexPath *indexPathToSelect;
    if (self.selectedProvider) {
        NSIndexPath *fetchResultsIndexPath = [self.fetchedResultsController indexPathForObject:self.selectedProvider];
        indexPathToSelect = [NSIndexPath indexPathForRow:fetchResultsIndexPath.row  inSection:(fetchResultsIndexPath.section + 1)];
    } else {
        indexPathToSelect = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    
    [self.tableView selectRowAtIndexPath:indexPathToSelect animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)createProviders
{
    NSArray *providers = [Provider providersArray];
    
    [providers enumerateObjectsUsingBlock:^(NSDictionary *providerDictionary, NSUInteger idx, BOOL *stop) {
        [self.coreDataManager createEntityWithClassName:NSStringFromClass([Provider class]) attributesDictionary:providerDictionary];
    }];
    
    [self.coreDataManager saveDataInManagedContextUsingBlock:^(BOOL saved, NSError *error) {
        if (saved) {
            [self fetchProviders];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"We're sorry, something went wrong :("
                                                               delegate:self
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil, nil];
            
            [alertView show];
        }
    }];
}

- (void)fetchProviders
{
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    self.fetchedResultsController = [self.coreDataManager fetchEntitiesWithClassName:NSStringFromClass([Provider class])
                                                                     sortDescriptors:sortDescriptors
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
        cell.imageView.image = [UIImage imageNamed:@"list_icon.png"];
    } else {
        NSIndexPath *providerIndexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:(indexPath.section - 1)];
        Provider *provider = [self.fetchedResultsController objectAtIndexPath:providerIndexPath];
        
        cell.textLabel.text = provider.commercialName;
        
        cell.imageView.image = [UIImage imageNamed:[Provider logoImageNameFromProviderName:provider.name]];
    }
    
    UIView *customColorView = [[UIView alloc] init];
    customColorView.backgroundColor = [UIColor colorWithRed:180/255.0 green:138/255.0 blue:171/255.0 alpha:0.5];
    
    cell.selectedBackgroundView =  customColorView;
    cell.textLabel.textColor = [UIColor blackColor];

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
        WebViewController *webViewController = (WebViewController *)webViewNavigation.topViewController;
        webViewController.provider = [self.fetchedResultsController objectAtIndexPath:providerIndexPath];
        webViewController.fromMenu = YES;
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
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20.0)];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:header.frame];
        textLabel.text = sMenuStoreSectionTitle;
        textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
        textLabel.backgroundColor = [UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:1];
        textLabel.textColor = [UIColor whiteColor];
        
        [header addSubview:textLabel];
        
        return header;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 20.0;
    }
    
    return 0;
}

@end
