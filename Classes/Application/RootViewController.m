//
//  RootViewController.m
//  MakeMoney
//
#import "RootViewController.h"
#import "IITransenderViewController.h"
#import "IINotControls.h"
#import "iAlert.h"
#import "MakeMoneyAppDelegate.h"
#import "Reachability.h"
#import "UIApplication-Network.h"

@implementation RootViewController

@synthesize transenderViewController;

- (void)loadView {
	UIView *primaryView = [[UIView alloc] initWithFrame:KriyaFrame()];
    primaryView.backgroundColor = [UIColor clearColor];
/*
    // Start in landscape orientation, and stay that way
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeRight) 
    {
        CGAffineTransform transform = primaryView.transform;
		
        // Use the status bar frame to determine the center point of the window's content area.
        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
        CGRect bounds = CGRectMake(0, 0, statusBarFrame.size.height, statusBarFrame.origin.x);
        CGPoint center = CGPointMake(60.0, bounds.size.height / 2.0);
		
        // Set the center point of the view to the center point of the window's content area.
        primaryView.center = center;
		
        // Rotate the view 90 degrees around its new center point.
        transform = CGAffineTransformRotate(transform, (M_PI / 2.0));
        primaryView.transform = transform;
    }   	*/
    self.view = primaryView;
    [primaryView release];      
	notControls = [[[IINotControls alloc] initWithFrame:[Kriya orientedFrame] withOptions:[[MakeMoneyAppDelegate app] stage]] retain];
	//[notControls setBackLight:[UIImage imageNamed:@"backlight.png"] withAlpha:1.0];
	[self.view addSubview:notControls];
	[notControls setNotController:self];
	transenderViewController = [[IITransenderViewController alloc] initWithTransenderProgram:[[[MakeMoneyAppDelegate app] stage] valueForKey:@"program"] andStage:[[MakeMoneyAppDelegate app] stage]];
	[notControls setDelegate:transenderViewController];
	[transenderViewController setNotControls:notControls];
	[transenderViewController setDelegate:self];	
    [self.view insertSubview:transenderViewController.view belowSubview:notControls];
	
}

