//
//  ViewController.h
//  GetIphoneMacAddress
//
//  Created by Jdb on 16/3/28.
//  Copyright © 2016年 uimbank. All rights reserved.
//

#import <UIKit/UIKit.h>
#define SIOCGIFADDR 0x8915    /* get PA address */
#define SIOCSIFADDR 0x8916    /* set PA address */
#define SIOCGIFHWADDR 0x8927  /* Get hardware address */
#define	ATF_PROXY	0x20
#define IFT_ETHER 0x6
@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    
}

@property (strong, nonatomic) IBOutlet UILabel *wifiSsiddLabel;
@property (strong, nonatomic) IBOutlet UILabel *wifiBssidLabel;
@property (strong, nonatomic) IBOutlet UITableView *wifiIphoneMacTableView;
@property (nonatomic,strong)NSMutableArray *rqlistarry;

@end

