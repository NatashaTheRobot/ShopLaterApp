//
//  ButtonFactory.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/18/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ButtonFactory : NSObject

+ (UIBarButtonItem *)barButtonItemWithImageName:(NSString *)imageName
                                         target:(id)target
                                         action:(SEL)action;

@end
