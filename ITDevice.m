//
//  PCDevice.m
//  PCDevice
//
//  Created by Patrick Perini on 2/14/12.
//  Licensing information availabe in README.md
//

#import "PCDevice.h"

#pragma mark - Global Constants
NSString *const PCDeviceOrientationDidChangeNotification     = @"PCDeviceOrientationDidChangeNotification";
NSString *const PCDeviceBatteryLevelDidChangeNotification    = @"PCDeviceBatteryLevelDidChangeNotification";
NSString *const PCDeviceBatteryStateDidChangeNotification    = @"PCDeviceBatteryStateDidChangeNotification";
NSString *const PCDeviceConnectionStateDidChangeNotification = @"PCDeviceConnectionStateDidChangeNotification";
static PCDevice *device;

#pragma mark - Private Implementation
@implementation PCDevice (Private)

#pragma mark ... Private Local Constants
NSString *const PCDeviceBatteryLevelDefaultsKey    = @"PCDeviceBatteryLevelDefaultsKey";
NSString *const PCDeviceBatteryStateDefaultsKey    = @"PCDeviceBatteryStateDefaultsKey";
NSString *const PCDeviceConnectionStateDefaultsKey = @"PCDeviceConnectionStateDefaultsKey";

#pragma mark ... Instance Methods
#pragma mark ... ... Orientation Methods
- (void)orientationDidChange: (NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName: PCDeviceOrientationDidChangeNotification
                                                        object: notification.object];
}

#pragma mark ... ... Battery Methods
- (void)batteryLevelDidChange: (NSNotification *)notification
{
    if (_batteryMonitoringEnabled)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: PCDeviceBatteryLevelDidChangeNotification
                                                            object: notification.object];
    }
}

- (void)batteryStateDidChange: (NSNotification *)notification
{
    if (_batteryMonitoringEnabled)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: PCDeviceBatteryStateDidChangeNotification
                                                            object: notification.object];
    }
}

- (NSDictionary *)battery
{
    #if !TARGET_OS_IPHONE
        NSString *iopsTypeKey = [NSString stringWithCString: kIOPSTypeKey encoding: NSUTF8StringEncoding];
        NSString *iopsBatteryType = [NSString stringWithCString: kIOPSInternalBatteryType encoding: NSUTF8StringEncoding];
        
        CFTypeRef powerSourcesBlob = IOPSCopyPowerSourcesInfo();
        CFArrayRef powerSources = IOPSCopyPowerSourcesList(powerSourcesBlob);
        for (int i = 0; i < CFArrayGetCount(powerSources); i++)
        {
            CFTypeRef powerSourceBlob = CFArrayGetValueAtIndex(powerSources, i);
            NSDictionary *powerSource = (__bridge_transfer NSDictionary *)IOPSGetPowerSourceDescription(powerSourcesBlob, powerSourceBlob);
            if ([(NSString *)[powerSource objectForKey: iopsTypeKey] isEqualToString: iopsBatteryType])
            {
                CFRelease(powerSourceBlob);
                CFRelease(powerSources);
                
                return powerSource;
            }
        }
    #endif
    
    return nil;
}

- (void)monitorBattery
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
    ^{
        [[NSUserDefaults standardUserDefaults] setFloat: [self batteryLevel] forKey: PCDeviceBatteryLevelDefaultsKey];
        [[NSUserDefaults standardUserDefaults] setInteger: [self batteryState] forKey: PCDeviceBatteryStateDefaultsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        for (; self; sleep(60))
        {
            if (_batteryMonitoringEnabled)
            {
                float batteryLevel = [self batteryLevel];
                if (batteryLevel != [[NSUserDefaults standardUserDefaults] floatForKey: PCDeviceBatteryLevelDefaultsKey])
                {
                    [[NSUserDefaults standardUserDefaults] setFloat: batteryLevel forKey: PCDeviceBatteryLevelDefaultsKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    dispatch_async(dispatch_get_main_queue(),
                    ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName: PCDeviceBatteryLevelDidChangeNotification object: nil];
                    });
                }
                
                PCDeviceBatteryState batteryState = [self batteryState];
                if (batteryState != [[NSUserDefaults standardUserDefaults] integerForKey: PCDeviceBatteryStateDefaultsKey])
                {
                    [[NSUserDefaults standardUserDefaults] setInteger: batteryState forKey: PCDeviceBatteryStateDefaultsKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    dispatch_async(dispatch_get_main_queue(),
                    ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName: PCDeviceBatteryStateDidChangeNotification object: nil];
                    });
                }
            }
        }
    });
}

