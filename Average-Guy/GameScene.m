//************************************************************//
//  GameScene.m                                               //
//  Average Guy                                               //
//                                                            //
//  Created by Andr!y Suden and V!ktor Kornyeyev on 2/23/14.  //
//  Copyright (c) 2014 DropGeeks. All rights reserved.        //
//************************************************************//

#import "GameScene.h"

//******************************Private******************************//

@interface GameScene ()
{
    
    SystemSoundID   playSoundID;
    AVAudioPlayer   *playThemeSong;
    
    CGPoint         locationPressed;
    CGPoint         centerOfGravity;
    
    CGVector        agVelocity;
    
    BOOL            screenTouched;
    BOOL            screenTouchedRight;
    BOOL            screenTouchedLeft;
    BOOL            nodesAreSpawning;
    BOOL            powerUpPickedUp;
    BOOL            okayToSpawnPowerUp;
    BOOL            lengthPowerUpIsActive;
    BOOL            boostPickedUp;
    BOOL            displayingLabel;
    BOOL            gameIsPaused;
    BOOL            pauseAnimation;
    BOOL            okayToHitPause;
    
    /* Tapping pause quickly after the game has been unpaused creates a potential cheat/glitch, which is why we need to wait a small amount of time before user can pause again */
    
    SKSpriteNode    *node1;
    SKSpriteNode    *node2;
    SKSpriteNode    *averageGuy;
    SKSpriteNode    *ground;
    SKSpriteNode    *scoreNode;
    SKSpriteNode    *powerUp;
    SKSpriteNode    *pauseButton;
    
    SKSpriteNode    *boughtBoostPowerup;
    SKSpriteNode    *boughtInvincibilityPowerup;
    SKSpriteNode    *boughtLengthPowerup;
    
    UISwitch        *soundSwitch;
    
    SKLabelNode     *averagePointsNumberLabel;
    
    SKLabelNode     *countOfInvincibilityNode;
    SKLabelNode     *countOfBoostNode;
    SKLabelNode     *countOfLengthNode;
    
    SKLabelNode     *costOfInvincibilityNode;
    SKLabelNode     *costOfLengthNode;
    SKLabelNode     *costOfBoostNode;
    SKLabelNode     *labelZ;
    
    NSMutableArray  *obstacleMovementArray;
    NSMutableArray  *actionsArrayForNode;
    
    int             counter;
    int             powerUpSwitch;
    
    float           spawnSeconds;
    
}


@property (nonatomic)         NSTimer           *spawnTimer;
@property (nonatomic, strong) NSMutableArray    *arrayOfObstacles;
@property (nonatomic, strong) NSMutableArray    *arrayOfPowerUps;
@property SKEmitterNode                         *smokeTrail;


@end


//**************************Implementation**************************//


@implementation GameScene

@synthesize spawnTimer;
@synthesize arrayOfPowerUps;
@synthesize smokeTrail;
@synthesize gameEnded  = _gameEnded;
@synthesize arrayOfObstacles;
@synthesize ground     = _ground;
@synthesize node1      = _node1;
@synthesize node2      = _node2;
@synthesize averageGuy = _averageGuy;
@synthesize scoreLabel;
@synthesize highScore;
@synthesize lastSpawnTimeInterval;
@synthesize lastUpdateTimeInterval;
@synthesize lastSpawnTimeInterval1;

static const uint32_t averageGuyCategory = 0x1 << 0;
static const uint32_t obstacleCategory   = 0x1 << 1;
static const uint32_t boundsCategory     = 0x1 << 2;
static const uint32_t scoreCategory      = 0x1 << 3;
static const uint32_t powerUpCategory    = 0x1 << 4;


//*****************************Methods*****************************//


#pragma mark Setting up the world here

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        
        /****TAKING*CARE*OF*SOUND*STUFF****/
        /**/NSURL *soundURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ring" ofType:@"wav"]];
        /**/AudioServicesCreateSystemSoundID((__bridge CFURLRef) soundURL, &playSoundID);
        /****TAKING*CARE*OF*SOUND*STUFF****/
        
        /****TAKING*CARE*OF*SOUND*STUFF****/
        /**/NSURL *themeSongURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"POL-clouds-castle-short" ofType:@"wav"]];
        /**/playThemeSong = [[AVAudioPlayer alloc]initWithContentsOfURL:themeSongURL error:Nil];
        /****TAKING*CARE*OF*SOUND*STUFF****/
        
        self.physicsWorld.gravity         = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        self.backgroundColor              = [SKColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1];
        
        //**************************************//
        //   TAKING CARE OF BOOLEANS AND GAME   //
        //**************************************//
        
        screenTouched              = NO;
        screenTouchedLeft          = NO;
        screenTouchedRight         = NO;
        self.gameEnded             = NO;
        nodesAreSpawning           = NO;
        gameIsPaused               = NO;
        displayingLabel = NO;
        okayToHitPause = YES;
        pauseAnimation = NO;
        
        listPath = [[self docsDir] stringByAppendingPathComponent:@"POL.plist"];
        
        dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:listPath];
        
        self.arrayOfObstacles = [NSMutableArray arrayWithCapacity:16];
        self.arrayOfPowerUps  = [NSMutableArray arrayWithCapacity:8];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"pauseGame" object:nil];
        
        soundSwitch        = [[UISwitch alloc] init];
        soundSwitch.center = CGPointMake(HALF_WIDTH, HALF_HEIGHT);
        soundSwitch.hidden = YES;
        soundSwitch.on     = [[dictionary valueForKey:@"Music Sounds"] boolValue];
        
        self.view.paused = NO;
        
        [self createInitialContentsOnScreen];
        
    }
    return self;
    
}

#pragma mark Create Initial Contents

