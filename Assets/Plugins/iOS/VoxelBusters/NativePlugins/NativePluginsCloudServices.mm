//
//  NativePluginsCloudServices.mm
//  Native Plugins
//
//  Created by Ashwin kumar on 22/01/19.
//  Copyright (c) 2019 Voxel Busters Interactive LLP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>
#import "NativePluginsDefines.h"
#import "NativePluginsBindingHelper.h"

#pragma mark - Custom definitions

// custom datatypes
struct iCloudAccountData
{
    // variables
    void*               accountIdentifier;
    CKAccountStatus     accountStatus;
    
    // destructor
    ~iCloudAccountData()
    {
        if (accountIdentifier)
        {
            free(accountIdentifier);
        }
    }
};
typedef iCloudAccountData iCloudAccountData;

#pragma mark - Callback definitions

// callback signatures
typedef void (*UserChangedNativeCallback)(iCloudAccountData accountData, const char* error);
typedef void (*SavedDataChangedNativeCallback)(int changeReason, const char** changedKeys);

static UserChangedNativeCallback        _userChangedCallback        = nil;
static SavedDataChangedNativeCallback   _savedDataChangedCallback   = nil;

#pragma mark - Wrappers

@interface NativePluginsCloudServicesEventObserver : NSObject

@end

@implementation NativePluginsCloudServicesEventObserver

- (id)init
{
    self = [super init];
    if (self)
    {
        // register for events
        NSUbiquitousKeyValueStore*  defaultStore = [NSUbiquitousKeyValueStore defaultStore];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onDataStoreChanged:)
                                                     name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                                   object:defaultStore];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onAccountChanged:)
                                                     name:CKAccountChangedNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    // unregister from events
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                                  object:[NSUbiquitousKeyValueStore defaultStore]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:CKAccountChangedNotification
                                                  object:nil];
}

- (void)onDataStoreChanged:(NSNotification *)notification
{
    NSDictionary*       userInfo        = [notification userInfo];
    NSNumber*           changeReason    = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangeReasonKey];
    NSArray<NSString*>* changedKeys     = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangedKeysKey];
    
    // raise an event
    int     changedKeysCount;
    char**  changedKeysCArray    = NPCreateArrayOfCString(changedKeys, &changedKeysCount);
    _savedDataChangedCallback([changeReason intValue], (const char**)changedKeysCArray);
}

- (void)onAccountChanged:(NSNotification *)notification
{
    [[CKContainer defaultContainer] accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError * _Nullable error) {
        
        id          identityToken       = nil;
        if (CKAccountStatusAvailable == accountStatus)
        {
            identityToken   = [[NSFileManager defaultManager] ubiquityIdentityToken];
            if (identityToken)
            {
                
            }
        }
        
        
        
        // create data
        iCloudAccountData*  accountData = (iCloudAccountData*)malloc(sizeof(iCloudAccountData));
        accountData->accountIdentifier  = (identityToken) ? NPCreateCStringCopyFromNSString(identityToken) : nil;
        accountData->accountStatus      = accountStatus;
        
        // send callback
        const char* errorCStr           = NPCreateCStringCopyFromNSError(error);
        _userChangedCallback(*accountData, errorCStr);
        
        // release
        free(accountData);
        if (errorCStr)
        {
            free((void*)errorCStr);
        }
    }];
}

@end

#pragma mark - Native binding methods

NPBINDING DONTSTRIP void NPCloudServicesRegisterCallbacks(UserChangedNativeCallback userChangedCallback, SavedDataChangedNativeCallback savedDataChangedCallback)
{
    // save values
    _userChangedCallback        = userChangedCallback;
    _savedDataChangedCallback   = savedDataChangedCallback;
}

NPBINDING DONTSTRIP void NPCloudServicesInit()
{
    // create observer
    static  NativePluginsCloudServicesEventObserver*   sharedEventObserver      = nil;
    if (nil == sharedEventObserver)
    {
        sharedEventObserver  = [[NativePluginsCloudServicesEventObserver alloc] init];
    }
}

NPBINDING DONTSTRIP bool NPCloudServicesGetBool(const char* key)
{
    return [[NSUbiquitousKeyValueStore defaultStore] boolForKey:NPCreateNSStringFromCString(key)];
}

NPBINDING DONTSTRIP long NPCloudServicesGetLong(const char* key)
{
    return [[NSUbiquitousKeyValueStore defaultStore] longLongForKey:NPCreateNSStringFromCString(key)];
}

NPBINDING DONTSTRIP double NPCloudServicesGetDouble(const char* key)
{
    return [[NSUbiquitousKeyValueStore defaultStore] doubleForKey:NPCreateNSStringFromCString(key)];
}

