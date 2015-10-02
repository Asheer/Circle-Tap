//
//  GameScene.m
//  BoxTap
//
//  Created by Final on 9/26/15.
//  Copyright (c) 2015 Asheer Tanveer. All rights reserved.
//

#import "GameScene.h"
#import "UIColor+FlatUI.h"
#import <AVFoundation/AVFoundation.h>

SKLabelNode *scoreLabel;
SKLabelNode *retryLabel;
SKLabelNode *highScoreLabel;
int score;
SKShapeNode *shape;
SKShapeNode *shape2;
float x,y;
BOOL gameover,doubleCircle;
NSInteger bestScore;
AVAudioPlayer *player;
AVAudioPlayer *gameOverPlayer;
@implementation GameScene


-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    self.backgroundColor = [SKColor blackColor];
    gameover = NO;
    doubleCircle = NO;
    score = 0;
    scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"TimesNewRomanPSMT-Bold"];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480)
        {
            // iPhone Classic
            scoreLabel.position = CGPointMake(320, self.frame.size.height - 35);

            
        } else {
            scoreLabel.position = CGPointMake(350, self.frame.size.height - 35);
        }
        
    }
    scoreLabel.zPosition = 4;
    scoreLabel.text = @"Score : 0";
    scoreLabel.color = [SKColor whiteColor];
    scoreLabel.fontSize = 20;
    [self addChild:scoreLabel];
    
    shape = [SKShapeNode node];
    CGRect rect = CGRectMake(0, 0, 60, 60);
    shape.path = [self circleInRect:rect];
    shape.strokeColor = [SKColor greenColor];
    shape.fillColor = [SKColor blueColor];
        float newY = arc4random() % (int)[UIScreen mainScreen].bounds.size.height + 20;
        shape.position = CGPointMake(self.frame.size.width/2,newY);
    [self addChild:shape];

    bestScore = [[NSUserDefaults standardUserDefaults] integerForKey: @"highScore"];
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"tap" ofType:@"wav"]];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    
    
    NSURL *urlGameOver = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"gameover" ofType:@"wav"]];
    gameOverPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:urlGameOver error:nil];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        if(([shape containsPoint:location] || [shape2 containsPoint:location]) && gameover == NO) {
            
            [player play];
            ++score;
           // score = 13;
            scoreLabel.text = [NSString stringWithFormat:@"Score : %d",score];
            
            if([shape containsPoint:location]) {
                float newX = arc4random_uniform([UIScreen mainScreen].bounds.size.width + 25);
                float newY = arc4random_uniform([UIScreen mainScreen].bounds.size.height + scoreLabel.position.y);

                [shape removeFromParent];
                shape.fillColor = [UIColor blueColor];
                shape.position = CGPointMake(newX,newY);
                [self addChild:shape];
            }
            
            if(score == 12) {
                doubleCircle = YES;
                
                shape2 = [SKShapeNode node];
                CGRect rect2 = CGRectMake(0, 0, 40, 40);
                shape2.path = [self circleInRect:rect2];
                shape2.strokeColor = [SKColor blackColor];
                shape2.fillColor = [SKColor orangeColor];
                float newY2 = arc4random() % (int)[UIScreen mainScreen].bounds.size.height + 100;
                shape2.position = CGPointMake(self.frame.size.width/4,newY2);
                [self addChild:shape2];
            }
            
            if([shape2 containsPoint:location]) {
                float newX = arc4random_uniform([UIScreen mainScreen].bounds.size.width + 60);
                float newY = arc4random_uniform([UIScreen mainScreen].bounds.size.height + scoreLabel.position.y * 1.5);
                
                [shape2 removeFromParent];
                shape2.fillColor = [UIColor blueColor];
                shape2.position = CGPointMake(newX,newY);
                [self addChild:shape2];
            }

        }
        /*
        else {
            // gameover sound
            
            if(!gameover)
                	[gameOverPlayer play];
            
            gameover = YES;

            [shape removeFromParent];
            [shape2 removeFromParent];
            
            SKShapeNode *shape = [SKShapeNode node];
            CGRect rect = CGRectMake(0, 0, 100, 100);
            shape.path = [self circleInRect:rect];
            shape.strokeColor = [SKColor blackColor];
            shape.fillColor = [SKColor redColor];
            shape.position = CGPointMake(500, 500);
            [self addChild:shape];
            
            if(score > bestScore) {
                bestScore = score;
                [self saveScore];
            }
            
            highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Superclarendon-Regular"];
            highScoreLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height /2);
            highScoreLabel.zPosition = 4;
            highScoreLabel.text = [NSString stringWithFormat:@"High Score: %ld",(long)bestScore];;
            highScoreLabel.fontColor = [SKColor redColor];
            highScoreLabel.fontSize = 60;
            
            [self addChild:highScoreLabel];
            
            retryLabel = [SKLabelNode labelNodeWithFontNamed:@"Superclarendon-Regular"];
            retryLabel.position = CGPointMake(self.frame.size.width/2, highScoreLabel.position.y - 60);
            retryLabel.zPosition = 4;
            retryLabel.text = @"Retry";
            retryLabel.fontColor = [SKColor redColor];
            retryLabel.fontSize = 40;
            
            [self addChild:retryLabel];
        } */
        
        if([retryLabel containsPoint:location] && gameover == YES) {
          [self removeAllChildren];
            score = 0;
          [self didMoveToView:self.view];
            gameover = NO;
        }
    }
}
-(void)saveScore {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:bestScore forKey:@"highScore"];
    [defaults synchronize];
}

