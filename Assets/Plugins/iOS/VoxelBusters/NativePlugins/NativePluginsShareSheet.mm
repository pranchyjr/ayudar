//
//  NativePluginsShareSheet.mm
//  Native Plugins
//
//  Created by Ashwin kumar on 22/01/19.
//  Copyright (c) 2019 Voxel Busters Interactive LLP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NativePluginsDefines.h"
#import "NativePluginsBindingHelper.h"

#pragma mark - Custom definitions

// callback signatures
typedef void (*ShareSheetClosedNativeCallback)(void* nativePtr, bool completed, const char* error);

// static properties
ShareSheetClosedNativeCallback _shareSheetClosedCallback;

#pragma mark - Wrapper object

@interface NativePluginsShareSheetWrapper : NSObject

- (void)addItem:(NSObject*)item;
- (void)showAtPosition:(CGPoint)position withAnimation:(BOOL)animated;

@end

@interface NativePluginsShareSheetWrapper ()

@property(nonatomic) NSMutableArray*           itemsArray;
@property(nonatomic) UIActivityViewController* activityController;
@property(nonatomic) UIPopoverController*      popoverController;
@property(nonatomic, copy) UIActivityViewControllerCompletionWithItemsHandler completionHandler;

@end

@implementation NativePluginsShareSheetWrapper

@synthesize itemsArray          = _itemsArray;
@synthesize activityController  = _activityController;
@synthesize popoverController   = _popoverController;
@synthesize completionHandler   = _completionHandler;

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setItemsArray:[NSMutableArray array]];
    }
    return self;
}

- (void)dealloc
{
    if ([self activityController])
    {
        [[self activityController] setCompletionWithItemsHandler:nil];
    }
}

#pragma mark - Public methods

- (void)addItem:(NSObject *)item
{
    [[self itemsArray] addObject:item];
}

- (void)setCompletionHandler:(UIActivityViewControllerCompletionWithItemsHandler)completionHandler
{
    _completionHandler = [completionHandler copy];
}

- (void)showAtPosition:(CGPoint)position withAnimation:(BOOL)animated
{
    __weak NativePluginsShareSheetWrapper* weakSelf = self;
    
    // create new instance
    UIActivityViewController* activityVC    = [[UIActivityViewController alloc] initWithActivityItems:_itemsArray applicationActivities:nil];
    [activityVC setCompletionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        [weakSelf onSheetActionFinished:activityType isCompleted:completed withReturnItems:returnedItems andError:activityError];
    }];
    [self setActivityController:activityVC];
    
    // show the view controller
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        UIPopoverController* popoverController = [[UIPopoverController alloc] initWithContentViewController:activityVC];
        [popoverController presentPopoverFromRect:CGRectMake(position.x, position.y, 1, 1)
                                           inView:UnityGetGLView()
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                         animated:YES];
        
        // cache reference
        [self setPopoverController:popoverController];
    }
    else
    {
        [UnityGetGLViewController() presentViewController:activityVC
                                                 animated:YES
                                               completion:nil];
    }
}
     
- (void)onSheetActionFinished:(UIActivityType)activityType
                  isCompleted:(BOOL)completed
              withReturnItems:(NSArray* __nullable)returnedItems
                     andError:(NSError* __nullable)activityError
{
    // remove composer from window
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        [[self popoverController] dismissPopoverAnimated:YES];
        [self setPopoverController: nil];
    }
    else
    {
        [UnityGetGLViewController() dismissViewControllerAnimated:YES completion:NULL];
    }
    
    // send data using callback
    void* nativePtr     = (void*)(__bridge CFTypeRef)self;
    char* errorCStr     = NPCreateCStringCopyFromNSError(activityError);
    _shareSheetClosedCallback(nativePtr, completed, errorCStr);
    
    // release unused properties
    if (errorCStr)
    {
        free(errorCStr);
    }
}

@end

#pragma mark - Native binding methods

NPBINDING DONTSTRIP void NPShareSheetRegisterCallback(ShareSheetClosedNativeCallback closedCallback)
{
    // save references
    _shareSheetClosedCallback    = closedCallback;
}

NPBINDING DONTSTRIP void* NPShareSheetCreate()
{
    NativePluginsShareSheetWrapper* shareSheet  = [[NativePluginsShareSheetWrapper alloc] init];
    return (void*)(__bridge_retained CFTypeRef)shareSheet;
}

NPBINDING DONTSTRIP void NPShareSheetShow(void* nativePtr, float posX, float posY)
{
    NativePluginsShareSheetWrapper*  shareSheet  = (__bridge NativePluginsShareSheetWrapper*)nativePtr;
    [shareSheet showAtPosition:CGPointMake(posX, posY) withAnimation:YES];
}

NPBINDING DONTSTRIP void NPShareSheetDestroy(void* nativePtr)
{
    CFBridgingRelease(nativePtr);
}

NPBINDING DONTSTRIP void NPShareSheetAddText(void* nativePtr, const char* value)
{
    NativePluginsShareSheetWrapper*  shareSheet  = (__bridge NativePluginsShareSheetWrapper*)nativePtr;
    [shareSheet addItem:[NSString stringWithUTF8String:value]];
}

NPBINDING DONTSTRIP void NPShareSheetAddScreenshot(void* nativePtr)
{
    NativePluginsShareSheetWrapper*  shareSheet  = (__bridge NativePluginsShareSheetWrapper*)nativePtr;
    [shareSheet addItem:NPCaptureScreenshotAsImage()];
}

NPBINDING DONTSTRIP void NPShareSheetAddImage(void* nativePtr, void* dataArrayPtr, int dataArrayLength)
{
    NativePluginsShareSheetWrapper*  shareSheet  = (__bridge NativePluginsShareSheetWrapper*)nativePtr;
    [shareSheet addItem:NPCreateImage(dataArrayPtr, dataArrayLength)];
}

NPBINDING DONTSTRIP void NPShareSheetAddURL(void* nativePtr, const char* value)
{
    NativePluginsShareSheetWrapper*  shareSheet  = (__bridge NativePluginsShareSheetWrapper*)nativePtr;
    [shareSheet addItem:[NSURL URLWithString:[NSString stringWithUTF8String:value]]];
}
