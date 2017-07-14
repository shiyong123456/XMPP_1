//
//  RegisterViewController.m
//  XMPP_1
//
//  Created by shiyong on 17/7/13.
//  Copyright © 2017年 SY. All rights reserved.
//

#import "RegisterViewController.h"
#import "XMPPManager.h"
@interface RegisterViewController ()<XMPPStreamDelegate>

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[XMPPManager shareManager].stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}
- (IBAction)registerButton:(UIButton *)sender{
    [[XMPPManager shareManager] registerWithName:self.registerName.text PassWord:self.regiserPassword.text];
}
-(void)xmppStreamDidRegister:(XMPPStream *)sender{
    NSLog(@"%s__%d__|注册成功",__FUNCTION__,__LINE__);
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
     NSLog(@"%s__%d__|注册失败",__FUNCTION__,__LINE__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
