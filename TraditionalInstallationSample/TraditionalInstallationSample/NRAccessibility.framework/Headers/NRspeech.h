
// NanorepUI version number: v1.5.8.rc2 

//
//  NRspeech.h
//  NRAccessibility
//
//  Created by Nissim Pardo on 04/03/2018.
//  Copyright © 2018 Nissim Pardo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NRSpeechDelegate.h"
#import "NRSpeechRecognizerAuthorizationStatus.h"

@protocol NRSpeech <NSObject>
@property (nonatomic, copy) NSLocale *locale;
@property (nonatomic, weak) id<NRSpeechDelegate> delegate;
- (void)record;
- (void)requestAuthorization:(void(^)(NRSpeechRecognizerAuthorizationStatus status))handler;
@end
