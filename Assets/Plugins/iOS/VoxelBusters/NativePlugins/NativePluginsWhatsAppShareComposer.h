//
//  NativePluginsWhatsAppShareComposer.h
//  Native Plugins
//
//  Created by Ashwin kumar on 22/01/19.
//  Copyright (c) 2019 Voxel Busters Interactive LLP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import "NativePluginsSocialShareComposeController.h"

@interface NativePluginsWhatsAppShareComposer : NSObject<UIDocumentInteractionControllerDelegate, NativePluginsSocialShareComposeController>

// static methods
+ (bool)IsServiceAvailable;

@end
