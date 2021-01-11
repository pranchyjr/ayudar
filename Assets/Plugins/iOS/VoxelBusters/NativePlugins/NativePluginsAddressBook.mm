//
//  NativePluginsAddressBook.mm
//  Native Plugins
//
//  Created by Ashwin kumar on 22/01/19.
//  Copyright (c) 2019 Voxel Busters Interactive LLP. All rights reserved.
//

#import <Contacts/Contacts.h>
#import <Foundation/Foundation.h>
#import "NativePluginsDefines.h"
#import "NativePluginsBindingHelper.h"

#pragma mark - Callback definitions

// callback signatures
typedef void (*RequestAccessNativeCallback)(CNAuthorizationStatus status, const char* error, void* tagPtr);
typedef void (*ReadContactsNativeCallback)(void* contactsPtr, int count, const char* error, void* tagPtr);

static RequestAccessNativeCallback      _accessCallback         = nil;
static ReadContactsNativeCallback       _readContactsCallback   = nil;

#pragma mark - Custom definitions

// custom datatypes
struct NativePluginsAddressBookContactNativeData
{
    // data members
    void*           nativeObjectPtr;
    void*           firstNamePtr;
    void*           middleNamePtr;
    void*           lastNamePtr;
    void*           imageDataPtr;
    int             phoneNumberCount;
    void*           phoneNumbersPtr;
    int             emailAddressCount;
    void*           emailAddressesPtr;
    
    // destructor
    ~NativePluginsAddressBookContactNativeData()
    {
        // release c objects
        if (firstNamePtr)
        {
            free(firstNamePtr);
        }
        if (middleNamePtr)
        {
            free(middleNamePtr);
        }
        if (lastNamePtr)
        {
            free(lastNamePtr);
        }
        for (int i = 0; i < phoneNumberCount; i++)
        {
            free(((char**)phoneNumbersPtr)[i]);
        }
        free(phoneNumbersPtr);
        for (int i = 0; i < emailAddressCount; i++)
        {
            free(((char**)emailAddressesPtr)[i]);
        }
        free(emailAddressesPtr);
        
        // release native objects
        CFBridgingRelease(nativeObjectPtr);
    }
};
typedef NativePluginsAddressBookContactNativeData NativeAddressBookContactData;

#pragma mark - Wrapper class

@interface NativePluginsContactsWrapper : NSObject

+ (CNAuthorizationStatus)getAuthorizationStatus;
+ (void)requestAccess:(void*)tagPtr;
+ (void)readContacts:(void*)tagPtr;
+ (void)reset;

@end

@implementation NativePluginsContactsWrapper

// static properties
static CNContactStore*                  _contactStore           = nil;
static NativeAddressBookContactData*    _contactsArray          = nil;
static int                              _totalContacts          = 0;

+ (CNContactStore*)getContactStore
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _contactStore = [[CNContactStore alloc] init];
    });
    return _contactStore;
}

