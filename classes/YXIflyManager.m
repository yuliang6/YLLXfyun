//
//  YXMediaManager.m
//  Pods
//
//  Created by Alvin on 16/11/2.
//
//

#import "YXIflyManager.h"
#import <iflyMSC/iflyMSC.h>
@interface YXIflyManager ()
<IFlySpeechSynthesizerDelegate>
@property (nonatomic, strong) OnCompletion speakCompletion;

@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, strong) IFlySpeechSynthesizer *iflySS;
@property (nonatomic, assign) YXSpeechPriority currentPriority;
@end

@implementation YXIflyManager
+ (YXIflyManager *)sharedInstance
{
    static YXIflyManager *sharedInstace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstace = [[self alloc] init];
    });
    return sharedInstace;
}
- (instancetype)init {
    if (self = [super init]) {
        _serialQueue = dispatch_queue_create([@"com.geely.yxiflymanager" UTF8String], DISPATCH_QUEUE_SERIAL);
        _currentPriority = YXSpeechPriorityLow;
        
    }
    return self;
}
- (void)speakingWithString:(NSString *)string onCompletion:(OnCompletion)completed; {
    if (string.length <= 0) {
        return;
    }
    self.speakCompletion = completed;
    [self speakingWithString:string];
}
- (void)speakingWithString:(NSString *)string priority:(YXSpeechPriority)priority onCompletion:(OnCompletion)completed; {
    if (string.length <= 0) {
        return;
    }
    switch (self.currentPriority) {
        case YXSpeechPriorityHigh:{
            // 当前正在播放高优先级的，不能被打断
            return;
        }
            
            break;
        case YXSpeechPriorityMiddle:{
            // 当前正在播放中优先级的，只能被高优先级的打断
            if (priority == YXSpeechPriorityHigh) {
                [self stopSpeaking];
                [self speakingWithString:string];
            }
        }
            
            break;
        case YXSpeechPriorityDefault:{
            // 当前正在播放默认优先级的，可以被高、中优先级打断
            if (priority == YXSpeechPriorityHigh || priority == YXSpeechPriorityMiddle) {
                [self stopSpeaking];
                [self speakingWithString:string];
            }
        }
            
            break;
        case YXSpeechPriorityLow:{
            // 低优先级的播放随时可以被打断
            [self stopSpeaking];
            [self speakingWithString:string];
        }
            
            break;
        case YXSpeechPriorityNone:{
            [self speakingWithString:string];
        }
            break;
        default: {
            [self speakingWithString:string];
        }
            break;
    }
    self.currentPriority = YXSpeechPriorityNone;
}
- (void)speakingWithString:(NSString *)string {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.iflySS && string.length > 0) {
            [self.iflySS startSpeaking:string];
        }
    });
}

- (void)stopSpeaking {
    [self.iflySS pauseSpeaking];
    [self.iflySS stopSpeaking];
    self.currentPriority = YXSpeechPriorityNone;
    self.speakCompletion = nil;
}

- (void)onCompleted:(IFlySpeechError *)error {
    // 合成结束，开始播放
}
- (void)onSpeakProgress:(int)progress beginPos:(int)beginPos endPos:(int)endPos {
    if (progress == 100) {
        // 播放结束
        self.currentPriority = YXSpeechPriorityNone;
        if (self.speakCompletion) {
            self.speakCompletion();
            self.speakCompletion = nil;
        }
    }
}

- (BOOL)isSpeaking {
    if (_iflySS == nil) {
        return NO;
    } else {
        return [self.iflySS isSpeaking];
    }
    
}
#pragma setter&getter 
- (void)setIflyAppId:(NSString *)iflyAppId {
    _iflyAppId = iflyAppId;
    // 配置appid放在APP启动的时候
    NSString * appid = [[NSString alloc] initWithFormat:@"appid=%@", _iflyAppId];
    [IFlySpeechUtility createUtility:appid];
    [IFlySetting showLogcat:NO];
}

#pragma mark - lazyloading
- (IFlySpeechSynthesizer *)iflySS {
    @synchronized (self) {
        // 讯飞的初始化比较耗时间，防止重复初始化多次，引起讯飞报错
        if (_iflySS == nil) {
            NSAssert(self.iflyAppId.length > 1, @"必须配置APPid才能正常使用讯飞语音合成");
            
            //1.创建合成对象
            _iflySS = [IFlySpeechSynthesizer sharedInstance];
            _iflySS.delegate = self;
            //2.设置合成参数
            //设置在线工作方式
            [_iflySS setParameter:[IFlySpeechConstant TYPE_CLOUD] forKey:[IFlySpeechConstant ENGINE_TYPE]];
            //音量,取值范围 0~100
            [_iflySS setParameter:@"100" forKey: [IFlySpeechConstant VOLUME]];
            // 语速，取值范围 0~100
            [_iflySS setParameter:@"85" forKey:[IFlySpeechConstant SPEED]];
            //发音人,默认为”xiaoyan”,可以设置的参数列表可参考“合成发音人列表”
            [_iflySS setParameter:@"vixq" forKey: [IFlySpeechConstant VOICE_NAME]];
            //保存合成文件名,如不再需要,设置设置为nil或者为空表示取消,默认目录位于 library/cache下
            //    [_iFlySpeechSynthesizer setParameter:@"tts.mp3" forKey: [IFlySpeechConstant TTS_AUDIO_PATH]];
        }
        return _iflySS;
    }
}
@end
