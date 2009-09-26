//
//  $RCSfile: TCPConnection.m,v $
//  
//  $Revision: 53 $
//  $Date: 2008-01-21 21:07:07 +0900#$
//

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/fcntl.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>

#import "TCPConnection.h"

const char code_CR = '\r';
const char code_LF = '\n';

//--- skipNextLine
// 次のCRもしくはLFまで読み飛ばす
const unsigned char* skipNextLine(const unsigned char* inString,
			 unsigned int inLength,
			 unsigned int* outLength)
{
    const unsigned char* pos = inString;
    unsigned int length = inLength;
    *outLength = 0;

    if (pos == nil || length == 0) return pos;
    
    // CRもしくはLFまで読み飛ばす
    while(*pos != code_CR && *pos != code_LF){
		pos++;
		if (--length < 1) return inString;
    }
    // 読み飛ばしたbyte数を出力
    *outLength = pos - inString;
    // 後ろのCR LFも読み飛ばす
    while(*pos == code_CR || *pos == code_LF){
		pos++;
		if (--length < 1) return pos;
    }

    return pos;
}


#pragma mark -

@implementation TCPConnection

//--- init
// 初期化
- (id) initWithSession:(id) inSession
{
    [super init];
    _localDataBuffer = [[NSMutableData alloc] init];
    _state = IRStateDisconnect;
    _session = [inSession retain];
    _dataQueue = [[NSMutableArray alloc] initWithCapacity:5];
    return self;
}


//--- dealloc
- (void) dealloc
{
    [self disconnect];
    [_session release];
	[super dealloc];
}


#pragma mark -

//--- connectTo
// hostname:portに接続する
- (BOOL) connectTo : (NSString*) hostName
			  port : (int) portNumber
{
    if (_state != IRStateDisconnect)
		return NO;
	
	if(hostName == nil){
		NSLog(@"TCPConnection:Null Hostname or Port");
		return NO;
	}
	
	NSHost* host = [NSHost hostWithName:hostName];
	[NSStream getStreamsToHost:host port:portNumber inputStream:&_inputStream outputStream:&_outputStream];
	
	[_inputStream setDelegate:self];
	[_outputStream setDelegate:self];
	
	[_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	
	[_inputStream open];
	[_outputStream open];
	
	_state = IRStateConnecting;
    _hasIncommingData = NO;
    return YES;
}


//-- steam:handleEvent
// Both streams call this when events happen
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
	if(stream == _inputStream){
        [self handleInputStreamEvent:eventCode];
    }else if(stream == _outputStream){
        [self handleOutputStreamEvent:eventCode];
    }
}


//-- handleInputStreamEvent
// 
- (void)handleInputStreamEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventHasBytesAvailable:
            [self readAvailableData];
            break;
        case NSStreamEventOpenCompleted:
            [self handleConnected];
			break;
		case NSStreamEventErrorOccurred:
		case NSStreamEventEndEncountered:
			[self handleDisconnect];
			break;
        default:
			NSLog(@"%d", eventCode);
            break;
    }
}


//-- handleOutputStreamEvent
// 
-(void) handleOutputStreamEvent:(NSStreamEvent) eventCode
{
	switch(eventCode){
		case NSStreamEventHasSpaceAvailable:
			[self acceptToWriteData];
			break;
		case NSStreamEventOpenCompleted:
			break;
		case NSStreamEventErrorOccurred:
		case NSStreamEventEndEncountered:
			[self handleDisconnect];
			break;
		default:
			NSLog(@"%d", eventCode);
			break;
	}
}


//-- handleConnected
// 接続完了
-(void) handleConnected
{
	_state = IRStateConnected;
    _hasIncommingData = NO;
}


//-- handleConnectionFailed
// エラー
-(void) handleConnectionFailed:(int) inErrorCode
{
    _state = IRStateDisconnect;
	[_session handleConnectionError:inErrorCode];
	[self handleDisconnect];
}


