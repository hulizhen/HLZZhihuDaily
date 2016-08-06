//
//  NSDate+HLZConversion.m
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 7/29/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import "NSDate+HLZConversion.h"

@implementation NSDate (HLZConversion)

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *formatter = nil;
    
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        
        // Default values.
        formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"zh_CN"];
        formatter.dateFormat = @"yyyyMMdd";
    }
    return formatter;
}

+ (NSDate *)hlz_dateFromString:(NSString *)string format:(NSString *)format {
    [NSDate dateFormatter].dateFormat = format;
    return [[NSDate dateFormatter] dateFromString:string];
}

- (NSString *)hlz_stringWithFormat:(NSString *)format {
    [NSDate dateFormatter].dateFormat = format;
    return [[NSDate dateFormatter] stringFromDate:self];
}

@end
