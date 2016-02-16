//**********************************************************//
//  GameScene.h
//  Average-Guy
//
//  Created by Andriy Suden and V!ktor Kornyeyev on 2/23/14.
//  Copyright (c) 2014 DropGeeks. All rights reserved.
//**********************************************************//

#import <SpriteKit/SpriteKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "MainMenuScene.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#define SELF_WIDTH  self.frame.size.width
#define SELF_HEIGHT self.frame.size.height
#define HALF_WIDTH  self.frame.size.width/2
#define HALF_HEIGHT self.frame.size.height/2
#define RED_COLOR_INT   0
#define GREEN_COLOR_INT 1
#define BLUE_COLOR_INT  2

#define FONT_00_STARMAP_TRUETYPE @"00 Starmap Truetype"

#define IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad


@interface GameScene : SKScene <SKPhysicsContactDelegate>
{
    
    SKNode *screenBounds;
    NSString *listPath;
    NSMutableDictionary *dictionary;
    
}

-(void)createInitialContentsOnScreen;

@property (nonatomic) BOOL gameEnded;
@property SKSpriteNode     *ground;
@property SKSpriteNode     *node1;
@property SKSpriteNode     *node2;
@property SKSpriteNode     *averageGuy;
@property NSUInteger       *highScore;
@property SKLabelNode      *scoreLabel;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval1;


@end

