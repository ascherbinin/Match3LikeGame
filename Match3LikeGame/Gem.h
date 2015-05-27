//
//  Gem.h
//  Match3LikeGame
//
//  Created by Андрей Щербинин on 27.05.15.
//  Copyright (c) 2015 Андрей Щербинин. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

static const NSUInteger NumGemsTypes = 6;

@interface Gem : NSObject

@property(assign, nonatomic) NSInteger column;
@property(assign, nonatomic) NSInteger row;
@property(assign, nonatomic) NSUInteger gemType;
@property(strong, nonatomic) SKSpriteNode *sprite;

-(NSString*) spriteName;
-(NSString*) hightlightedSpriteName;

@end
