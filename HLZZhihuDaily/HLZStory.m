//
//  HLZStory.m
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 6/2/16.
//  Copyright © 2016 hulz. All rights reserved.
//

#import "HLZStory.h"
#import "Constants.h"

@interface HLZStory ()


@end

@implementation HLZStory


- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _gaPrefix = dictionary[@"ga_prefix"];
        _id       = dictionary[@"id"];
        _title    = dictionary[@"title"];
        _type     = dictionary[@"type"];
        
        NSString *urlString = dictionary[@"images"] ? dictionary[@"images"][0] : dictionary[@"image"];
        _imageURL = [NSURL URLWithString:urlString];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[id:%@] [%@]", self.id, self.title];
}

@end
