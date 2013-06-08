//
//  ProviderViewController.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/7/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "ProviderViewController.h"
#import "CoreDataManager.h"

@interface ProviderViewController ()

@property (strong, nonatomic) NSArray *providerNames;
@property (strong, nonatomic) CoreDataManager *coreDataManager;

- (void)setupProviders;

@end

@implementation ProviderViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        self.coreDataManager = [CoreDataManager sharedManager];
        
        // if providers exist?
        [self setupProviders];
        
        // if provider doesn't exist
        }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.showNavigationBar) {
        self.navigationItem.hidesBackButton = YES;
    }
	
}

- (void)setupProviders
{
    self.providerNames = @[@"toysrus"];
    [self.providerNames enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop) {
        [self.coreDataManager createProviderWithName:name];
    }];
    
    BOOL didSave = [self.coreDataManager saveDataInManagedContext];
    if (!didSave) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"We're sorry, something went wrong :("
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
        
        [alertView show];
        
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
