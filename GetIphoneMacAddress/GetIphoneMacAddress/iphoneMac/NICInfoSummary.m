//
//  NICInfoSummary.m
//  NICInfo
//
//  Class for getting network interfaces address information instantly.
//  Refer to showNICInfo method of ViewController for USAGE.
//
//  USE FREELY, CAUSE I GOT FREELY.
//
//
//
//
//  Created by Kenial on 11. 11. 19..
//  Copyright (c) 2011 Mind in Machine. All rights reserved.
//

#import "NICInfoSummary.h"

@implementation NICInfoSummary



- (NSArray*)nicInfos
{
    if(nicInfos == nil)
        nicInfos = [[NICInfo nicInfos] init];
    return nicInfos;
}

- (NICInfo*)findNICInfo:(NSString*)interface_name
{
    for(int i=0; i<self.nicInfos.count; i++)
    {
        NICInfo* nic_info = [self.nicInfos objectAtIndex:i];
        if([nic_info.interfaceName isEqualToString:interface_name])
            return nic_info;
    }
    return nil;
}

- (bool)isWifiConnected
{
    NICInfo* nic_info = nil;
    nic_info = [self findNICInfo:@"en0"];
    if(nic_info != nil)
    {
        if(nic_info.nicIPInfos.count > 0)
            return YES;
    }
    return NO;
}

- (bool)isWifiConnectedToNAT
{
    NICInfo* nic_info = nil;
    nic_info = [self findNICInfo:@"en0"];
    if(nic_info != nil)
    {
        for(int i=0; i<nic_info.nicIPInfos.count; i++)
        {
            NICIPInfo* ip_info = [nic_info.nicIPInfos objectAtIndex:i];
            NSRange range = [ip_info.ip rangeOfString:@"192.168"];
            if(range.location == 0)
                return YES;
        }
    }
    return NO;
}

- (bool)isBluetoothConnected
{
    NICInfo* nic_info = nil;
    nic_info = [self findNICInfo:@"en2"];
    if(nic_info != nil)
    {
        if(nic_info.nicIPInfos.count > 0)
            return YES;
    }
    return NO;
}

- (bool)isPersonalHotspotActivated
{
    NICInfo* nic_info = nil;
    nic_info = [self findNICInfo:@"bridge0"];
    if(nic_info != nil)
    {
        if(nic_info.nicIPInfos.count > 0)
            return YES;
    }
    return NO;
}

- (bool)is3GConnected
{
    NICInfo* nic_info = nil;
    nic_info = [self findNICInfo:@"pdp_ip0"];
    if(nic_info != nil)
    {
        if(nic_info.nicIPInfos.count > 0)
            return YES;
    }
    return NO;
}

@end
