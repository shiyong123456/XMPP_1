//
//  ViewController.m
//  XMPP_1
//
//  Created by shiyong on 17/7/13.
//  Copyright © 2017年 SY. All rights reserved.
//

#import "ViewController.h"
#import "XMPPManager.h"
@interface ViewController ()<XMPPStreamDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[XMPPManager shareManager].stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}
/*
 登录的方法
 */
- (IBAction)login:(UIButton *)sender {
    [[XMPPManager shareManager] loginWithName:self.nameText.text passWord:self.screte.text];
}
/**
 *验证成功
 */
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    NSLog(@"%s__%d__|登录成功",__FUNCTION__,__LINE__);
    XMPPPresence *perence = [XMPPPresence presenceWithType:@"available"];
    [[XMPPManager shareManager].stream sendElement:perence];
    [self performSegueWithIdentifier:@"roster" sender:nil];
}
/**
 *登录失败
 */
-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    NSLog(@"%s__%d__|登录失败",__FUNCTION__,__LINE__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
