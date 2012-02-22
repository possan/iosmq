(function(target){
 
 if( target.IOSMQ )
    return;
 
 var IOSMQ = {
 };
 
 var _receivequeue = [];
 var _sendqueue = [];
 var _msgcallbacks = {};
 var _idx = 0;
 var _listeners = [];
 
 IOSMQ._genid = function() {
    _idx ++;
    return "JSMSG."+_idx+"."+Math.round(Math.random()*10000000);
 }
 
 IOSMQ._backendPollString = function() {
    if( _sendqueue.length == 0 )
        return '';
 
    var item = _sendqueue[0];
    _sendqueue.splice(0,1);
    return JSON.stringify(item);
 }
 
 IOSMQ._backendPush = function(msg)  {
    // _receivequeue.push(msg);
    if( typeof( _msgcallbacks[ msg.id ] ) != 'undefined' )  {
        _msgcallbacks[ msg.id ].call( null, msg.message, msg.id );
        delete _msgcallbacks[ msg.id ];
        // _msgcallbacks[ msg.id ] = undefined;
    } else {
        for( var i=0; i<_listeners.length; i++ ) {
            _listeners[i].call( null, msg.message, msg.id );
        }
    }
 }
 
 IOSMQ.post = function(msg, id) {
    if(typeof(id) == 'undefined')
        id = IOSMQ._genid();
    _sendqueue.push( { id:id, message: msg } );
 }
 
 IOSMQ.get = function(msg, callback) {
    var id = IOSMQ._genid();
    _sendqueue.push( { id:id, message: msg } );
    _msgcallbacks[id] = callback;
 }
 
 IOSMQ.listen = function(callback) {
    _listeners.push(callback);
 }
 
 target.IOSMQ = IOSMQ; 
 
})(this);

 
 
