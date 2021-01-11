//
//  NativePluginsSLComposeViewControllerAdapter.h
//  Native Plugins
//
//  Created by Ashwin kumar on 22/01/19.
//  Copyright (c) 2019 Voxel Busters Interactive LLP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import "NativePluginsSocialShareComposeController.h"

@interface NativePluginsSLComposeViewControllerAdapter : NSObject<NativePluginsSocialShareComposeController>

// static methods
+ (bool)IsServiceTypeAvailable:(NSString*)serviceType;

// init methods
- (id)initWithServiceType:(NSString*)serviceType;

@end
