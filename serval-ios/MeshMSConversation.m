//
//  MeshMSConversation.m
//  serval-ios
//
//  Created by Jonas Höchst on 01.02.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

#import "MeshMSConversation.h"

@implementation MeshMSConversation

-(id) init{
    if(!(self = [super init]))
        return nil;
    
    self.messages = [[NSMutableArray alloc] init];
    
    return self;
}

@end
