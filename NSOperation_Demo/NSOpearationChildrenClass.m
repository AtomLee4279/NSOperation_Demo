//
//  NSOpearationChildrenClass.m
//  NSOperation_Demo
//
//  Created by 李一贤 on 2019/7/12.
//  Copyright © 2019 李一贤. All rights reserved.
//

#import "NSOpearationChildrenClass.h"

@implementation NSOpearationChildrenClass

-(void)main {
    
    if (!self.isCancelled) {
        for (int i = 0; i<2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"NSOpearationChildrenClass---%@",[NSThread currentThread]);
        }
    }
    
}

@end