#pragma mark ... ... Network Connection Methods
- (void)monitorConnectionState
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
    ^{
        [[NSUserDefaults standardUserDefaults] setInteger: [self connectionState] forKey: PCDeviceConnectionStateDefaultsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        for (; self; sleep(60))
        {
            if (_generateConnectionStateNotifications)
            {
                PCDeviceConnectionState connectionState = [self connectionState];
                if (connectionState != [[NSUserDefaults standardUserDefaults] integerForKey: PCDeviceConnectionStateDefaultsKey])
                {
                    [[NSUserDefaults standardUserDefaults] setInteger: connectionState forKey: PCDeviceConnectionStateDefaultsKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    dispatch_async(dispatch_get_main_queue(),
                    ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName: PCDeviceConnectionStateDidChangeNotification object: nil];
                    });
                }
            }
        }
    });
}

@end

#pragma mark - Public Implementation
@implementation PCDevice

#pragma mark ... Local Constants
NSString *const PCUniqueIdentifierDefaultsKey         = @"PCUniqueIdentifierDefaultsKey";
char     *const PCDeviceConnectionExternalHostAddress = "www.google.com";

#pragma mark ... Class Methods
+ (void)initialize
{
    if (self == [PCDevice class])
    {
        static dispatch_once_t initializeOnce;
        dispatch_once(&initializeOnce,
        ^{
            device = [PCDevice alloc];
            
            #if TARGET_OS_IPHONE
                [[NSNotificationCenter defaultCenter] addObserver: device
                                                         selector: @selector(orientationDidChange:)
                                                             name: UIDeviceOrientationDidChangeNotification
                                                           object: nil];
                [[NSNotificationCenter defaultCenter] addObserver: device
                                                         selector: @selector(batteryLevelDidChange:)
                                                             name: UIDeviceBatteryLevelDidChangeNotification
                                                           object: nil];
                [[NSNotificationCenter defaultCenter] addObserver: device
                                                         selector: @selector(batteryStateDidChange:)
                                                             name: UIDeviceBatteryStateDidChangeNotification
                                                           object: nil];
            #else
                [device monitorBattery];
            #endif
            
            [device monitorConnectionState];
        });
    }
}

+ (PCDevice *)currentDevice
{
    return device;
}

#pragma mark ... Instance Methods
- (void)dealloc
{
    #if TARGET_OS_IPHONE
        [[NSNotificationCenter defaultCenter] removeObserver: self];
    #endif
}

#pragma mark ... ... System Identification Methods
- (NSString *)name
{
    #if TARGET_OS_IPHONE
        return [[UIDevice currentDevice] name];
    #else
        return (__bridge_transfer NSString *) SCDynamicStoreCopyComputerName(NULL, NULL);
    #endif
}

- (NSString *)systemName
{
    #if TARGET_OS_IPHONE
        return [[UIDevice currentDevice] systemName];
    #else
        return [[NSProcessInfo  processInfo] operatingSystemName];
    #endif
}

- (NSString *)systemVersion
{
    #if TARGET_OS_IPHONE
        return [[UIDevice currentDevice] systemVersion];
    #else
        return [[NSProcessInfo  processInfo] operatingSystemVersionString];
    #endif
}

- (NSString *)model
{
    #if TARGET_OS_IPHONE
        return [[UIDevice currentDevice] model];
    #else
        size_t len = 0;
        sysctlbyname("hw.model", NULL, &len, NULL, 0);
        
        char *model = malloc(len * sizeof(char));
        sysctlbyname("hw.model", model, &len, NULL, 0);
        NSString *modelName = [NSString stringWithCString: model
                                                 encoding: NSUTF8StringEncoding];
        
        free(model);
        return modelName;
    #endif
}

