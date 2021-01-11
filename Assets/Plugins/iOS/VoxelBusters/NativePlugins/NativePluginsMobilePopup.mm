//
//  NativePluginsMobilePopup.mm
//  Native Plugins
//
//  Created by Ashwin kumar on 22/01/19.
//  Copyright (c) 2019 Voxel Busters Interactive LLP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NativePluginsDefines.h"
#import "NativePluginsBindingHelper.h"

#pragma mark - Callback definitions

// signature
typedef void (*NativeButtonClickCallback)(void* nativePtr, int selectedButtonIndex);

// static properties
static NativeButtonClickCallback _buttonClickCallback = nil;

#pragma mark - Native binding methods

NPBINDING DONTSTRIP void NPAlertDialogRegisterCallback(NativeButtonClickCallback clickCallback)
{
    // save references
    _buttonClickCallback    = clickCallback;
}

NPBINDING DONTSTRIP void* NPAlertDialogCreate(const char* title, const char* message, UIAlertControllerStyle preferredStyle)
{
    UIAlertController*  alert       = [UIAlertController alertControllerWithTitle:[NSString stringWithUTF8String:title]
                                                                          message:[NSString stringWithUTF8String:message]
                                                                   preferredStyle:preferredStyle];
    void*               nativePtr   = (void*)(__bridge_retained CFTypeRef)alert;
    
    return nativePtr;
}

NPBINDING DONTSTRIP void NPAlertDialogShow(void* nativePtr)
{
    UIAlertController*  alert       = (__bridge UIAlertController*)nativePtr;
    [UnityGetGLViewController() presentViewController:alert animated:YES completion:nil];
}

NPBINDING DONTSTRIP void NPAlertDialogDismiss(void* nativePtr)
{
    UIViewController*   parentVC    = UnityGetGLViewController();
    UIAlertController*  alert       = (__bridge UIAlertController*)nativePtr;
    if (parentVC.presentedViewController == alert)
    {
        [UnityGetGLViewController() dismissViewControllerAnimated:YES completion:nil];
    }
}

NPBINDING DONTSTRIP void NPAlertDialogDestroy(void* nativePtr)
{
    CFBridgingRelease(nativePtr);
}

NPBINDING DONTSTRIP void NPAlertDialogSetTitle(void* nativePtr, const char* value)
{
    UIAlertController*  alert       = (__bridge UIAlertController*)nativePtr;
    [alert setTitle:[NSString stringWithUTF8String:value]];
}

NPBINDING DONTSTRIP const char* NPAlertDialogGetTitle(void* nativePtr)
{
    UIAlertController*  alert       = (__bridge UIAlertController*)nativePtr;
    NSString*           title       = [alert title];
    return NPCreateCStringCopyFromNSString(title);
}

NPBINDING DONTSTRIP void NPAlertDialogSetMessage(void* nativePtr, const char* value)
{
    UIAlertController*  alert       = (__bridge UIAlertController*)nativePtr;
    [alert setMessage:[NSString stringWithUTF8String:value]];
}

NPBINDING DONTSTRIP const char* NPAlertDialogGetMessage(void* nativePtr)
{
    UIAlertController*  alert       = (__bridge UIAlertController*)nativePtr;
    NSString*           message     = [alert message];
    return NPCreateCStringCopyFromNSString(message);
}

NPBINDING DONTSTRIP void NPAlertDialogAddAction(void* nativePtr, const char* text, bool isCancelType)
{
    UIAlertController*  alert       = (__bridge UIAlertController*)nativePtr;
    
    // create action
    int                 actionIndex = (int)[[alert actions] count];
    UIAlertAction*      action      = [UIAlertAction actionWithTitle:[NSString stringWithUTF8String:text]
                                                               style:isCancelType ? UIAlertActionStyleCancel : UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction* _Nonnull action) {
                                                                 NSLog(@"[NativePlugins] Selected alert action is at index: %d", actionIndex);
                                                                 _buttonClickCallback(nativePtr, actionIndex);
                                                             }];
    // add action to controller
    [alert addAction:action];
}
