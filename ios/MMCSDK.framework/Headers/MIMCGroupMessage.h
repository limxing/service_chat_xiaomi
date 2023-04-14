//
//  MIMCGroupMessage.h
//  MIMCSDK
//
//  Created by zhangdan on 2017/12/13.
//  Copyright © 2017年 zhangdan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MIMCGroupMessage : NSObject

- (id)initWithPacketId:(NSString *)packetId andSequence:(int64_t)sequence andTimestamp:(int64_t)timestamp andFromAccount:(NSString *)fromAccount andTopicId:(int64_t)topicId andPayload:(NSData *)payload;
- (id)initWithPacketId:(NSString *)packetId andSequence:(int64_t)sequence andTimestamp:(int64_t)timestamp andFromAccount:(NSString *)fromAccount andTopicId:(int64_t)topicId andPayload:(NSData *)payload andBizType:(NSString *)bizType;
- (id)initWithPacketId:(NSString *)packetId andSequence:(int64_t)sequence andTimestamp:(int64_t)timestamp andFromAccount:(NSString *)fromAccount andFromResource:(NSString *)fromResource  andTopicId:(int64_t)topicId andPayload:(NSData *)payload andBizType:(NSString *)bizType;
- (id)initWithPacketId:(NSString *)packetId andSequence:(int64_t)sequence andTimestamp:(int64_t)timestamp andFromAccount:(NSString *)fromAccount andFromResource:(NSString *)fromResource  andTopicId:(int64_t)topicId andPayload:(NSData *)payload andBizType:(NSString *)bizType andConvIndex:(int64_t)convIndex;
- (NSString *)getPacketId;
- (int64_t)getSequence;
- (int64_t)getTimestamp;
- (NSString *)getFromAccount;
- (NSString *)getFromResource;
- (int64_t)getTopicId;
- (NSData *)getPayload;
- (NSString *)getBizType;
- (int64_t)getConvIndex;
@end
