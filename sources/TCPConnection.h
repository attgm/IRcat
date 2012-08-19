//
//  $RCSfile: TCPConnection.h,v $
//  
//  $Revision: 53 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#import <Foundation/Foundation.h>

typedef enum {
	IRStateDisconnect,
    IRStateConnecting,
    IRStateConnected
} ConnectionState;

typedef enum {
	IRErrorIllegalAddress	= -1,
	IRErrorCannotConnect	= -2
} ConnectionErrorCode;

@protocol Session
-(void) handleIncommingData : (NSData*) inIncommingData;
-(void) handleConnected;
-(void) handleDisconnect;
-(void) handleConnectionError:(int) inErrorCode;
@end

@protocol TCPEndPointHandlerProtocol
-(void) handleConnected;
-(void) handleConnectionFailed:(int) inError;
@end;


@interface TCPConnection : NSObject <TCPEndPointHandlerProtocol, NSStreamDelegate> {
	NSMutableData*	_localDataBuffer;
	NSMutableArray* _dataQueue;
	
    ConnectionState _state;

    id _session;

    BOOL _hasIncommingData;
    NSTimer* _idleTimer;
    
	NSInputStream*	_inputStream;
	NSOutputStream* _outputStream;
}

-(id) initWithSession:(id)inSession;

-(BOOL) connectTo:(NSString*)inHostname port:(int)inPort;
-(void) disconnect;

//-- recive and send
-(BOOL) sendData:(NSData*)inData immediately:(BOOL)immediate;
-(void) sendDataInInterval:(id) userInfo;
-(void) stopTimer;

-(void) readAvailableData;

-(void) handleIncommingData;
-(void) reciveLine:(NSData*) inData;
-(void) handleDisconnect;

-(void) acceptToWriteData;
-(void) handleConnected;
-(void) handleConnectionFailed:(int)inError;

-(void) handleInputStreamEvent:(NSStreamEvent)eventCode;
-(void) handleOutputStreamEvent:(NSStreamEvent)eventCode;


@end

