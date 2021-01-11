//
//  NativePluginsGameServices.mm
//  Native Plugins
//
//  Created by Ashwin kumar on 22/01/19.
//  Copyright (c) 2019 Voxel Busters Interactive LLP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "NativePluginsDefines.h"
#import "NativePluginsBindingHelper.h"

#pragma mark - Custom definitions


#pragma mark - Callback definitions

@interface NPGameKitWrapper : NSObject

+ (bool)isServiceAvailable;


@end

@implementation NPGameKitWrapper

+ (bool)isServiceAvailable
{
    return true;
}

@end

#pragma mark - Native binding methods

NPBINDING DONTSTRIP bool NPGameServicesIsServiceAvailable()
{
    return [NPGameKitWrapper isServiceAvailable];
}

NPBINDING DONTSTRIP void Init()
{
    
}
