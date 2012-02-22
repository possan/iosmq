Simple Objective-C to JavaScript bridge
=======================================

I needed to communicate between the app logic and the standard html pages deployed on a regular webserver, so this is the result, it's polling for events from javascript every second which isn't optimal but could easily be changed.

Requires the excellent [SBJSON JSON Library](http://stig.github.com/json-framework/)

On the Objective-C end:
-----------------------

Initialize the messagequeue and connect it to a UIWebView 

```Objective-C
mq = [[IOSMQ queueWithWebView:browserview] retain];
[mq setDelegate:self];
[mq start];
```

Implement the callback in your delegate

```Objective-C
- (void)queue:(IOSMQ *)queue message:(IOSMQMessage *)message {
    NSLog( @"Got message:%@ with id:%@", message.message, message.id );
    if( [message.message hasPrefix:@"purchase-status/"] ) {
        NSString *pid = [message.message substringFromIndex:16];
        // check status for specific id and then send the response...
        [queue send:[IOSMQMessage messageWithMessage:[NSString stringWithFormat:@"reply data from app (pid=%@)", pid] withID:message.id]];
    }
}
```

Send messages to the html app

```Objective-C
[mq send:[IOSMQMessage messageWithMessage:@"message from app"]];
````

In JavaScript land:
-------------------

Embed the javascript code in your page or load it

Register your callbacks:

```JavaScript
IOSMQ.listen(function(message,id){
	alert('got message from app; message='+message+', id='+id);
	// id is used if you want to reply to the sender
});
```

Query for data in the native app:

```JavaScript
IOSMQ.get( 'purchase-status/'+id, function( answer ) {
	alert(answer);
} );
```

Just posting messages to the native app is easy:

```JavaScript
IOSMQ.post('msg123');
```







