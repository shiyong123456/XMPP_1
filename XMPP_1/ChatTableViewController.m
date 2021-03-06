//
//  ChatTableViewController.m
//  XMPP_1
//
//  Created by shiyong on 17/7/13.
//  Copyright © 2017年 SY. All rights reserved.
//

#import "ChatTableViewController.h"
#import "XMPPManager.h"
#import "Mycell.h"
#import "FriendCell.h"
@interface ChatTableViewController ()<XMPPStreamDelegate,UIAlertViewDelegate>
@property (nonatomic , strong)NSMutableArray *messageArray;
@end

@implementation ChatTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化数组
    self.messageArray = [NSMutableArray array];
    //给通信信道对象添加代理
    [[XMPPManager shareManager].stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    //检索信息
    [self reloadMessages];
}
/**
 * 消息发送成功的方法
 */
-(void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{
    [self reloadMessages];
}
/**
 *接收消息成功
 */
-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
  
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.friendJID];
        [message addBody:textField.text];
        [[XMPPManager shareManager].stream sendElement:message];
    }
}
-(void)reloadMessages{
    NSManagedObjectContext *context = [XMPPManager shareManager].context;
    //创建查询类
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    //创建实体描述类
    NSEntityDescription *entityDescription =  [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:context];
    [fetchRequest setEntity:entityDescription];
    //创建谓词
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr = %@ and streamBareJidStr = %@",self.friendJID,[XMPPManager shareManager].stream.myJID.bare];
    //创建排序类
    NSSortDescriptor *sortDec = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:@[sortDec]];
    //从临时数据鲁中查找聊天信息
    NSArray *fetchArray = [context executeFetchRequest:fetchRequest error:nil];
    if (fetchArray.count!=0) {
        if (self.messageArray.count!=0) {
            [self.messageArray removeAllObjects];
        }
        [self.messageArray addObjectsFromArray:fetchArray];
        [self.tableView reloadData];
    if (self.messageArray.count!=0) {
        //动画效果
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    }
}
- (IBAction)sendInfo:(UIBarButtonItem *)sender {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"发送消息" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    //取出数据源中的消息
    XMPPMessageArchiving_Message_CoreDataObject *mesaage = self.messageArray[indexPath.row];
    if (mesaage.isOutgoing) {
        Mycell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell" forIndexPath:indexPath];
        cell.chatLabel.text = mesaage.body;
        return cell;
    }else{
        FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell2" forIndexPath:indexPath];
        cell.chatLabel.text = mesaage.body;
        return cell;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//}
//

@end
