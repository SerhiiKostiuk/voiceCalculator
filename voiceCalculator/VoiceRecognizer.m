//
//  VoiceRecognizer.m
//  voiceCalculator
//
//  Created by Сергій Костюк on 10/10/17.
//  Copyright © 2017 Сергій Костюк. All rights reserved.
//

#import "VoiceRecognizer.h"
#import "Converter.h"

@interface VoiceRecognizer () <SFSpeechRecognizerDelegate>
@property (nonatomic, strong) SFSpeechRecognizer                    *voiceRecognizer;
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property (nonatomic, strong) SFSpeechRecognitionTask               *recognitionTask;
@property (nonatomic, strong) AVAudioEngine                         *audioEngine;
@property (nonatomic, strong) Converter                             *converter;

@end

@implementation VoiceRecognizer

- (void)setupVoiceRecognizer:(void (^)(BOOL isAutorized))handler {
    self.voiceRecognizer = [[SFSpeechRecognizer alloc]initWithLocale:[NSLocale localeWithLocaleIdentifier:@"en-US"]];
    self.voiceRecognizer.delegate = self;
    self.converter = [Converter new];
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        BOOL isEnabled = NO;
        switch (status) {
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                isEnabled = YES;
                break;
                
            default:
                break;
        }
        
        handler(isEnabled);
    }];
    
    self.audioEngine = [AVAudioEngine new];
}

- (void)stopRecord {
    if (self.audioEngine.isRunning) {
        [self.audioEngine stop];
        [self.recognitionRequest endAudio];
        [self.audioEngine.inputNode removeTapOnBus:0];
    }
}

- (void)startRecording {
    if (self.recognitionTask != nil) {
        [self.recognitionTask cancel];
        self.recognitionTask = nil;
    }
    
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    @try {
        [audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
        [audioSession setMode:AVAudioSessionModeMeasurement error:&error];
        [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    } @catch (NSException *exception) {
        NSLog(@"Get error");
    }
    
    self.recognitionRequest = [SFSpeechAudioBufferRecognitionRequest new];
    AVAudioInputNode *inputNode = self.audioEngine.inputNode;
    
    if (inputNode == nil) {
        NSLog(@"input node is nil");
    }
    if (self.recognitionRequest == nil) {
        NSLog(@"recognition Request is nil");
    }
    __weak typeof(self)weakSelf = self;

    self.recognitionRequest.shouldReportPartialResults = YES;
    self.recognitionTask = [self.voiceRecognizer recognitionTaskWithRequest:self.recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;

        if (result != nil && result.isFinal == YES) {
            [strongSelf.delegate voiceRecognizerAnswer:[strongSelf.converter wordsFromNumbersString:result.bestTranscription.formattedString]];
        }
    }];
    
    AVAudioFormat *audioFormat = [inputNode outputFormatForBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:audioFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    
    [self.audioEngine prepare];
    
    @try {
        [self.audioEngine startAndReturnError:&error];
    } @catch (NSException *exception) {
        NSLog(@"get error when audio engine start %@", exception);
    }
}

- (void)speechRecognizer:(SFSpeechRecognizer*)speechRecognizer availabilityDidChange:(BOOL)available {
    [self.delegate microphoneAvailabilityDidChange:available];
}

@end