- (NSString *)uniqueIdentifier
{
    NSString *uid = [[NSUserDefaults standardUserDefaults] stringForKey: PCUniqueIdentifierDefaultsKey];
    
    if (!uid)
    {
        uid = @"";
        for (int i = 0; i < 2; i++)
        {
            CFUUIDRef uuid = CFUUIDCreate(NULL);
            CFStringRef uuid_string = CFUUIDCreateString(NULL, uuid);
            CFRelease(uuid);
            uid = [uid stringByAppendingString: (__bridge_transfer NSString *) uuid_string];
        }
        
        [[NSUserDefaults standardUserDefaults] setValue: uid forKey: PCUniqueIdentifierDefaultsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return uid;
}

#pragma mark ... ... System State Information
#pragma mark ... ... ... User Interface Idiom Methods
- (PCUserInterfaceIdiom)userInterfaceIdiom
{
    #if TARGET_OS_IPHONE
        return (PCUserInterfaceIdiom)[[UIDevice currentDevice] userInterfaceIdiom];
    #else
        return PCUserInterfaceIdiomDesktop;
    #endif
}

#pragma mark ... ... ... Orientation Methods
- (PCDeviceOrientation)orientation
{
    #if TARGET_OS_IPHONE
        return (PCDeviceOrientation)[[UIDevice currentDevice] orientation];
    #else
        return PCDeviceOrientationPortrait;
    #endif
}

- (BOOL)isGeneratingDeviceOrientationNotifications
{
    #if TARGET_OS_IPHONE
        return [[UIDevice currentDevice] isGeneratingDeviceOrientationNotifications];
    #else
        return NO;
    #endif
}

- (void)setGeneratesDeviceOrientationNotifications:(BOOL)generatesDeviceOrientationNotifications
{
    #if TARGET_OS_IPHONE
        if (generatesDeviceOrientationNotifications && ![[UIDevice currentDevice] isGeneratingDeviceOrientationNotifications])
        {
            [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        }
        else if (!generatesDeviceOrientationNotifications && [[UIDevice currentDevice] isGeneratingDeviceOrientationNotifications])
        {
            [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
        }
    #endif
}

#pragma mark ... ... ... Multitasking Methods
- (BOOL)isMultitaskingSupported
{
    #if TARGET_OS_IPHONE
        return [[UIDevice currentDevice] isMultitaskingSupported];
    #else
        return YES;
    #endif
}

#pragma mark ... ... ... Push Notification Methods
- (BOOL)arePushNotificationsSupported
{
    #if TARGET_OS_IPHONE
        return [[UIApplication sharedApplication] respondsToSelector: @selector(registerForRemoteNotificationTypes:)];
    #else
        return [[NSApplication sharedApplication] respondsToSelector: @selector(registerForRemoteNotificationTypes:)];
    #endif
}

#pragma mark ... ... ... iCloud Synchronization Information
- (BOOL)isiCloudKeyValSyncSupported
{
    return NSClassFromString(@"NSUbiquitousKeyValueStore") &&
           [NSUbiquitousKeyValueStore defaultStore];
}

- (BOOL)isiCloudFileSyncSupported
{
    return [[NSFileManager defaultManager] respondsToSelector: @selector(URLForUbiquityContainerIdentifier:)] &&
           [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier: nil];
}

#pragma mark ... ... ... Battery Methods
- (float)batteryLevel
{
    #if TARGET_OS_IPHONE
        return [[UIDevice currentDevice] batteryLevel];
    #else
        if (_batteryMonitoringEnabled)
        {
            NSString *iopsCurrentCapacityKey = [NSString stringWithCString: kIOPSCurrentCapacityKey encoding: NSUTF8StringEncoding];
            return [(NSNumber *)[[self battery] objectForKey: iopsCurrentCapacityKey] floatValue];
        }
        
        return -1;
    #endif
}

- (BOOL)isBatteryMonitoringEnabled
{
    return _batteryMonitoringEnabled;
}

- (void)setBatteryMonitoringEnabled:(BOOL)batteryMonitoringEnabled
{
    _batteryMonitoringEnabled = batteryMonitoringEnabled;
    
    #if TARGET_OS_IPHONE
        [[UIDevice currentDevice] setBatteryMonitoringEnabled: batteryMonitoringEnabled];
    #endif
}

- (PCDeviceBatteryState)batteryState
{
    #if TARGET_OS_IPHONE
        return [[UIDevice currentDevice] batteryState];
    #else
        if (_batteryMonitoringEnabled)
        {
            NSString *iopsSourceStateKey = [NSString stringWithCString: kIOPSPowerSourceStateKey encoding: NSUTF8StringEncoding];
            NSString *iopsACPowerValue = [NSString stringWithCString: kIOPSACPowerValue encoding: NSUTF8StringEncoding];
            
            BOOL pluggedIn = [[[self battery] valueForKey: iopsSourceStateKey] isEqualToString: iopsACPowerValue];
            BOOL charged = [self batteryLevel] >= 1.0;
            
            if (pluggedIn && charged)
            {
                return PCDeviceBatteryStateFull;
            }
            else if (pluggedIn && !charged)
            {
                return PCDeviceBatteryStateCharging;
            }
            else if (!pluggedIn)
            {
                return PCDeviceBatteryStateUnplugged;
            }
        }
    
        return PCDeviceBatteryStateUnknown;
    #endif
}

#pragma mark ... ... ... Network Connection Methods
- (PCDeviceConnectionState)connectionState
{
    SCNetworkReachabilityFlags reachabilityFlags;
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, PCDeviceConnectionExternalHostAddress);
    SCNetworkReachabilityGetFlags(reachability, &reachabilityFlags);
    CFRelease(reachability);
    
    if (reachabilityFlags & kSCNetworkReachabilityFlagsConnectionRequired)
    {
        return PCDeviceConnectionStateDisconnected;
    }
    else if (reachabilityFlags & kSCNetworkReachabilityFlagsReachable)
    {
        #if TARGET_OS_IPHONE
            if (reachabilityFlags & kSCNetworkReachabilityFlagsIsWWAN)
            {
                return PCDeviceConnectionStateMobile;
            }
        #endif
        
        return PCDeviceConnectionStateWiFi;
    }
    
    return PCDeviceConnectionStateUnknown;
}

- (BOOL) isGeneratingConnectionStateNotifications
{
    return _generateConnectionStateNotifications;
}

- (void) setGeneratesConnectionStateNotifications:(BOOL)generatesConnectionStateNotifications
{
    _generateConnectionStateNotifications = generatesConnectionStateNotifications;
}

@end