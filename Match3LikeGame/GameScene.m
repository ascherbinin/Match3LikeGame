//
//  GameScene.m
//  Match3LikeGame
//
//  Created by Андрей Щербинин on 27.05.15.
//  Copyright (c) 2015 Андрей Щербинин. All rights reserved.
//

#import "GameScene.h"
#import "Level.h"
#import "Gem.h"
#import "Swap.h"

static const CGFloat TileWidth = 32.0;
static const CGFloat TileHeight = 36.0;

@interface GameScene()
@property (strong, nonatomic) SKNode *gameLayer;
@property (strong, nonatomic) SKNode *gemsLayer;
@property (strong, nonatomic) SKNode *tilesLayer;

@property(assign, nonatomic) NSInteger swipeFromColumn;
@property(assign, nonatomic) NSInteger swipeFromRow;

@property(strong,nonatomic) SKSpriteNode *selectedSprite;



@end

@implementation GameScene

-(id) initWithSize:(CGSize)size{
    if((self =[super initWithSize:size]))
    {
        self.anchorPoint = CGPointMake(0.5, 0.5);
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"Background"];
        
        self.gameLayer = [SKNode node];
        [self addChild:self.gameLayer];
        
        CGPoint layerPosition = CGPointMake(-TileWidth*NumColumns/2, -TileHeight*NumRows/2);
        
        self.gemsLayer = [SKNode node];
        self.gemsLayer.position = layerPosition;
        
        self.tilesLayer = [SKNode node];
        self.tilesLayer.position = layerPosition;
        [self.gameLayer addChild:self.tilesLayer];
        
        [self.gameLayer addChild:self.gemsLayer];
        
        [self addChild:background];
        
        self.swipeFromColumn = self.swipeFromRow = NSNotFound;
        
        self.selectedSprite = [SKSpriteNode node];
    }
    return  self;
}

-(void) addSpriteForGems:(NSSet *)gems
{
    for (Gem *gem in gems) {
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:[gem spriteName]];
        sprite.position = [self pointForColumn:gem.column row:gem.row];
        [self.gemsLayer addChild:sprite];
        gem.sprite = sprite;
    }
    
    
}

-(void)addTiles
{
    for (NSInteger row = 0; row < NumRows; row++) {
        for (NSInteger column = 0; column< NumColumns; column++) {
            if([self.level tileAtColumn:column row:row]!=nil)
            {
                SKSpriteNode *tileNode = [SKSpriteNode spriteNodeWithImageNamed:@"Tile"];
                tileNode.position = [self pointForColumn:column row:row];
                [self.tilesLayer addChild:tileNode];
            }
        }
    }
}

-(CGPoint)pointForColumn:(NSInteger)column row:(NSInteger)row
{
    return CGPointMake(column*TileWidth+TileWidth/2, row*TileHeight +TileHeight/2);
}

#pragma Touches Area

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self.gemsLayer];
    
    NSInteger column,row;
    
    if([self convertPoint:location toColumn:&column row:&row])
    {
        Gem *gem  = [self.level gemAtColumn:column row:row];
        if(gem !=nil)
        {
            [self showSelectionIndicatorForGem:gem];
            self.swipeFromColumn = column;
            self.swipeFromRow = row;
        }
    }
}

-(BOOL) convertPoint:(CGPoint)point toColumn:(NSInteger*)column row:(NSInteger*)row
{
    NSParameterAssert(column);
    NSParameterAssert(row);
    
    if(point.x >=0 && point.x <NumColumns*TileWidth &&
       point.y >= 0 && point.y< NumRows*TileHeight)
    {
        *column = point.x/TileWidth;
        *row = point.y/TileHeight;
        return YES;
    }
    else
    {
        *column = NSNotFound;
        *row = NSNotFound;
        return NO;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.swipeFromColumn == NSNotFound) return;
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:[self gemsLayer]];
    
    NSInteger column, row;
    
    if([self convertPoint:location toColumn:&column row:&row])
    {
        NSInteger horzDelta = 0, vertDelta=0;
        if(column < self.swipeFromColumn)
        {
            horzDelta = -1;
        }
        else if (column >self.swipeFromColumn)
        {
            horzDelta = 1;
        }
        else if(row <self.swipeFromRow)
        {
            vertDelta = -1;
        }
        else if(row>self.swipeFromRow)
        {
            vertDelta = 1;
        }
        
        if(horzDelta !=0 || vertDelta !=0)
        {
            [self trySwapHorizontal: horzDelta vertical: vertDelta];
            [self hideSelectionIndicator];
            self.swipeFromColumn = NSNotFound;
        }
    }
}

