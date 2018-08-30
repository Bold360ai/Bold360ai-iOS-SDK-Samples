
// NanorepUI version number: v1.5.8.rc2 

//
//  NSString+Utilities.h
//  NanoRepSDK
//
//  Created by Nissim Pardo on 9/2/15.
//  Copyright (c) 2015 nanorep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *const NRScriptsPath;
extern NSString *const NRFaqPath;
extern NSString *const NRWidgetPath;
extern NSString *const NRGifPath;

typedef NS_ENUM(NSInteger, NRPathType) {
    NRPathTypeScripts,
    NRPathTypeFaq,
    NRPathTypeWidget,
    NRPathTypeGIF
};

@interface NSString (Utilities)
@property (nonatomic, readonly) NSString *appParams;
@property (nonatomic, readonly) NSMutableURLRequest *refererRequest;
@property (nonatomic, readonly) NSString *md5;
@property (nonatomic, readonly, copy) NSString *wrappedBase64;
@property (nonatomic, readonly) NRPathType pathType;
@property (nonatomic, readonly) UIColor *hex;
@property (nonatomic, readonly) NSDictionary *parseJSON;
@property (nonatomic, readonly) NSString *methodName;
@property (nonatomic, readonly) NSString *decode;
@property (nonatomic, readonly) NSString *resultId;
@property (nonatomic, readonly) NSString *inHex;
@property (nonatomic, readonly, copy) NSArray *extractExtraData;
@property (nonatomic, readonly) NSString *extractSelector;
@property (nonatomic, readonly) NSString *extractSignature;
@property (nonatomic, readonly) NSArray *extractArguments;
@property (nonatomic, readonly) NSString *inJsonText;
@end
