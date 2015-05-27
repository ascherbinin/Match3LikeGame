//
//  Swap.m
//  Match3LikeGame
//
//  Created by Андрей Щербинин on 27.05.15.
//  Copyright (c) 2015 Андрей Щербинин. All rights reserved.
//

#import "Swap.h"
#import "Gem.h"

@implementation Swap



-(NSString *)description
{
    return [NSString stringWithFormat:@"%@ swap %@ with %@",[super description],self.gemA, self.gemB];
}

-(BOOL) isEqual:(id)object
{
    if(![object isKindOfClass:[Swap class]]) return NO;
    
    Swap *other = (Swap*)object;
    return (other.gemA == self.gemA && other.gemB == self.gemB) ||(other.gemB == self.gemA && other.gemA == self.gemB);
}

-(NSUInteger)hash
{
    return [self.gemA hash] ^ [self.gemB hash];
}
@end
