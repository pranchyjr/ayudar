//
//  NativePluginsBindingHelper.mm
//  Native Plugins
//
//  Created by Ashwin kumar on 22/01/19.
//  Copyright (c) 2019 Voxel Busters Interactive LLP. All rights reserved.
//

#import "NativePluginsBindingHelper.h"
#import "NativePluginsDefines.h"

#pragma mark - String operations

char* NPCreateCStringCopyFromNSString(NSString* string)
{
    if (string)
    {
        // create copy
        const char* cString = [string UTF8String];
        char*       copy    = (char*)malloc(strlen(cString) + 1);
        strcpy(copy, cString);
        return copy;
    }
    
    return nil;
}

char* NPCreateCStringCopyFromNSError(NSError* error)
{
    if (error)
    {
        return NPCreateCStringCopyFromNSString([error localizedDescription]);
    }
    
    return nil;
}

NSArray<NSString*>* NPCreateArrayOfNSString(const char** array, int length)
{
    if (array)
    {
        NSMutableArray<NSString*>*  nativeArray     = [NSMutableArray<NSString*> arrayWithCapacity:length];
        for (int iter = 0; iter < length; iter++)
        {
            const char* cValue  = array[iter];
            [nativeArray addObject:[NSString stringWithUTF8String:cValue]];
        }
        
        return nativeArray;
    }
    
    return nil;
}

NSString* NPCreateNSStringFromCString(const char* cString)
{
    if (cString)
    {
        return [NSString stringWithUTF8String:cString];
    }
    
    return nil;
}

char** NPCreateArrayOfCString(NSArray<NSString*>* array, int* length)
{
    if (array)
    {
        int     arrayLength     = (int)[array count];
        char**  cStringArray    = (char**)calloc(arrayLength, sizeof(char*));
        for (int iter = 0; iter < arrayLength; iter++)
        {
            cStringArray[iter]  = (char*)[[array objectAtIndex:iter] UTF8String];
        }
        
        // set out reference value
        *length = arrayLength;
        
        return cStringArray;
    }
    
    // set out reference value
    *length = 0;
    return nil;
}

#pragma mark - Image operations

UIImage* NPCaptureScreenshotAsImage()
{
    UIView*     glView  = UnityGetGLView();
    CGRect      bounds  = glView.bounds;
    
    // write contents of view to context and create image using it
    UIGraphicsBeginImageContextWithOptions(bounds.size, YES, 0.0);
    [glView drawViewHierarchyInRect:bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

NSData* NPCaptureScreenshotAsData(UIImageEncodeType encodeType)
{
    switch (encodeType)
    {
        case UIImageEncodeTypePNG:
            return UIImagePNGRepresentation(NPCaptureScreenshotAsImage());
            
        case UIImageEncodeTypeJPEG:
            return UIImageJPEGRepresentation(NPCaptureScreenshotAsImage(), 1);
            
        default:
            return nil;
    }
}

UIImage* NPCreateImage(void* dataArrayPtr, int dataLength)
{
    NSData* data = [NSData dataWithBytes:dataArrayPtr length:dataLength];
    return [UIImage imageWithData:data];
}

#pragma mark - Converter operations

NSString* NPConvertMimeTypeToUTType(NSString* mimeType)
{
    if ([mimeType isEqualToString:kMimeTypePNG])
    {
        return (NSString*)kUTTypePNG;
    }
    if ([mimeType isEqualToString:kMimeTypeJPG])
    {
        return (NSString*)kUTTypeJPEG;
    }
    
    return NULL;
}

#pragma mark - JSON utility methods

NSString* NPToJson(id object, NSError** error)
{
    NSData* jsonData    = [NSJSONSerialization dataWithJSONObject:object
                                                          options:0
                                                            error:error];
    if (!error)
    {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return nil;
}

id NPFromJson(NSString* jsonString, NSError** error)
{
    NSData* jsonData    = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData)
    {
        id  object      = [NSJSONSerialization JSONObjectWithData:jsonData
                                                              options:0
                                                                error:error];
        if (!error)
        {
            return object;
        }
    }
    
    return nil;
}
