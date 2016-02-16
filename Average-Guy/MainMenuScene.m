//**********************************************************//
//  MainMenuScene.m
//  Average-Guy
//
//  Created by Andriy Suden and V!ktor Kornyeyev on 2/23/14.
//  Copyright (c) 2014 DropGeeks. All rights reserved.
//**********************************************************//

#import "MainMenuScene.h"

@interface MainMenuScene ()
{
    SKLabelNode  *titleLabel;
    SKLabelNode  *playButtonText;
    SKLabelNode  *optionsButtonText;
    SKLabelNode  *tutorialButtonText;
    SKLabelNode  *scoreNode;
    SKLabelNode  *averagePointsLabel;
    SKLabelNode  *soundOptionsNode;
    SKLabelNode  *exitNode;
    
    SKShapeNode  *optionsMenu;
    
    UISwitch     *musicSwitch;
    
    BOOL          playButtonPressed;
    BOOL          aboutButtonPressed;
    BOOL          tutorialButtonPressed;
}

@property CGPoint locationPressed;

@end

@implementation MainMenuScene

@synthesize optionsButton;
@synthesize myHighScore;
@synthesize playButton;
@synthesize locationPressed;
@synthesize tutorialButton;

-(void)setUpPlist{
    
    listPath = [[self docsDir] stringByAppendingPathComponent:@"POL.plist"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:listPath]) {
        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"POL" ofType:@"plist"] toPath:listPath error:nil];
        
    }
    
    dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:listPath];
}

