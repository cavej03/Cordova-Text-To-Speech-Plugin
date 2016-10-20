#import <Cordova/CDV.h>
#import <AVFoundation/AVFoundation.h>

@interface TtsPlugin : CDVPlugin

- (void)initTTS:(CDVInvokedUrlCommand*)command;
- (void)setRate:(CDVInvokedUrlCommand*)command;
- (void)setLanguage:(CDVInvokedUrlCommand*)command;
- (void)setVoice:(CDVInvokedUrlCommand*)command;
- (void)getVoices:(CDVInvokedUrlCommand*)command;
- (void)speak:(CDVInvokedUrlCommand*)command;
- (void)getSpeechStatus:(CDVInvokedUrlCommand*)command;
- (void)stop:(CDVInvokedUrlCommand*)command;
- (void)pause:(CDVInvokedUrlCommand*)command;
- (void)resume:(CDVInvokedUrlCommand*)command;
- (void)restart:(CDVInvokedUrlCommand*)command;

@end