-(void)createInitialContentsOnScreen{
    
    //sound shit
    if([soundSwitch isOn]){
        [playThemeSong setNumberOfLoops:-1];
        [playThemeSong setVolume: 1];
        [playThemeSong play];
    } else {
        [playThemeSong setNumberOfLoops:-1];
        [playThemeSong setVolume: 0];
    }
    
    listPath = [[self docsDir] stringByAppendingPathComponent:@"POL.plist"];
    dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:listPath];
    
    SKTexture *boostPowerupTexture         = [SKTexture textureWithImageNamed:@"boostPowerup.png"];
    SKTexture *invincibilityPowerupTexture = [SKTexture textureWithImageNamed:@"invincibilityPowerup.png"];
    SKTexture *lengthPowerupTexture        = [SKTexture textureWithImageNamed:@"length.png"];
    
    boughtBoostPowerup         = [SKSpriteNode spriteNodeWithTexture:boostPowerupTexture];
    boughtInvincibilityPowerup = [SKSpriteNode spriteNodeWithTexture:invincibilityPowerupTexture];
    boughtLengthPowerup        = [SKSpriteNode spriteNodeWithTexture:lengthPowerupTexture];
    
    boughtBoostPowerup.name         = @"bought_boost_powerup";
    boughtInvincibilityPowerup.name = @"bought_invincibility_powerup";
    boughtLengthPowerup.name        = @"bought_length_powerup";
    
    
    [boughtBoostPowerup setScale:0.4];
    [boughtInvincibilityPowerup setScale:0.4];
    [boughtLengthPowerup setScale:0.4];
    
    boughtBoostPowerup.position = CGPointMake(SELF_WIDTH/6, boughtBoostPowerup.size.height/2);
    boughtInvincibilityPowerup.position = CGPointMake(SELF_WIDTH/2, boughtInvincibilityPowerup.size.height/2);
    boughtLengthPowerup.position = CGPointMake(5*SELF_WIDTH/6, boughtLengthPowerup.size.height/2);
    
    
    countOfInvincibilityNode = [SKLabelNode labelNodeWithFontNamed:@"Calibri"];
    countOfInvincibilityNode.fontColor = [SKColor whiteColor];
    countOfInvincibilityNode.fontSize  = 10;
    countOfInvincibilityNode.position  = CGPointMake(boughtInvincibilityPowerup.position.x+boughtInvincibilityPowerup.size.width/2, boughtInvincibilityPowerup.position.y-boughtInvincibilityPowerup.size.height/2);
    countOfInvincibilityNode.zPosition = 31;
    countOfInvincibilityNode.text = [NSString stringWithFormat:@"%i",[[dictionary valueForKey:@"Invincibility Count"] intValue]];
    
    countOfBoostNode = [SKLabelNode labelNodeWithFontNamed:@"Calibri"];
    countOfBoostNode.fontColor = [SKColor whiteColor];
    countOfBoostNode.fontSize  = 10;
    countOfBoostNode.position  = CGPointMake(boughtBoostPowerup.position.x+boughtBoostPowerup.size.width/2, boughtBoostPowerup.position.y-boughtBoostPowerup.size.height/2);
    countOfBoostNode.zPosition = 31;
    countOfBoostNode.text = [NSString stringWithFormat:@"%i",[[dictionary valueForKey:@"Boost Count"] intValue]];
    
    countOfLengthNode = [SKLabelNode labelNodeWithFontNamed:@"Calibri"];
    countOfLengthNode.fontColor = [SKColor whiteColor];
    countOfLengthNode.fontSize  = 10;
    countOfLengthNode.position  = CGPointMake(boughtLengthPowerup.position.x+boughtLengthPowerup.size.width/2, boughtLengthPowerup.position.y-boughtLengthPowerup.size.height/2);
    countOfLengthNode.zPosition = 31;
    countOfLengthNode.text = [NSString stringWithFormat:@"%i",[[dictionary valueForKey:@"Length Count"] intValue]];
    
    okayToSpawnPowerUp      = YES;
    powerUpPickedUp         = NO;
    lengthPowerUpIsActive   = NO;
    spawnSeconds            = 0.6f;
    counter                 = 0;
    
    //*************************************//
    //   SETTING UP THE SCORE LABEL HERE   //
    //*************************************//
    
    scoreLabel           = [SKLabelNode labelNodeWithFontNamed:@"Calibri"];
    scoreLabel.fontSize  = 60;
    scoreLabel.zPosition = 13;
    scoreLabel.position  = CGPointMake(HALF_WIDTH, 3*SELF_HEIGHT/4);
    scoreLabel.text      = @"0";
    
    //**************************************//
    //   SETTING UP THE GROUND RIGHT HERE   //
    //**************************************//
    
    ground            = [SKSpriteNode spriteNodeWithColor:[SKColor blueColor] size:CGSizeMake(SELF_WIDTH, SELF_HEIGHT/10)];
    ground.position   = CGPointMake(SELF_WIDTH/2, 0);
    ground.zPosition  = 20;
    
    //*******************************//
    //   SETTING UP JIM RIGHT HERE   //
    //*******************************//
    
    SKTexture *averageGuyTexture              = [SKTexture textureWithImage:[UIImage imageNamed:@"agUp"]];
    averageGuy                                = [SKSpriteNode spriteNodeWithTexture:averageGuyTexture];
    
    averageGuy.position                       = CGPointMake(self.frame.size.width / 2, boughtLengthPowerup.position.y+(boughtLengthPowerup.frame.size.height/2)+(averageGuy.frame.size.height/2));
    
    averageGuy.physicsBody                    = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(averageGuy.frame.size.width, averageGuy.frame.size.height)];
    averageGuy.physicsBody.mass               = .01;
    averageGuy.physicsBody.density            = 1;
    averageGuy.physicsBody.dynamic            = YES;
    averageGuy.physicsBody.allowsRotation     = NO;
    averageGuy.physicsBody.affectedByGravity  = YES;
    averageGuy.physicsBody.categoryBitMask    = averageGuyCategory;
    averageGuy.physicsBody.collisionBitMask   = 0;
    averageGuy.physicsBody.contactTestBitMask = obstacleCategory | powerUpCategory;
    averageGuy.zPosition                      = 21;
    averageGuy.physicsBody.friction           = 15;
    
    //***********************************************************************//
    //   SET UP TERRAIN HERE TO LESSEN THE PROCESSOR REQ. WHEN GAME STARTS   //
    //***********************************************************************//
    
    CGMutablePathRef screenPath = CGPathCreateMutable();
    CGPathMoveToPoint   (screenPath, NULL, 0.0f, 0.0f);
    CGPathAddLineToPoint(screenPath, NULL, 320.0f, 0.0f);
    CGPathAddLineToPoint(screenPath, NULL, 320.0f, 568.0f);
    CGPathAddLineToPoint(screenPath, NULL, 0.0f, 568.0f);
    CGPathAddLineToPoint(screenPath, NULL, 0.0f, 0.0f);
    CGPathCloseSubpath  (screenPath);
    
    screenBounds                                = [SKNode node];
    screenBounds.physicsBody                    = [SKPhysicsBody bodyWithEdgeLoopFromPath:screenPath];
    CGPathRelease(screenPath);
    screenBounds.physicsBody.affectedByGravity  = NO;
    screenBounds.physicsBody.categoryBitMask    = boundsCategory;
    screenBounds.physicsBody.contactTestBitMask = powerUpCategory;
    screenBounds.physicsBody.collisionBitMask   = 0;
    
    NSString *smokePath = [[NSBundle mainBundle] pathForResource:@"smokeParticle" ofType:@"sks"];
    self.smokeTrail = [SKEmitterNode node];
    self.smokeTrail = [NSKeyedUnarchiver unarchiveObjectWithFile:smokePath];
    self.smokeTrail.position = averageGuy.position;
    self.smokeTrail.zPosition = averageGuy.zPosition-10;
    
    pauseButton           = [SKSpriteNode spriteNodeWithImageNamed:@"pauseButton.png"];
    pauseButton.size      = CGSizeMake(50.0f, 50.0f);
    pauseButton.position  = CGPointMake(SELF_WIDTH-50.0f, SELF_HEIGHT-50.0f);
    pauseButton.name      = @"pauseButton";
    pauseButton.zPosition = 50;
    
    //********************************//
    //   TEXTURES FOR THE OBSTACLES   //
    //********************************//
    
    SKTextureAtlas *obstacleAtlas = [SKTextureAtlas atlasNamed:@"iPhoneObstacles"];
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:42];
    
    NSString *textureName = [NSString stringWithFormat:@"redUp~iPhone"];
    [tempArray addObject:[obstacleAtlas textureNamed:textureName]];
    
    textureName = [NSString stringWithFormat:@"redStraight~iPhone"];
    [tempArray addObject:[obstacleAtlas textureNamed:textureName]];
    
    textureName = [NSString stringWithFormat:@"magentaDown~iPhone"];
    [tempArray addObject:[obstacleAtlas textureNamed:textureName]];
    
    textureName = [NSString stringWithFormat:@"magentaStraight~iPhone"];
    [tempArray addObject:[obstacleAtlas textureNamed:textureName]];
    
    textureName = [NSString stringWithFormat:@"purpleUp~iPhone"];
    [tempArray addObject:[obstacleAtlas textureNamed:textureName]];
    
    textureName = [NSString stringWithFormat:@"purpleStraight~iPhone"];
    [tempArray addObject:[obstacleAtlas textureNamed:textureName]];
    
    textureName = [NSString stringWithFormat:@"bluePurpDown~iPhone"];
    [tempArray addObject:[obstacleAtlas textureNamed:textureName]];
    
    textureName = [NSString stringWithFormat:@"bluePurpStraight~iPhone"];
    [tempArray addObject:[obstacleAtlas textureNamed:textureName]];
    
    textureName = [NSString stringWithFormat:@"blueeUp~iPhone"];
    [tempArray addObject:[obstacleAtlas textureNamed:textureName]];
    
    textureName = [NSString stringWithFormat:@"blueeStraight~iPhone"];
    [tempArray addObject:[obstacleAtlas textureNamed:textureName]];
    
    textureName = [NSString stringWithFormat:@"blueCyanDown~iPhone"];
    [tempArray addObject:[obstacleAtlas textureNamed:textureName]];
    
    textureName = [NSString stringWithFormat:@"blueCyanStraight~iPhone"];
    [tempArray addObject:[obstacleAtlas textureNamed:textureName]];
    
    textureName = [NSString stringWithFormat:@"cyanUp~iPhone"];
    [tempArray addObject:[obstacleAtlas textureNamed:textureName]];
    
    textureName = [NSString stringWithFormat:@"cyanStraight~iPhone"];
    [tempArray addObject:[obstacleAtlas textureNamed:textureName]];
    
    textureName = [NSString stringWithFormat:@"turquoiseDown~iPhone"];
    [tempArray addObject:[obstacleAtlas textureNamed:textureName]];
    
    textureName = [NSString stringWithFormat:@"turquoiseStraight~iPhone"];
    [tempArray addObject:[obstacleAtlas textureNamed:textureName]];
    
    textureName = [NSString stringWithFormat:@"greenUp~iPhone"];
    [tempArray addObject:[obstacleAtlas textureNamed:textureName]];
    
    textureName = [NSString stringWithFormat:@"greenStraight~iPhone"];
    [tempArray addObject:[obstacleAtlas textureNamed:textureName]];
    
    textureName = [NSString stringWithFormat:@"yeGreenDown~iPhone"];
    [tempArray addObject:[obstacleAtlas textureNamed:textureName]];
    
    textureName = [NSString stringWithFormat:@"yeGreenStraight~iPhone"];
    [tempArray addObject:[obstacleAtlas textureNamed:textureName]];
    
    textureName = [NSString stringWithFormat:@"yellowUp~iPhone"];
    [tempArray addObject:[obstacleAtlas textureNamed:textureName]];
    
    textureName = [NSString stringWithFormat:@"yellowStraight~iPhone"];
    [tempArray addObject:[obstacleAtlas textureNamed:textureName]];
    
    textureName = [NSString stringWithFormat:@"yeOrangeDown~iPhone"];
    [tempArray addObject:[obstacleAtlas textureNamed:textureName]];
    
    textureName = [NSString stringWithFormat:@"yeOrangeStraight~iPhone"];
    [tempArray addObject:[obstacleAtlas textureNamed:textureName]];
    
    textureName = [NSString stringWithFormat:@"orangeUp~iPhone"];
    [tempArray addObject:[obstacleAtlas textureNamed:textureName]];
    
    textureName = [NSString stringWithFormat:@"orangeStraight~iPhone"];
    [tempArray addObject:[obstacleAtlas textureNamed:textureName]];
    
    textureName = [NSString stringWithFormat:@"orRedDown~iPhone"];
    [tempArray addObject:[obstacleAtlas textureNamed:textureName]];
    
    textureName = [NSString stringWithFormat:@"orRedStraight~iPhone"];
    [tempArray addObject:[obstacleAtlas textureNamed:textureName]];
    
    obstacleMovementArray = tempArray;
    
    
    //**************************************//
    //          ADDING THE CONTENTS         //
    //**************************************//
    
    listPath = [[self docsDir] stringByAppendingPathComponent:@"POL.plist"];
    
    [self addChild:scoreLabel];
    [self addChild:screenBounds];
    [self addChild:ground];
    [self addChild:averageGuy];
    [self addChild:pauseButton];
    
    nodesAreSpawning = YES;
    
}

-(void)spawnBackgroundNodes {
    
    // Create Needed Stuff
    
    float randomInt = arc4random() %100 +1;
    randomInt /= 100;
    CGSize randomSize = CGSizeMake(10*randomInt, 10*randomInt);
    
    randomInt = arc4random() %100 +1;
    randomInt /= 100;
    float randomInt2 = arc4random() %100 +1;
    randomInt2 /= 100;
    
    CGPathRef backgroundPath = CGPathCreateWithEllipseInRect(CGRectMake(0, 0, randomSize.width, randomSize.height), nil);
    
    CGPoint randomPoint = CGPointMake(randomInt*SELF_WIDTH, randomInt2*SELF_HEIGHT);
    
    // Set Up Node Here
    
    SKShapeNode *backgroundNode = [SKShapeNode node];
    backgroundNode.path = backgroundPath;
    
    CGPathRelease(backgroundPath);
    
    backgroundNode.fillColor = [SKColor whiteColor];
    backgroundNode.strokeColor = [SKColor whiteColor];
    backgroundNode.glowWidth = 3.0f;
    backgroundNode.position = randomPoint;
    backgroundNode.zPosition = 10;
    backgroundNode.alpha = 0.8f;
    randomInt = arc4random() %100 +1;
    if (randomInt <= 50) randomInt += 50;
    randomInt /= 100;
    
    [self addChild:backgroundNode];
    [backgroundNode runAction:[SKAction fadeOutWithDuration:3.0f*randomInt] completion:^{
        [backgroundNode runAction:[SKAction removeFromParent]];
    }];
    
}

