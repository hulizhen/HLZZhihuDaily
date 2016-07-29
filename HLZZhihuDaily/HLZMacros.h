//
//  Macros.h
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 7/27/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#ifndef Macros_h
#define Macros_h

#define HLZColorFromRGBA(rgbaValue) [UIColor colorWithRed:((float)((rgbaValue & 0xFF000000) >> 24))/255.0 \
                                                    green:((float)((rgbaValue & 0x00FF0000) >> 16))/255.0 \
                                                     blue:((float)((rgbaValue & 0x0000FF00) >>  8))/255.0 \
                                                    alpha:((float)((rgbaValue & 0x000000FF) >>  0))/255.0]

#endif /* Macros_h */
