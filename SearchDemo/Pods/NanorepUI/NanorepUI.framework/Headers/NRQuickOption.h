
// NanorepUI version number: v1.6.0 

//
// Created by Nissim Pardo on 07/06/2017.
// Copyright (c) 2017 nanorep. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NRQuickOptionKind) {
    NRQuickOptionKindCarousel,
    NRQuickOptionKindReadMore,
    NRQuickOptionKindInlineChoice,
    NRQuickOptionKindChannel,
    NRQuickOptionKindWasHelpful,
    NRQuickOptionKindLocation,
    NRQuickOptionKindFeedback,
    NRQuickOptionKindOther,
    NRQuickOptionKindTrack,
    NRQuickOptionKindUNKNOWN
};

typedef NS_ENUM(NSInteger, NRQuickOptionType) {
    NRQuickOptionTypeLocation,
    NRQuickOptionTypeApplication,
    NRQuickOptionTypePostback,
    NRQuickOptionTypeURL,
    NRQuickOptionTypeUNKNOWN
};


@interface NRQuickOption : NSObject
- (void)updateKind:(NRQuickOptionKind)kind;
- (void)updateType:(NRQuickOptionType)type;

- (instancetype)initWithParams:(NSDictionary *)params;

@property(nonatomic, copy) NSString *text;
@property (nonatomic, readonly) NSString *kind;
@property(nonatomic, copy) NSString *postback;
@property(nonatomic, copy) NSString *payload;
@property(nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) NSDictionary *params;
@end
