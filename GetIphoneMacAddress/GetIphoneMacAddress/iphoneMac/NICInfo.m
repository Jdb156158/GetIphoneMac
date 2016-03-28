//
//  NICInfo.m
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

#import "NICInfo.h"
#include <sys/socket.h>
#include <net/if_dl.h>
#include <netinet/in.h>
#include <ifaddrs.h>
#include <arpa/inet.h>

// find NIC info from nic_array
NICInfo* findNICInfo(NSString* interface_name, NSArray* nic_array);
NICInfo* findNICInfo(NSString* interface_name, NSArray* nic_array)
{
    for(int i=0; i<nic_array.count; i++)
    {
        NICInfo* nic_info = [nic_array objectAtIndex:i];
        if([nic_info.interfaceName isEqualToString:interface_name])
            return nic_info;
    }
    return nil;
}


#pragma mark NICIPInfo
@implementation NICIPInfo
@synthesize ip, netmask, broadcastIP;
@end



#pragma mark NICInfo
@implementation NICInfo
@synthesize interfaceName, nicIPInfos, nicIPv6Infos, macAddress;

- (id)init
{
    self = [super init];
    if(self == nil) return nil;
    nicIPInfos = [[NSMutableArray alloc] init];
    nicIPv6Infos = [[NSMutableArray alloc] init];
    return self;   
}



- (NSString*)getMacAddressWithSeparator:(NSString*)separator
{
    return [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@"
            , [macAddress substringWithRange:NSMakeRange(0, 2)], separator
            , [macAddress substringWithRange:NSMakeRange(2, 2)], separator
            , [macAddress substringWithRange:NSMakeRange(4, 2)], separator
            , [macAddress substringWithRange:NSMakeRange(6, 2)], separator
            , [macAddress substringWithRange:NSMakeRange(8, 2)], separator
            , [macAddress substringWithRange:NSMakeRange(10, 2)]];
}


+ (NSArray*)nicInfos
{
    NSMutableArray* nic_array = [[NSMutableArray alloc] init];
    
	int	result;
	struct ifaddrs	*ifbase, *ifiterator;
	
	result = getifaddrs(&ifbase);
	ifiterator = ifbase;
	while (!result && (ifiterator != NULL))
	{
        NSString* interface_name = [NSString stringWithFormat:@"%s", ifiterator->ifa_name];
        NICInfo* nic_info = findNICInfo(interface_name, nic_array);
        
        // if new NICInfo, add to array
        if(nic_info == nil)
        {
            nic_info = [NICInfo new];
            [nic_info setInterfaceName:interface_name];
            [nic_array addObject:nic_info];
        }
        
        // when it has IPv4 info ...
		if (ifiterator->ifa_addr->sa_family == AF_INET)
		{
			struct	sockaddr *saddr, *netmask, *daddr;
			saddr = ifiterator->ifa_addr;
			netmask = ifiterator->ifa_netmask;
			daddr = ifiterator->ifa_dstaddr;
			
			// we've found an entry for the IP address
			struct sockaddr_in	*iaddr;
			char				addrstr[64];
			char				netmaskstr[64];
			char				broadstr[64];
			iaddr = (struct sockaddr_in *)saddr;
			inet_ntop(saddr->sa_family, &iaddr->sin_addr, addrstr, sizeof(addrstr));
            iaddr = (struct sockaddr_in *)netmask;
			inet_ntop(saddr->sa_family, &iaddr->sin_addr, netmaskstr, sizeof(addrstr));
            iaddr = (struct sockaddr_in *)daddr;
			inet_ntop(saddr->sa_family, &iaddr->sin_addr, broadstr, sizeof(addrstr));
            
            NICIPInfo* ip_info = [[NICIPInfo alloc] init];
            ip_info.ip = [NSString stringWithFormat:@"%s", addrstr];
            ip_info.netmask = [NSString stringWithFormat:@"%s", netmaskstr];
            ip_info.broadcastIP = [NSString stringWithFormat:@"%s", broadstr];
            [nic_info.nicIPInfos addObject:ip_info];
		}
		// when it has ipv6 ...
		else if (ifiterator->ifa_addr->sa_family == AF_INET6)
		{
			// we've found an entry for the IP address
			struct	sockaddr *saddr, *netmask, *daddr;
			saddr = ifiterator->ifa_addr;
			netmask = ifiterator->ifa_netmask;
			daddr = ifiterator->ifa_dstaddr;
            
			struct sockaddr_in6	*iaddr6;
			char				addrstr[256];
			char				netmaskstr[256];
			char				broadstr[256];
            iaddr6 = (struct sockaddr_in6 *)saddr;
			inet_ntop(ifiterator->ifa_addr->sa_family, iaddr6, addrstr, sizeof(addrstr));
            iaddr6 = (struct sockaddr_in6 *)netmask;
			inet_ntop(ifiterator->ifa_addr->sa_family, iaddr6, netmaskstr, sizeof(addrstr));
            iaddr6 = (struct sockaddr_in6 *)daddr;
			inet_ntop(ifiterator->ifa_addr->sa_family, iaddr6, broadstr, sizeof(addrstr));
            
            NICIPInfo* ipv6_info = [[NICIPInfo alloc] init];
            ipv6_info.ip = [NSString stringWithFormat:@"%s", addrstr];
            ipv6_info.netmask = [NSString stringWithFormat:@"%s", netmaskstr];
            ipv6_info.broadcastIP = [NSString stringWithFormat:@"%s", broadstr];
            [nic_info.nicIPv6Infos addObject:ipv6_info];
        }
		// when it has MAC address ...
		else if(ifiterator->ifa_addr->sa_family == AF_LINK) 
		{
			struct sockaddr_dl* dlAddr;
			dlAddr = (struct sockaddr_dl *)(ifiterator->ifa_addr);
            unsigned char mac_address[6];
            memcpy(mac_address, &dlAddr->sdl_data[dlAddr->sdl_nlen], 6);
            
            nic_info.macAddress = 
            [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X"
             , mac_address[0], mac_address[1], mac_address[2]
             , mac_address[3], mac_address[4], mac_address[5]];
		}
		ifiterator = ifiterator->ifa_next;
	}
    return nic_array;
}

@end