-(void) spawnObstaclesAndPowerUps {
    
    //*****************************************************//
    //   CREATE THE TWO OBSTACLES + SCORE DETECTION NODE   //
    //*****************************************************//
    
    node1     = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"redUp"]];
    node2     = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"redUp"]];
    
    scoreNode = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(SELF_WIDTH, 1)];
    
    //********************************************************//
    //   SETUP THE TWO OBSTACLES HERE + SCORE DETECTION NODE  //
    //********************************************************//
    
    //                             \\
    //SETUP THE FIRST OBSTACLE NODE\\
    //                             \\
    
    node1.position = CGPointMake((averageGuy.frame.size.width + arc4random () % (int)(SELF_WIDTH - 5 * averageGuy.frame.size.width)) - node1.frame.size.width/2, SELF_HEIGHT);
    node1.physicsBody                    = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(node1.frame.size.width-8, node1.frame.size.height-10)];
    node1.physicsBody.affectedByGravity  = NO;
    node1.physicsBody.categoryBitMask    = obstacleCategory;
    node1.physicsBody.collisionBitMask   = 0;
    node1.zPosition                      = 10;
    node1.name                           = @"node1";
    
    //                              \\
    //SETUP THE SECOND OBSTACLE NODE\\
    //                              \\
    
    node2.position = CGPointMake(((node1.position.x + node1.frame.size.width/2 ) + 3 * averageGuy.frame.size.width) + node2.frame.size.width/2, SELF_HEIGHT);
    node2.physicsBody                   = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(node1.frame.size.width-8, node1.frame.size.height-10)];
    node2.physicsBody.affectedByGravity = NO;
    node2.physicsBody.categoryBitMask   = obstacleCategory;
    node2.physicsBody.collisionBitMask  = 0;
    node2.zPosition                     = 11;
    node2.name                          = @"node2";
    
    NSLog(@"Offset: %f", (SELF_WIDTH-node2.position.x));
    
    
    if (lengthPowerUpIsActive) {
        
        node1.position = CGPointMake(node1.position.x - averageGuy.frame.size.width, node1.position.y);
        node2.position = CGPointMake(node2.position.x + averageGuy.frame.size.width, node2.position.y);
        
    }
    
    //                          \\
    //SETUP SCORE DETECTION NODE\\
    //                          \\
    
    scoreNode.position                       = CGPointMake(HALF_WIDTH, SELF_HEIGHT);
    scoreNode.zPosition                      = 12;
    scoreNode.physicsBody                    = [SKPhysicsBody bodyWithRectangleOfSize:scoreNode.size];
    scoreNode.physicsBody.affectedByGravity  = NO;
    scoreNode.physicsBody.categoryBitMask    = scoreCategory;
    scoreNode.physicsBody.contactTestBitMask = averageGuyCategory;
    scoreNode.physicsBody.collisionBitMask   = 0;
    scoreNode.name                           = @"scoreNode";
    
    
    //********************************//
    //   MOVEMENT FOR THE OBSTACLES   //
    //********************************//
    
    
    SKAction *moveDown             = [SKAction moveByX:0.0f y:-(SELF_HEIGHT) duration:1.3];
    SKAction *removeFromParent     = [SKAction removeFromParent];
    
    if (!powerUpPickedUp) {
        actionsArrayForNode  = [NSMutableArray arrayWithObjects: moveDown, removeFromParent, nil];
    }
    
    SKAction *fall                 = [SKAction sequence:actionsArrayForNode];
    SKAction *animation            = [SKAction repeatActionForever:[SKAction animateWithTextures:obstacleMovementArray timePerFrame:0.07f resize:NO restore:YES]];
    
    
    //*************************//
    //   Animate The Objects   //
    //*************************//
    
    
    [node1 runAction:animation withKey:@"Node1IsAnimating"];
    [node2 runAction:animation withKey:@"Node2IsAnimating"];
    
    
    //****************************//
    //   Spawn A Powerup Object   //
    //****************************//
    
    if (counter % 2 == 0 && (arc4random() % 50 + 1 == 1)) {
        
        if (okayToSpawnPowerUp) /* then */ [self spawnPowerUp];
        
    } counter++;
    
    
    [self                  addChild:scoreNode];
    
    [self.arrayOfObstacles addObject:node1];
    [self                  addChild:node1];
    
    [self.arrayOfObstacles addObject:node2];
    [self                  addChild:node2];
    
    if (counter == 1){
        [self runAction:[SKAction runBlock:^{[ground runAction:moveDown];}] completion:^{
            
            [self addChild:boughtBoostPowerup];
            [self addChild:boughtInvincibilityPowerup];
            [self addChild:boughtLengthPowerup];
            
            [self addChild:countOfBoostNode];
            [self addChild:countOfInvincibilityNode];
            [self addChild:countOfLengthNode];}];
    }
    [scoreNode runAction:fall withKey:@"falling"];
    [node1     runAction:fall withKey:@"falling"];
    [node2     runAction:fall withKey:@"falling"];
    
}

#pragma mark Contact Testing for Game End

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    // 1
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody  = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody  = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & averageGuyCategory) != 0 && (secondBody.categoryBitMask & scoreCategory) != 0)
    {
        int score       = [scoreLabel.text intValue] + 1;
        scoreLabel.text = [NSString stringWithFormat:@"%i", score];
        secondBody.contactTestBitMask = 0;
        
        if ([soundSwitch isOn]) {
            AudioServicesPlaySystemSound(playSoundID);
        }
        
        
    }
    
    if ((firstBody.categoryBitMask & averageGuyCategory)     != 0 && (secondBody.categoryBitMask & obstacleCategory) != 0)
    {
        
        [self gameDidEnd];
        
    }
    
    //3
    if ((firstBody.categoryBitMask & averageGuyCategory)     != 0 && (secondBody.categoryBitMask & powerUpCategory) != 0)
    {
        [powerUp removeAllActions];
        [powerUp removeFromParent];
        [self.arrayOfPowerUps removeObject:powerUp];
        [self pickedUpPowerUp: @"random"];
    }
    
    
    
    if ((firstBody.categoryBitMask & boundsCategory)         != 0 && (secondBody.categoryBitMask & powerUpCategory) != 0)
    {
        if (!(powerUp.position.y > 1)) {
            [self.arrayOfPowerUps removeObject:powerUp];
        }
    }
    
}

-(void)gameDidEnd {
    
    [boughtBoostPowerup         removeFromParent];
    [boughtInvincibilityPowerup removeFromParent];
    [boughtLengthPowerup        removeFromParent];
    
    [countOfBoostNode         removeFromParent];
    [countOfInvincibilityNode removeFromParent];
    [countOfLengthNode        removeFromParent];
    
    
    if ([soundSwitch isOn]) {
        playThemeSong.volume = .4;
    }
    
    [self UpdatePlist];
    
    //*********************************************//
    //   SETTING ALL BOOLS TO NO AND CLEANING UP   //
    //*********************************************//
    
    screenTouched      = NO;
    screenTouchedLeft  = NO;
    screenTouchedRight = NO;
    nodesAreSpawning   = NO;
    self.view.paused   = NO;
    self.gameEnded     = YES;
    
    [pauseButton removeFromParent];
    
    averageGuy.alpha = 1;
    
    [self updateCostColors];
    
    for (SKSpriteNode *obstacle in self.arrayOfObstacles) {
        [obstacle removeAllActions];
        SKAction *moveOutOfScreenLeft = [SKAction moveBy:CGVectorMake(-1000, 0) duration:2];
        SKAction *moveOutOfScreenRight = [SKAction moveBy:CGVectorMake(1000, 0) duration:2];
        
        if (obstacle.position.x < HALF_WIDTH) {
            [obstacle runAction:moveOutOfScreenLeft];
        }
        if (obstacle.position.x > HALF_WIDTH) {
            [obstacle runAction:moveOutOfScreenRight];
        }
    }
    
    for (SKSpriteNode *powerup in self.arrayOfPowerUps) {
        [powerup removeAllActions];
        [powerup runAction:[SKAction fadeOutWithDuration:.5f]];
    }
    
    
    //RUN COOL SCRIPTS ON AVERAGE GUY + END GAME OPTIONS MENU + STORE MENU
    
    averageGuy.physicsBody = Nil;
    
    [averageGuy runAction:[SKAction rotateByAngle:-M_PI duration:1]];
    [averageGuy runAction:[SKAction runBlock:^{
        [averageGuy runAction:[SKAction moveByX:0.0f y:25.0f duration:.25] completion:^{
            [averageGuy runAction:[SKAction moveByX:0.0f y:-150.0f duration:.65] completion:^{
                
                for (SKSpriteNode *obstacle in self.arrayOfObstacles) {
                    [obstacle removeFromParent];
                }
                
                for (SKSpriteNode *powerup in self.arrayOfPowerUps) {
                    [powerup removeFromParent];
                }
                
                [averageGuy runAction:[SKAction removeFromParent]];
                [self gameDidEndStoreMenu];
                [self gameDidEndOptionsMenu];
                
            }];
        }];
    }]];
    
}

