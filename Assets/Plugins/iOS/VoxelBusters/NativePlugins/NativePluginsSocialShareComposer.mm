//
//  NativePluginsSocialShareComposer.mm
//  Native Plugins
//
//  Created by Ashwin kumar on 22/01/19.
//  Copyright (c) 2019 Voxel Busters Interactive LLP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import "NativePluginsDefines.h"
#import "NativePluginsBindingHelper.h"
#import "NativePluginsSocialShareComposeController.h"
#import "NativePluginsWhatsAppShareComposer.h"
#import "NativePluginsSLComposeViewControllerAdapter.h"

#pragma mark - Callback definitions

typedef void (*SocialShareComposerClosedNativeCallback)(void* nativePtr, SLComposeViewControllerResult result);

// static properties
SocialShareComposerClosedNativeCallback _shareComposerClosedCallback;

#pragma mark - Custom definitions

typedef enum
{
    SocialShareComposerTypeFacebook,
    SocialShareComposerTypeTwitter,
    SocialShareComposerTypeWhatsApp,
}
SocialShareComposerType;

#pragma mark - Static methods

// inline functions
inline id<NativePluginsSocialShareComposeController> CreateShareComposer(SocialShareComposerType composerType)
{
    switch (composerType)
    {
        case SocialShareComposerTypeFacebook:
            return [[NativePluginsSLComposeViewControllerAdapter alloc] initWithServiceType:SLServiceTypeFacebook];
            
        case SocialShareComposerTypeTwitter:
            return [[NativePluginsSLComposeViewControllerAdapter alloc] initWithServiceType:SLServiceTypeTwitter];

        case SocialShareComposerTypeWhatsApp:
            return [[NativePluginsWhatsAppShareComposer alloc] init];
            
        default:
            return NULL;
    }
}

#pragma mark - Native binding methods

NPBINDING DONTSTRIP bool NPSocialShareComposerIsComposerAvailable(SocialShareComposerType composerType)
{
    switch (composerType)
    {
        case SocialShareComposerTypeFacebook:
            return [NativePluginsSLComposeViewControllerAdapter IsServiceTypeAvailable:SLServiceTypeFacebook];
            
        case SocialShareComposerTypeTwitter:
            return [NativePluginsSLComposeViewControllerAdapter IsServiceTypeAvailable:SLServiceTypeTwitter];
            
        case SocialShareComposerTypeWhatsApp:
            return [NativePluginsWhatsAppShareComposer IsServiceAvailable];
            
        default:
            return NO;
    }
}

NPBINDING DONTSTRIP void NPSocialShareComposerRegisterCallback(SocialShareComposerClosedNativeCallback closedCallback)
{
    // save references
    _shareComposerClosedCallback    = closedCallback;
}

NPBINDING DONTSTRIP void* NPSocialShareComposerCreate(SocialShareComposerType composerType)
{
    id<NativePluginsSocialShareComposeController>   composer    = CreateShareComposer(composerType);
    void*                                           nativePtr   = (void*)(__bridge_retained CFTypeRef)composer;
    [composer setCompletionHandler:^(SLComposeViewControllerResult result) {
        _shareComposerClosedCallback(nativePtr, result);
    }];
    return nativePtr;
}

NPBINDING DONTSTRIP void NPSocialShareComposerShow(void* nativePtr, float posX, float posY)
{
    id<NativePluginsSocialShareComposeController>   composer   = (__bridge id<NativePluginsSocialShareComposeController>)nativePtr;
    [composer showAtPosition:CGPointMake(posX, posY)];
}

NPBINDING DONTSTRIP void NPSocialShareComposerDestroy(void* nativePtr)
{
    CFBridgingRelease(nativePtr);
}

NPBINDING DONTSTRIP void NPSocialShareComposerAddText(void* nativePtr, const char* value)
{
    id<NativePluginsSocialShareComposeController>   composer   = (__bridge id<NativePluginsSocialShareComposeController>)nativePtr;
    [composer addText:[NSString stringWithUTF8String:value]];
}

NPBINDING DONTSTRIP void NPSocialShareComposerAddScreenshot(void* nativePtr)
{
    id<NativePluginsSocialShareComposeController>   composer   = (__bridge id<NativePluginsSocialShareComposeController>)nativePtr;
    [composer addImage:NPCaptureScreenshotAsImage()];
}

NPBINDING DONTSTRIP void NPSocialShareComposerAddImage(void* nativePtr, void* dataArrayPtr, int dataArrayLength)
{
    id<NativePluginsSocialShareComposeController>   composer   = (__bridge id<NativePluginsSocialShareComposeController>)nativePtr;
    [composer addImage:NPCreateImage(dataArrayPtr, dataArrayLength)];
}

NPBINDING DONTSTRIP void NPSocialShareComposerAddURL(void* nativePtr, const char* value)
{
    id<NativePluginsSocialShareComposeController>   composer   = (__bridge id<NativePluginsSocialShareComposeController>)nativePtr;
    [composer addURL:[NSURL URLWithString:[NSString stringWithUTF8String:value]]];
}
