//
//  Story.h
//  oZhihuDaily
//
//  Created by Hu Lizhen on 6/2/16.
//  Copyright © 2016 hulz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Story : NSObject

@property (nonatomic, copy  ) NSString *gaPrefix;
@property (nonatomic, assign) NSNumber *id;
@property (nonatomic, copy  ) NSURL    *imageURL;
@property (nonatomic, copy  ) NSString *title;
@property (nonatomic, assign) NSNumber *type;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
