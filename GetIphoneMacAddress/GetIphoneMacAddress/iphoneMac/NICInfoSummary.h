//
//  NICInfoSummary.h
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
#import "NICInfo.h"

@interface NICInfoSummary : NSObject {
    NSArray*    nicInfos;
}

@property (readonly,retain) NSArray* nicInfos;


// Let me have all NIC information on this device!
- (NICInfo*)findNICInfo:(NSString*)interface_name;

// iPhone's NIC :
//  pdp_ip0 : 3G
//  en0 : wifi
//  en2 : bluetooth
//  bridge0 : personal hotspot

// macbook air's NIC (it varies on devices) :
//  en0 : wifi
//  en1 : iphone USB
//  en2 : bluetooth


- (bool)isWifiConnected;
- (bool)isWifiConnectedToNAT;
- (bool)isBluetoothConnected;
- (bool)isPersonalHotspotActivated;
- (bool)is3GConnected;

@end