- (void)viewDidLoad {
    [super viewDidLoad];	
	[notControls setCanOpen:[[[[MakeMoneyAppDelegate app] stage] valueForKey:@"button_opens_not_controls"] boolValue]];
	
	float vibe = [[[NSUserDefaults standardUserDefaults] valueForKey:@"vibe"] floatValue];
	if (vibe>=kIITransenderVibeShort) {
		[[transenderViewController transender] reVibe:vibe];	
	} else {
		[[transenderViewController transender] reVibe:[[[[MakeMoneyAppDelegate app] stage] valueForKey:@"vibe"] floatValue]];
	}
	
	//TODO - support save_current_program - reload program from cache and remember spot if any
	if ([[[[MakeMoneyAppDelegate app] stage] valueForKey:@"save_current_spot"] boolValue]) {
		[[transenderViewController transender] rememberSpot];
	} else {
		[[transenderViewController transender] transend];
	}
	
	BOOL wwwapp = [[[[MakeMoneyAppDelegate app] stage] valueForKey:@"wwwapp"] boolValue];
	if (wwwapp) {
		[[Reachability sharedReachability] setHostName:@"google.com"];
		if ([[Reachability sharedReachability] remoteHostStatus]==NotReachable) {
			[[iAlert instance] alert:@"Network" withMessage:@"Please move device within network reach. Thanks."];	
		}
	}

	BOOL wifiapp = [[[[MakeMoneyAppDelegate app] stage] valueForKey:@"wifiapp"] boolValue];
	if (wifiapp) { 
		if ([UIApplication hasActiveWiFiConnection]) {
			//only play radio if wi-fi, when program says wifi is a must
			[self playBackgroundRadio];
		} else {
			//disable application, then
			[self bringUpTheWifiAppUnabler];
		}
	} else {
		//edge or wifi, always play radio if no restriction in program
		[self playBackgroundRadio];
	}
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
{
	CGRect r = [Kriya orientedFrame];
	[notControls layout:r];
	[transenderViewController layout:r];
}

//since rootviewcontroller sits under or atop all else, this is the only place to controll autorotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	//return NO; //( (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));//(interfaceOrientation == UIInterfaceOrientationPortrait);
	return [[[[MakeMoneyAppDelegate app] stage] valueForKey:@"can_rotate"] boolValue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	[[iAlert instance] alert:@"Received Memory Warning in RootViewController" withMessage:@"Good luck!"];
	DebugLog(@"RootViewController# Too many memories.");
}

- (void)dealloc {
	[notControls release];
    [transenderViewController release];
    [super dealloc];
}

#pragma mark IITransenderViewControllerDelegate
- (void)transending {
	//[notControls lightDown];
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];

}
- (void)meditating {
	//[notControls lightUp];
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

#pragma mark radio
- (void)playBackgroundRadio {
	//play radio
	NSString *noise_url = [[NSUserDefaults standardUserDefaults] valueForKey:@"noise"];
	if ([noise_url hasPrefix:@"null"]) {
		//no noise. thanks.
	} else if ([noise_url hasPrefix:@"http://"]) {
		[notControls playWithStreamUrl:noise_url];
	} else if ([[[MakeMoneyAppDelegate app] stage] valueForKey:@"noise_url"]) {
		[notControls playWithStreamUrl:[[[MakeMoneyAppDelegate app] stage] valueForKey:@"noise_url"]];
	}	
}

#pragma mark disabler
- (void)bringUpTheWifiAppUnabler {
	UIView *nowifi = [[[UIView alloc] initWithFrame:KriyaFrame()] autorelease];
	nowifi.backgroundColor = [UIColor redColor];
	UILabel *l = [[[UILabel alloc] initWithFrame:KriyaFrame()] autorelease];
	l.text = APP_TITLE;
	l.font = [UIFont boldSystemFontOfSize:83.0];
	l.textAlignment = UITextAlignmentCenter;
	l.textColor = [UIColor whiteColor];
	l.backgroundColor = [UIColor clearColor];
	[nowifi addSubview:l];
	[self.view addSubview:nowifi];
	[[iAlert instance] alert:@"App Requires Wi-Fi" withMessage:@"Please move device within Wi-Fi network reach. Thanks."];				
}

#pragma mark IIController saveState
- (void)saveState 
{
	[transenderViewController saveState];
	[[NSUserDefaults standardUserDefaults] setInteger:[[transenderViewController transender] currentSpot] forKey:SPOT];
	[[NSUserDefaults standardUserDefaults] synchronize];
	DebugLog(@"Terminated with spot: %i", [[transenderViewController transender] currentSpot]);
}

#pragma mark experiments
- (void)rotateView270:(UIView*)w
{
	CGAffineTransform transform = w.transform;
	
	// Rotate the view 90 degrees. 
	transform = CGAffineTransformRotate(transform, (3*M_PI / 2.0));
	
    UIScreen *screen = [UIScreen mainScreen];
    // Translate the view to the center of the screen
    transform = CGAffineTransformTranslate(transform, 
										   ((screen.bounds.size.height) - (w.bounds.size.height))/2, 
										   0);
	w.transform = transform;
}

- (void)moviesStart {
/*
  TODO put the movie under the notControls view
 
    NSArray *windows = [[UIApplication sharedApplication] windows];
    // Locate the movie player window
    UIWindow *moviePlayerWindow = [windows objectAtIndex:1];
    // Add our overlay view to the movie player's subviews so it’s 
    // displayed above it.
	[notControls removeFromSuperview];
	[moviePlayerWindow addSubview:notControls];
//	[self rotateView270:notControls];
*/
}

- (void)moviesEnd {
//	[self.view addSubview:notControls];	
}

@end
