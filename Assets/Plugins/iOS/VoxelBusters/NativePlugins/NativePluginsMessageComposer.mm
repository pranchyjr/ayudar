//
//  NativePluginsMessageComposer.mm
//  Native Plugins
//
//  Created by Ashwin kumar on 22/01/19.
//  Copyright (c) 2019 Voxel Busters Interactive LLP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <MessageUI/MessageUI.h>
#import "NativePluginsDefines.h"
#import "NativePluginsBindingHelper.h"

#pragma mark - Callback definitions

// callback signatures
typedef void (*MessageComposerClosedNativeCallback)(void* nativePtr, MessageComposeResult result);

// static properties
static MessageComposerClosedNativeCallback _messageComposerClosedCallback = nil;

#pragma mark - Custom definitions

// custom object as delegate
@interface NativePluginsMessageComposerDelegate : NSObject<MFMessageComposeViewControllerDelegate>

@end

@implementation NativePluginsMessageComposerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    // dismiss view controller
    [UnityGetGLViewController() dismissViewControllerAnimated:YES completion:nil];
    
    // send callback
    void*   nativePtr   = (void*)(__bridge CFTypeRef)controller;
    _messageComposerClosedCallback(nativePtr, result);
}

@end

#pragma mark - Native binding methods

NPBINDING DONTSTRIP bool NPMessageComposerCanSendText()
{
    return [MFMessageComposeViewController canSendText];
}

NPBINDING DONTSTRIP bool NPMessageComposerCanSendAttachments()
{
    return [MFMessageComposeViewController canSendAttachments];
}

NPBINDING DONTSTRIP bool NPMessageComposerCanSendSubject()
{
    return [MFMessageComposeViewController canSendSubject];
}

NPBINDING DONTSTRIP void NPMessageComposerRegisterCallback(MessageComposerClosedNativeCallback closedCallback)
{
    // save references
    _messageComposerClosedCallback  = closedCallback;
}

NPBINDING DONTSTRIP void* NPMessageComposerCreate()
{
    // create delegate
    static  NativePluginsMessageComposerDelegate*   sharedDelegate      = nil;
    if (nil == sharedDelegate)
    {
        sharedDelegate  = [[NativePluginsMessageComposerDelegate alloc] init];
    }

    // create composer
    MFMessageComposeViewController* composerController      = [[MFMessageComposeViewController alloc] init];
    [composerController setMessageComposeDelegate:sharedDelegate];
    return (void*)(__bridge_retained CFTypeRef)composerController;
}

NPBINDING DONTSTRIP void NPMessageComposerShow(void* nativePtr)
{
    MFMessageComposeViewController* composerController      = (__bridge MFMessageComposeViewController*)nativePtr;
    [UnityGetGLViewController() presentViewController:composerController animated:YES completion:nil];
}

NPBINDING DONTSTRIP void NPMessageComposerDestroy(void* nativePtr)
{
    CFBridgingRelease(nativePtr);
}

NPBINDING DONTSTRIP void NPMessageComposerSetRecipients(void* nativePtr, const char** recipients, int count)
{
    MFMessageComposeViewController* composerController      = (__bridge MFMessageComposeViewController*)nativePtr;
    NSArray*                        recipientsNativeArray   = NPCreateArrayOfNSString(recipients, count);
    [composerController setRecipients:recipientsNativeArray];
}

NPBINDING DONTSTRIP void NPMessageComposerSetSubject(void* nativePtr, const char* value)
{
    MFMessageComposeViewController* composerController      = (__bridge MFMessageComposeViewController*)nativePtr;
    [composerController setSubject:[NSString stringWithUTF8String:value]];
}

NPBINDING DONTSTRIP void NPMessageComposerSetBody(void* nativePtr, const char* value)
{
    MFMessageComposeViewController* composerController      = (__bridge MFMessageComposeViewController*)nativePtr;
    [composerController setBody:[NSString stringWithUTF8String:value]];
}

NPBINDING DONTSTRIP void NPMessageComposerAddScreenshot(void* nativePtr, const char* fileName)
{
    NSData*                         screenshotData          = NPCaptureScreenshotAsData(UIImageEncodeTypePNG);
    NSString*                       typeId                  = (NSString*)kUTTypePNG;
    MFMessageComposeViewController* composerController      = (__bridge MFMessageComposeViewController*)nativePtr;
    [composerController addAttachmentData:screenshotData
                           typeIdentifier:typeId
                                 filename:[NSString stringWithUTF8String:fileName]];
}

NPBINDING DONTSTRIP void NPMessageComposerAddAttachment(void* nativePtr, NativePluginsAttachmentData data)
{
    MFMessageComposeViewController* composerController      = (__bridge MFMessageComposeViewController*)nativePtr;
    [composerController addAttachmentData:[NSData dataWithBytes:data.dataArrayPtr length:data.dataArrayLength]
                           typeIdentifier:NPConvertMimeTypeToUTType([NSString stringWithUTF8String:(const char*)data.mimeTypePtr])
                                 filename:[NSString stringWithUTF8String:(const char*)data.fileNamePtr]];
}
