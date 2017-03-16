//
//  YXMediaManager.h
//  Pods
//
//  Created by Alvin on 16/11/2.
//
//

#import <Foundation/Foundation.h>
// 标号越高，优先级越高
typedef NS_ENUM(NSInteger, YXSpeechPriority) {
    YXSpeechPriorityNone            = 0,    // 保留标示符，标示语音播放完成
    YXSpeechPriorityLow             = 1,    // 低优先级，可以被所有优先级的打断
    YXSpeechPriorityDefault         = 2,    // 默认优先级，除了低优先级外，可以被打断
    YXSpeechPriorityMiddle          = 3,    // 次高优先级，只可以被最高优先级或者同级的打断
    YXSpeechPriorityHigh            = 4,    // 最高优先级，这个优先级的语音正在播放时，不可被打断
};

typedef void(^OnCompletion)();

@interface YXIflyManager : NSObject

/**
 是否有任务正在播放
 */
@property (nonatomic, assign, readonly) BOOL isSpeaking;

/**
 讯飞的APPkey，必须设置APPId才能使用语音合成
 建议：APP启动的时候就配置好
 */
@property (nonatomic, strong) NSString *iflyAppId;

+ (YXIflyManager *)sharedInstance;

/**
 停止当前的播放
 */
- (void)stopSpeaking;

/**
 开始合成且自动播放

 @param string   要合成的文字
 @param priority 播放优先级
 */
- (void)speakingWithString:(NSString *)string priority:(YXSpeechPriority)priority onCompletion:(OnCompletion)completed;

- (void)speakingWithString:(NSString *)string onCompletion:(OnCompletion)completed;
@end
