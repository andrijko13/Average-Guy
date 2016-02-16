//
//  TutorialScene.m
//  Average Guy
//
//  Created by Boss on 2014-08-16.
//  Copyright (c) 2014 DropGeeks. All rights reserved.
//

#import "TutorialScene.h"

@interface TutorialScene ()
{
   
    SKSpriteNode *Screen;
    SKSpriteNode *Movement;
    SKSpriteNode *Currency;
    SKSpriteNode *PowerUps;
    
    SKLabelNode *redX;
    
}

@end

@implementation TutorialScene

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor blackColor];
        
        [self createOrDestroyRedX:@"create"];
        [self createInitialContentsOnScreen];
        
    }
    return self;
    
}

-(void)createOrDestroyRedX:(NSString *)operation{
    if([operation isEqualToString:@"create"]){
        
        redX = [SKLabelNode labelNodeWithFontNamed:@"Calibri"];
        redX.name = @"redX";
        redX.fontColor = [SKColor redColor];
        redX.fontSize  = 35;
        redX.text = @"X";
        redX.position = CGPointMake(redX.frame.size.width-5, self.size.height-redX.frame.size.height-10);
        redX.zPosition = 150;
        redX.hidden = NO;
        
        [self addChild:redX];
        
    }
    else if([operation isEqualToString:@"destroy"]){
        
        [redX removeFromParent];
        
        [Screen removeFromParent];
        [Movement removeFromParent];
        [Currency removeFromParent];
        [PowerUps removeFromParent];
        
        MainMenuScene  *mainScene = [[MainMenuScene alloc] initWithSize: self.size];
        SKTransition *transition = [SKTransition pushWithDirection:SKTransitionDirectionUp duration:0.7];
        transition.pausesIncomingScene = NO;
        
        [self.view presentScene:mainScene transition:transition];

        
    }
}

-(void)createInitialContentsOnScreen{
    
    SKTexture *Screen1Texture  = [SKTexture textureWithImageNamed:@"photo1.png"];
    SKTexture *Screen2Texture  = [SKTexture textureWithImageNamed:@"photo2.png"];
    SKTexture *Screen3Texture  = [SKTexture textureWithImageNamed:@"photo3.png"];
    SKTexture *MovementTexture = [SKTexture textureWithImageNamed:@"Movement"];
    SKTexture *CurrencyTexture = [SKTexture textureWithImageNamed:@"Currency"];
    SKTexture *PowerUpsTexture = [SKTexture textureWithImageNamed:@"PowerUps"];

    Screen   = [SKSpriteNode spriteNodeWithTexture:Screen1Texture];
    Movement = [SKSpriteNode spriteNodeWithTexture:MovementTexture];
    Currency = [SKSpriteNode spriteNodeWithTexture:CurrencyTexture];
    PowerUps = [SKSpriteNode spriteNodeWithTexture:PowerUpsTexture];
    
    [Movement setScale:0.7];
    [Currency setScale:0.7];
    [PowerUps setScale:0.7];
    [Screen setScale:.37];
    
    Movement.position = CGPointMake(self.frame.size.width/2+10, SELF_HEIGHT-Movement.size.height/2-2);
    Currency.position = CGPointMake(self.frame.size.width/2+10, SELF_HEIGHT-Currency.size.height/2-2);
    PowerUps.position = CGPointMake(self.frame.size.width/2+10, SELF_HEIGHT-PowerUps.size.height/2-2);
    Screen.position   = CGPointMake(self.frame.size.width/2, Movement.position.y-Movement.size.height/2-2-Screen.size.height/2);
    
    PowerUps.zPosition = Screen.zPosition+10;
    
    SKAction *fadeOut          = [SKAction fadeOutWithDuration:1.5];
    SKAction *fadeIn           = [SKAction fadeInWithDuration:1.5];
    SKAction *removeFromParent = [SKAction removeFromParent];
    SKAction *pause            = [SKAction waitForDuration:5];
    SKAction *swithTexture     = [SKAction runBlock:^{ if(Screen.texture == Screen1Texture) /*then*/ Screen.texture = Screen2Texture;
                                                  else if(Screen.texture == Screen2Texture) /*then*/ Screen.texture = Screen3Texture;
                                                  else if(Screen.texture == Screen3Texture) /*then*/ Screen.texture = Screen1Texture;}];
    
    SKAction *move = [SKAction sequence:[NSMutableArray arrayWithObjects: fadeIn, pause, fadeOut, removeFromParent, nil]];
    SKAction *animate = [SKAction sequence:[NSMutableArray arrayWithObjects:fadeIn, pause, fadeOut, swithTexture, nil]];
    
    [self addChild:Movement];
    [self addChild:Currency];
    [self addChild:PowerUps];
    [self addChild:Screen];
    
    Movement.alpha = 0;
    Currency.alpha = 0;
    PowerUps.alpha = 0;
    Screen.alpha   = 0;
    
    [self runAction:[SKAction runBlock:^{
        Screen.position   = CGPointMake(self.frame.size.width/2, Movement.position.y-Movement.size.height/2-2-Screen.size.height/2);
        [Screen runAction:animate];
        [Movement runAction:move completion:^{
            Screen.position   = CGPointMake(self.frame.size.width/2, Currency.position.y-Currency.size.height/2-2-Screen.size.height/2);
            [Screen runAction:animate];
            [Currency runAction:move completion:^{
                Screen.position   = CGPointMake(self.frame.size.width/2, PowerUps.position.y-PowerUps.size.height/2-2-Screen.size.height/2);
                [Screen setScale:.35];
                [Screen runAction:animate];
                [PowerUps runAction:move completion:^{
                    [Screen removeFromParent];
                    [self createInitialContentsOnScreen];}];}];}];}]];
    
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        
        CGPoint locationPressed  = [touch locationInNode:self];
        SKNode *tempNode = [self nodeAtPoint:locationPressed];
        
        if ([tempNode.name isEqualToString:@"redX"]) {
            [self createOrDestroyRedX:@"destroy"];
        }
        
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
}

-(void)update:(CFTimeInterval)currentTime {
    
}

@end
