//
//  NICInfo.h
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

#import <Foundation/Foundation.h>


@interface NICInfo : NSObject {
    NSString*           interfaceName;
    NSString*           macAddress;
    NSMutableArray*     nicIPInfos;
    NSMutableArray*     nicIPv6Infos;
}

@property (copy)        NSString*       interfaceName;
@property (copy)        NSString*       macAddress;
@property (retain)      NSMutableArray* nicIPInfos;
@property (retain)      NSMutableArray* nicIPv6Infos;


// If 'FF-FF-FF-FF-FF-FF' format MAC address is needed, use this method
- (NSString*)getMacAddressWithSeparator:(NSString*)separator;

+ (NSArray*)nicInfos;

@end





// Depicts a specific ip address and its netmask, broadcast ip
// This class represents both IPv4 and IPv6 info. 
@interface NICIPInfo : NSObject {
    NSString*   ip;
    NSString*   netmask;
    NSString*   broadcastIP;
}

@property (retain)     NSString*   ip;
@property (retain)     NSString*   netmask;
@property (retain)     NSString*   broadcastIP;
@end

