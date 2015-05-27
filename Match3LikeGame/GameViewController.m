//
//  GameViewController.m
//  Match3LikeGame
//
//  Created by Андрей Щербинин on 27.05.15.
//  Copyright (c) 2015 Андрей Щербинин. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "Level.h"

@interface GameViewController ()
@property (strong, nonatomic) GameScene *scene;
@property (strong, nonatomic) Level *level;
@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    
    
    skView.multipleTouchEnabled = NO;
    
    // Create and configure the scene.
    self.scene = [GameScene sceneWithSize:skView.bounds.size];
    self.scene.scaleMode = SKSceneScaleModeAspectFill;
    
    self.level = [[Level alloc] initWithFile:@"Level_1"];
    self.scene.level=self.level;
    [self.scene addTiles];
    
    id block = ^(Swap *swap)
    {
        self.view.userInteractionEnabled = NO;
        if([self.level isPossibleSwaps:swap])
        {
        [self.level performSwap:swap];
        [self.scene animateSwap:swap completion:^
         {
             self.view.userInteractionEnabled =YES;
         }];
        }
        else
        {
            [self.scene animateInvalidSwap:swap completion:^{
                self.view.userInteractionEnabled =YES;
            }];
        }
    };
    
    self.scene.swipeHandler = block;
    
    // Present the scene.
    [skView presentScene:_scene];
    
    [self beginGame];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
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

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)beginGame
{
    [self shuffle];
}

-(void) shuffle
{
    NSSet *newGems = [self.level shuffle];
    [self.scene addSpriteForGems:newGems];
}

@end
