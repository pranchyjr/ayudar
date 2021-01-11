//
//  NativePluginsDefines.h
//  Native Plugins
//
//  Created by Ashwin kumar on 22/01/19.
//  Copyright (c) 2019 Voxel Busters Interactive LLP. All rights reserved.
//

#pragma mark - Symbols

#define NPBINDING       extern "C" __attribute__((visibility ("default")))
#define DONTSTRIP       __attribute__((used))

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#pragma mark - Global definitions

typedef struct
{
    int     dataArrayLength;
    void*   dataArrayPtr;
    void*   mimeTypePtr;
    void*   fileNamePtr;
} NativePluginsAttachmentData;

#pragma mark - Constants

static NSString* const kMimeTypeJPG = @"image/jpeg";
static NSString* const kMimeTypePNG = @"image/png";
