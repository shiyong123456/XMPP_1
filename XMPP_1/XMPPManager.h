//
//  XMPPManager.h
//  XMPP_1
//
//  Created by shiyong on 17/7/13.
//  Copyright © 2017年 SY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
@interface XMPPManager : NSObject<XMPPStreamDelegate,XMPPRosterDelegate>
//通讯通道对象
@property(nonatomic , strong)XMPPStream *stream;
//信息归档对象
@property(nonatomic , strong)XMPPMessageArchiving *xmppMessageArchiving;
//创建一个数据管理器
@property(nonatomic , strong)NSManagedObjectContext *context;
//好友花名册管理对象
@property(nonatomic , strong)XMPPRoster *xmppRoster;

+(XMPPManager *)shareManager;

-(void)loginWithName:(NSString *)userName passWord:(NSString *)passWord;
-(void)registerWithName:(NSString *)registerName PassWord:(NSString *)passWord;
@end
