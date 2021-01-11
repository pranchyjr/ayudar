//
//  NativePluginsUtility.mm
//  Native Plugins
//
//  Created by Ashwin kumar on 22/01/19.
//  Copyright (c) 2019 Voxel Busters Interactive LLP. All rights reserved.
//

#import "NativePluginsDefines.h"

#pragma mark - Callback definitions

// callback signatures
typedef void (*LoadTextureNativeCallback)(void* dataArrayPtr, int dataLength, void* tagPtr);

// static properties
static LoadTextureNativeCallback _loadTextureCallback = nil;

#pragma mark - Native binding methods

NPBINDING DONTSTRIP void NPUtilityRegisterCallbacks(LoadTextureNativeCallback loadTextureCallback)
{
    // cache
    _loadTextureCallback    = loadTextureCallback;
}

NPBINDING DONTSTRIP void NPUtilityLoadTexture(void* nativeDataPtr, void* tagPtr)
{
    NSData*     imageData   = (__bridge NSData*)nativeDataPtr;
    if (imageData)
    {
        _loadTextureCallback((void *)[imageData bytes], (int)[imageData length], tagPtr);
    }
    else
    {
        _loadTextureCallback(nil, 0, tagPtr);
    }
}