-(NSString *)docsDir{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        
        [self setUpPlist];
        
        unsigned long highScore     = [[dictionary valueForKey:@"High Score"] unsignedLongValue];
        unsigned long averagePoints = [[dictionary valueForKey:@"Average Points"] unsignedLongValue];
        
        self.backgroundColor = [SKColor colorWithRed:0.733 green:1 blue:1 alpha:1.0];
        
        titleLabel = [SKLabelNode node];
        titleLabel.position = CGPointMake(HALF_WIDTH, SELF_HEIGHT+titleLabel.frame.size.height/2);
        titleLabel.fontName = @"00 Starmap Truetype";
        titleLabel.text = @"Average Guy";
        titleLabel.fontSize = 50;
        titleLabel.fontColor = [SKColor blueColor];
        
        SKTextureAtlas *obstacleAtlas = [SKTextureAtlas atlasNamed:@"iPhoneObstacles"];
        SKTexture *blueStraight = [obstacleAtlas textureNamed:@"turquoiseStraight~iPhone"];
        SKSpriteNode *underlineNode = [SKSpriteNode spriteNodeWithTexture:blueStraight];
        underlineNode.position = CGPointMake(HALF_WIDTH, 3*SELF_HEIGHT/4);
        underlineNode.zPosition = titleLabel.zPosition;
        underlineNode.size = CGSizeMake(blueStraight.size.width*.1, blueStraight.size.height);
        
        SKSpriteNode *bgNode = [SKSpriteNode spriteNodeWithImageNamed:@"mainMenuPicture"];
        bgNode.position = CGPointMake(HALF_WIDTH, HALF_HEIGHT);
        bgNode.zPosition = -100;
        if (bgNode.size.width != [[UIScreen mainScreen] bounds].size.width) {
            bgNode.texture = [SKTexture textureWithImageNamed:@"i6bg.png"];
            [bgNode runAction:[SKAction scaleXTo:SELF_WIDTH/bgNode.size.width y:SELF_HEIGHT/bgNode.size.height duration:0]];
        }
        
        
        //***********************//
        //   PLAY BUTTON SETUP   //
        //***********************//
        
        SKTexture *playButtonTexture = [SKTexture textureWithImageNamed:@"PlayButton"];
        playButtonTexture.filteringMode = SKTextureFilteringNearest;
        playButton = [SKSpriteNode spriteNodeWithTexture:playButtonTexture];
        [playButton setScale:0.8];
        playButton.name = @"playButton";
        playButton.position = CGPointMake(3*SELF_WIDTH/4, 20 + SELF_HEIGHT/3);
        
        playButtonText = [SKLabelNode labelNodeWithFontNamed:@"Calibri"];
        playButtonText.fontSize = 23;
        playButtonText.fontColor = [SKColor whiteColor];
        playButtonText.position = CGPointMake(playButton.position.x, playButton.position.y-8);
        playButtonText.name = @"playButtonText";
        playButtonText.text = @"Play";
        playButtonText.zPosition = playButton.zPosition+1;
        
        //************************//
        //   ABOUT BUTTON SETUP   //
        //************************//
        
        SKTexture *optionsButtonTexture = [SKTexture textureWithImageNamed:@"PlayButton"];
        optionsButtonTexture.filteringMode = SKTextureFilteringNearest;
        optionsButton = [SKSpriteNode spriteNodeWithTexture:optionsButtonTexture];
        [optionsButton setScale:0.8];
        optionsButton.name = @"optionsButton";
        optionsButton.position = CGPointMake(3*SELF_WIDTH/4, playButton.position.y - 50);
        
        optionsButtonText = [SKLabelNode labelNodeWithFontNamed:@"Calibri"];
        optionsButtonText.fontSize = 23;
        optionsButtonText.fontColor = [SKColor whiteColor];
        optionsButtonText.position = CGPointMake(optionsButton.position.x, optionsButton.position.y-8);
        optionsButtonText.name = @"optionsButtonText";
        optionsButtonText.text = @"Options";
        optionsButtonText.zPosition = optionsButton.zPosition+1;
        
        //***************************//
        //   TUTORIAL BUTTON SETUP   //
        //***************************//
        
        SKTexture *tutorialButtonTexture = [SKTexture textureWithImageNamed:@"PlayButton"];
        tutorialButtonTexture.filteringMode = SKTextureFilteringNearest;
        tutorialButton = [SKSpriteNode spriteNodeWithTexture:tutorialButtonTexture];
        [tutorialButton setScale:0.8];
        tutorialButton.name = @"tutorialButton";
        tutorialButton.position = CGPointMake(3*SELF_WIDTH/4, optionsButton.position.y - 50);
        
        tutorialButtonText = [SKLabelNode labelNodeWithFontNamed:@"Calibri"];
        tutorialButtonText.fontSize = 23;
        tutorialButtonText.fontColor = [SKColor whiteColor];
        tutorialButtonText.position = CGPointMake(tutorialButton.position.x, tutorialButton.position.y-8);
        tutorialButtonText.name = @"tutorialButtonText";
        tutorialButtonText.text = @"Tutorial";
        tutorialButtonText.zPosition = tutorialButton.zPosition+1;
        
        
        
        
        
        scoreNode = [SKLabelNode labelNodeWithFontNamed:@"Calibri"];
        scoreNode.position = CGPointMake(3*SELF_WIDTH/4, 6*SELF_HEIGHT/11);
        scoreNode.fontColor = [SKColor whiteColor];
        scoreNode.fontSize = 20;
        scoreNode.name = @"ScoreNode";
        scoreNode.text = [NSString stringWithFormat:@"High Score:"];
        
        SKLabelNode *scoreTextNode = [SKLabelNode labelNodeWithFontNamed:@"Calibri"];
        scoreTextNode.fontColor = [SKColor blueColor];
        scoreTextNode.fontSize = 21;
        scoreTextNode.name = @"Score Text";
        scoreTextNode.text = [NSString stringWithFormat:@"%lu", highScore];
        
        averagePointsLabel = [SKLabelNode labelNodeWithFontNamed:@"Calibri"];
        averagePointsLabel.position = CGPointMake(scoreNode.position.x, scoreNode.position.y-40);
        averagePointsLabel.fontColor = [SKColor whiteColor];
        averagePointsLabel.fontSize = 20;
        averagePointsLabel.name = @"AveragePointsLabel";
        averagePointsLabel.text = [NSString stringWithFormat:@"Average Points:"];
        
        scoreTextNode.position = CGPointMake(3*SELF_WIDTH/4, (scoreNode.position.y+averagePointsLabel.position.y)/2);
        
        SKLabelNode *apLabel = [SKLabelNode labelNodeWithFontNamed:@"Calibri"];
        apLabel.position = CGPointMake(averagePointsLabel.position.x, averagePointsLabel.position.y-22);
        apLabel.fontColor = [SKColor blueColor];
        apLabel.fontSize = 21;
        apLabel.name = @"Average Points Text Label";
        apLabel.text = [NSString stringWithFormat:@"%lu", averagePoints];
        
        playButtonPressed     = NO;
        aboutButtonPressed    = NO;
        tutorialButtonPressed = NO;
        
        scoreNode.alpha = 0;
        averagePointsLabel.alpha = 0;
        scoreTextNode.alpha = 0;
        apLabel.alpha = 0;
        playButton.alpha = 0;
        playButtonText.alpha = 0;
        optionsButton.alpha = 0;
        optionsButtonText.alpha = 0;
        tutorialButton.alpha = 0;
        tutorialButtonText.alpha = 0;
        
        [self addChild:bgNode];
        [self addChild:scoreNode];
        [self addChild:titleLabel];
        [self addChild:underlineNode];
        [self addChild:playButtonText];
        [self addChild:playButton];
        [self addChild:optionsButton];
        [self addChild:optionsButtonText];
        [self addChild:tutorialButton];
        [self addChild:tutorialButtonText];
        [self addChild:averagePointsLabel];
        [self addChild:scoreTextNode];
        [self addChild:apLabel];
        
        
        [titleLabel runAction:[SKAction moveToY:10+3*SELF_HEIGHT/4 duration:.5] completion:^{
            [underlineNode runAction:[SKAction resizeToWidth:blueStraight.size.width*1.5 duration:1] completion:^{
                SKAction *fadeInn = [SKAction fadeInWithDuration:.05];
                SKAction *fadeOutt = [SKAction fadeOutWithDuration:.05];
                SKAction *wait = [SKAction waitForDuration:.3];
                NSArray *tempAr = [NSArray arrayWithObjects:fadeOutt, fadeInn, fadeOutt, fadeInn, wait, wait, wait, fadeOutt, fadeInn, wait, wait, nil];
                [underlineNode runAction:[SKAction repeatActionForever:[SKAction sequence:tempAr]]];
            }];
        }];
        
        [scoreNode runAction:[SKAction fadeInWithDuration:.5f] completion:^{
            [scoreTextNode runAction:[SKAction fadeInWithDuration:.55f] completion:^{
                [averagePointsLabel runAction:[SKAction fadeInWithDuration:.5f] completion:^{
                    [apLabel runAction:[SKAction fadeInWithDuration:.5f] completion:^{
                        [playButtonText runAction:[SKAction fadeInWithDuration:.6f]];
                        [playButton runAction:[SKAction fadeInWithDuration:.6f]];
                        [optionsButtonText runAction:[SKAction fadeInWithDuration:.6f]];
                        [optionsButton runAction:[SKAction fadeInWithDuration:.6f]];
                        [tutorialButtonText runAction:[SKAction fadeInWithDuration:.6f]];
                        [tutorialButton runAction:[SKAction fadeInWithDuration:.6f]];
                    }];
                }];
            }];
        }];
    }
    return self;
}

