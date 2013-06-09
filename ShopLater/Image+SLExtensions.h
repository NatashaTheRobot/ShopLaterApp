//
//  Image+SLExtensions.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/9/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "Image.h"
#import "Provider.h"

@interface Image (SLExtensions)

+ (UIImage *)imageForProvider:(Provider *)provider type:(NSString *)imageType;

@end
