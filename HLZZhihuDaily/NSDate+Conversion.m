//
//  NSDate+Conversion.m
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 7/29/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import "NSDate+Conversion.h"
#import "objc/runtime.h"

@interface NSDate ()

@property (nonatomic, readonly, strong, getter=hlz_dateFormatter) NSDateFormatter *dateFormatter;

@end

@implementation NSDate (Conversion)

- (NSString *)hlz_stringWithFormat:(NSString *)format {
    self.dateFormatter.dateFormat = format;
    return [self.dateFormatter stringFromDate:self];
}

- (NSString *)hlz_stringWithFormat:(NSString *)format locale:(NSString *)locale {
    self.dateFormatter.dateFormat = format;
    self.dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:locale];
    return [self.dateFormatter stringFromDate:self];
}

- (NSDateFormatter *)hlz_dateFormatter {
    NSDateFormatter *formatter = objc_getAssociatedObject(self, @selector(hlz_dateFormatter));
    
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        
        // Default values.
        formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"zh_CN"];
        formatter.dateFormat = @"yyyyMMdd";
        
        objc_setAssociatedObject(self, @selector(hlz_dateFormatter), formatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return formatter;
}

@end
