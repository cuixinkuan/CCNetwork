//
//  CCNetwork.h
//  CCNetworkDemo
//
//  Created by admin on 2018/1/25.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef _CCNETWORK_
    #define _CCNETWORK_

#if __has_include(<CCNetwork/CCNetwork.h>)

FOUNDATION_EXPORT double CCNetworkVersionNumber;
FOUNDATION_EXPORT const unsigned char CCNetworkVersionString[];

#import <CCNetwork/CCRequest.h>
#import <CCNetwork/CCBaseRequest.h>
#import <CCNetwork/CCNetworkAgent.h>
#import <CCNetwork/CCBatchRequest.h>
#import <CCNetwork/CCBatchRequestAgent.h>
#import <CCNetwork/CCChainRequest.h>
#import <CCNetwork/CCChainRequestAgent.h>
#import <CCNetwork/CCNetworkConfig.h>

#else

#import "CCRequest.h"
#import "CCBaseRequest.h"
#import "CCNetworkAgent.h"
#import "CCBatchRequest.h"
#import "CCBatchRequestAgent.h"
#import "CCChainRequest.h"
#import "CCChainRequestAgent.h"
#import "CCNetworkConfig.h"

#endif /* __has_include */

#endif /* _CCNETWORK_ */