-(void)gameDidEndStoreMenu{
    
    listPath   = [[self docsDir] stringByAppendingPathComponent:@"POL.plist"];
    dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:listPath];
    
    unsigned long aPoints = [[dictionary valueForKey:@"Average Points"] unsignedLongValue];
    
    SKTexture    *invincibilityPowerupTexture  =  [SKTexture textureWithImageNamed:@"invincibilityPowerup"];
    SKTexture    *boostPowerupTexture          =  [SKTexture textureWithImageNamed:@"boostPowerup"];
    SKTexture    *lengthPowerupTexture         =  [SKTexture textureWithImageNamed:@"length"];
    SKTexture    *lockTexture                  =  [SKTexture textureWithImageNamed:@"lock-10"];
    
    SKSpriteNode *invincibilityPowerup         =  [SKSpriteNode spriteNodeWithTexture:invincibilityPowerupTexture];
    invincibilityPowerup.name    = @"invincibility_powerup";
    invincibilityPowerup.size    = invincibilityPowerupTexture.size;
    SKSpriteNode *boostPowerup                 =  [SKSpriteNode spriteNodeWithTexture:boostPowerupTexture];
    boostPowerup.name            = @"boost_powerup";
    boostPowerup.size            = boostPowerupTexture.size;
    SKSpriteNode *lengthPowerup                =  [SKSpriteNode spriteNodeWithTexture:lengthPowerupTexture];
    lengthPowerup.name           = @"length_powerup";
    lengthPowerup.size           = lengthPowerupTexture.size;
    SKSpriteNode *lock                         =  [SKSpriteNode spriteNodeWithTexture:lockTexture];
    lock.size                    = lockTexture.size;
    
    //create store menu outline
    SKShapeNode *storeMenu = [SKShapeNode node];
    CGRect    tempRect     = CGRectMake(2, 2, SELF_WIDTH-4, invincibilityPowerup.frame.size.height+20);
    CGPathRef tempPath     = CGPathCreateWithRoundedRect(tempRect, 5, 5, Nil);
    
    storeMenu.path        = tempPath;
    storeMenu.fillColor   = [SKColor blackColor];
    storeMenu.strokeColor = [SKColor blueColor];
    storeMenu.glowWidth   = 2.0f;
    storeMenu.zPosition   = 24;
    storeMenu.alpha       = 0;
    storeMenu.position    = CGPointMake(storeMenu.position.x, storeMenu.position.y-20);
    CGPathRelease(tempPath);
    
#define STORE_MENU_CENTER_Y (storeMenu.position.y+storeMenu.frame.size.height)/2
    
    invincibilityPowerup.zPosition             = storeMenu.zPosition+10;
    boostPowerup.zPosition                     = storeMenu.zPosition+10;
    lengthPowerup.zPosition                    = storeMenu.zPosition+10;
    lock.zPosition                             = storeMenu.zPosition+15;
    
    lock.color = [SKColor whiteColor];
    
    SKSpriteNode *lockCopy1 = lock.copy;
    SKSpriteNode *lockCopy2 = lock.copy;
    
    invincibilityPowerup.position              = CGPointMake(SELF_WIDTH/6, STORE_MENU_CENTER_Y);
    boostPowerup.position                      = CGPointMake(SELF_WIDTH/2, STORE_MENU_CENTER_Y);
    lengthPowerup.position                     = CGPointMake(5*SELF_WIDTH/6, STORE_MENU_CENTER_Y);
    lock.position                              = invincibilityPowerup.position;
    lockCopy1.position                         = boostPowerup.position;
    lockCopy2.position                         = lengthPowerup.position;
    
    invincibilityPowerup.alpha = 0;
    boostPowerup.alpha         = 0;
    lengthPowerup.alpha        = 0;
    lock.alpha                 = 0;
    lockCopy1.alpha            = 0;
    lockCopy2.alpha            = 0;
    
    lock.name = @"lock";
    lockCopy1.name = @"lock1";
    lockCopy2.name = @"lock2";
    
    unsigned long currentHighScore = [[dictionary valueForKey:@"High Score"] unsignedLongValue];
    
    [self runAction:[SKAction runBlock:^{[self addChild:storeMenu];}]            completion:^{
        
        [storeMenu runAction:[SKAction fadeInWithDuration:1.0]];
        
        [self runAction:[SKAction runBlock:^{
            
            [self addChild:invincibilityPowerup];
            if (currentHighScore < 100) {
                [self addChild:lock];}
        }]          completion:^{
            
            if (currentHighScore<100) {
                [lock runAction:[SKAction fadeAlphaTo:.75 duration:2.0]];
                [invincibilityPowerup runAction:[SKAction fadeAlphaTo:.5 duration:2.0]];
            }
            else [invincibilityPowerup runAction:[SKAction fadeInWithDuration:2.0]];
            
            [self runAction:[SKAction runBlock:^{
                
                if (currentHighScore < 250) {
                    [self addChild:lockCopy1];}
                [self addChild:boostPowerup];
            }]         completion:^{
                
                if (currentHighScore<250){
                    [lockCopy1 runAction:[SKAction fadeAlphaTo:.75 duration:3.0]];
                    [boostPowerup runAction:[SKAction fadeAlphaTo:.5 duration:3.0]];
                }
                else [boostPowerup runAction:[SKAction fadeInWithDuration:3.0]];
                
                [self runAction:[SKAction runBlock:^{
                    if (currentHighScore<50) {
                        [self addChild:lockCopy2];}
                    [self addChild:lengthPowerup];
                }]        completion:^{
                    
                    if (currentHighScore<50){
                        [lockCopy2 runAction:[SKAction fadeAlphaTo:.75 duration:4.0]];
                        [lengthPowerup runAction:[SKAction fadeAlphaTo:.5 duration:4.0]];
                    }
                    else [lengthPowerup runAction:[SKAction fadeInWithDuration:4.0]];
                    
                }];}];}];}];
    
    SKLabelNode *storeLabel = [SKLabelNode labelNodeWithFontNamed:@"Calibri"];
    storeLabel.position = CGPointMake(tempRect.origin.x+(tempRect.size.width/2), 1.2f*(STORE_MENU_CENTER_Y*2));
    storeLabel.text = @"Tap powerup to buy (MAX 5)";
    storeLabel.fontColor = [SKColor whiteColor];
    storeLabel.fontSize  = 25;
    storeLabel.zPosition = 31;
    storeLabel.name = @"Store Label";
    
    [self addChild:storeLabel];
    
    countOfInvincibilityNode.fontColor = [SKColor whiteColor];
    countOfInvincibilityNode.fontSize  = 20;
    countOfInvincibilityNode.position  = CGPointMake(invincibilityPowerup.position.x+invincibilityPowerup.size.width/2, invincibilityPowerup.position.y-invincibilityPowerup.size.height/2);
    countOfInvincibilityNode.zPosition = 31;
    countOfInvincibilityNode.name = @"Invincibility Count Node";
    countOfInvincibilityNode.text = [NSString stringWithFormat:@"%i",[[dictionary valueForKey:@"Invincibility Count"] intValue]];
    [self addChild:countOfInvincibilityNode];
    
    costOfInvincibilityNode = [SKLabelNode labelNodeWithFontNamed:@"Calibri"];
    if (aPoints >= 50) {
        costOfInvincibilityNode.fontColor = [SKColor whiteColor];
    }
    else costOfInvincibilityNode.fontColor = [SKColor redColor];
    costOfInvincibilityNode.fontSize = 20;
    costOfInvincibilityNode.position = CGPointMake(invincibilityPowerup.position.x, invincibilityPowerup.position.y+invincibilityPowerup.size.height*2/3);
    costOfInvincibilityNode.zPosition = 31;
    costOfInvincibilityNode.name = @"Invincibility Cost Node";
    costOfInvincibilityNode.text = [NSString stringWithFormat:@"$50"];
    
    countOfBoostNode.fontColor = [SKColor whiteColor];
    countOfBoostNode.fontSize  = 20;
    countOfBoostNode.position  = CGPointMake(boostPowerup.position.x+boostPowerup.size.width/2, boostPowerup.position.y-boostPowerup.size.height/2);
    countOfBoostNode.zPosition = 31;
    countOfBoostNode.name = @"Boost Count Node";
    countOfBoostNode.text = [NSString stringWithFormat:@"%i",[[dictionary valueForKey:@"Boost Count"] intValue]];
    
    [self addChild:countOfBoostNode];
    
    costOfBoostNode = [SKLabelNode labelNodeWithFontNamed:@"Calibri"];
    if (aPoints >= 100) {
        costOfBoostNode.fontColor = [SKColor whiteColor];
    }
    else costOfBoostNode.fontColor = [SKColor redColor];
    costOfBoostNode.fontSize = 20;
    costOfBoostNode.position = CGPointMake(boostPowerup.position.x, boostPowerup.position.y+boostPowerup.size.height*2/3);
    costOfBoostNode.zPosition = 31;
    costOfBoostNode.name = @"Boost Cost Node";
    costOfBoostNode.text = [NSString stringWithFormat:@"$100"];
    
    countOfLengthNode.fontColor = [SKColor whiteColor];
    countOfLengthNode.fontSize  = 20;
    countOfLengthNode.position  = CGPointMake(lengthPowerup.position.x+lengthPowerup.size.width/2, lengthPowerup.position.y-lengthPowerup.size.height/2);
    countOfLengthNode.zPosition = 31;
    countOfLengthNode.name = @"Length Count Node";
    countOfLengthNode.text = [NSString stringWithFormat:@"%i",[[dictionary valueForKey:@"Length Count"] intValue]];
    
    [self addChild:countOfLengthNode];
    
    costOfLengthNode = [SKLabelNode labelNodeWithFontNamed:@"Calibri"];
    if (aPoints >= 30) {
        costOfLengthNode.fontColor = [SKColor whiteColor];
    }
    else costOfLengthNode.fontColor = [SKColor redColor];
    costOfLengthNode.fontSize = 20;
    costOfLengthNode.position = CGPointMake(lengthPowerup.position.x, lengthPowerup.position.y+lengthPowerup.size.height*2/3);
    costOfLengthNode.zPosition = 31;
    costOfLengthNode.name = @"Length Cost Node";
    costOfLengthNode.text = [NSString stringWithFormat:@"$30"];
    
    [self runAction:[SKAction waitForDuration:2.5] completion:^{
        [self addChild:costOfInvincibilityNode];
        [self addChild:costOfBoostNode];
        [self addChild:costOfLengthNode];
    }];
    
    [storeLabel runAction:[SKAction fadeOutWithDuration:2] completion:^{
        [storeLabel runAction:[SKAction removeFromParent]];
    }];
    
#undef STORE_MENU_CENTER_Y
}

