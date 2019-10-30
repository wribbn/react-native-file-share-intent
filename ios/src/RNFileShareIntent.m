//
//  ShareFileIntentModule.m
//  Share Intent
//
//  Created by Ajith A B on 16/08/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "RNFileShareIntent.h"
#import "RCTRootView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <RCTLog.h>
@implementation RNFileShareIntent
static NSItemProvider* ShareFileIntentModule_itemProvider;
static NSExtensionContext* extContext;

#define URL_IDENTIFIER @"public.url"
#define IMAGE_IDENTIFIER @"public.image"
#define TEXT_IDENTIFIER (NSString *)kUTTypePlainText

NSExtensionContext* extensionContext;

RCT_EXPORT_MODULE();

RCT_REMAP_METHOD(data,
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    [self extractDataFromContext: extensionContext withCallback:^(NSDictionary* dict, NSException* err) {
        NSLog(@"react-native-share-extension dict: %@", dict);
        if(err) {
            reject(@"error", err.description, nil);
        } else {
            resolve(dict);
        }
    }];
}

- (void)extractDataFromContext:(NSExtensionContext *)context withCallback:(void(^)(NSDictionary* dict, NSException *exception)) callback {
    @try {
        NSExtensionItem *item = [context.inputItems firstObject];
        NSArray *attachments = item.attachments;

        __block NSItemProvider *urlProvider = nil;
        __block NSItemProvider *imageProvider = nil;
        __block NSItemProvider *textProvider = nil;

        [attachments enumerateObjectsUsingBlock:^(NSItemProvider *provider, NSUInteger idx, BOOL *stop) {
            if([provider hasItemConformingToTypeIdentifier:URL_IDENTIFIER]) {
                urlProvider = provider;
            } else if ([provider hasItemConformingToTypeIdentifier:TEXT_IDENTIFIER]){
                textProvider = provider;
            }
        }];

        __block NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        __block BOOL ok = false;

        if(urlProvider) {
            [urlProvider loadItemForTypeIdentifier:URL_IDENTIFIER options:nil completionHandler:^(id<NSSecureCoding> item, NSError *error) {
                NSURL *url = (NSURL *)item;

                [dict setObject:[url absoluteString] forKey:@"url"];
            }];
            ok = true;
        }
        if (imageProvider) {
            [imageProvider loadItemForTypeIdentifier:IMAGE_IDENTIFIER options:nil completionHandler:^(id<NSSecureCoding> item, NSError *error) {
                NSURL *url = (NSURL *)item;

                [dict setObject:[url absoluteString] forKey:[[[url absoluteString] pathExtension] lowercaseString]];
            }];
            ok = true;
        }
        if (textProvider) {
            [textProvider loadItemForTypeIdentifier:TEXT_IDENTIFIER options:nil completionHandler:^(id<NSSecureCoding> item, NSError *error) {
                NSString *text = (NSString *)item;

                [dict setObject:text forKey:@"text"];
            }];
            ok = true;
        }

        if (!callback) return;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if (ok) {
                if (callback) {
                    callback(dict, nil);
                }
            } else {
                if (callback) {
                    callback(nil, [NSException exceptionWithName:@"Error" reason:@"couldn't find provider" userInfo:nil]);
                }
            }
        });
    }
    @catch (NSException *exception) {
        if(callback) {
            callback(nil, exception);
        }
    }
}

RCT_EXPORT_METHOD(getFilePath:(RCTResponseSenderBlock)callback)
{
    if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *url, NSError *error) {
            callback(@[url.absoluteString]);
        }];
    }

    if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeFileURL]) {
        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeFileURL options:nil completionHandler:^(NSURL *url, NSError *error) {
            callback(@[url.absoluteString]);
        }];
    }
    if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePDF]) {
        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypePDF options:nil completionHandler:^(NSURL *url, NSError *error) {
            callback(@[url.absoluteString]);
        }];
    }

    if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeBMP]) {
        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeBMP options:nil completionHandler:^(NSURL *url, NSError *error) {
            callback(@[url.absoluteString]);
        }];
    }

    if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeGIF]) {
        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeGIF options:nil completionHandler:^(NSURL *url, NSError *error) {
            callback(@[url.absoluteString]);
        }];
    }
    if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeICO]) {
        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeICO options:nil completionHandler:^(NSURL *url, NSError *error) {
            callback(@[url.absoluteString]);
        }];
    }
    if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeMP3]) {
        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeMP3 options:nil completionHandler:^(NSURL *url, NSError *error) {
            callback(@[url.absoluteString]);
        }];
    }
    if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePNG]) {
        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypePNG options:nil completionHandler:^(NSURL *url, NSError *error) {
            callback(@[url.absoluteString]);
        }];
    }
    if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeJPEG]) {
        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeJPEG options:nil completionHandler:^(NSURL *url, NSError *error) {
            callback(@[url.absoluteString]);
        }];
    }
    if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeMPEG]) {
        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeMPEG options:nil completionHandler:^(NSURL *url, NSError *error) {
            callback(@[url.absoluteString]);
        }];
    }
    if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(NSURL *url, NSError *error) {
            callback(@[url.absoluteString]);
        }];
    }
    if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeText]) {
        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeText options:nil completionHandler:^(NSURL *url, NSError *error) {
            callback(@[url.absoluteString]);
        }];
    }
    if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeAudio]) {
        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeAudio options:nil completionHandler:^(NSURL *url, NSError *error) {
            callback(@[url.absoluteString]);
        }];
    }
    if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeVideo]) {
        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeVideo options:nil completionHandler:^(NSURL *url, NSError *error) {
            callback(@[url.absoluteString]);
        }];
    }

}

RCT_EXPORT_METHOD(openURL:(NSString *)url) {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *urlToOpen = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [application openURL:urlToOpen options:@{} completionHandler: nil];
}


RCT_EXPORT_METHOD(close)
{

    [ extContext completeRequestReturningItems: @[] completionHandler: nil ];
}





+(void) setShareFileIntentModule_itemProvider: (NSItemProvider*) itemProvider
{
    ShareFileIntentModule_itemProvider = itemProvider;
}

+(void) setContext: (NSExtensionContext*) context
{
    extContext = context;
}
@end
