//
//  NativePluginsBindingHelper.h
//  Native Plugins
//
//  Created by Ashwin kumar on 22/01/19.
//  Copyright (c) 2019 Voxel Busters Interactive LLP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

typedef enum
{
    UIImageEncodeTypePNG,
    UIImageEncodeTypeJPEG,
} UIImageEncodeType;

// common functions
char* NPCreateCStringCopyFromNSString(NSString* string);
char* NPCreateCStringCopyFromNSError(NSError* error);
NSArray<NSString*>* NPCreateArrayOfNSString(const char** array, int length);
NSString* NPCreateNSStringFromCString(const char* cString);
char** NPCreateArrayOfCString(NSArray<NSString*>* array, int* length);

// image operations
UIImage* NPCaptureScreenshotAsImage();
NSData* NPCaptureScreenshotAsData(UIImageEncodeType encodeType);
UIImage* NPCreateImage(void* dataArrayPtr, int dataLength);

// convertor operations
NSString* NPConvertMimeTypeToUTType(NSString* mimeType);

// JSON methods
NSString* NPToJson(id object, NSError** error);
id NPFromJson(NSString* jsonString, NSError** error);