//--- disconnect
// 切断する
- (void) disconnect
{
	[_inputStream close];
	[_outputStream close];
	
	[self stopTimer];
    _state = IRStateDisconnect;
}




#pragma mark -

//--- sendData
// データの送信
-(BOOL) sendData:(NSData*)inData
	 immediately:(BOOL)immediate
{
	if(immediate == YES){ // 即座に送信する
		[_dataQueue insertObject:inData atIndex:0];
		[self sendDataInInterval:nil];
	}else{
		[_dataQueue addObject:inData]; // queueの先頭にobjectを挿入する
	}
	return YES;
}


//-- sendDataInInterval
// 0.1秒に1回呼び出される. 1行分メッセージを送信する
- (void) sendDataInInterval:(id) userInfo
{
    if([_dataQueue count] > 0){
        NSData* data = [_dataQueue objectAtIndex:0];
        NS_DURING
		[_outputStream write:[data bytes] maxLength:[data length]];
		[_outputStream write:(const void*)"\r\n" maxLength:2];
		NS_HANDLER
		NSLog(@"SENDDATA:%@", [localException name]);
        NS_ENDHANDLER
        [_dataQueue removeObjectAtIndex:0];
    }
}


//--- readAvailableData
// データが到着したよ
- (void) readAvailableData
{
    NS_DURING
	if([_inputStream hasBytesAvailable]){
		[self handleIncommingData];
	}else{
		[self handleDisconnect];
	}
    NS_HANDLER
	[_localDataBuffer setLength:0]; // 読み込み済みのデータを無効にする
    NS_ENDHANDLER
}



//--- handleIncommingData
// 到着したデータを1行ずつ分ける
- (void) handleIncommingData
{
    const unsigned char *data, *nextLineEnd;
    unsigned int lineBytes;
    
	
	while([_inputStream hasBytesAvailable]){
		uint8_t		buffer[1024];
		
		NSInteger length = [_inputStream read:(void*)&buffer maxLength:1024];
		[_localDataBuffer appendBytes:buffer length:length];
    
		data = [_localDataBuffer bytes];
		length = [_localDataBuffer length];
	
		// 1行ずつデータを切り離す
		nextLineEnd = skipNextLine(data, length, &lineBytes);
		while(nextLineEnd != data && length > 0){
			if(lineBytes > 0){
				[self reciveLine:[NSData dataWithBytes:data length:lineBytes]];
			}
			length -= (nextLineEnd - data);
			data = nextLineEnd;
			nextLineEnd = skipNextLine(data, length, &lineBytes);
		}
		// 途中のデータがあった場合bufferに保存しておく
		if(length > 0){
			unsigned int endOfData = [_localDataBuffer length];
			[_localDataBuffer setData:
			 [_localDataBuffer subdataWithRange:NSMakeRange(endOfData - length,length)]];
		}else{
			[_localDataBuffer setLength:0];
		}
	}
}


//--- reciveLine
// 1行受信した時の処理
- (void) reciveLine : (NSData*) inData
{
	if(inData){
		[_session handleIncommingData:inData];
	}
}


//-- handleDisconnect
// 切断処理
- (void) handleDisconnect
{
	if(_state != IRStateDisconnect){
		[_session handleDisconnect];
		[self stopTimer];
		_state = IRStateDisconnect;
	}
}


//--- acceptToWriteData
// dataの書き込みが可能になった時の処理
- (void) acceptToWriteData
{
	if(!_idleTimer){
		_state = IRStateConnected;
		[_session handleConnected];
    
		// データ書き出し用のTimerを設定する (1/10秒に1回しかメッセージを送信しない)
		_idleTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
													  target:self
													selector:@selector(sendDataInInterval:)
													userInfo:nil
													 repeats:YES];
		[_idleTimer retain];
	}
}


//-- stopTimer
// idle timerの停止
- (void) stopTimer
{
    if(_idleTimer){
        [_idleTimer invalidate];
        [_idleTimer release];
        _idleTimer = nil;
    }
}

@end
