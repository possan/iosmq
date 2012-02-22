//
//  IOSMQ.h
//  Flyessence
//
//  Created by Per-Olov Jernberg on 2012-02-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IOSMQMessage : NSObject

+ (IOSMQMessage *)message;
+ (IOSMQMessage *)messageWithMessage:(NSString *)message;
+ (IOSMQMessage *)messageWithMessage:(NSString *)message withID:(NSString *)id;

@property (retain) NSString *id;
@property (retain) NSString *message;

@end

/*
@interface IOSMQQuery : NSObject
+ (IOSMQQuery *)query;
+ (IOSMQQuery *)queryWithMessage:(NSString *)message;
@property (retain) NSString *message;
@property (retain) NSString *messageid;
@end
*/

@class IOSMQ;

@protocol IOSMQDelegate <NSObject>

- (void) queue:(IOSMQ *)queue message:(IOSMQMessage*)message;
// - (void) queue:(IOSMQ *)queue query:(IOSMQQuery *)query;
// - (void) queue:(IOSMQ *)queue response:(NSString*)message withID:(NSString *)messageid;

@end


@interface IOSMQ : NSObject<UIWebViewDelegate> {
    NSTimer *timer;
}

@property (strong,retain) id<UIWebViewDelegate> nextDelegate;
@property (strong,retain) id<IOSMQDelegate> delegate;
@property (strong,retain) UIWebView *webview;

// + (NSString *) generateID;
+ (id) queueWithWebView:(UIWebView *)webview;

// - (id) initWithWebView:(UIWebView *)webview;
- (void) send:(IOSMQMessage *)message;
- (void) start;
// - (void) query:(IOSMQQuery *)query;
// - (void) postMessage:(NSString *)string;
// - (void) sendResponse:(NSString *)message toQuery:(NSString *)messageid;

@end