-(void)playButtonPressed{
    
    if (playButtonPressed && !aboutButtonPressed && !tutorialButtonPressed) {
        
        playButtonPressed     = NO;
        aboutButtonPressed    = NO;
        tutorialButtonPressed = NO;
        
        GameScene    *gameScene = [[GameScene alloc] initWithSize: self.size];
        
        //************************************************//
        //        EDIT ANY GAMESCENE PROPERTIES HERE      //
        //************************************************//
        
        gameScene.averageGuy.texture = NULL;
        gameScene.node1.texture      = NULL;
        gameScene.node2.texture      = NULL;
        gameScene.gameEnded          = NO;
        gameScene.ground.texture     = NULL;
        
        //*********//
        //   END   //
        //*********//
        
        SKTransition *transition = [SKTransition pushWithDirection:SKTransitionDirectionUp duration:0.7];
        transition.pausesIncomingScene = NO;
        
        titleLabel.hidden     = YES;
        playButtonText.hidden = YES;
        playButton.hidden     = YES;
        [musicSwitch removeFromSuperview];
        
        
        [self.view presentScene:gameScene transition:transition];
        
    }
    
}

-(void)optionsButtonPressed{
    
    playButtonPressed     = NO;
    aboutButtonPressed    = NO;
    tutorialButtonPressed = NO;
    
    optionsMenu = [SKShapeNode node];
    CGRect    tempRect     = CGRectMake(2, 2, SELF_WIDTH-4, SELF_HEIGHT/4);
    CGPathRef tempPath     = CGPathCreateWithRoundedRect(tempRect, 5, 5, Nil);
    
    optionsMenu.path        = tempPath;
    optionsMenu.fillColor   = [SKColor blackColor];
    optionsMenu.strokeColor = [SKColor colorWithRed:0 green:255/255.0f blue:127/255.0f alpha:1];
    optionsMenu.glowWidth   = 2.0f;
    optionsMenu.zPosition   = 20;
    optionsMenu.alpha       = 0;
    optionsMenu.position    = CGPointMake(HALF_WIDTH-optionsMenu.frame.size.width/2, HALF_HEIGHT-optionsMenu.frame.size.height/2);
    CGPathRelease(tempPath);
    
    soundOptionsNode = [SKLabelNode labelNodeWithFontNamed:@"Calibri"];
    soundOptionsNode.position = CGPointMake(3*HALF_WIDTH/7, HALF_HEIGHT - 7);
    soundOptionsNode.text = @"Music/Sounds";
    soundOptionsNode.name = @"Sound Options";
    soundOptionsNode.fontColor = [SKColor whiteColor];
    soundOptionsNode.fontSize = 17;
    soundOptionsNode.alpha = 0;
    soundOptionsNode.zPosition = 100;
    
    musicSwitch = [[UISwitch alloc] init];
    
    BOOL shouldMusicPlay = [[dictionary valueForKey:@"Music Sounds"] boolValue];
    
    musicSwitch.on = shouldMusicPlay;
    musicSwitch.center = CGPointMake(soundOptionsNode.position.x + 3.2*soundOptionsNode.frame.size.width/4, HALF_HEIGHT);
    musicSwitch.alpha = 1;
    
    [musicSwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    
    exitNode = [SKLabelNode labelNodeWithFontNamed:@"Calibri"];
    exitNode.position = CGPointMake(optionsMenu.frame.size.width-15, HALF_HEIGHT+optionsMenu.frame.size.height/4);
    exitNode.text = @"x";
    exitNode.fontColor = [SKColor redColor];
    exitNode.fontSize = 40;
    exitNode.name = @"Exit Button";
    exitNode.zPosition = 25;
    exitNode.alpha = 0;
    
    [self addChild:exitNode];
    [self addChild:optionsMenu];
    [self addChild:soundOptionsNode];
    
    [optionsMenu runAction:[SKAction fadeInWithDuration:1] completion:^{
        [exitNode runAction:[SKAction fadeInWithDuration:1]];
        [soundOptionsNode runAction:[SKAction fadeInWithDuration:1] completion:^{
            [self.view addSubview:musicSwitch];
        }];
    }];
}


-(void)tutorialButtonPressed{
    
    if (!playButtonPressed && !aboutButtonPressed && tutorialButtonPressed) {
        
        playButtonPressed     = NO;
        aboutButtonPressed    = NO;
        tutorialButtonPressed = NO;
        
        TutorialScene *tutorialScene = [[TutorialScene alloc] initWithSize: self.size];
        
        //*********//
        //   END   //
        //*********//
        
        SKTransition *transition = [SKTransition pushWithDirection:SKTransitionDirectionUp duration:0.7];
        transition.pausesIncomingScene = NO;
        
        titleLabel.hidden         = YES;
        tutorialButtonText.hidden = YES;
        tutorialButton.hidden     = YES;
        [musicSwitch removeFromSuperview];
        
        
        [self.view presentScene:tutorialScene transition:transition];
        
    }
}

-(void)changeSwitch:(id)sender {
    if ([sender isOn]) {
        BOOL musicShouldPlay = YES;
        [dictionary setValue:[NSNumber numberWithBool:musicShouldPlay] forKey:@"Music Sounds"];
        [dictionary writeToFile:listPath atomically:YES];
    }
    else if (![sender isOn]) {
        BOOL musicShouldPlay = NO;
        [dictionary setValue:[NSNumber numberWithBool:musicShouldPlay] forKey:@"Music Sounds"];
        [dictionary writeToFile:listPath atomically:YES];
    }
}

-(void)buttonPressedBringUp: (SKSpriteNode *) button{
    
    if([button.name  isEqualToString:@"playButton"])
    {
        playButton.position     = CGPointMake(playButton.position.x, playButton.position.y+1);
        playButtonText.position = CGPointMake(playButtonText.position.x, playButtonText.position.y+1);
    }
    else if ([button.name isEqualToString:@"optionsButton"])
    {
        optionsButton.position     = CGPointMake(optionsButton.position.x, optionsButton.position.y+1);
        optionsButtonText.position = CGPointMake(optionsButtonText.position.x, optionsButtonText.position.y+1);
    }
    else if ([button.name isEqualToString:@"tutorialButton"])
    {
        tutorialButton.position     = CGPointMake(tutorialButton.position.x, tutorialButton.position.y+1);
        tutorialButtonText.position = CGPointMake(tutorialButtonText.position.x, tutorialButtonText.position.y+1);
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    for (UITouch *touch in touches) {
        
        locationPressed  = [touch locationInNode:self];
        SKNode *someNode = [self nodeAtPoint:locationPressed];
        
        if (([someNode.name isEqualToString:@"playButton"]
             ||[someNode.name isEqualToString:@"playButtonText"]))
        {
            playButtonPressed       = YES;
            aboutButtonPressed      = NO;
            tutorialButtonPressed   = NO;
            playButton.position     = CGPointMake(playButton.position.x, playButton.position.y-1);
            playButtonText.position = CGPointMake(playButtonText.position.x, playButtonText.position.y-1);
        }
        
        if (([someNode.name isEqualToString:@"optionsButton"]
             ||[someNode.name isEqualToString:@"optionsButtonText"]))
        {
            aboutButtonPressed       = YES;
            playButtonPressed        = NO;
            tutorialButtonPressed    = NO;
            optionsButton.position     = CGPointMake(optionsButton.position.x, optionsButton.position.y-1);
            optionsButtonText.position = CGPointMake(optionsButtonText.position.x, optionsButtonText.position.y-1);
        }
        
        if (([someNode.name isEqualToString:@"tutorialButton"]
             ||[someNode.name isEqualToString:@"tutorialButtonText"]))
        {
            tutorialButtonPressed       = YES;
            playButtonPressed           = NO;
            aboutButtonPressed          = NO;
            tutorialButton.position     = CGPointMake(tutorialButton.position.x, tutorialButton.position.y-1);
            tutorialButtonText.position = CGPointMake(tutorialButtonText.position.x, tutorialButtonText.position.y-1);
        }
        
        if ([someNode.name isEqualToString:@"Exit Button"]) {
            [optionsMenu removeFromParent];
            [exitNode removeFromParent];
            [soundOptionsNode removeFromParent];
            [musicSwitch removeFromSuperview];
        }
        
        someNode = Nil;
        
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (playButtonPressed && !aboutButtonPressed && !tutorialButtonPressed) {
        [self performSelector:@selector(buttonPressedBringUp:) withObject:playButton];
        [self performSelector:@selector(playButtonPressed)     withObject:self afterDelay:0.1];
    }
    
    if (aboutButtonPressed && !playButtonPressed && !tutorialButtonPressed) {
        [self performSelector:@selector(buttonPressedBringUp:) withObject:optionsButton];
        [self performSelector:@selector(optionsButtonPressed)    withObject:self afterDelay:0.1];
    }
    
    if (!aboutButtonPressed && !playButtonPressed && tutorialButtonPressed) {
        [self performSelector:@selector(buttonPressedBringUp:) withObject:tutorialButton];
        [self performSelector:@selector(tutorialButtonPressed)    withObject:self afterDelay:0.1];
    }
    
}

@end