-(void)gameDidEndOptionsMenu{
    
    //*****************************//
    //   END GAME OPTIONS SCREEN   //
    //*****************************//
    
    SKLabelNode *restartButton = [SKLabelNode labelNodeWithFontNamed:@"00 Starmap Truetype"];
    restartButton.text         = @"Play Again";
    restartButton.zPosition    = 31;
    restartButton.fontColor    = [SKColor blueColor];
    restartButton.fontSize     = 30;
    restartButton.position     = CGPointMake(HALF_WIDTH, HALF_HEIGHT-50);
    restartButton.name         = @"restart_button";
    
    SKLabelNode *restartButtonShadow = restartButton.copy;
    restartButtonShadow.position = CGPointMake(restartButton.position.x+1, restartButton.position.y-1);
    restartButtonShadow.color = [SKColor colorWithRed:0 green:0 blue:.5 alpha:.1];
    
    SKLabelNode *mainMenuButton = [SKLabelNode labelNodeWithFontNamed:@"00 Starmap Truetype"];
    mainMenuButton.text         = @"Main Menu";
    mainMenuButton.zPosition    = 31;
    mainMenuButton.fontColor    = [SKColor blueColor];
    mainMenuButton.fontSize     = 30;
    mainMenuButton.position     = CGPointMake(HALF_WIDTH, HALF_HEIGHT - 85);
    mainMenuButton.name         = @"main_menu_button";
    
    SKLabelNode *mainMenuButtonShadow = mainMenuButton.copy;
    mainMenuButtonShadow.position = CGPointMake(mainMenuButton.position.x+1, mainMenuButton.position.y-1);
    mainMenuButtonShadow.color = [SKColor colorWithRed:0 green:0 blue:.5 alpha:.1];
    
    unsigned long updatedAveragePoints = [[dictionary valueForKey:@"Average Points"] unsignedLongValue];
    unsigned long score = (unsigned long)[scoreLabel.text intValue];
    
    SKLabelNode *newAveragePointsLabel = [SKLabelNode labelNodeWithFontNamed:@"00 Starmap Truetype"];
    newAveragePointsLabel.text = [NSString stringWithFormat:@"Average Points:"];
    newAveragePointsLabel.zPosition = 32;
    newAveragePointsLabel.fontColor = [SKColor whiteColor];
    newAveragePointsLabel.fontSize = 30;
    newAveragePointsLabel.position = CGPointMake(HALF_WIDTH, HALF_HEIGHT+25);
    newAveragePointsLabel.name = @"newAveragePointsLabel";
    
    SKSpriteNode *lineNode = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:CGSizeMake(newAveragePointsLabel.frame.size.width, 2)];
    lineNode.position = CGPointMake(HALF_WIDTH, newAveragePointsLabel.position.y-(newAveragePointsLabel.frame.size.height/2)+10);
    lineNode.zPosition = 33;
    
    averagePointsNumberLabel = [SKLabelNode labelNodeWithFontNamed:@"00 Starmap Truetype"];
    averagePointsNumberLabel.text = [NSString stringWithFormat:@"%lu",updatedAveragePoints];
    averagePointsNumberLabel.zPosition = 32;
    averagePointsNumberLabel.fontColor = [SKColor whiteColor];
    averagePointsNumberLabel.fontSize = 30;
    averagePointsNumberLabel.position = CGPointMake(HALF_WIDTH, HALF_HEIGHT -12.5f);
    averagePointsNumberLabel.name = @"Average Points Number Label";
    averagePointsNumberLabel.text = [NSString stringWithFormat:@"%lu", updatedAveragePoints - score];
    
    SKAction *wait = [SKAction waitForDuration:.1];
    SKAction *wait2 = [SKAction waitForDuration:.17];
    NSMutableArray *endGameActionsArray = [NSMutableArray array];
    
    for (int s = 0; s <20; s++) {
        double x = (updatedAveragePoints - score) + (s+1)*((double)score/20);
        unsigned long m = x;
        SKAction *blockAction = [SKAction runBlock:^{
            averagePointsNumberLabel.text = [NSString stringWithFormat:@"%lu",m];
        }];
        [endGameActionsArray addObject:blockAction];
        if (s<15) [endGameActionsArray addObject:wait];
        else if (s>=15) [endGameActionsArray addObject:wait2];
    }
    
    SKAction *animatePoints = [SKAction sequence:endGameActionsArray];
    
    SKLabelNode *finalScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"00 Starmap Truetype"];
    finalScoreLabel.text = [NSString stringWithFormat:@"Score: %lu",score];
    finalScoreLabel.zPosition = 33;
    finalScoreLabel.fontColor = [SKColor whiteColor];
    finalScoreLabel.fontSize = 30;
    finalScoreLabel.position = CGPointMake(HALF_WIDTH, HALF_HEIGHT+60);
    finalScoreLabel.name = @"finalScoreLabel";
    
    SKShapeNode *optionsMenu = [SKShapeNode node];
    
    CGRect    tempRect = CGRectMake(SELF_WIDTH/2, SELF_HEIGHT/2, SELF_WIDTH-20, (finalScoreLabel.position.y+(finalScoreLabel.frame.size.height/2)) - (mainMenuButton.position.y-(mainMenuButton.frame.size.height/2)) + 20);
    CGPathRef tempPath = CGPathCreateWithRoundedRect(CGRectMake(tempRect.origin.x - tempRect.size.width/2, tempRect.origin.y - tempRect.size.height/2, tempRect.size.width, tempRect.size.height), 5, 5, Nil);
    
    optionsMenu.path        = tempPath;
    optionsMenu.fillColor   = [SKColor grayColor];
    optionsMenu.strokeColor = [SKColor blueColor];
    optionsMenu.zPosition   = 30;
    optionsMenu.glowWidth   = 2.0f;
    
    CGPathRelease(tempPath);
    
    //******************************//
    //   ADD THE END GAME OPTIONS   //
    //******************************//
    
    [self addChild:optionsMenu];
    [self addChild:restartButton];
    [self addChild:restartButtonShadow];
    [self addChild:mainMenuButton];
    [self addChild:mainMenuButtonShadow];
    [self addChild:newAveragePointsLabel];
    [self addChild:finalScoreLabel];
    [self addChild:averagePointsNumberLabel];
    [self addChild:lineNode];
    [self runAction:[SKAction waitForDuration:.5] completion:^{
        [self runAction:animatePoints withKey:@"Animating Points"];
    }];
    
}

