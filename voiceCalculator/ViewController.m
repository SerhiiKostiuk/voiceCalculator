//
//  ViewController.m
//  voiceCalculator
//
//  Created by Сергій Костюк on 10/10/17.
//  Copyright © 2017 Сергій Костюк. All rights reserved.
//

#import "ViewController.h"
#import "VoiceRecognizer.h"

@interface ViewController () <VoiceRecognizerAnswerDelegate>

@property (nonatomic, strong) VoiceRecognizer *recognizer;
@property (weak, nonatomic) IBOutlet UIButton *startRecordButton;
@property (weak, nonatomic) IBOutlet UITextView *resultTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.startRecordButton.enabled = NO;
    
    self.recognizer = [[VoiceRecognizer alloc] init];
    self.recognizer.delegate = self;
    __weak typeof(self)weakSelf = self;
    
    [self.recognizer setupVoiceRecognizer:^(BOOL isAutorized) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            strongSelf.startRecordButton.enabled = isAutorized;
        });
    }];
}

- (IBAction)startRecordButtonTapped:(id)sender {
    if (self.recognizer.audioEngine.isRunning == YES) {
        [self.recognizer stopRecord];
        [self.startRecordButton setTitle:@"Start Recording" forState:UIControlStateNormal];
    } else {
        [self.recognizer startRecording];
        [self.startRecordButton setTitle:@"Stop Record" forState:UIControlStateNormal];
    }
}

- (void)voiceRecognizerAnswer:(NSString *)answer {
    dispatch_async(dispatch_get_main_queue(), ^{
    self.resultTextView.text = answer.capitalizedString;
    });
}

- (void)microphoneAvailabilityDidChange:(BOOL)avaliable {
    self.startRecordButton.enabled = avaliable;
}


@end
