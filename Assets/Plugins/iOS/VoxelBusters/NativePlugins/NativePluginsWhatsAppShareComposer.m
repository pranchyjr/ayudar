//
//  NativePluginsWhatsAppShareComposer.m
//  Native Plugins
//
//  Created by Ashwin kumar on 22/01/19.
//  Copyright (c) 2019 Voxel Busters Interactive LLP. All rights reserved.
//

#import "NativePluginsWhatsAppShareComposer.h"
#import "NativePluginsBindingHelper.h"

typedef enum
{
    NativePluginsWhatsAppShareTypeUndefined,
    NativePluginsWhatsAppShareTypeText,
    NativePluginsWhatsAppShareTypeImage,
} NativePluginsWhatsAppShareType;

@interface NativePluginsWhatsAppShareComposer ()
{
    SLComposeViewControllerCompletionHandler    completionHandler;
    NSString*                                   text;
    UIImage*                                    image;
    NativePluginsWhatsAppShareType              shareType;
    BOOL                                        didCompleteSharing;
    CGPoint                                     openPoint;
}

@end

@implementation NativePluginsWhatsAppShareComposer

- (id)init
{
	self	= [super init];
    if (self)
	{
        shareType           = NativePluginsWhatsAppShareTypeUndefined;
		didCompleteSharing  = NO;
        openPoint           = CGPointZero;
	}
	
	return self;
}

#pragma mark - Static methods

+ (bool)IsServiceAvailable
{
	return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"whatsapp://app"]];
}

#pragma mark - NativePluginsShareComposeController methods

- (BOOL)addText:(NSString*)text
{
    if (NativePluginsWhatsAppShareTypeUndefined == shareType)
    {
        bool canShare = [NativePluginsWhatsAppShareComposer IsServiceAvailable];
        if (canShare)
        {
            self->text  = text;
            shareType   = NativePluginsWhatsAppShareTypeText;
        }
        
        return canShare;
    }
    
    return false;
}

- (BOOL)addImage:(UIImage*)image
{
//    if (NativePluginsWhatsAppShareTypeUndefined == shareType)
//    {
//        bool canShare = [NativePluginsWhatsAppShareComposer IsServiceAvailable];
//        if (canShare)
//        {
//            self->image = image;
//            shareType   = NativePluginsWhatsAppShareTypeImage;
//        }
//
//        return canShare;
//    }
    
    return false;
}

- (BOOL)addURL:(NSURL*)url
{
    return [self addText:[url absoluteString]];
}

- (void)setCompletionHandler:(SLComposeViewControllerCompletionHandler)completionHandler
{
    self->completionHandler = [completionHandler copy];
}

- (void)showAtPosition:(CGPoint)position
{
    // save position
    openPoint  = position;

    // based on item type execute appropriate action
    switch (shareType)
    {
        case NativePluginsWhatsAppShareTypeText:
            [self shareText];
            break;
            
        case NativePluginsWhatsAppShareTypeImage:
            [self shareImage];
            break;
            
        default:
            [self invokeCompletionCallbackWithStatus:NO];
            break;
    }
}

#pragma mark - Private methods

- (void)shareText
{
    NSString*   messageURLStr   = [NSString stringWithFormat:@"whatsapp://send?text=%@", text];
    NSURL*      messageURL      = [NSURL URLWithString:[messageURLStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    
    // pass data to destination app
    [[UIApplication sharedApplication] openURL:messageURL
                                       options:@{}
                             completionHandler:^(BOOL success) {
                                 // send callback
                                 [self invokeCompletionCallbackWithStatus:success];
                             }];
}

- (void)shareImage
{
    if (self->image)
    {
        NSString*   tempFilePath    = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/WhatsAppTemp.wai"];
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:tempFilePath atomically:YES];

        // create interaction controller
        UIDocumentInteractionController* interactionController  = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:tempFilePath]];
        interactionController.UTI                               = @"net.whatsapp.image";
        interactionController.delegate                          = self;
        [interactionController presentOpenInMenuFromRect:CGRectMake(openPoint.x, openPoint.y, 1, 1)
                                                  inView:UnityGetGLView()
                                                animated:YES];
    }
    else
    {
        [self invokeCompletionCallbackWithStatus:NO];
    }
}
    
- (void)invokeCompletionCallbackWithStatus:(BOOL)status
{
    if (completionHandler)
    {
        completionHandler(status ? SLComposeViewControllerResultDone : SLComposeViewControllerResultCancelled);
    }
}
    
#pragma mark - UIDocumentInteractionControllerDelegate implementation

- (void)documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController*)controller
{
    NSLog(@"[NativePlugins] WhatsApp share controller will present.");
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController*)controller
{
    NSLog(@"[NativePlugins] WhatsApp share controller did dismiss.");
}

- (void)documentInteractionController:(UIDocumentInteractionController*)controller willBeginSendingToApplication:(nullable NSString*)application
{
    NSLog(@"[NativePlugins] WhatsApp share controller will begin sending to application.");
    didCompleteSharing	= YES;
}

- (void)documentInteractionController:(UIDocumentInteractionController*)controller didEndSendingToApplication:(nullable NSString*)application
{
    NSLog(@"[NativePlugins] WhatsApp share controller did end sending to application.");
    // execute callback block
    [self invokeCompletionCallbackWithStatus:didCompleteSharing];
}

@end