-(void) trySwapHorizontal:(NSInteger)horzDelta vertical:(NSInteger)vertDelta
{
    NSInteger toColumn = self.swipeFromColumn+horzDelta;
    NSInteger toRow = self.swipeFromRow+vertDelta;
    
    if(toColumn <0 || toColumn >=NumColumns) return;
    if(toRow <0 || toRow >=NumRows) return;
    
    Gem *toGem = [self.level gemAtColumn:toColumn row:toRow];
    if (toGem==nil) {
        return;
    }
    Gem *fromGem = [self.level gemAtColumn:self.swipeFromColumn row:self.swipeFromRow];
    
    if(self.swipeHandler !=nil)
    {
        Swap *swap = [Swap new];
        swap.gemA = fromGem;
        swap.gemB = toGem;
        self.swipeHandler(swap);
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.selectedSprite.parent !=nil && self.swipeFromColumn !=NSNotFound)
    {
        [self hideSelectionIndicator];
    }
    
    self.swipeFromColumn = self.swipeFromRow = NSNotFound;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

#pragma Animation and Graphic Area

-(void) animateSwap:(Swap*) swap completion:(dispatch_block_t)completion
{
    swap.gemA.sprite.zPosition = 100;
    swap.gemB.sprite.zPosition = 90;
    
    const NSTimeInterval Duration = 0.3;
    SKAction *moveA = [SKAction moveTo:swap.gemB.sprite.position duration:Duration];
    moveA.timingMode = SKActionTimingEaseOut;
    [swap.gemA.sprite runAction:[SKAction sequence:@[moveA, [SKAction runBlock:completion]]]];
    
    SKAction *moveB = [SKAction moveTo:swap.gemA.sprite.position duration:Duration];
    moveB.timingMode = SKActionTimingEaseOut;
    [swap.gemB.sprite runAction:moveB];
}

- (void)animateInvalidSwap:(Swap *)swap completion:(dispatch_block_t)completion {
    swap.gemA.sprite.zPosition = 100;
    swap.gemB.sprite.zPosition = 90;
    
    const NSTimeInterval Duration = 0.2;
    
    SKAction *moveA = [SKAction moveTo:swap.gemB.sprite.position duration:Duration];
    moveA.timingMode = SKActionTimingEaseOut;
    
    SKAction *moveB = [SKAction moveTo:swap.gemA.sprite.position duration:Duration];
    moveB.timingMode = SKActionTimingEaseOut;
    
    [swap.gemA.sprite runAction:[SKAction sequence:@[moveA, moveB, [SKAction runBlock:completion]]]];
    [swap.gemB.sprite runAction:[SKAction sequence:@[moveB, moveA]]];
}

-(void) showSelectionIndicatorForGem:(Gem*)gem
{
    if(self.selectedSprite != nil)
    {
        [self.selectedSprite removeFromParent];
    }
    SKTexture *texture = [SKTexture textureWithImageNamed:[gem hightlightedSpriteName]];
    self.selectedSprite.size = texture.size;
    [self.selectedSprite runAction:[SKAction setTexture:texture]];
    
    [gem.sprite addChild:self.selectedSprite];
    self.selectedSprite.alpha = 1.0;
}

-(void)hideSelectionIndicator
{
    [self.selectedSprite runAction:[SKAction sequence:@[
                                                        [SKAction fadeOutWithDuration:0.3],
                                                        [SKAction removeFromParent]]
                                    ]];
}

@end
