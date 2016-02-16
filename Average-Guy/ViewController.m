//**********************************************************//
//  ViewController.m
//  Average Guy
//
//  Created by Andriy Suden and V!ktor Kornyeyev on 2/23/14.
//  Copyright (c) 2014 DropGeeks. All rights reserved.
//**********************************************************//

#import "ViewController.h"

@interface ViewController () <ADBannerViewDelegate>

@property (nonatomic) ADBannerView *banner;

@end

@implementation ViewController

@synthesize bannerIsVisible;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    
    // Create and configure the scene.
    SKScene * scene = [MainMenuScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
    
}

- (BOOL)shouldAutorotate
{
    return YES;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
