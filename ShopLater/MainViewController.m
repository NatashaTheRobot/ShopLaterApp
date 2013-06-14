//
//  MainViewController.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/14/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "MainViewController.h"
#import "LeftPanelViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

@interface MainViewController () <LeftPanelViewControllerDelegate, UIGestureRecognizerDelegate>

@property (assign, nonatomic) BOOL showingLeftPanel;
@property (assign, nonatomic) BOOL showPanel;
@property (strong, nonatomic) LeftPanelViewController *leftPanelViewController;
@property (assign, nonatomic) CGPoint preVelocity;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;

- (IBAction)showLeftPanelWithButton:(id)sender;

- (void)setupGestures;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupGestures];
}

- (void)setupGestures
{
	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanel:)];
	[panRecognizer setMinimumNumberOfTouches:1];
	[panRecognizer setMaximumNumberOfTouches:1];
	[panRecognizer setDelegate:self];
    
	[self.view addGestureRecognizer:panRecognizer];
}

-(void)showCenterViewWithShadow:(BOOL)value withOffset:(double)offset {
	if (value) {
		[self.view.layer setCornerRadius:sMenuCornerRadius];
		[self.view.layer setShadowColor:[UIColor blackColor].CGColor];
		[self.view.layer setShadowOpacity:0.8];
		[self.view.layer setShadowOffset:CGSizeMake(offset, offset)];
        
	} else {
		[self.view.layer setCornerRadius:0.0f];
		[self.view.layer setShadowOffset:CGSizeMake(offset, offset)];
	}
}

-(UIView *)getLeftView {
	// init view if it doesn't already exist
	if (self.leftPanelViewController == nil)
	{
		// this is where you define the view for the left panel
        self.leftPanelViewController = [self.storyboard instantiateViewControllerWithIdentifier:
                                        NSStringFromClass([LeftPanelViewController class])];
		self.leftPanelViewController.view.tag = sMenuLeftPanelTag;
		self.leftPanelViewController.delegate = self;
        
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

-(void)movePanel:(id)sender {
	[[[(UITapGestureRecognizer *)sender view] layer] removeAllAnimations];
    
	CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
	CGPoint velocity = [(UIPanGestureRecognizer*)sender velocityInView:[sender view]];
    
	if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        UIView *childView = nil;
        
        if(velocity.x > 0) {
            [self getLeftView];
        }
        // make sure the view we're working with is front and center
        [self.view sendSubviewToBack:childView];
        [[sender view] bringSubviewToFront:[(UIPanGestureRecognizer *)sender view]];
	}
    
	if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        
        if (!self.showPanel) {
            [self movePanelToOriginalPosition];
        } else {
//            if (self.showingLeftPanel) {
//                [self movePanelRight];
//            }
        }
	}
    
	if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged) {
        
        // are we more than halfway, if so, show the panel when done dragging by setting this value to YES (1)
        self.showPanel = abs([sender view].center.x - self.view.frame.size.width/2) > self.view.frame.size.width/2;
        
        // allow dragging only in x coordinates by only updating the x coordinate with translation position
        [sender view].center = CGPointMake([sender view].center.x + translatedPoint.x, [sender view].center.y);
        [(UIPanGestureRecognizer*)sender setTranslation:CGPointMake(0,0) inView:self.view];
        
        self.preVelocity = velocity;
	}
}

- (void)movePanelRight {
	UIView *childView = [self getLeftView];
	[self.view sendSubviewToBack:childView];
    
	[UIView animateWithDuration:sMenuSlideTiming delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.view.frame = CGRectMake(self.view.frame.size.width - sMenuPanelWidth, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
                     completion:^(BOOL finished) {
                         if (finished) {
                             self.menuButton.tag = 0;
                         }
                     }];
}

- (void)resetMainView
{
	// remove left and right views, and reset variables, if needed
	if (self.leftPanelViewController != nil) {
		[self.leftPanelViewController.view removeFromSuperview];
		self.leftPanelViewController = nil;
		self.menuButton.tag = 1;
		self.showingLeftPanel = NO;
	}
	// remove view shadows
	[self showCenterViewWithShadow:NO withOffset:0];
}

- (void)movePanelToOriginalPosition
{
	[UIView animateWithDuration:sMenuSlideTiming delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self resetMainView];
                         }
                     }];
}

- (IBAction)showLeftPanelWithButton:(UIButton *)button
{
	switch (button.tag) {
		case 0: {
			[self movePanelToOriginalPosition];
			break;
		}
		case 1: {
			[self movePanelRight];
			break;
		}
		default:
			break;
	}
}
@end
