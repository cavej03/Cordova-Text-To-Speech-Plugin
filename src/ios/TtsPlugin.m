#import "TtsPlugin.h"
#import <Cordova/CDV.h>

@implementation TtsPlugin

AVSpeechSynthesizer *synth;
NSString *lang = @"en-US";
double rate = .2;

- (void)initTTS:(CDVInvokedUrlCommand*)command{
    synth = [[AVSpeechSynthesizer alloc] init];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setLanguage:(CDVInvokedUrlCommand*)command{
    lang = [command.arguments objectAtIndex:0];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setRate:(CDVInvokedUrlCommand*)command{
    @try {
        rate = [[command.arguments objectAtIndex:0] doubleValue];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    @catch (NSException * e) {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"ERROR"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    //@finally { }
}

- (void)speak:(CDVInvokedUrlCommand*)command{
    NSString* text = [command.arguments objectAtIndex:0];
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:lang];
    utterance.rate = rate;
    [synth speakUtterance:utterance];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:text];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)stop:(CDVInvokedUrlCommand*)command{
    [synth stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getSpeechStatus:(CDVInvokedUrlCommand*)command{
    bool isSpeaking = [synth isSpeaking];
    bool isPaused = [synth isSpeaking];
    NSMutableString *speechStatus = @"stopped";

    if (isSpeaking && isPaused){
        *speechStatus = @"paused";
    }else if(isSpeaking){
        *speechStatus = @"speaking";
    }

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:speechStatus];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)pause:(CDVInvokedUrlCommand*)command{
    [synth pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)resume:(CDVInvokedUrlCommand*)command{
    [synth continueSpeaking];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)restart:(CDVInvokedUrlCommand*)command{
    [synth continueSpeaking];
    [synth stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end