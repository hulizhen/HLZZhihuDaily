//
//  NSDate+Conversion.h
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 7/29/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Conversion)

- (NSString *)hlz_stringWithFormat:(NSString *)format;
- (NSString *)hlz_stringWithFormat:(NSString *)format locale:(NSString *)locale;

@end
