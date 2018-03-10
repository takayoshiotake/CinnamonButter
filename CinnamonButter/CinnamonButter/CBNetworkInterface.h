//
//  CBNetworkInterface.h
//  CinnamonButter
//
//  Created by OTAKE Takayoshi on 2018/03/10.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(UInt32, CBNetworkInterfaceType) {
    CBNetworkInterfaceTypeEther,
    CBNetworkInterfaceTypeIp4,
    CBNetworkInterfaceTypeIp6
};

@interface CBNetworkAddress : NSObject

@property (readwrite, assign) CBNetworkInterfaceType interfaceType;
@property (readwrite, strong, nonnull) NSString * stringValue;

@end

@interface CBNetworkInterface : NSObject

@property (readwrite, strong, nonnull) NSString * name;
@property (readwrite, strong, nonnull) NSArray<CBNetworkAddress *> * addresses;

+ (nonnull NSArray<CBNetworkInterface *> *)list;

@end
