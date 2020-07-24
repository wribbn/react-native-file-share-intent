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
#define PUBLIC_IMAGE_IDENTIFIER @"public.image"
#define JPEG_IMAGE_IDENTIFIER @"public.jpeg"
#define UTT_IMAGE_IDENTIFIER (NSString *)kUTTypeImage
#define TEXT_IDENTIFIER (NSString *)kUTTypePlainText

RCT_EXPORT_MODULE();

RCT_REMAP_METHOD(data,
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    [self extractDataFromContext: extContext withCallback:^(NSDictionary* dict, NSException* err) {
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
        NSMutableArray *images = [NSMutableArray array];

        NSLog(@"****** ATTACHMENTS ******: %@",attachments);

        __block NSItemProvider *urlProvider = nil;
        __block NSItemProvider *publicImageProvider = nil;
        __block NSItemProvider *uttImageProvider = nil;
        __block NSItemProvider *textProvider = nil;
        __block NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        __block BOOL ok = false;

        [attachments enumerateObjectsUsingBlock:^(NSItemProvider *provider, NSUInteger idx, BOOL *stop) {
            if([provider hasItemConformingToTypeIdentifier:URL_IDENTIFIER]) {
                urlProvider = provider;
            } else if ([provider hasItemConformingToTypeIdentifier:TEXT_IDENTIFIER]){
                textProvider = provider;
            } else if ([provider hasItemConformingToTypeIdentifier:PUBLIC_IMAGE_IDENTIFIER]) {
                publicImageProvider = provider;

            [publicImageProvider loadItemForTypeIdentifier:PUBLIC_IMAGE_IDENTIFIER options:nil completionHandler:^(id<NSSecureCoding> item, NSError *error) {
                    NSURL *imageUrl = (NSURL *)item;
                    NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
                    UIImage *image = [UIImage imageWithData:imageData];
                    NSNumber *width = [NSNumber numberWithFloat:image.size.width];
                    NSNumber *height = [NSNumber numberWithFloat:image.size.height];

                    __block NSMutableDictionary* response = [[NSMutableDictionary alloc] init];

                    [response setObject:[imageUrl absoluteString] forKey:@"filePath"];
                    [response setObject:width forKey:@"width"];
                    [response setObject:height forKey:@"height"];

                    [images addObject:response];

                    ok = true;
                }];
            } else if ([provider hasItemConformingToTypeIdentifier:UTT_IMAGE_IDENTIFIER]) {
                uttImageProvider = provider;

                [uttImageProvider loadItemForTypeIdentifier:UTT_IMAGE_IDENTIFIER options:nil completionHandler:^(id<NSSecureCoding> item, NSError *error) {
                    if (item) {
                        NSURL *url = (NSURL *)item;

                        [dict setObject:[url absoluteString] forKey:[[[url absoluteString] pathExtension] lowercaseString]];
                    } else if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(NSURL *url, NSError *error) {

                            if (url) {
                                [dict setObject:[url absoluteString] forKey:[[[url absoluteString] pathExtension] lowercaseString]];
                            } else {
                                [dict setObject:@"provider_failure" forKey:@"error"];
                            }
                        }];
                    } else {
                        [dict setObject:@"provider_failure" forKey:@"error"];
                    }
                }];

                ok = true;
            }
        }];

        if(urlProvider) {
            [urlProvider loadItemForTypeIdentifier:URL_IDENTIFIER options:nil completionHandler:^(id<NSSecureCoding> item, NSError *error) {
                NSURL *url = (NSURL *)item;

                NSLog(@"****** URL ******: %@", url);

                [dict setObject:[url absoluteString] forKey:@"url"];
            }];
            ok = true;
        }
        if (textProvider) {
            [textProvider loadItemForTypeIdentifier:TEXT_IDENTIFIER options:nil completionHandler:^(id<NSSecureCoding> item, NSError *error) {
                NSString *text = (NSString *)item;
                NSLog(@"****** TEXT ******: %@", text);
                [dict setObject:text forKey:@"text"];
            }];
            ok = true;
        }

        if (sizeof images) {
          [dict setObject:images forKey:@"images"];
        }

        if (!callback) return;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
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

RCT_EXPORT_METHOD(getBase64StringFromFilePath:(NSString *)imagePath resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    NSURL *imageUrl = [NSURL URLWithString:[imagePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *dataFromFile = [NSData dataWithContentsOfFile:imageUrl.path];
    NSString *base64String = nil;

    if (dataFromFile == nil) {
        resolve(@[[NSNull null], base64String]);
    } else {
        NSString *base64String = [dataFromFile base64EncodedStringWithOptions:0];
        resolve(@[[NSNull null], base64String]);
    }
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
