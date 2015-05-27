//
//  Level.m
//  Match3LikeGame
//
//  Created by Андрей Щербинин on 27.05.15.
//  Copyright (c) 2015 Андрей Щербинин. All rights reserved.
//

#import "Level.h"

@interface Level()

@property (strong,nonatomic) NSSet *possibleSwaps;

@end

@implementation Level
{
    Gem *_gems[NumColumns][NumRows];
    Tile *_tiles[NumColumns][NumRows];
}

-(Gem*) gemAtColumn:(NSInteger)column row:(NSInteger)row
{
    NSAssert1(column >=0 && column < NumColumns, @"Invalid column: %ld",(long)column);
    NSAssert1(row>=0 && row<NumRows, @"Invalid row:%ld",(long)row);
    
    return _gems[column][row];
}

-(NSSet*) shuffle
{
    NSSet *set;
    do
    {
        set = [self createInitialGems];
        
        [self detectPossibleSwaps];
        
        NSLog(@"Возможные перемещения: %@", self.possibleSwaps);
    }
    while([self.possibleSwaps count] ==0);
    
    
    return set;
}

-(NSSet*) createInitialGems
{
    NSMutableSet *set = [NSMutableSet set];
    
    for (NSInteger row = 0; row <NumRows; row++) {
        for (NSInteger column = 0; column<NumColumns; column++) {
            if(_tiles[column][row] !=nil)
            {

                NSUInteger gemType;
                do {
                    gemType = arc4random_uniform(NumGemsTypes) +1;
                }
                while ((column >=2 &&
                        _gems[column-1][row].gemType == gemType &&
                        _gems[column - 2][row].gemType == gemType)
                       ||
                       (row >=2 &&
                        _gems[column][row-1].gemType == gemType &&
                        _gems[column][row-2].gemType ==gemType));
                
            Gem *gem = [self createGemAtColumn:column row:row withType:gemType];
            
            [set addObject:gem];
                
            }
        }
    }
    return set;
}

-(Gem*) createGemAtColumn:(NSInteger) column row:(NSInteger)row withType:(NSUInteger)gemType
{
    Gem *gem = [Gem new];
    gem.gemType = gemType;
    gem.column = column;
    gem.row = row;
    
    _gems[column][row] = gem;
    
    return gem;
}


#pragma Region Load Json

-(NSDictionary*) loadJSON:(NSString*)filename
{
    NSString* path = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];
    if(path == nil)
    {
        NSLog(@"Не найден файл уровня: %@", filename);
        return  nil;
    }
    
    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:path options:0 error:&error];
    if(data == nil)
    {
        NSLog(@"Не получилось загрузить уровень: %@, ошибка: %@",filename,error);
        return  nil;
    }
    
    NSDictionary *dictionary  = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if(dictionary==nil || ![dictionary isKindOfClass:[NSDictionary class]])
    {
        NSLog(@"Фаил уровня '%@' не соответствует JSON файлу: %@",filename,error);
        return  nil;
    }
    
    return dictionary;
        
}

-(id)initWithFile:(NSString *)filename
{
    self = [super init];
    if(self !=nil)
    {
        NSDictionary *dictionary = [self loadJSON:filename];
        
        [dictionary[@"tiles"] enumerateObjectsUsingBlock:^(NSArray *array, NSUInteger row, BOOL *stop) {
            [array enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger column, BOOL *stop) {
                NSInteger tileRow = NumRows-row-1;
                if([value integerValue] ==1)
                {
                    _tiles[column][tileRow] = [Tile new];
                }
            }];
        }];
    }
         return  self;
}

-(Tile*)tileAtColumn:(NSInteger)column row:(NSInteger)row
{
    NSAssert1(column>=0 && column<NumColumns, @"Не правильная колонка: %ld", (long)column);
    NSAssert1(row>=0 && row<NumRows, @"Не правильная строка: %ld", (long)row);
    
    return _tiles[column][row];
}

-(void) performSwap:(Swap *)swap
{
    NSInteger columnA = swap.gemA.column;
    NSInteger rowA = swap.gemA.row;
    NSInteger columnB = swap.gemB.column;
    NSInteger rowB = swap.gemB.row;
    
    _gems[columnA][rowA] = swap.gemB;
    swap.gemB.column = columnA;
    swap.gemB.row = rowA;
    
    _gems[columnB][rowB] = swap.gemA;
    swap.gemA.column = columnB;
    swap.gemA.row = rowB;
    
    
}

#pragma Swap Detect Area

- (BOOL)hasChainAtColumn:(NSInteger)column row:(NSInteger)row {
    NSUInteger gemType = _gems[column][row].gemType;
    
    NSUInteger horzLength = 1;
    for (NSInteger i = column - 1; i >= 0 && _gems[i][row].gemType == gemType; i--, horzLength++) ;
    for (NSInteger i = column + 1; i < NumColumns && _gems[i][row].gemType == gemType; i++, horzLength++) ;
    if (horzLength >= 3) return YES;
    
    NSUInteger vertLength = 1;
    for (NSInteger i = row - 1; i >= 0 && _gems[column][i].gemType == gemType; i--, vertLength++) ;
    for (NSInteger i = row + 1; i < NumRows && _gems[column][i].gemType == gemType; i++, vertLength++) ;
    return (vertLength >= 3);
}

-(void) detectPossibleSwaps
{
    NSMutableSet *set = [NSMutableSet set];
    
    for (NSInteger row = 0; row < NumRows; row++) {
        for (NSInteger column = 0; column<NumColumns; column++) {
            Gem *gem = _gems[column][row];
            if(gem !=nil)
            {
                if(column <NumColumns-1)
                {
                    Gem *other = _gems[column+1][row];
                    if(other !=nil)
                    {
                        _gems[column][row] = other;
                        _gems[column+1][row] = gem;
                        
                        if([self hasChainAtColumn:column +1 row:row] || [self hasChainAtColumn:column row:row])
                        {
                            Swap *swap = [Swap new];
                            swap.gemA = gem;
                            swap.gemB = other;
                            [set addObject:swap];
                        }
                        
                        _gems[column][row] = gem;
                        _gems[column+1][row] = other;
                    }
                }
                
                if (row < NumRows - 1) {
                    
                    Gem *other = _gems[column][row + 1];
                    if (other != nil) {
                        // Swap them
                        _gems[column][row] = other;
                        _gems[column][row + 1] = gem;
                        
                        if ([self hasChainAtColumn:column row:row + 1] ||
                            [self hasChainAtColumn:column row:row]) {
                            
                            Swap *swap = [Swap new];
                            swap.gemA = gem;
                            swap.gemB = other;
                            [set addObject:swap];
                        }
                        
                        _gems[column][row] = gem;
                        _gems[column][row + 1] = other;
                    }
                }
            }
        }
    }
    self.possibleSwaps = set;
}

-(BOOL)isPossibleSwaps:(Swap*)swap
{
    return [self.possibleSwaps containsObject:swap];
}

@end
