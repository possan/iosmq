//
//  IOSMQ.m
//  Flyessence
//
//  Created by Per-Olov Jernberg on 2012-02-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IOSMQ.h"
#import "JSON.h"
#include <time.h>

@implementation IOSMQMessage

@synthesize id;
@synthesize message;

+ (IOSMQMessage *) message {
    IOSMQMessage *ret = [[IOSMQMessage alloc] init];
    return [ret autorelease];
}

+ (IOSMQMessage *)messageWithMessage:(NSString *)message {
    IOSMQMessage *ret = [[IOSMQMessage alloc] init];
    ret.message = message;
    return [ret autorelease];
}

+ (IOSMQMessage *)messageWithMessage:(NSString *)message withID:(NSString *)id {
    IOSMQMessage *ret = [[IOSMQMessage alloc] init];
    ret.message = message;
    ret.id = id;
    return [ret autorelease];
}

- (id) init {
    self = [super init];
    if( self != nil ) {
        self.id = [NSString stringWithFormat:@"APPMSG.%d.%d",time(NULL),rand()];
        self.message = @"";
    }
    return self;
}

@end
 
@implementation IOSMQ

@synthesize nextDelegate;
@synthesize delegate;
@synthesize webview;
@synthesize pollInterval;

- (id) initWithWebView:(UIWebView *)_webview {
    self = [super init];
    if( self != nil ) { 
        self.pollInterval = 0.5;
        self.webview = _webview;
        self.nextDelegate = _webview.delegate;
        _webview.delegate = nil;
    }
    return self;
}

+ (id) queueWithWebView:(UIWebView *)webview {
    IOSMQ *mq = [[IOSMQ alloc] initWithWebView:webview];
    return [mq autorelease];
}

+ (NSString *) generateID {
    return @"";
}

- (void) send:(IOSMQMessage *)message {
    // TODO: Use SBJsonWriter instead
    NSString *js = [NSString stringWithFormat:@"IOSMQ._backendPush({id:'%@',message:'%@'})",message.id,message.message];
    NSLog(@"pushing json: %@",js);
    [self.webview stringByEvaluatingJavaScriptFromString:js];
} 

- (void) _poll {
    NSString *polled = [self.webview stringByEvaluatingJavaScriptFromString:@"IOSMQ._backendPollString()"];
    if( [polled hasPrefix:@"{"] ) {
        // NSLog(@"IOSMQ: polled json: %@", polled );
        // probably json...
        id jsonroot = [polled JSONValue];
        if( jsonroot != nil) {
            // NSLog(@"jsonroot=%@",jsonroot);
            IOSMQMessage *msg = [IOSMQMessage message];
            id _id = [[jsonroot objectForKey:@"id"] retain];
            id _msg = [[jsonroot objectForKey:@"message"] retain];
            // NSLog(@"IOSMQ: json id = %@", _id );
            // NSLog(@"IOSMQ: json message = %@", _msg );
            msg.id = _id;
            msg.message = _msg;
            if( delegate != nil )
                [delegate queue:self message:msg];
            [_id release];
            [_msg release];
        }
    }
}

- (void) start {
    NSLog(@"IOSMQ: start" );
    // hook events
    [self.webview setDelegate:self];
    self->timer = [NSTimer scheduledTimerWithTimeInterval:self.pollInterval target:self selector:@selector(_poll) userInfo:nil repeats:YES];
}

- (void) dealloc {
    [self->timer invalidate];
    [self->timer release];
    [super dealloc];
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"IOSMQ: did fail; %@", error);
    if( nextDelegate != nil )
        [nextDelegate webView:webView didFailLoadWithError:error];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"IOSMQ: did start load");
    
    if( nextDelegate != nil )
        [nextDelegate webViewDidStartLoad:webView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"IOSMQ: did finish loading");
    
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"IOSMQ" ofType:@"js"];
    if( filepath != nil ){
        NSString *js = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
        if( js != nil ){
            NSLog(@"Injecting IOSMQ JavaScript..."); // too late for onload to work though :/
            [webView stringByEvaluatingJavaScriptFromString:js];
        }
    }

    if( nextDelegate != nil )
        [nextDelegate webViewDidFinishLoad:webView];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString* urlString = [[request URL] absoluteString];
    NSLog(@"IOSMQ: request: %@", urlString);

    if( nextDelegate != nil )
        return [nextDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    
    return YES;
}






@end
