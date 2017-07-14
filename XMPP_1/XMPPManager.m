//
//  XMPPManager.m
//  XMPP_1
//
//  Created by shiyong on 17/7/13.
//  Copyright © 2017年 SY. All rights reserved.
//

#import "XMPPManager.h"
//枚举
typedef NS_ENUM(NSInteger,ConnectToServerPurpose)
{
   ConnectToServerLogin,
   ConnectToServerRegister
};
@interface XMPPManager ()<UIAlertViewDelegate>
@property (nonatomic,copy)NSString *password;
@property (nonatomic,assign)ConnectToServerPurpose connectToServerPurpose;
@property (nonatomic,strong)XMPPJID *fromJID;
@end
@implementation XMPPManager
/**
 * 创建单例
 */
+(XMPPManager *)shareManager{
    static XMPPManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[XMPPManager alloc]init];
    });
    return manager;
}
/**
 *初始化方法
 */
-(instancetype)init{
    if (self = [super init]) {
        //创建化通道对象
        self.stream = [[XMPPStream alloc]init];
        //设置服务器IP地址
        self.stream.hostName = KHostName;
        //设置服务器端口
        self.stream.hostPort = KHostPost;
        //设置代理方法
        [self.stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        //创建信息归档数据存储对象
        XMPPMessageArchivingCoreDataStorage *coreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        //创建信息归档对象
        self.xmppMessageArchiving = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:coreDataStorage dispatchQueue:dispatch_get_main_queue()];
        //激活通信信道对象
        [self.xmppMessageArchiving activate:self.stream];
        //创建数据管理器
        self.context = coreDataStorage.mainThreadManagedObjectContext;
        //花名册数据存储对象
        XMPPRosterCoreDataStorage *rosterCoreDataStorage = [XMPPRosterCoreDataStorage sharedInstance];
        //创建好友花名册管理对象
        self.xmppRoster = [[XMPPRoster alloc]initWithRosterStorage:rosterCoreDataStorage dispatchQueue:dispatch_get_main_queue()];
        [self.xmppRoster activate:self.stream];
        [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}
/**
 *登录方法
 */
-(void)loginWithName:(NSString *)userName passWord:(NSString *)passWord{
    self.connectToServerPurpose = ConnectToServerLogin;
    self.password = passWord;
   //链接服务器
    [self connnectToServeWithUserName:userName];
}
/**
 *注册方法
 */
-(void)registerWithName:(NSString *)registerName PassWord:(NSString *)passWord{
    self.connectToServerPurpose = ConnectToServerRegister;
    self.password = passWord;
    [self connnectToServeWithUserName:registerName];
}
/**
 *连接服务器
 */
-(void)connnectToServeWithUserName:(NSString *)userName{
  //创建XMPPJID对象
    XMPPJID *jid = [XMPPJID jidWithUser:userName domain:KDomin resource:KResouse];
    //设置通信通道对象的jid
    self.stream.myJID = jid;
    //发送请求
    if([self.stream isConnected]||[self.stream isConnecting]){
       //先发送下线状态
        XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
        [self.stream sendElement:presence];
        //断开连接
        [self.stream disconnect];
    }
    //向服务器重新发送请求
    NSError *error = nil;
    [self.stream connectWithTimeout:-1 error:&error];
    if (error!=nil) {
        NSLog(@"%s_%d_%@|连接失败",__FUNCTION__,__LINE__,[error localizedDescription]);
    }
}
/**
 * 连接超时的方法
 */
-(void)xmppStreamConnectDidTimeout:(XMPPStream *)sender{
    NSLog(@"%s__%d__|连接服务器超时",__FUNCTION__,__LINE__);
}
/**
 * 连接成功
 */
-(void)xmppStreamDidConnect:(XMPPStream *)sender{
    switch (self.connectToServerPurpose) {
        case ConnectToServerLogin:
            [self.stream authenticateWithPassword:self.password error:nil];
            break;
        case ConnectToServerRegister:
            [self.stream registerWithPassword:self.password error:nil];
        default:
            break;
    }
    
    
}
-(void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    self.fromJID = presence.from;
    UIAlertView *alertVIew = [[UIAlertView alloc]initWithTitle:@"好友请求" message:presence.from.user delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"同意", nil];
    [alertVIew show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            //拒绝添加此好友
            [self.xmppRoster rejectPresenceSubscriptionRequestFrom:self.fromJID];
            break;
        case 1:
            //同意添加此好友
            [self.xmppRoster acceptPresenceSubscriptionRequestFrom:self.fromJID andAddToRoster:YES];
        default:
            break;
    }
}
@end
