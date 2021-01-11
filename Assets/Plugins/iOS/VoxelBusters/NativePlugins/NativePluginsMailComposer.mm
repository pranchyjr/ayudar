//
//  NativePluginsMailComposer.mm
//  Native Plugins
//
//  Created by Ashwin kumar on 22/01/19.
//  Copyright (c) 2019 Voxel Busters Interactive LLP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "NativePluginsDefines.h"
#import "NativePluginsBindingHelper.h"

#pragma mark - Callback definitions

// callback signatures
typedef void (*MailComposerClosedNativeCallback)(void* nativePtr, MFMailComposeResult result, const char* error);

// static properties
static MailComposerClosedNativeCallback _mailComposerClosedCallback = nil;

#pragma mark - Custom definitions

// enum for determining recipient type
typedef enum
{
    MailRecipientTypeTo,
    MailRecipientTypeCc,
    MailRecipientTypeBcc,
} MailRecipientType;

// custom object as delegate
@interface NativePluginsMailComposerDelegate : NSObject<MFMailComposeViewControllerDelegate>

@end

@implementation NativePluginsMailComposerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error
{
    // dismiss view controller
    [UnityGetGLViewController() dismissViewControllerAnimated:YES completion:nil];
    
    // send callback
    void*   nativePtr   = (void*)(__bridge CFTypeRef)controller;
    char*   errorCStr   = NPCreateCStringCopyFromNSError(error);
    _mailComposerClosedCallback(nativePtr, result, errorCStr);
    
    // release unused values
    if (errorCStr)
    {
        free(errorCStr);
    }
}

@end

#pragma mark - Native binding methods

NPBINDING DONTSTRIP bool NPMailComposerCanSendMail()
{
    return [MFMailComposeViewController canSendMail];
}

NPBINDING DONTSTRIP void NPMailComposerRegisterCallback(MailComposerClosedNativeCallback closedCallback)
{
    // save references
    _mailComposerClosedCallback    = closedCallback;
}

NPBINDING DONTSTRIP void* NPMailComposerCreate()
{
    // create delegate
    static  NativePluginsMailComposerDelegate*   sharedDelegate      = nil;
    if (nil == sharedDelegate)
    {
        sharedDelegate  = [[NativePluginsMailComposerDelegate alloc] init];
    }
    
    // create composer
    MFMailComposeViewController*    composerController      = [[MFMailComposeViewController alloc] init];
    [composerController setMailComposeDelegate:sharedDelegate];
    return (void*)(__bridge_retained CFTypeRef)composerController;
}

NPBINDING DONTSTRIP void NPMailComposerShow(void* nativePtr)
{
    MFMailComposeViewController*     composerController     = (__bridge MFMailComposeViewController*)nativePtr;
    [UnityGetGLViewController() presentViewController:composerController animated:YES completion:nil];
}

NPBINDING DONTSTRIP void NPMailComposerDestroy(void* nativePtr)
{
    CFBridgingRelease(nativePtr);
}

NPBINDING DONTSTRIP void NPMailComposerSetRecipients(void* nativePtr, MailRecipientType recipientType, const char** recipients, int count)
{
    // convert to native representation
    NSArray*                         recipientsNativeArray   = NPCreateArrayOfNSString(recipients, count);

    // set value
    MFMailComposeViewController*     composerController      = (__bridge MFMailComposeViewController*)nativePtr;
    switch (recipientType)
    {
        case MailRecipientTypeTo:
            [composerController setToRecipients:recipientsNativeArray];
            break;
            
        case MailRecipientTypeCc:
            [composerController setCcRecipients:recipientsNativeArray];
            break;
            
        case MailRecipientTypeBcc:
            [composerController setBccRecipients:recipientsNativeArray];
            break;
            
        default:
            break;
    }
}

NPBINDING DONTSTRIP void NPMailComposerSetSubject(void* nativePtr, const char* value)
{
    MFMailComposeViewController*     composerController      = (__bridge MFMailComposeViewController*)nativePtr;
    [composerController setSubject:[NSString stringWithUTF8String:value]];
}

NPBINDING DONTSTRIP void NPMailComposerSetBody(void* nativePtr, const char* value, bool isHtml)
{
    MFMailComposeViewController*     composerController      = (__bridge MFMailComposeViewController*)nativePtr;
    [composerController setMessageBody:[NSString stringWithUTF8String:value] isHTML:isHtml];
}

NPBINDING DONTSTRIP void NPMailComposerAddScreenshot(void* nativePtr, const char* fileName)
{
    MFMailComposeViewController*     composerController      = (__bridge MFMailComposeViewController*)nativePtr;
    [composerController addAttachmentData:NPCaptureScreenshotAsData(UIImageEncodeTypePNG)
                                 mimeType:kMimeTypePNG
                                 fileName:[NSString stringWithUTF8String:fileName]];
}

NPBINDING DONTSTRIP void NPMailComposerAddAttachment(void* nativePtr, NativePluginsAttachmentData data)
{
    MFMailComposeViewController*     composerController      = (__bridge MFMailComposeViewController*)nativePtr;
    [composerController addAttachmentData:[NSData dataWithBytes:data.dataArrayPtr length:data.dataArrayLength]
                                 mimeType:[NSString stringWithUTF8String:(const char*)data.mimeTypePtr]
                                 fileName:[NSString stringWithUTF8String:(const char*)data.fileNamePtr]];
}
