//**********************************************************//
//  MainMenuScene.h
//  Average-Guy
//
//  Created by Andriy Suden and V!ktor Kornyeyev on 2/23/14.
//  Copyright (c) 2014 DropGeeks. All rights reserved.
//**********************************************************//

#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"
#import "TutorialScene.h"

@interface MainMenuScene : SKScene
{
    BOOL firstTimePlaying;
    
    SKSpriteNode *playButton;
    SKSpriteNode *optionsButton;
    SKSpriteNode *turotialButton;
    NSMutableDictionary *dictionary;
    NSString *listPath;
}

@property SKSpriteNode *playButton;
@property NSUInteger   myHighScore;
@property SKSpriteNode *optionsButton;
@property SKSpriteNode *tutorialButton;

@end