#pragma mark Handling Touches

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    /* Called when a touch begins */
    
    screenTouched = YES;
    
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    
    for (UITouch *touch in touches) {
        
        locationPressed  = [touch locationInNode:self];
        SKNode *tempNode = [self nodeAtPoint:locationPressed];
        
        //***//
        
        if (([tempNode.name isEqualToString:@"bought_boost_powerup"] || [tempNode.name isEqualToString:@"bought_invincibility_powerup"] || [tempNode.name isEqualToString:@"bought_length_powerup"]) && okayToSpawnPowerUp && !powerUpPickedUp) {
            
            if ([tempNode.name isEqualToString:@"bought_boost_powerup"] && okayToSpawnPowerUp) {
                
                dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:listPath];
                int boostCount = [[dictionary valueForKey:@"Boost Count"] intValue];
                if (boostCount > 0){
                    
                    [powerUp removeAllActions];
                    [powerUp removeFromParent];
                    [self.arrayOfPowerUps removeObject:powerUp];
                    [self pickedUpPowerUp:@"bought_boost"];
                    [boughtBoostPowerup runAction:[SKAction fadeOutWithDuration:.7]];
                    [countOfBoostNode runAction:[SKAction fadeOutWithDuration:.7]];
                    boostCount--;
                    [dictionary setValue:[NSNumber numberWithInt:boostCount] forKey:@"Boost Count"];
                    [dictionary writeToFile:listPath atomically:YES];
                    countOfBoostNode.text = [NSString stringWithFormat:@"%i",boostCount];
                    
                }
            }
            
            else if ([tempNode.name isEqualToString:@"bought_invincibility_powerup"] && okayToSpawnPowerUp) {
                
                dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:listPath];
                int invincibilityCount = [[dictionary valueForKey:@"Invincibility Count"] intValue];
                if (invincibilityCount > 0){
                    
                    [powerUp removeAllActions];
                    [powerUp removeFromParent];
                    [self.arrayOfPowerUps removeObject:powerUp];
                    [self pickedUpPowerUp:@"bought_invincibility"];
                    [boughtInvincibilityPowerup runAction:[SKAction fadeOutWithDuration:.7]];
                    [countOfInvincibilityNode runAction:[SKAction fadeOutWithDuration:.7]];
                    invincibilityCount--;
                    [dictionary setValue:[NSNumber numberWithInt:invincibilityCount] forKey:@"Invincibility Count"];
                    [dictionary writeToFile:listPath atomically:YES];
                    countOfInvincibilityNode.text = [NSString stringWithFormat:@"%i",invincibilityCount];
                }
            }
            
            else if ([tempNode.name isEqualToString:@"bought_length_powerup"] && okayToSpawnPowerUp) {
                
                dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:listPath];
                int lengthCount = [[dictionary valueForKey:@"Length Count"] intValue];
                if (lengthCount > 0){
                    
                    [powerUp removeAllActions];
                    [powerUp removeFromParent];
                    [self.arrayOfPowerUps removeObject:powerUp];
                    [self pickedUpPowerUp:@"bought_length"];
                    [boughtLengthPowerup runAction:[SKAction fadeOutWithDuration:.7]];
                    [countOfLengthNode runAction:[SKAction fadeOutWithDuration:.7]];
                    lengthCount--;
                    [dictionary setValue:[NSNumber numberWithInt:lengthCount] forKey:@"Length Count"];
                    [dictionary writeToFile:listPath atomically:YES];
                    countOfLengthNode.text = [NSString stringWithFormat:@"%i",lengthCount];
                }
            }
        }
        else {
            if (locationPressed.x >= HALF_WIDTH) {
                screenTouchedRight = YES;
                screenTouchedLeft  = NO;
            }
            else if (locationPressed.x < HALF_WIDTH) {
                screenTouchedLeft  = YES;
                screenTouchedRight = NO;
            }
            
        }
        
        //***//
        
        if ([tempNode.name isEqualToString:@"invincibility_powerup"]) {
            dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:listPath];
            int invCount = [[dictionary valueForKey:@"Invincibility Count"] intValue];
            unsigned long averagePoints = [[dictionary valueForKey:@"Average Points"] unsignedLongValue];
            if (invCount<5 && averagePoints >= 50) {
                invCount++;
                averagePoints -= 50;
                [dictionary setValue:[NSNumber numberWithUnsignedLong:averagePoints] forKey:@"Average Points"];
                [dictionary setValue:[NSNumber numberWithInt:invCount] forKeyPath:@"Invincibility Count"];
                [dictionary writeToFile:listPath atomically:YES];
                [self updateCountNodes:countOfInvincibilityNode];
                [self updateCostColors];
            }
            [dictionary setValue:[NSNumber numberWithInt:invCount] forKey:@"Invincibility Count"];
            [dictionary writeToFile:listPath atomically:YES];
        }
        
        if ([tempNode.name isEqualToString:@"boost_powerup"]) {
            dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:listPath];
            int booCount = [[dictionary valueForKey:@"Boost Count"] intValue];
            unsigned long averagePoints = [[dictionary valueForKey:@"Average Points"] unsignedLongValue];
            if (booCount<5 && averagePoints >= 100) {
                booCount++;
                averagePoints -= 100;
                [dictionary setValue:[NSNumber numberWithInt:booCount] forKey:@"Boost Count"];
                [dictionary setValue:[NSNumber numberWithUnsignedLong:averagePoints] forKey:@"Average Points"];
                [dictionary writeToFile:listPath atomically:YES];
                [self updateCountNodes:countOfBoostNode];
                [self updateCostColors];
            }
            [dictionary setValue:[NSNumber numberWithInt:booCount] forKey:@"Boost Count"];
            [dictionary writeToFile:listPath atomically:YES];
            
        }
        
        if ([tempNode.name isEqualToString:@"length_powerup"]) {
            dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:listPath];
            int lenCount = [[dictionary valueForKey:@"Length Count"] intValue];
            unsigned long averagePoints = [[dictionary valueForKey:@"Average Points"] unsignedLongValue];
            if (lenCount<5 && averagePoints >= 30) {
                lenCount++;
                averagePoints -= 30;
                [dictionary setValue:[NSNumber numberWithInt:lenCount] forKey:@"Length Count"];
                [dictionary setValue:[NSNumber numberWithUnsignedLong:averagePoints] forKey:@"Average Points"];
                [dictionary writeToFile:listPath atomically:YES];
                [self updateCountNodes:countOfLengthNode];
                [self updateCostColors];
            }
            [dictionary setValue:[NSNumber numberWithInt:lenCount] forKey:@"Length Count"];
            [dictionary writeToFile:listPath atomically:YES];
            
        }
        
        if ([tempNode.name isEqualToString:@"restart_button"]) {
            
            [self removeAllChildren];
            [self removeAllActions];
            
            [playThemeSong stop];
            
            screenTouched      = NO;
            screenTouchedLeft  = NO;
            screenTouchedRight = NO;
            self.gameEnded     = NO;
            nodesAreSpawning   = NO;
            
            
            for (SKSpriteNode *tempSpriteNode in self.arrayOfObstacles) {
                [tempSpriteNode removeFromParent];
            }
            
            for (SKSpriteNode *tempSpriteNode in self.arrayOfPowerUps) {
                [tempSpriteNode removeFromParent];
            }
            
            [self.arrayOfObstacles removeAllObjects];
            [self.arrayOfPowerUps  removeAllObjects];
            [self createInitialContentsOnScreen];
            
        }
        
        if([tempNode.name isEqualToString:@"main_menu_button"]){
            
            MainMenuScene *mainMenuScene   = [[MainMenuScene alloc] initWithSize:self.size];
            SKTransition *transition       = [SKTransition pushWithDirection:SKTransitionDirectionDown duration:0.7];
            transition.pausesIncomingScene = NO;
            
            [playThemeSong stop];
            
            //optional
            [self removeAllChildren];
            [self removeAllActions];
            
            for (SKSpriteNode *tempSpriteNode in self.arrayOfObstacles) {
                [tempSpriteNode removeFromParent];
            }
            
            for (SKSpriteNode *tempSpriteNode in self.arrayOfPowerUps) {
                [tempSpriteNode removeFromParent];
            }
            
            [self.arrayOfObstacles removeAllObjects];
            [self.arrayOfPowerUps removeAllObjects];
            
            mainMenuScene.playButton.hidden = YES;
            
            [self.view presentScene:mainMenuScene transition:transition];
            
            mainMenuScene.playButton.hidden = NO;
            
        }
        
        if ([tempNode.name isEqualToString:@"pauseButton"]) {
            
            if (!gameIsPaused) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"pauseGame" object:nil];
                
            }
            else if (gameIsPaused) {
                
                if (pauseAnimation == NO) {
                    pauseAnimation = YES;
                    
                    //SKAction *fall = [SKAction sequence:actionsArrayForNode];
                    
                    [soundSwitch removeFromSuperview];
                    soundSwitch.hidden = YES;
                    
                    SKNode *removeable = [self childNodeWithName:@"removeMe1"];
                    [removeable removeFromParent];
                    removeable = [self childNodeWithName:@"removeMe2"];
                    [removeable removeFromParent];
                    removeable = [self childNodeWithName:@"Exit Button"];
                    [removeable removeFromParent];
                    
                    SKLabelNode *countDown = [SKLabelNode labelNodeWithFontNamed:@"Calibri"];
                    countDown.text = @"3";
                    countDown.fontColor = [SKColor whiteColor];
                    countDown.fontSize = 40;
                    countDown.position = CGPointMake(HALF_WIDTH, HALF_HEIGHT);
                    
                    [self runAction:[SKAction runBlock:^{[self addChild:countDown];}] completion:^{
                        [self runAction:[SKAction waitForDuration:1] completion:^{
                            countDown.text = @"2";
                            [self runAction:[SKAction waitForDuration:1] completion:^{
                                countDown.text = @"1";
                                [self runAction:[SKAction waitForDuration:1] completion:^{
                                    [playThemeSong play];
                                    
                                    for (SKSpriteNode *tempNode in self.arrayOfObstacles) {
                                        [[tempNode actionForKey:@"falling"] setSpeed:1.0f];
                                    }
                                    for (SKSpriteNode *tempNode in self.arrayOfPowerUps) {
                                        [[tempNode actionForKey:@"falling"] setSpeed:1.0f];
                                    }
                                    [self enumerateChildNodesWithName:@"scoreNode" usingBlock:^(SKNode *node, BOOL *stop){
                                        SKSpriteNode *myScoreNode = (SKSpriteNode *)node;
                                        [[myScoreNode actionForKey:@"falling"] setSpeed:1.0f];
                                    }];
                                    averageGuy.paused = NO;
                                    self.smokeTrail.paused = NO;
                                    
                                    averageGuy.physicsBody.velocity = agVelocity;
                                    gameIsPaused = NO;
                                    pauseAnimation = NO;
                                    okayToHitPause = NO;
                                    
                                    [countDown removeFromParent];
                                    
                                    [self runAction:[SKAction waitForDuration:.75f] completion:^{ // Wait for duration is set to the minimum possible (tested)
                                        okayToHitPause = YES;
                                    }];
                                }];
                            }];
                        }];
                    }];
                }
                
            }
            
            [soundSwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
            
        }
        
        if ([tempNode.name isEqualToString:@"lock"] && displayingLabel == NO) {
            
            displayingLabel = YES;
            
            SKLabelNode *tempLabel = [SKLabelNode labelNodeWithFontNamed:@"Calibri"];
            tempLabel.text = @"Reach a Score of 100 to unlock";
            tempLabel.fontColor = [SKColor redColor];
            tempLabel.fontSize = 20;
            tempLabel.position = CGPointMake(HALF_WIDTH, HALF_HEIGHT*5/11);
            
            [self addChild:tempLabel];
            
            SKAction *move = [SKAction moveBy:CGVectorMake(750, 0) duration:1];
            SKAction *wait = [SKAction waitForDuration:.5];
            SKAction *fade = [SKAction fadeOutWithDuration:.2];
            SKAction *remove = [SKAction removeFromParent];
            
            [tempLabel runAction:wait completion:^{
                [tempLabel runAction:move];
                [tempLabel runAction:fade completion:^{
                    [tempLabel runAction:remove];
                    displayingLabel = NO;
                }];
            }];
            
        }
        
        if ([tempNode.name isEqualToString:@"lock1"] && displayingLabel == NO) {
            
            displayingLabel = YES;
            
            SKLabelNode *tempLabel = [SKLabelNode labelNodeWithFontNamed:@"Calibri"];
            tempLabel.text = @"Reach a Score of 250 to unlock";
            tempLabel.fontColor = [SKColor redColor];
            tempLabel.fontSize = 20;
            tempLabel.position = CGPointMake(HALF_WIDTH, HALF_HEIGHT*5/11);
            
            [self addChild:tempLabel];
            
            SKAction *move = [SKAction moveBy:CGVectorMake(750, 0) duration:1];
            SKAction *wait = [SKAction waitForDuration:.5];
            SKAction *fade = [SKAction fadeOutWithDuration:.2];
            SKAction *remove = [SKAction removeFromParent];
            
            [tempLabel runAction:wait completion:^{
                [tempLabel runAction:move];
                [tempLabel runAction:fade completion:^{
                    [tempLabel runAction:remove];
                    displayingLabel = NO;
                }];
            }];
            
        }
        
        if ([tempNode.name isEqualToString:@"lock2"] && displayingLabel == NO) {
            
            displayingLabel = YES;
            
            SKLabelNode *tempLabel = [SKLabelNode labelNodeWithFontNamed:@"Calibri"];
            tempLabel.text = @"Reach a Score of 50 to unlock";
            tempLabel.fontColor = [SKColor redColor];
            tempLabel.fontSize = 20;
            tempLabel.position = CGPointMake(HALF_WIDTH, HALF_HEIGHT*5/11);
            
            [self addChild:tempLabel];
            
            SKAction *move = [SKAction moveBy:CGVectorMake(750, 0) duration:1];
            SKAction *wait = [SKAction waitForDuration:.5];
            SKAction *fade = [SKAction fadeOutWithDuration:.2];
            SKAction *remove = [SKAction removeFromParent];
            
            [tempLabel runAction:wait completion:^{
                [tempLabel runAction:move];
                [tempLabel runAction:fade completion:^{
                    [tempLabel runAction:remove];
                    displayingLabel = NO;
                }];
            }];
            
        }
        
    }
    
}

