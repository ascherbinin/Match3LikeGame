//
//  GameScene.h
//  Match3LikeGame
//

//  Copyright (c) 2015 Андрей Щербинин. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Swap.h"

@class Level;

@interface GameScene : SKScene

@property(strong, nonatomic) Level *level;
@property(copy, nonatomic) void (^swipeHandler)(Swap *swap);

-(void) addSpriteForGems:(NSSet*) gems;
-(void) addTiles;
-(void) animateSwap:(Swap*) swap completion:(dispatch_block_t)completion;
- (void)animateInvalidSwap:(Swap *)swap completion:(dispatch_block_t)completion;

@end
