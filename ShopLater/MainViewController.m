//
//  MainViewController.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/14/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "MainViewController.h"
#import "CenterViewController.h"
#import "LeftPanelViewController.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>

typedef enum ViewControllerType : NSUInteger {
    kCenterTag,
    kLeftTag
} ViewControllerType;

@interface MainViewController () <CenterViewControllerDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) CenterViewController *centerViewController;
@property (strong, nonatomic) LeftPanelViewController *leftPanelViewController;
@property (assign, nonatomic) BOOL showingLeftPanel;
@property (assign, nonatomic) BOOL showPanel;
@property (assign, nonatomic) CGPoint preVelocity;

- (void)setupView;
- (void)showCenterViewWithShadow:(BOOL)value withOffset:(double)offset;
- (void)resetMainView;
- (UIView *)getLeftView;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self setupView];
}

#pragma mark Setup View

- (void)setupView
{
    self.centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([CenterViewController class])];
    self.centerViewController.view.tag = sMenuCenterTag;
    self.centerViewController.delegate = self;
    
    [self.view addSubview:self.centerViewController.view];
    [self addChildViewController:self.centerViewController];
    
    [self.centerViewController didMoveToParentViewController:self];
}

- (void)showCenterViewWithShadow:(BOOL)value withOffset:(double)offset
{
	if (value) {
		[self.centerViewController.view.layer setCornerRadius:sMenuCornerRadius];
		[self.centerViewController.view.layer setShadowColor:[UIColor blackColor].CGColor];
		[self.centerViewController.view.layer setShadowOpacity:0.8];
		[self.centerViewController.view.layer setShadowOffset:CGSizeMake(offset, offset)];
        
	} else {
		[_centerViewController.view.layer setCornerRadius:0.0f];
		[_centerViewController.view.layer setShadowOffset:CGSizeMake(offset, offset)];
	}
}

- (void)resetMainView
{
	// remove left and right views, and reset variables, if needed
	if (self.leftPanelViewController != nil) {
		[self.leftPanelViewController.view removeFromSuperview];
		self.leftPanelViewController = nil;
		self.centerViewController.menuButton.tag = 1;
		self.showingLeftPanel = NO;
	}
	// remove view shadows
	[self showCenterViewWithShadow:NO withOffset:0];
}

-(UIView *)getLeftView
{
	// init view if it doesn't already exist
	if (self.leftPanelViewController == nil)
	{
		// this is where you define the view for the left panel
		self.leftPanelViewController = [self.storyboard instantiateViewControllerWithIdentifier:
                                        NSStringFromClass([LeftPanelViewController class])];
		self.leftPanelViewController.view.tag = sMenuLeftPanelTag;
		self.leftPanelViewController.delegate = self.centerViewController;
        
		[self.view addSubview:self.leftPanelViewController.view];
        
		[self addChildViewController:self.leftPanelViewController];
		[self.leftPanelViewController didMoveToParentViewController:self];
        
		self.leftPanelViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	}
    
	self.showingLeftPanel = YES;
    
	// setup view shadows
	[self showCenterViewWithShadow:YES withOffset:-2];
    
	UIView *view = self.leftPanelViewController.view;
	return view;
}

#pragma mark Swipe Gesture Setup/Actions

-(void)movePanel:(id)sender {
	[[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
    
	CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
	CGPoint velocity = [(UIPanGestureRecognizer*)sender velocityInView:[sender view]];
    
	if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        UIView *childView = nil;
        
        if(velocity.x > 0) {
            childView = [self getLeftView];
        }
        // make sure the view we're working with is front and center
        [self.view sendSubviewToBack:childView];
        [[sender view] bringSubviewToFront:[(UIPanGestureRecognizer*)sender view]];
	}
    
	if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        
        if(velocity.x > 0) {
            // NSLog(@"gesture went right");
        } else {
            // NSLog(@"gesture went left");
        }
        
        if (!self.showPanel) {
            [self movePanelToOriginalPosition];
        } else {
            [self movePanelLeft];
        }
	}
    
	if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged) {
        if(velocity.x > 0) {
            // NSLog(@"gesture went right");
        } else {
            // NSLog(@"gesture went left");
        }
        
        // are we more than halfway, if so, show the panel when done dragging by setting this value to YES (1)
        self.showPanel = abs([sender view].center.x - self.centerViewController.view.frame.size.width/2) > self.centerViewController.view.frame.size.width/2;
        
        // allow dragging only in x coordinates by only updating the x coordinate with translation position
        [sender view].center = CGPointMake([sender view].center.x + translatedPoint.x, [sender view].center.y);
        [(UIPanGestureRecognizer*)sender setTranslation:CGPointMake(0,0) inView:self.view];
        
        // if you needed to check for a change in direction, you could use this code to do so
        if(velocity.x*self.preVelocity.x + velocity.y*self.preVelocity.y > 0) {
            // NSLog(@"same direction");
        } else {
            // NSLog(@"opposite direction");
        }
        
        self.preVelocity = velocity;
	}
}

#pragma mark Delegate Actions

-(void)movePanelRight
{
	UIView *childView = [self getLeftView];
	[self.view sendSubviewToBack:childView];
    
	[UIView animateWithDuration:sMenuSlideTiming delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.centerViewController.view.frame = CGRectMake(self.view.frame.size.width - sMenuPanelWidth, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
                     completion:^(BOOL finished) {
                         if (finished) {
                             self.centerViewController.menuButton.tag = 0;
                         }
                     }];
}

-(void)movePanelToOriginalPosition
{
	[UIView animateWithDuration:sMenuSlideTiming delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.centerViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self resetMainView];
                         }
                     }];
}


@end