- (CGPathRef) circleInRect:(CGRect)rect
{
    // Adjust position so path is centered in shape
    CGRect adjustedRect = CGRectMake(rect.origin.x-rect.size.width/2, rect.origin.y-rect.size.height/2, rect.size.width, rect.size.height);
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithOvalInRect:adjustedRect];

    return bezierPath.CGPath;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    if(gameover == NO) {
        CGFloat oldX = shape.position.x;
        CGFloat oldY = shape.position.y;
        
        CGFloat newX;
        CGFloat newY;
        CGFloat newX2;
        CGFloat newY2;
        
            if(score <= 5) {
            newX = oldX+= 4;
            newY = oldY +=4;
        } else if(score > 4 && score < 12) {
            self.backgroundColor = [SKColor yellowColor];
            scoreLabel.fontColor = [SKColor blackColor];
            shape.fillColor = [UIColor whiteColor];
            newX = oldX+=6;
            newY = oldY+=6;
        } else if(score >= 12 && score <14) {
            self.backgroundColor = [SKColor purpleColor];
            shape.fillColor = [UIColor yellowColor];
            scoreLabel.fontColor = [SKColor whiteColor];
         //   newX = arc4random() % (int)[UIScreen mainScreen].bounds.size.width + 60;
            newY = oldY +=2.0;
            newX = newY +=1.5;
        } else if(score >=14 && score <= 20) {
            self.backgroundColor = [SKColor belizeHoleColor];
            shape.fillColor = [UIColor pumpkinColor];
            newX = oldX+= 8;
            newY = oldY+=7.5;
        } else {
            self.backgroundColor = [SKColor brownColor];
            shape.fillColor = [UIColor redColor];
            newX = oldX+= 10.5;
            newY = oldY+=9.5;
            
        }
    
    CGPoint newLocation = CGPointMake(newX,newY);
    shape.position = newLocation;
    	
        if(score >=12 && score < 17 && doubleCircle == YES) {
            CGFloat oldX2 = shape2.position.x;
            CGFloat oldY2 = shape2.position.y;
            
            newX2 = oldX2+= 3.5;
            newY2 = oldY2+=4.5;
            CGPoint newLocation2 = CGPointMake(newX2,newY2);
            shape2.position = newLocation2;
        }
        if(score >=17 && doubleCircle == YES) {
            CGFloat oldX2 = shape2.position.x;
            CGFloat oldY2 = shape2.position.y;
            shape2.fillColor = [SKColor blueColor];

            newX2 = oldX2+=5.5;
            newY2 = oldY2+=7.5;
            CGPoint newLocation2 = CGPointMake(newX2,newY2);
            shape2.position = newLocation2;
        }
        
    
        
        if (!CGRectIntersectsRect(self.frame, shape.frame) || (!CGRectIntersectsRect(self.frame, shape2.frame))) {   // Outside the bounds of the scene because the frames are no longer intersecting.

        NSLog(@"outside lol");
        if(score <= 15) {
            float newX = arc4random_uniform([UIScreen mainScreen].bounds.size.width + 40);
            float newY = arc4random_uniform([UIScreen mainScreen].bounds.size.height + scoreLabel.position.y + 20);
            shape.position = CGPointMake(newX,newY);

        } else if(score > 15) {
            
            float newX = arc4random_uniform([UIScreen mainScreen].bounds.size.width + 80);
            float newY = arc4random_uniform([UIScreen mainScreen].bounds.size.height + 100);

            shape.position = CGPointMake(newX,newY);

        }
    }
        
        if ((!CGRectIntersectsRect(self.frame, shape2.frame))) {   // Outside the bounds of the scene because the frames are no longer intersecting.
            
            if(doubleCircle == YES) {
                
                float newX = arc4random_uniform([UIScreen mainScreen].bounds.size.width + 80);
                float newY = arc4random_uniform([UIScreen mainScreen].bounds.size.height + 120);
                
                shape2.position = CGPointMake(newX,newY);
            }
        }

    }
}

@end