-(void)changeSwitch:(id)sender{
    if([sender isOn]){
        [playThemeSong setVolume: 1];
        NSLog(@"Sound is ON");
        [dictionary setValue:[NSNumber numberWithBool:1] forKey:@"Music Sounds"];
        [dictionary writeToFile:listPath atomically:YES];
        
    } else if (![sender isOn]){
        [playThemeSong setVolume: 0];
        NSLog(@"Sound is OFF");
        [dictionary setValue:[NSNumber numberWithBool:0] forKey:@"Music Sounds"];
        [dictionary writeToFile:listPath atomically:YES];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        locationPressed = [touch locationInNode:self];
        if (locationPressed.x > HALF_WIDTH) {
            screenTouchedRight = YES;
            screenTouchedLeft  = NO;
        }
        else if (locationPressed.x < HALF_WIDTH) {
            screenTouchedLeft  = YES;
            screenTouchedRight = NO;
        }
    }
    
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    screenTouched = NO;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    screenTouched = NO;
}

#pragma mark Updates

-(void)update:(CFTimeInterval)currentTime {
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > spawnSeconds) {
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    
    
    if (averageGuy.position.x <= -(averageGuy.frame.size.width/2+1)) {
        averageGuy.position = CGPointMake(SELF_WIDTH+averageGuy.frame.size.width/2-1, averageGuy.position.y);
    }
    if (averageGuy.position.x >= (SELF_WIDTH+averageGuy.frame.size.width/2+1)) {
        averageGuy.position = CGPointMake(-(averageGuy.frame.size.width/2-1), averageGuy.position.y);
    }
    
    if (screenTouched == YES && !gameIsPaused) {
        
        averageGuy.physicsBody.friction = 0.0f;
        
        if (screenTouchedRight == YES && screenTouchedLeft == NO) {
            
            
            if (boostPickedUp == NO) {
                averageGuy.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"agRight"]];
            }
            [averageGuy.physicsBody applyForce:CGVectorMake(70.0f, 0.0f)];
            
        }
        else if (screenTouchedRight == NO && screenTouchedLeft == YES) {
            
            if (boostPickedUp == NO) {
                averageGuy.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"agLeft"]];
            }
            [averageGuy.physicsBody applyForce:CGVectorMake(-70.0f, 0.0f)];
            
            
        }
        else {
            //error occured with touches - reset touches to no
            screenTouched      = NO;
            screenTouchedLeft  = NO;
            screenTouchedRight = NO;
        }
    }
    
    if (averageGuy.physicsBody.velocity.dx > 2 && !screenTouched) {
        averageGuy.physicsBody.velocity = CGVectorMake(averageGuy.physicsBody.velocity.dx - 2, 0);
    }
    else if (averageGuy.physicsBody.velocity.dx < -2 && !screenTouched) {
        averageGuy.physicsBody.velocity = CGVectorMake(averageGuy.physicsBody.velocity.dx + 2, 0);
    }
    
    if (averageGuy.physicsBody.velocity.dx > 300) {
        averageGuy.physicsBody.velocity = CGVectorMake(300, 0.0f);
    }
    else if (averageGuy.physicsBody.velocity.dx < -300) {                   //Maximum speed here
        averageGuy.physicsBody.velocity = CGVectorMake(-300, 0.0f);
    }
    if (powerUpPickedUp) {
        [self removeChildrenInArray:self.arrayOfPowerUps];
    }
    if (boostPickedUp) {
        self.smokeTrail.position = averageGuy.position;
    }
    
}

-(void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    if (!gameIsPaused) self.lastSpawnTimeInterval += timeSinceLast;
    self.lastSpawnTimeInterval1 += timeSinceLast;
    if (self.lastSpawnTimeInterval > spawnSeconds) {
        self.lastSpawnTimeInterval = 0;
        if (nodesAreSpawning == YES && !gameIsPaused) {
            [self spawnObstaclesAndPowerUps];
        }
    }
    if (self.lastSpawnTimeInterval1 > 0.25f) {
        self.lastSpawnTimeInterval1 = 0;
        if (!self.gameEnded) {
            [self spawnBackgroundNodes];
        }
    }
}

-(void)updateCostColors{
    
    listPath = [[self docsDir] stringByAppendingPathComponent:@"POL.plist"];
    dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:listPath];
    
    unsigned long aPoints = [[dictionary valueForKey:@"Average Points"] unsignedLongValue];
    
    if (aPoints >= 100) {
        costOfLengthNode.fontColor = [SKColor whiteColor];
        costOfInvincibilityNode.fontColor = [SKColor whiteColor];
        costOfBoostNode.fontColor = [SKColor whiteColor];
    }
    else if (aPoints >= 50) {
        costOfBoostNode.fontColor = [SKColor redColor];
        costOfLengthNode.fontColor = [SKColor whiteColor];
        costOfInvincibilityNode.fontColor = [SKColor whiteColor];
    }
    else if (aPoints >= 30) {
        costOfBoostNode.fontColor = [SKColor redColor];
        costOfLengthNode.fontColor = [SKColor redColor];
        costOfInvincibilityNode.fontColor = [SKColor whiteColor];
    }
    else {
        costOfBoostNode.fontColor = [SKColor redColor];
        costOfLengthNode.fontColor = [SKColor redColor];
        costOfInvincibilityNode.fontColor = [SKColor redColor];
    }
    
}

-(void)updateCountNodes:(SKLabelNode *)nodeToUpdate{
    
    dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:listPath];
    
    unsigned long aPoints = [[dictionary valueForKey:@"Average Points"] unsignedLongValue];
    
    SKLabelNode *copyOfNode = [nodeToUpdate copy];
    SKLabelNode *copyOfPointsNode = averagePointsNumberLabel.copy;
    
    
    if ([nodeToUpdate.name isEqualToString:@"Invincibility Count Node"]) {
        copyOfNode.text = @"+1";
        copyOfNode.zPosition = nodeToUpdate.zPosition + 100;
        [self addChild:copyOfNode];
        countOfInvincibilityNode.text = [NSString stringWithFormat:@"%lu",(unsigned long)[[dictionary valueForKey:@"Invincibility Count"] unsignedLongValue]];
        copyOfPointsNode.text = @"-50";
        copyOfPointsNode.fontColor = [SKColor redColor];
        copyOfPointsNode.zPosition = averagePointsNumberLabel.zPosition + 100;
        [self addChild:copyOfPointsNode];
        [self removeActionForKey:@"Animating Points"];
        averagePointsNumberLabel.text = [NSString stringWithFormat:@"%lu", aPoints];
        
    }
    if ([nodeToUpdate.name isEqualToString:@"Boost Count Node"]) {
        copyOfNode.text = @"+1";
        copyOfNode.zPosition = nodeToUpdate.zPosition + 100;
        [self addChild:copyOfNode];
        countOfBoostNode.text = [NSString stringWithFormat:@"%lu",(unsigned long)[[dictionary valueForKey:@"Boost Count"] unsignedLongValue]];
        copyOfPointsNode.text = @"-100";
        copyOfPointsNode.fontColor = [SKColor redColor];
        copyOfPointsNode.zPosition = averagePointsNumberLabel.zPosition + 100;
        [self addChild:copyOfPointsNode];
        [self removeActionForKey:@"Animating Points"];
        averagePointsNumberLabel.text = [NSString stringWithFormat:@"%lu", aPoints];
        
    }
    if ([nodeToUpdate.name isEqualToString:@"Length Count Node"]) {
        copyOfNode.text = @"+1";
        copyOfNode.zPosition = nodeToUpdate.zPosition + 100;
        [self addChild:copyOfNode];
        countOfLengthNode.text = [NSString stringWithFormat:@"%lu",(unsigned long)[[dictionary valueForKey:@"Length Count"] unsignedLongValue]];
        copyOfPointsNode.text = @"-30";
        copyOfPointsNode.fontColor = [SKColor redColor];
        copyOfPointsNode.zPosition = averagePointsNumberLabel.zPosition + 100;
        [self addChild:copyOfPointsNode];
        [self removeActionForKey:@"Animating Points"];
        averagePointsNumberLabel.text = [NSString stringWithFormat:@"%lu", aPoints];
        
    }
    
    SKAction *fadeOut = [SKAction fadeOutWithDuration:3];
    SKAction *glideUp = [SKAction moveBy:CGVectorMake(0.0f, 150.0f) duration:5];
    SKAction *remove = [SKAction removeFromParent];
    
    [copyOfNode runAction:fadeOut];
    [copyOfNode runAction:glideUp completion:^{
        [copyOfNode runAction:remove];
    }];
    [copyOfPointsNode runAction:fadeOut];
    [copyOfPointsNode runAction:glideUp completion:^{
        [copyOfPointsNode runAction:remove];
    }];
}

#pragma mark plist Methods

-(NSString *)docsDir{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

-(void)UpdatePlist{
    
    listPath = [[self docsDir] stringByAppendingPathComponent:@"POL.plist"];
    dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:listPath];
    
    unsigned long storedHighScore = [[dictionary valueForKey:@"High Score"] unsignedLongValue];
    unsigned long currentScore = [scoreLabel.text integerValue];
    
    unsigned long updatedAveragePoints = [[dictionary valueForKey:@"Average Points"] unsignedLongValue]+currentScore;
    [dictionary setValue:[NSNumber numberWithUnsignedLong:updatedAveragePoints] forKey:@"Average Points"];
    
    if (currentScore>storedHighScore) {
        [dictionary setValue:[NSNumber numberWithUnsignedLong:currentScore] forKey:@"High Score"];
    }
    [dictionary writeToFile:listPath atomically:YES];
}


#pragma mark powerUp Methods

