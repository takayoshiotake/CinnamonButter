//
//  CBNetworkInterface.m
//  CinnamonButter
//
//  Created by OTAKE Takayoshi on 2018/03/10.
//

#import "CBNetworkInterface.h"

#include <ifaddrs.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <net/if_types.h>
#include <net/if_dl.h>
#include <arpa/inet.h>

@implementation CBNetworkAddress

- (id)initWith:(CBNetworkInterfaceType)interfaceType stringValue:(nonnull NSString *)stringValue {
    if (self = [super init]) {
        _interfaceType = interfaceType;
        _stringValue = stringValue;
    }
    return self;
}

@end

@implementation CBNetworkInterface

- (id)initWith:(nonnull NSString *)name addresses:(nonnull NSArray<CBNetworkAddress *> *)addresses {
    if (self = [super init]) {
        _name = name;
        _addresses = addresses;
    }
    return self;
}

+ (nonnull NSArray<CBNetworkInterface *> *)list {
    struct ifaddrs * ptr;
    if (getifaddrs(&ptr) != 0) {
        return @[];
    }
    
    NSMutableDictionary<NSString *, NSMutableArray<CBNetworkAddress *> *> * dict = [NSMutableDictionary dictionary];
    for (struct ifaddrs * itr = ptr; itr != NULL; itr = itr->ifa_next) {
        NSString * const name = [NSString stringWithUTF8String: itr->ifa_name];
        NSMutableArray * addresses = dict[name];
        if (addresses == nil) {
            addresses = [NSMutableArray array];
            dict[name] = addresses;
        }
        
        CBNetworkInterfaceType interfaceType;
        NSString * stringValue;
        switch (itr->ifa_addr->sa_family) {
            case AF_LINK: {
                struct sockaddr_dl * link = (struct sockaddr_dl *)itr->ifa_addr;
                if (link->sdl_alen != 6 || link->sdl_type != IFT_ETHER) {
                    continue;
                }
                interfaceType = CBNetworkInterfaceTypeEther;
                stringValue = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", (unsigned char)link->sdl_data[0], (unsigned char)link->sdl_data[1], (unsigned char)link->sdl_data[2], (unsigned char)link->sdl_data[3], (unsigned char)link->sdl_data[4], (unsigned char)link->sdl_data[5]];
            } break;
            case AF_INET: {
                interfaceType = CBNetworkInterfaceTypeIp4;
                char dst[INET_ADDRSTRLEN];
                bzero(dst, sizeof(dst));
                inet_ntop(AF_INET, &((struct sockaddr_in *)itr->ifa_addr)->sin_addr, dst, sizeof(dst));
                stringValue = [NSString stringWithUTF8String:dst];
            } break;
            case AF_INET6: {
                interfaceType = CBNetworkInterfaceTypeIp6;
                char dst[INET6_ADDRSTRLEN];
                bzero(dst, sizeof(dst));
                inet_ntop(AF_INET6, &((struct sockaddr_in6 *)itr->ifa_addr)->sin6_addr, dst, sizeof(dst));
                stringValue = [NSString stringWithUTF8String:dst];
            } break;
            default:
                continue;
        }
        [addresses addObject:[[CBNetworkAddress alloc] initWith:interfaceType stringValue:stringValue]];
    }
    freeifaddrs(ptr);
    
    NSMutableArray<CBNetworkInterface *> * list = [NSMutableArray array];
    for (NSString * name in dict.allKeys) {
        [list addObject:[[CBNetworkInterface alloc] initWith:name addresses:dict[name]]];
    }
    return [NSArray arrayWithArray:list];
}

@end