NPBINDING DONTSTRIP char* NPCloudServicesGetString(const char* key)
{
    NSString*   savedValue  = [[NSUbiquitousKeyValueStore defaultStore] stringForKey:NPCreateNSStringFromCString(key)];
    return NPCreateCStringCopyFromNSString(savedValue);
}

NPBINDING DONTSTRIP char* NPCloudServicesGetArray(const char* key)
{
    NSArray*        savedValue  = [[NSUbiquitousKeyValueStore defaultStore] arrayForKey:NPCreateNSStringFromCString(key)];
    if (savedValue)
    {
        NSError*    error;
        NSString*   jsonStr     = NPToJson(savedValue, &error);
        
        if (error)
        {
            NSLog(@"[NativePlugins] Failed to convert to json string.");
            return nil;
        }
        
        return NPCreateCStringCopyFromNSString(jsonStr);
    }
    
    return nil;
}

NPBINDING DONTSTRIP char* NPCloudServicesGetDictionary(const char* key)
{
    NSDictionary*   savedValue  = [[NSUbiquitousKeyValueStore defaultStore] dictionaryForKey:NPCreateNSStringFromCString(key)];
    if (savedValue)
    {
        NSError*    error;
        NSString*   jsonStr     = NPToJson(savedValue, &error);
        
        if (error)
        {
            NSLog(@"[NativePlugins] Failed to convert to json string.");
            return nil;
        }
        
        return NPCreateCStringCopyFromNSString(jsonStr);
    }
    
    return nil;
}

NPBINDING DONTSTRIP void NPCloudServicesSetBool(const char* key, bool value)
{
    [[NSUbiquitousKeyValueStore defaultStore] setBool:value forKey:NPCreateNSStringFromCString(key)];
}

NPBINDING DONTSTRIP void NPCloudServicesSetLong(const char* key, long value)
{
    [[NSUbiquitousKeyValueStore defaultStore] setLongLong:value forKey:NPCreateNSStringFromCString(key)];
}

NPBINDING DONTSTRIP void NPCloudServicesSetDouble(const char* key, double value)
{
    [[NSUbiquitousKeyValueStore defaultStore] setDouble:value forKey:NPCreateNSStringFromCString(key)];
}

NPBINDING DONTSTRIP void NPCloudServicesSetString(const char* key, const char* value)
{
    [[NSUbiquitousKeyValueStore defaultStore] setString:NPCreateNSStringFromCString(value) forKey:NPCreateNSStringFromCString(key)];
}

NPBINDING DONTSTRIP void NPCloudServicesSetArray(const char* key, const char* valueAsJSONStr)
{
    id  object  = nil;
    if (valueAsJSONStr)
    {
        // create native object
        NSError*    error;
        object              = NPFromJson([NSString stringWithUTF8String:valueAsJSONStr], &error);
        
        // validate request
        if (error)
        {
            NSLog(@"[NativePlugins] Failed to create NSArray object from given json string.");
            return;
        }
    }
    
    // add data to cloud
    [[NSUbiquitousKeyValueStore defaultStore] setArray:(NSArray*)object forKey:NPCreateNSStringFromCString(key)];
}

NPBINDING DONTSTRIP void NPCloudServicesSetDictionary(const char* key, const char* valueAsJSONStr)
{
    id  object  = nil;
    if (valueAsJSONStr)
    {
        // create native object
        NSError*    error;
        object              = NPFromJson([NSString stringWithUTF8String:valueAsJSONStr], &error);
    
        // validate request
        if (error)
        {
            NSLog(@"[NativePlugins] Failed to create NSDictionary object from given json string.");
            return;
        }
    }
    
    // add data to cloud
    [[NSUbiquitousKeyValueStore defaultStore] setDictionary:(NSDictionary*)object forKey:NPCreateNSStringFromCString(key)];
}

NPBINDING DONTSTRIP void NPCloudServicesRemoveKey(const char* key)
{
    [[NSUbiquitousKeyValueStore defaultStore] removeObjectForKey:NPCreateNSStringFromCString(key)];
}

NPBINDING DONTSTRIP bool NPCloudServicesSynchronize()
{
	return [[NSUbiquitousKeyValueStore defaultStore] synchronize];
}

NPBINDING DONTSTRIP char* NPCloudServicesSnapshot()
{
    NSDictionary*   snapshot    = [[NSUbiquitousKeyValueStore defaultStore] dictionaryRepresentation];
    if (snapshot)
    {
        // convert to json representation
        NSError*        error;
        NSString*       jsonStr     = NPToJson(snapshot, &error);
        
        if (error)
        {
            NSLog(@"[NativePlugins] Failed to convert to json representation.");
            return nil;
        }
        
        return NPCreateCStringCopyFromNSString(jsonStr);
    }
    
    return nil;
}