-(void)spawnPowerUp{
    
    powerUp       = [SKSpriteNode node];
    powerUp.size  = CGSizeMake(45.0f, 45.0f);
    
    BOOL spawn = YES;
    
    for (SKSpriteNode *powerUpNode in self.arrayOfPowerUps) {
        if (powerUpNode.position.y > 0) {
            spawn = NO;
        }
    }
    
    if (spawn) powerUpSwitch = arc4random() % 3;
    
    switch (powerUpSwitch) {
        case RED_COLOR_INT:
            powerUp.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"invincibilityPowerup"]];
            break;
            
        case BLUE_COLOR_INT:
            powerUp.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"boostPowerup"]];
            break;
            
        case GREEN_COLOR_INT:
            powerUp.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"length"]];
            break;
            
        default:
            break;
    }
    powerUp.position = CGPointMake((node1.position.x+node2.position.x)/2, SELF_HEIGHT);
    powerUp.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:35];
    powerUp.physicsBody.affectedByGravity  = NO;
    powerUp.physicsBody.categoryBitMask    = powerUpCategory;
    powerUp.physicsBody.contactTestBitMask = averageGuyCategory | boundsCategory;
    powerUp.physicsBody.collisionBitMask   = 0;
    powerUp.zPosition                      = node1.zPosition;
    powerUp.name                           = @"lol3";
    
    SKAction *moveOneLeft  = [SKAction moveByX:-5.0f y:-(SELF_HEIGHT/40) duration:1.6/40];
    SKAction *moveTwoRight = [SKAction moveByX:10.0f y:-(SELF_HEIGHT/20) duration:1.6/20];
    
    NSArray *powerUpMoveDown = [NSArray arrayWithObjects:moveOneLeft, moveTwoRight, moveOneLeft, nil];
    
    SKAction *moveDown = [SKAction repeatAction:[SKAction sequence:powerUpMoveDown] count:10];
    SKAction *removeFromParent = [SKAction removeFromParent];
    
    NSArray *powerUpMoveDownAndRemove = [NSArray arrayWithObjects:moveDown, removeFromParent, nil];
    
    SKAction *moveDownAndRemove = [SKAction sequence:powerUpMoveDownAndRemove];
    
    [self.arrayOfPowerUps addObject:powerUp];
    
    if (okayToSpawnPowerUp && spawn) {
        [self addChild:powerUp];
        [powerUp runAction:moveDownAndRemove withKey:@"falling"];
    }
}

-(void)pickedUpPowerUp: (NSString *) reasonForPowerup{
    powerUpPickedUp = YES;
    okayToSpawnPowerUp = NO;
    
    if ([reasonForPowerup isEqualToString:@"random"]) {
        
        switch (powerUpSwitch) {
            case RED_COLOR_INT:
                [self invincibilityPickedUp];
                break;
                
            case BLUE_COLOR_INT:
                [self boostPickedUp];
                break;
                
            case GREEN_COLOR_INT:
                [self lengthPickedUp];
                break;
                
            default:
                break;
        }
        
    } else if ([reasonForPowerup isEqualToString:@"bought_boost"]){
        
        [self boostPickedUp];
        
    } else if ([reasonForPowerup isEqualToString:@"bought_invincibility"]){
        
        [self invincibilityPickedUp];
        
    } else if ([reasonForPowerup isEqualToString:@"bought_length"]){
        
        [self lengthPickedUp];
        
    }
    
    
}

-(void)invincibilityPickedUp {
    
    averageGuy.physicsBody.contactTestBitMask = 0;
    SKAction *fadeOut = [SKAction fadeOutWithDuration:.2];
    SKAction *fadeIn = [SKAction fadeInWithDuration:.2];
    SKAction *fadeOutX2 = [SKAction fadeOutWithDuration:.09];
    SKAction *fadeInX2  = [SKAction fadeInWithDuration:.09];
    NSMutableArray *tempArray = [NSMutableArray arrayWithObjects:fadeOut, fadeIn, nil];
    
    [averageGuy runAction:[SKAction repeatActionForever:[SKAction sequence:tempArray]] withKey:@"runningNow"];
    tempArray = [NSMutableArray arrayWithObjects:fadeOutX2, fadeInX2, nil];
    [averageGuy runAction:[SKAction waitForDuration:3] completion:^{
        [averageGuy removeActionForKey:@"runningNow"];
        [averageGuy runAction:[SKAction repeatActionForever:[SKAction sequence:tempArray]] withKey:@"runningX2Now"];
        [averageGuy runAction:[SKAction waitForDuration:1.7] completion:^{
            averageGuy.alpha = 1;
            averageGuy.physicsBody.contactTestBitMask = obstacleCategory | powerUpCategory;
            [averageGuy removeActionForKey:@"runningX2Now"];
            [boughtInvincibilityPowerup runAction:[SKAction fadeInWithDuration:.5] completion:^{
                powerUpPickedUp = NO;
                okayToSpawnPowerUp = YES;
            }];
            [countOfInvincibilityNode runAction:[SKAction fadeInWithDuration:.5]];
        }];
    }];
}

-(void)boostPickedUp {
    
    boostPickedUp = YES;
    averageGuy.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"agUp"]];
    averageGuy.physicsBody.contactTestBitMask = 0;
    SKAction *boostedMoveDown = [SKAction moveByX:0.0f y:-(SELF_HEIGHT) duration:0.5f];
    [actionsArrayForNode setObject:boostedMoveDown atIndexedSubscript:0];
    SKAction *boostAction = [SKAction sequence:actionsArrayForNode];
    spawnSeconds = 0.3f;
    
    for (SKSpriteNode *__temp__ in self.arrayOfObstacles) {
        [__temp__ removeAllActions];
        [__temp__ runAction:boostAction];
    }
    
    [self addChild:self.smokeTrail];
    [averageGuy runAction:[SKAction waitForDuration:4.7] completion:^{
        powerUpPickedUp = NO;
        spawnSeconds = 0.6f;
        averageGuy.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"agUp"]];
        [self.smokeTrail runAction:[SKAction fadeOutWithDuration:.5] completion:^{
            [self.smokeTrail runAction:[SKAction removeFromParent]];
            NSString *smokePath = [[NSBundle mainBundle] pathForResource:@"smokeParticle" ofType:@"sks"];
            self.smokeTrail = [NSKeyedUnarchiver unarchiveObjectWithFile:smokePath];
            self.smokeTrail.position = averageGuy.position;
            self.smokeTrail.zPosition = averageGuy.zPosition-10;
        }];
        
        [averageGuy runAction:[SKAction waitForDuration:.5] completion:^{
            [countOfBoostNode runAction:[SKAction fadeInWithDuration:.5]];
            [boughtBoostPowerup runAction:[SKAction fadeInWithDuration:.5] completion:^{
                if (!powerUpPickedUp) {
                    averageGuy.physicsBody.contactTestBitMask = obstacleCategory | powerUpCategory;
                }
                okayToSpawnPowerUp = YES;
                boostPickedUp = NO;
            }];
        }];
    }];
}

-(void)lengthPickedUp{
    
    lengthPowerUpIsActive = YES;
    okayToSpawnPowerUp    = NO;
    spawnSeconds = .6f;
    
    for(SKSpriteNode *obstacle in self.arrayOfObstacles){
        
        if (obstacle.position.x < HALF_WIDTH) {
            [obstacle runAction:[SKAction moveBy:CGVectorMake(-50, 0) duration:1]];
            
        }
        else if (obstacle.position.x > HALF_WIDTH){
            [obstacle runAction:[SKAction moveBy:CGVectorMake(50, 0) duration:1]];
        }
        
    }
    
    [averageGuy runAction:[SKAction waitForDuration:5] completion:^{
        
        lengthPowerUpIsActive = NO;
        powerUpPickedUp       = NO;
        okayToSpawnPowerUp    = YES;
        [boughtLengthPowerup runAction:[SKAction fadeInWithDuration:.5] completion:^{
        }];
        [countOfLengthNode runAction:[SKAction fadeInWithDuration:.5]];
    }];
    
}

#pragma mark Pause

- (void)handleNotification:(NSNotification *)notification
{
    if ([notification.name isEqualToString:@"pauseGame"]) {
        if (!gameIsPaused && okayToHitPause) {
            if (!self.gameEnded) {
                
                agVelocity = averageGuy.physicsBody.velocity;
                averageGuy.physicsBody.velocity = CGVectorMake(0, 0);
                
                gameIsPaused = YES;
                [self.view addSubview:soundSwitch];
                soundSwitch.hidden = NO;
                [playThemeSong pause];
                
                for (SKSpriteNode *tempNode in self.arrayOfObstacles) {
                    [[tempNode actionForKey:@"falling"] setSpeed:0.0f];
                }
                for (SKSpriteNode *tempNode in self.arrayOfPowerUps) {
                    [[tempNode actionForKey:@"falling"] setSpeed:0.0f];
                }
                [self enumerateChildNodesWithName:@"scoreNode" usingBlock:^(SKNode *node, BOOL *stop){
                    SKSpriteNode *myScoreNode = (SKSpriteNode *)node;
                    [[myScoreNode actionForKey:@"falling"] setSpeed:0.0f];
                }];
                averageGuy.paused = YES;
                self.smokeTrail.paused = YES;
                
                SKShapeNode *optionsMenu;
                SKLabelNode *soundOptionsNode;
                
                optionsMenu = [SKShapeNode node];
                CGRect    tempRect     = CGRectMake(2, 2, SELF_WIDTH-4, SELF_HEIGHT/4);
                CGPathRef tempPath     = CGPathCreateWithRoundedRect(tempRect, 5, 5, Nil);
                
                optionsMenu.path        = tempPath;
                optionsMenu.fillColor   = [SKColor blackColor];
                optionsMenu.strokeColor = [SKColor colorWithRed:0 green:255/255.0f blue:127/255.0f alpha:1];
                optionsMenu.glowWidth   = 2.0f;
                optionsMenu.zPosition   = 20;
                optionsMenu.position    = CGPointMake(HALF_WIDTH-optionsMenu.frame.size.width/2, HALF_HEIGHT-optionsMenu.frame.size.height/2);
                CGPathRelease(tempPath);
                optionsMenu.name = @"removeMe1";
                
                soundOptionsNode = [SKLabelNode labelNodeWithFontNamed:@"Calibri"];
                soundOptionsNode.position = CGPointMake(3*HALF_WIDTH/7, HALF_HEIGHT - 7);
                soundOptionsNode.text = @"Music/Sounds";
                soundOptionsNode.fontColor = [SKColor whiteColor];
                soundOptionsNode.fontSize = 17;
                soundOptionsNode.zPosition = 100;
                soundOptionsNode.name = @"removeMe2";
                
                [self addChild:optionsMenu];
                [self addChild:soundOptionsNode];
            }
        }
    }
}

@end

