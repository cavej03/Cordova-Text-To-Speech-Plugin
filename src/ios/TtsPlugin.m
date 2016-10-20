#import "TtsPlugin.h"
#import <Cordova/CDV.h>

@implementation TtsPlugin

AVSpeechSynthesizer *synth;
//NSString *lang = @"en-US";
NSString *lang = @"en-US";
AVSpeechSynthesisVoice *globalVoice;
double rate = 0.2;
NSString *currentLocale;

- (void)initTTS:(CDVInvokedUrlCommand*)command{
    synth = [[AVSpeechSynthesizer alloc] init];
    synth.delegate = self;

    NSString *locale = [[NSLocale currentLocale] localeIdentifier];
    NSRange startRange = [locale rangeOfString:@"_"]; // this isn't the underscore you see in the first string
    currentLocale = [locale stringByReplacingCharactersInRange:NSMakeRange(0, startRange.length+1) withString:[[NSLocale preferredLanguages] objectAtIndex:0]];
    currentLocale = [currentLocale stringByReplacingOccurrencesOfString:@"_"
                                         withString:@"-"];
    NSLog(@"current locale: %@", currentLocale);

    
    for (AVSpeechSynthesisVoice *voice in [AVSpeechSynthesisVoice speechVoices]) {
        NSLog(@"voice: %@", voice.language);
        NSString *language = voice.language;
        
        if ([language isEqualToString:currentLocale]){
            NSLog(@"setting voice to locale: %@", currentLocale);
            globalVoice = voice;
        }
    }
    
    
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
        //NSLog(@"setting rate: %f", rate);
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    @catch (NSException * e) {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"ERROR"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    //@finally { }
}

- (void)getVoices:(CDVInvokedUrlCommand*)command{
    NSMutableArray *stringArray = [[NSMutableArray alloc] init];
    for (AVSpeechSynthesisVoice *voice in [AVSpeechSynthesisVoice speechVoices]) {
        NSString *fullstring = voice.name;
        NSString *nameAndLocale = [fullstring stringByAppendingString:voice.language];
        [stringArray addObject:nameAndLocale];
    }
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:stringArray];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setVoice:(CDVInvokedUrlCommand*)command{
    NSString* text = [command.arguments objectAtIndex:0];
    
    for (AVSpeechSynthesisVoice *voice in [AVSpeechSynthesisVoice speechVoices]) {
        NSLog(@"voice: %@", voice.language);
        NSLog(@"name: %@", voice.name);
        //NSString *language = voice.language;
        NSString *name = voice.name;
        
        if ([name isEqualToString:text]){
            NSLog(@"setting voice to locale: %@", currentLocale);
            globalVoice = voice;
        }
        
//        
//        if ([language isEqualToString:text]){
//            NSLog(@"setting voice to locale: %@", currentLocale);
//            globalVoice = voice;
//        }
        
    }
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:globalVoice.language];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


- (void)speak:(CDVInvokedUrlCommand*)command{
    NSString* text = [command.arguments objectAtIndex:0];
    //AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:@"by not setting it it should use the default cool cool"];
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
//    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:lang];
    utterance.voice = globalVoice;
    //utterance.voice = [AVSpeechSynthesisVoice currentLanguageCode]; JC didnt work... 20150609 by not setting it it should use the default locale
    
    //NSLog(@"max: %f", AVSpeechUtteranceMaximumSpeechRate);
    //NSLog(@"min: %f", AVSpeechUtteranceMinimumSpeechRate);
    //NSLog(@"default: %f", AVSpeechUtteranceDefaultSpeechRate);

    utterance.rate = rate*AVSpeechUtteranceDefaultSpeechRate/0.2;
    NSLog(@"current: %f", utterance.rate);
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
    bool isPaused = [synth isPaused];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"stopped"];
     //NSString *speechStatus = @"stopped";

    if (isSpeaking && isPaused){
        // *speechStatus = @"paused";
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"paused"];
    }else if(isSpeaking){
        // *speechStatus = @"speaking";
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"speaking"];
    }

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

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance{
    NSLog(@"Started Speaking");
    [self.commandDelegate evalJs:@"ttsPlugin.callbacks.startedSpeaking()"];
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance{
    NSLog(@"Stopped Speaking");
    [self.commandDelegate evalJs:@"ttsPlugin.callbacks.finishedSpeaking()"];
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance{
    NSLog(@"Paused Speaking");
    [self.commandDelegate evalJs:@"ttsPlugin.callbacks.pausedSpeaking()"];
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance *)utterance{
    NSLog(@"Continued Speaking");
    [self.commandDelegate evalJs:@"ttsPlugin.callbacks.continuedSpeaking()"];
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance{
    NSLog(@"Cancelled Speaking");
    [self.commandDelegate evalJs:@"ttsPlugin.callbacks.cancelledSpeaking()"];
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance{
    //NSLog(@"willSpeakRangeOfSpeechString: %@", NSStringFromRange(characterRange));
    NSString* jsString = [[NSString alloc] initWithFormat:@"ttsPlugin.callbacks.currentRangeOfSpeech(\"%@\")",NSStringFromRange(characterRange)];
    [self.commandDelegate evalJs:jsString];
}

@end
