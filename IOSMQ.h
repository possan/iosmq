//
//  IOSMQ.h
//
//  Created by Per-Olov Jernberg on 2012-02-22.
//

#import <Foundation/Foundation.h>

@interface IOSMQMessage : NSObject

+ (IOSMQMessage *)message;
+ (IOSMQMessage *)messageWithMessage:(NSString *)message;
+ (IOSMQMessage *)messageWithMessage:(NSString *)message withID:(NSString *)id;

@property (retain) NSString *id;
@property (retain) NSString *message;

@end

@class IOSMQ;

@protocol IOSMQDelegate <NSObject>

- (void) queue:(IOSMQ *)queue message:(IOSMQMessage*)message;

@end

@interface IOSMQ : NSObject<UIWebViewDelegate> {
    NSTimer *timer;
}

@property (strong,retain) id<UIWebViewDelegate> nextDelegate;
@property (strong,retain) id<IOSMQDelegate> delegate;
@property (strong,retain) UIWebView *webview;
@property (nonatomic,assign) float pollInterval;

+ (id) queueWithWebView:(UIWebView *)webview;

- (void) send:(IOSMQMessage *)message;
- (void) start;

@end
