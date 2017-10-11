//
//  VoiceRecognizer.h
//  voiceCalculator
//
//  Created by Сергій Костюк on 10/10/17.
//  Copyright © 2017 Сергій Костюк. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Speech/Speech.h>

@protocol VoiceRecognizerAnswerDelegate <NSObject>

- (void)voiceRecognizerAnswer:(NSString *)answer;
- (void)microphoneAvailabilityDidChange:(BOOL)avaliable;

@end

@interface VoiceRecognizer : NSObject
@property (nonatomic, readonly) AVAudioEngine *audioEngine;

@property (nonatomic, weak) id<VoiceRecognizerAnswerDelegate>        delegate;

- (void)setupVoiceRecognizer:(void (^)(BOOL isAutorized))handler;
- (void)startRecording;
- (void)stopRecord;



@end
