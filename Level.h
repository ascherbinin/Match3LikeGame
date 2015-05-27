//
//  Level.h
//  Match3LikeGame
//
//  Created by Андрей Щербинин on 27.05.15.
//  Copyright (c) 2015 Андрей Щербинин. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Gem.h"
#import "Tile.h"
#import "Swap.h"

static const NSInteger NumColumns = 9;
static const NSInteger NumRows = 9;


@interface Level : NSObject

-(NSSet* ) shuffle;

-(Gem*)gemAtColumn:(NSInteger)column row:(NSInteger)row;

-(id)initWithFile:(NSString*) filename;
-(Tile*)tileAtColumn:(NSInteger)column row:(NSInteger) row;

-(void)performSwap:(Swap*) swap;
-(BOOL)isPossibleSwaps:(Swap*)swap;

@end
