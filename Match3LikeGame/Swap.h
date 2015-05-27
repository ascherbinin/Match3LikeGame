//
//  Swap.h
//  Match3LikeGame
//
//  Created by Андрей Щербинин on 27.05.15.
//  Copyright (c) 2015 Андрей Щербинин. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Gem.h"


@interface Swap : NSObject

@property(strong,nonatomic) Gem *gemA;
@property(strong,nonatomic) Gem *gemB;

@end
