//
//  Gem.m
//  Match3LikeGame
//
//  Created by Андрей Щербинин on 27.05.15.
//  Copyright (c) 2015 Андрей Щербинин. All rights reserved.
//

#import "Gem.h"

@implementation Gem

-(NSString*)spriteName
{
    static NSString* const spriteNames[] =
    {
        @"Croissant",
        @"Cupcake",
        @"Danish",
        @"Donut",
        @"Macaroon",
        @"SugarCookie",
    };
    
    return spriteNames[self.gemType-1];
}

-(NSString*) hightlightedSpriteName
{
    static NSString* const highlightedSpriteNames[] =
    {
        @"Croissant-Highlighted",
        @"Cupcake-Highlighted",
        @"Danish-Highlighted",
        @"Donut-Highlighted",
        @"Macaroon-Highlighted",
        @"SugarCookie-Highlighted",
    };
    return highlightedSpriteNames[self.gemType-1];
}

-(NSString*) description
{
    return [NSString stringWithFormat:@"Тип блока:%ld, Позиция(Колонка, Строка)(%ld,%ld)",(long)self.gemType,(long)self.column,(long)self.row];
}

@end