+ (CNAuthorizationStatus)getAuthorizationStatus
{
    return [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
}

+ (void)requestAccess:(void*)tagPtr
{
    CNAuthorizationStatus   authStatus  = [NativePluginsContactsWrapper getAuthorizationStatus];
    if (CNAuthorizationStatusNotDetermined == authStatus)
    {
        [[NativePluginsContactsWrapper getContactStore] requestAccessForEntityType:CNEntityTypeContacts
                                                                 completionHandler:^(BOOL granted, NSError* __nullable error) {
                                                                     // send callback
                                                                     CNAuthorizationStatus newStatus = [NativePluginsContactsWrapper getAuthorizationStatus];
                                                                     char*                 errorCStr = NPCreateCStringCopyFromNSError(error);
                                                                     _accessCallback(newStatus, errorCStr, tagPtr);

                                                                     // release c string
                                                                     if (errorCStr)
                                                                     {
                                                                         free(errorCStr);
                                                                     }
                                                                 }];
    }
    else
    {
        // send callback
        _accessCallback(authStatus, nil, tagPtr);
    }
}

+ (void)readContacts:(void*)tagPtr
{
    // prepare component
    [NativePluginsContactsWrapper clearCachedInfo];
    
    // read contacts information from database
    CNContactStore*         contactStore        = [NativePluginsContactsWrapper getContactStore];
    NSMutableArray*         contactsList        = [NSMutableArray array];
    bool                    finished            = false;
    NSError*                error               = nil;
    CNContactFetchRequest*  fetchRequest        = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[CNContactGivenNameKey,
                                                                                                       CNContactMiddleNameKey,
                                                                                                       CNContactFamilyNameKey,
                                                                                                       CNContactImageDataKey,
                                                                                                       CNContactPhoneNumbersKey,
                                                                                                       CNContactEmailAddressesKey]];
    [fetchRequest setUnifyResults:YES];
    [fetchRequest setSortOrder:CNContactSortOrderGivenName];
    
    do
    {
        finished    = [contactStore enumerateContactsWithFetchRequest:fetchRequest
                                                                error:&error
                                                           usingBlock:^(CNContact* _Nonnull contact, BOOL * _Nonnull stop) {
                                                               [contactsList addObject:contact];
                                                           }];
        
    } while (!finished);
    
    // check whether read operation status and send appropriate data using callback
    if (error)
    {
        // send error info
        char*   errorCStr = NPCreateCStringCopyFromNSError(error);
        _readContactsCallback(nil, 0, errorCStr, tagPtr);
        return;
    }
    else
    {
        NSCharacterSet* phoneNumExcludedCharacterSet    = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789+"] invertedSet];
        
        // transform data to unity format
        int                             totalContacts   = (int)[contactsList count];
        NativeAddressBookContactData    contactsArray[totalContacts];
        for (int iter = 0; iter < totalContacts; iter++)
        {
            CNContact*  currentContact      = [contactsList objectAtIndex:iter];
            
            // copy phone numbers
            NSArray*    phoneNumbers        = currentContact.phoneNumbers;
            int         phoneNumberCount    = 0;
            char**      phoneNumbersCArray  = nil;
            if (phoneNumbers != NULL)
            {
                phoneNumberCount            = (int)[phoneNumbers count];
                phoneNumbersCArray          = (char**)calloc(phoneNumberCount, sizeof(char*));
                for (int iter = 0; iter < phoneNumberCount; iter++)
                {
                    CNLabeledValue<CNPhoneNumber*>* phoneNumber     = [phoneNumbers objectAtIndex:iter];
                    NSString* rawFormatNumber                       = [[phoneNumber value] stringValue];
                    NSString* formattedNumber                       = [[rawFormatNumber componentsSeparatedByCharactersInSet:phoneNumExcludedCharacterSet] componentsJoinedByString:@""];
                    
                    // add to c-array
                    phoneNumbersCArray[iter]    = NPCreateCStringCopyFromNSString(formattedNumber);
                }
            }
            
            // copy email addresses
            NSArray*    emailAddresses  = currentContact.emailAddresses;
            int         emailCount      = 0;
            char**      emailCArray     = nil;
            if (currentContact.emailAddresses != NULL)
            {
                emailCount              = (int)[emailAddresses count];
                emailCArray             = (char**)calloc(emailCount, sizeof(char*));
                for (int iter = 0; iter < emailCount; iter++)
                {
                    CNLabeledValue<NSString*>*  emailValue      = [emailAddresses objectAtIndex:iter];
                    NSString*                   emailStr        = [emailValue value];
                    
                    // add to c-array
                    emailCArray[iter]   = NPCreateCStringCopyFromNSString(emailStr);
                }
            }
            
            // set properties
            NativeAddressBookContactData*   nativeData  = &contactsArray[iter];
            nativeData->nativeObjectPtr                 = (__bridge_retained void*)currentContact;
            nativeData->firstNamePtr                    = (void*)NPCreateCStringCopyFromNSString(currentContact.givenName);
            nativeData->middleNamePtr                   = (void*)NPCreateCStringCopyFromNSString(currentContact.middleName);
            nativeData->lastNamePtr                     = (void*)NPCreateCStringCopyFromNSString(currentContact.familyName);
            nativeData->imageDataPtr                    = (__bridge void*)currentContact.imageData;
            nativeData->phoneNumberCount                = phoneNumberCount;
            nativeData->phoneNumbersPtr                 = (void*)phoneNumbersCArray;
            nativeData->emailAddressCount               = emailCount;
            nativeData->emailAddressesPtr               = (void*)emailCArray;
        }
        
        // cache information
        _totalContacts  = totalContacts;
        _contactsArray  = contactsArray;
        
        // send data using callback
        _readContactsCallback(contactsArray, totalContacts, nil, tagPtr);
    }
}

+ (void)reset
{
    [NativePluginsContactsWrapper clearCachedInfo];
    _contactStore = nil;
}

+ (void)clearCachedInfo
{
    if (_contactsArray)
    {
        for (int iter = 0; iter < _totalContacts; iter++)
        {
            free(&_contactsArray[iter]);
        }
        
        free(_contactsArray);
    }
    
    _contactsArray  = nil;
    _totalContacts  = 0;
}

@end

#pragma mark - Native binding methods

NPBINDING DONTSTRIP void NPAddressBookRegisterCallbacks(RequestAccessNativeCallback accessCallback, ReadContactsNativeCallback readContactsCallback)
{
    // save callbacks
    _accessCallback         = accessCallback;
    _readContactsCallback   = readContactsCallback;
}

NPBINDING DONTSTRIP CNAuthorizationStatus NPAddressBookGetAuthorizationStatus()
{
    return [NativePluginsContactsWrapper getAuthorizationStatus];
}

NPBINDING DONTSTRIP void NPAddressBookRequestAccess(void* tagPtr)
{
    [NativePluginsContactsWrapper requestAccess:tagPtr];
}

NPBINDING DONTSTRIP void NPAddressBookReadContacts(void* tagPtr)
{
    [NativePluginsContactsWrapper readContacts:tagPtr];
}

NPBINDING DONTSTRIP void NPAddressBookReset()
{
    [NativePluginsContactsWrapper reset];
}
