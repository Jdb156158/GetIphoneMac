//
//  ViewController.m
//  GetIphoneMacAddress
//
//  Created by Jdb on 16/3/28.
//  Copyright © 2016年 uimbank. All rights reserved.
//

#import "ViewController.h"
#include <sys/sysctl.h>
#import "sys/utsname.h"
#import <ifaddrs.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <sys/sysctl.h>
#include <sys/param.h>
#include <sys/file.h>
#include <net/if.h>
#include <netinet/in.h>
#include <net/if_dl.h>
#include <netdb.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include "if_arp.h"
#include "if_dl.h"
#include "route.h"
#include "if_ether.h"
#include <net/ethernet.h>
#include <err.h>
#include <errno.h>
#include <paths.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#include "NICInfo.h"
#include "NICInfoSummary.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    id info = nil;
    info = [self fetchSSIDInfo];
    //NSLog(@"%@WIFI名字：%@",info,[info objectForKey:@"SSID"]);
    self.wifiSsiddLabel.text = [NSString stringWithFormat:@"当前热点：%@",[info objectForKey:@"SSID"]];
    self.wifiBssidLabel.text = [NSString stringWithFormat:@"路由地址：%@",[self standardFormateMAC:[info objectForKey:@"BSSID"]]];
    
    _rqlistarry = [NSMutableArray array];//人气榜数组
    
    self.wifiIphoneMacTableView.delegate = self;
    self.wifiIphoneMacTableView.dataSource = self;
    self.wifiIphoneMacTableView.tag = 1;
    [self.wifiIphoneMacTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [self ip2mac];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    //告诉TableView有几个分区
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    //告诉Tableview当前分区有几行
    if ([self.rqlistarry count] == 0)
        return 0;
    //NSLog(@"namesection count[%i]",[self.shopTitle count]);
    return [self.rqlistarry count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    NSUInteger section = [indexPath section];
    NSLog(@"section[%lu]",(unsigned long)section);
    
    NSUInteger row = [indexPath row];
    static NSString *CellIdentifier = @"Cell";
    //错误写法，先不赋值
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    //正确写法
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell != nil) {
        cell = [[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault
                 reuseIdentifier:CellIdentifier];
    }
    
    UIView *cellview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    UIImageView *Shopimageicon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 40, 40)];
    Shopimageicon.image = [UIImage imageNamed:@"wifiicon.png"];
    
    UILabel *iphoneMacTitletext = [[UILabel alloc] initWithFrame:CGRectMake(55, 3, self.view.frame.size.width-55, 19)];
    iphoneMacTitletext.text = [[self.rqlistarry objectAtIndex:row] substringToIndex:17];
    iphoneMacTitletext.font = [UIFont systemFontOfSize:16.0f];
    
    UILabel *iphoneIpTitletext = [[UILabel alloc] initWithFrame:CGRectMake(55, 25, self.view.frame.size.width-55, 19)];
    iphoneIpTitletext.textColor = [UIColor grayColor];
    iphoneIpTitletext.text = [[self.rqlistarry objectAtIndex:row] substringFromIndex:17];
    iphoneIpTitletext.font = [UIFont systemFontOfSize:16.0f];
    
    
    [cellview.self addSubview:Shopimageicon];
    [cellview.self addSubview:iphoneMacTitletext];
    [cellview.self addSubview:iphoneIpTitletext];
    
    
    [cell.self addSubview:cellview];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;//后边有小箭头
    return cell;
    
}
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
//头部高
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}
//尾部部高
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}
//头部view
- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section{
    UIView *v_headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];    v_headerView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *v_headerLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 40/2-10, self.view.frame.size.width, 20)];
    v_headerLab.text = [NSString stringWithFormat:@"路由器所链接的设备数为：%lu",(unsigned long)[_rqlistarry count]];
    v_headerLab.textColor = [UIColor grayColor];
    v_headerLab.font = [UIFont fontWithName:@"Arial" size:17];
    [v_headerView addSubview:v_headerLab];
    
    return v_headerView;
}


-(NSString*) ip2mac
{
    int flags = 0,  found_entry = 0;
    NSString *mAddr = nil;
    u_long addr = inet_addr([[self getIPAddress] UTF8String]);
    //NSLog(@"---------%s",[[self getIPAddress] UTF8String]);
    int mib[6];
    size_t needed;
    char *host, *lim, *buf, *next;
    struct rt_msghdr *rtm;
    struct sockaddr_inarp *sin;
    struct sockaddr_dl *sdl;
    extern int h_errno;
    struct hostent *hp;
    
    mib[0] = CTL_NET;
    mib[1] = PF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_INET;
    mib[4] = NET_RT_FLAGS;
    mib[5] = RTF_LLINFO;
    
    if (sysctl(mib, 6, NULL, &needed, NULL, 0) < 0)
        err(1, "route-sysctl-estimate");
    if ((buf = malloc(needed)) == NULL)
        err(1, "malloc");
    if (sysctl(mib, 6, buf, &needed, NULL, 0) < 0)
        err(1, "actual retrieval of routing table");
    
    lim = buf + needed;
    //NSLog(@"********---%s",lim);
    for (next = buf; next < lim; next += rtm->rtm_msglen) {
        rtm = (struct rt_msghdr *)next;
        sin = (struct sockaddr_inarp *)(rtm + 1);
        sdl = (struct sockaddr_dl *)(sin + 1);
        if (addr) {
            if (addr != sin->sin_addr.s_addr)
                //NSLog(@"%lu,%u",addr,sin->sin_addr.s_addr);
                //continue;
                found_entry = 1;
        }
        if (flags == 0)
            hp = gethostbyaddr((caddr_t)&(sin->sin_addr),
                               sizeof sin->sin_addr, AF_INET);
        else
            hp = 0;
        if (hp)
            host = hp->h_name;
        else {
            host = "?";
            if (h_errno == TRY_AGAIN)
                flags = 1;
        }
        
        if (sdl->sdl_alen) {
            u_char  *cp = (u_char*)LLADDR(sdl);
            mAddr = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", cp[0], cp[1], cp[2], cp[3], cp[4], cp[5]];
            [_rqlistarry addObject:[NSString stringWithFormat:@"%@%s",mAddr,inet_ntoa(sin->sin_addr)]];
            [self.wifiIphoneMacTableView reloadData];
        }else{
            mAddr = nil;
        }
    }
    
    if (found_entry == 0) {
        free(buf);
        return nil;
    } else {
        free(buf);
        return mAddr;
    }
}

// Get IP Address
-(NSString *)getIPAddress
{
    NSString *address = @"";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

#pragma mark -获取当前已经链接的wifi信息
- (id)fetchSSIDInfo {
    NSArray *ifs = (id)CFBridgingRelease(CNCopySupportedInterfaces());
    //NSLog(@"%s: Supported interfaces: %@", __func__, ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        //NSLog(@"%@ => %@ ssidname:[%@]", ifnam, info,[info objectForKey:@"SSID"]);
        if (info && [info count]) { break; }
    }
    return info;
}

#pragma mark ----wifi mac少头0预防
- (NSString *)standardFormateMAC:(NSString *)MAC {
    NSArray * subStr = [MAC componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":-"]];
    NSMutableArray * subStr_M = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSString * str in subStr) {
        if (1 == str.length) {
            NSString * tmpStr = [NSString stringWithFormat:@"0%@", str];
            [subStr_M addObject:tmpStr];
        } else {
            [subStr_M addObject:str];
        }
    }
    
    NSString * formateMAC = [subStr_M componentsJoinedByString:@":"];
    return [formateMAC uppercaseString];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
