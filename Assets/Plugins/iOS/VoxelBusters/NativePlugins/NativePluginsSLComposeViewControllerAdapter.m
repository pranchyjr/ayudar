//
//  NativePluginsSLComposeViewControllerAdapter.m
//  Native Plugins
//
//  Created by Ashwin kumar on 22/01/19.
//  Copyright (c) 2019 Voxel Busters Interactive LLP. All rights reserved.
//

#import "NativePluginsSLComposeViewControllerAdapter.h"
#import "NativePluginsDefines.h"

// constants
static NSString* const kURLSchemeFacebook   = @"fb://";
static NSString* const kURLSchemeTwitter    = @"twitter://";

@interface NativePluginsSLComposeViewControllerAdapter ()

// internal properties
@property(nonatomic) SLComposeViewController*                       slComposer;
@property(nonatomic) SLComposeViewControllerCompletionHandler       completionHandler;
@property(nonatomic) UIPopoverController*                           popoverController;

@end

@implementation NativePluginsSLComposeViewControllerAdapter

@synthesize slComposer          = _slComposer;
@synthesize completionHandler   = _completionHandler;
@synthesize popoverController   = _popoverController;

#pragma mark - Static methods

+ (bool)IsServiceTypeAvailable:(NSString*)serviceType
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0"))
    {
        if ([serviceType isEqualToString:SLServiceTypeFacebook])
        {
            return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:kURLSchemeFacebook]];
        }
        if ([serviceType isEqualToString:SLServiceTypeTwitter])
        {
            return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:kURLSchemeTwitter]];
        }
        return false;
    }
    else
    {
        return [SLComposeViewController isAvailableForServiceType:serviceType];
    }
}

#pragma mark - Init methods

- (id)initWithServiceType:(NSString*)serviceType
{
    self = [super init];
    if (self)
    {
        // create composer instance
        __weak NativePluginsSLComposeViewControllerAdapter* weakSelf    = self;
        __weak SLComposeViewController*                     composer    = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        [composer setCompletionHandler:^(SLComposeViewControllerResult result) {
            [weakSelf onComposerDimissedWithResult:result];
        }];
        
        // set properties
        [self setSlComposer:composer];
    }
    return self;
}

- (void)dealloc
{
    if ([self slComposer])
    {
        [[self slComposer] setCompletionHandler:nil];
    }
}

#pragma mark - Private methods

- (void)onComposerDimissedWithResult:(SLComposeViewControllerResult)result
{
    // clean view
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        [[self popoverController] dismissPopoverAnimated:YES];
        [self setPopoverController:nil];
    }
    else
    {
        [UnityGetGLViewController() dismissViewControllerAnimated:YES completion:NULL];
    }
    
    // invoke user defined completion block
    if ([self completionHandler])
    {
        [self completionHandler](result);
    }
}

#pragma mark - NativePluginsSocialShareComposeController methods

- (BOOL)addText:(NSString*)text
{
    return [[self slComposer] setInitialText:text];
}

- (BOOL)addImage:(UIImage*)image
{
   return [[self slComposer] addImage:image];
}

- (BOOL)addURL:(NSURL*)url
{
    return [[self slComposer] addURL:url];
}

- (void)setCompletionHandler:(SLComposeViewControllerCompletionHandler)completionHandler
{
    _completionHandler = [completionHandler copy];
}

- (void)showAtPosition:(CGPoint)pos
{
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        UIPopoverController* popoverController  = [[UIPopoverController alloc] initWithContentViewController:[self slComposer]];
        [popoverController presentPopoverFromRect:CGRectMake(pos.x, pos.y, 1, 1)
                                           inView:UnityGetGLView()
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                         animated:YES];
    }
    else
    {
        [UnityGetGLViewController() presentViewController:[self slComposer] animated:YES completion:nil];
    }
}

@end
