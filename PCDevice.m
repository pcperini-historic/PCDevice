//
//  PCDevice.m
//  PCDevice
//
//  Created by Patrick Perini on 2/14/12.
//  Licensing information availabe in README.md
//

#import "PCDevice.h"

#pragma mark - External Constants
NSString *const PCDeviceOrientationDidChangeNotification = @"PCDeviceOrientationDidChangeNotification";
NSString *const PCDeviceBatteryLevelDidChangeNotification = @"PCDeviceBatteryLevelDidChangeNotification";
NSString *const PCDeviceBatteryStateDidChangeNotification = @"PCDeviceBatteryStateDidChangeNotification";
NSString *const PCDeviceConnectionStateDidChangeNotification = @"PCDeviceConnectionStateDidChangeNotification";

#pragma mark - Internal Constants
/*!
 *  DOCME
 */
NSString *const PCDeviceBatteryLevelDefaultsKey = @"PCDeviceBatteryLevelDefaultsKey";

/*!
 *  DOCME
 */
NSString *const PCDeviceBatteryStateDefaultsKey = @"PCDeviceBatteryStateDefaultsKey";

/*!
 *  DOCME
 */
NSString *const PCDeviceConnectionStateDefaultsKey = @"PCDeviceConnectionStateDefaultsKey";

/*!
 *  DOCME
 */
NSString *const PCUniqueIdentifierDefaultsKey = @"PCUniqueIdentifierDefaultsKey";

/*!
 *  DOCME
 */
char *const PCDeviceConnectionExternalHostAddress = "www.google.com";

#pragma mark - Globals
static PCDevice *PCCurrentDevice;

@interface PCDevice ()

#pragma mark - Accessors
/*!
 *  DOCME
 */
- (NSDictionary *)batteryDictionary;

#pragma mark - Mutators
/*!
 *  DOCME
 */
- (void)startMonitoringBattery;

/*!
 *  DOCME
 */
- (void)startMonitoringConnectionState;

#pragma mark - Responders
/*!
 *  DOCME
 */
- (void)orientationDidChange:(NSNotification *)notification;

/*!
 *  DOCME
 */
- (void)batteryLevelDidChange:(NSNotification *)notification;

/*!
 *  DOCME
 */
- (void)batteryStateDidChange:(NSNotification *)notification;

@end

@implementation PCDevice

#pragma mark - Singletons
+ (PCDevice *)currentDevice
{
    if (!PCCurrentDevice)
    {
        PCCurrentDevice = [[PCDevice alloc] init];
    }
    
    return PCCurrentDevice;
}

#pragma mark - Initializers
- (id)init
{
    self = [super init];
    if (!self)
        return nil;
    
    #if TARGET_OS_IPHONE
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(orientationDidChange:)
                                                 name: UIDeviceOrientationDidChangeNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(batteryLevelDidChange:)
                                                 name: UIDeviceBatteryLevelDidChangeNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(batteryStateDidChange:)
                                                 name: UIDeviceBatteryStateDidChangeNotification
                                               object: nil];
    #else
    [self startMonitoringBattery];
    #endif
    
    [self startMonitoringConnectionState];
    
    return self;
}

#pragma mark - Deallocators
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

#pragma mark - Accessors
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
        [[NSUserDefaults standardUserDefaults] setValue: [[NSUUID UUID] UUIDString] forKey: PCUniqueIdentifierDefaultsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return uid;
}

- (PCDevicePlatform)platform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    
    char *platformNameString = malloc(size);
    sysctlbyname("hw.machine", platformNameString, &size, NULL, 0);
    
    NSString *platformName = [NSString stringWithCString: platformNameString encoding: NSUTF8StringEncoding];
    free(platformNameString);
    
    // iPhones
    if ([platformName isEqualToString: @"iPhone1,1"])
        return PCDeviceiPhonePlatform;
    
    if ([platformName isEqualToString: @"iPhone1,2"])
        return PCDeviceiPhone3GPlatform;
    
    if ([platformName hasPrefix: @"iPhone2"])
        return PCDeviceiPhone3GSPlatform;
    
    if ([platformName hasPrefix: @"iPhone3"])
        return PCDeviceiPhone4Platform;
    
    if ([platformName hasPrefix: @"iPhone4"])
        return PCDeviceiPhone4SPlatform;
    
    if ([platformName isEqualToString: @"iPhone5,3"])
        return PCDeviceiPhone5cPlatform;
    
    if ([platformName hasPrefix: @"iPhone5"])
        return PCDeviceiPhone5Platform;
    
    if ([platformName hasPrefix: @"iPhone6"])
        return PCDeviceiPhone5sPlatform;
    
    // iPods Touch
    if ([platformName hasPrefix: @"iPod1"])
        return PCDevice1stGeniPodTouchPlatform;
    
    if ([platformName hasPrefix: @"iPod2"])
        return PCDevice2ndGeniPodTouchPlatform;
    
    if ([platformName hasPrefix: @"iPod3"])
        return PCDevice3rdGeniPodTouchPlatform;
    
    if ([platformName hasPrefix: @"iPod4"])
        return PCDevice4thGeniPadPlatform;
    
    if ([platformName hasPrefix: @"iPod5"])
        return PCDevice5thGeniPodTouchPlatform;
    
    // iPads Mini
    if ([platformName isEqualToString: @"iPad2,5"])
        return PCDeviceiPadMiniPlatform;
    
    if ([platformName isEqualToString: @"iPad2,6"])
        return PCDeviceiPadMiniPlatform;
    
    if ([platformName isEqualToString: @"iPad2,7"])
        return PCDeviceiPadMiniPlatform;
    
    // iPads
    if ([platformName hasPrefix: @"iPad1"])
        return PCDeviceiPadPlatform;
    
    if ([platformName hasPrefix: @"iPad2"])
        return PCDeviceiPad2Platform;
    
    if ([platformName hasPrefix: @"iPad3"])
        return PCDeviceiPad3Platform;
    
    if ([platformName hasPrefix: @"iPad4"])
        return PCDevice4thGeniPadPlatform;
    
    // Macs
    if ([platformName hasPrefix: @"iMac"])
        return PCDeviceiMacPlatform;
    
    // Macs
    if ([platformName hasPrefix: @"iMac"])
        return PCDeviceiMacPlatform;
    
    if ([platformName hasPrefix: @"MacBookAir"])
        return PCDeviceMacBookAirPlatform;
    
    if ([platformName hasPrefix: @"MacBookPro"])
        return PCDeviceMacBookProPlatform;
    
    NSRange macIndicatorRange = [platformName rangeOfString: @"Mac"];
    if (macIndicatorRange.location != -1)
        return PCDeviceOtherMacPlatform;
    
    return PCDeviceUnknownPlatform;
}

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

- (BOOL)isMultitaskingSupported
{
    #if TARGET_OS_IPHONE
    return [[UIDevice currentDevice] isMultitaskingSupported];
    #else
    return YES;
    #endif
}

- (BOOL)arePushNotificationsSupported
{
    #if TARGET_OS_IPHONE
        return [[UIApplication sharedApplication] respondsToSelector: @selector(registerForRemoteNotificationTypes:)];
    #else
        return [[NSApplication sharedApplication] respondsToSelector: @selector(registerForRemoteNotificationTypes:)];
    #endif
}

- (BOOL)isiCloudKeyValSyncSupported
{
    return NSClassFromString(@"NSUbiquitousKeyValueStore") && [NSUbiquitousKeyValueStore defaultStore];
}

- (BOOL)isiCloudFileSyncSupported
{
    return [[NSFileManager defaultManager] respondsToSelector: @selector(URLForUbiquityContainerIdentifier:)] && [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier: nil];
}

- (NSDictionary *)batteryDictionary
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

- (CGFloat)batteryLevel
{
    #if TARGET_OS_IPHONE
    return [[UIDevice currentDevice] batteryLevel];
    #else
    if ([self batteryMonitoringIsEnabled])
    {
        NSString *iopsCurrentCapacityKey = [NSString stringWithCString: kIOPSCurrentCapacityKey encoding: NSUTF8StringEncoding];
        return [(NSNumber *)[[self batteryDictionary] objectForKey: iopsCurrentCapacityKey] floatValue];
    }
    
    return -1;
    #endif
}
- (PCDeviceBatteryState)batteryState
{
    #if TARGET_OS_IPHONE
    return (PCDeviceBatteryState)[[UIDevice currentDevice] batteryState];
    #else
    if ([self batteryMonitoringIsEnabled])
    {
        NSString *iopsSourceStateKey = [NSString stringWithCString: kIOPSPowerSourceStateKey encoding: NSUTF8StringEncoding];
        NSString *iopsACPowerValue = [NSString stringWithCString: kIOPSACPowerValue encoding: NSUTF8StringEncoding];
        
        BOOL pluggedIn = [[[self batteryDictionary] valueForKey: iopsSourceStateKey] isEqualToString: iopsACPowerValue];
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

#pragma mark - Mutators
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

- (void)setBatteryMonitoringEnabled:(BOOL)batteryMonitoringEnabled
{
    _batteryMonitoringEnabled = batteryMonitoringEnabled;
    
    #if TARGET_OS_IPHONE
    [[UIDevice currentDevice] setBatteryMonitoringEnabled: batteryMonitoringEnabled];
    #endif
}

- (void) setGeneratesConnectionStateNotifications:(BOOL)generatesConnectionStateNotifications
{
    _generatesConnectionStateNotifications = generatesConnectionStateNotifications;
}

- (void)startMonitoringBattery
{
    __weak typeof(self) weakSelf = self;
    dispatch_queue_t batteryMonitoringQueue = dispatch_queue_create("PCDevice.batteryMonitoringQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(batteryMonitoringQueue,
    ^{
       [[NSUserDefaults standardUserDefaults] setFloat: [weakSelf batteryLevel] forKey: PCDeviceBatteryLevelDefaultsKey];
       [[NSUserDefaults standardUserDefaults] setInteger: [weakSelf batteryState] forKey: PCDeviceBatteryStateDefaultsKey];
       [[NSUserDefaults standardUserDefaults] synchronize];
       
       for (; weakSelf; sleep(60))
       {
           if ([weakSelf batteryMonitoringIsEnabled])
           {
               float batteryLevel = [weakSelf batteryLevel];
               if (batteryLevel != [[NSUserDefaults standardUserDefaults] floatForKey: PCDeviceBatteryLevelDefaultsKey])
               {
                   [[NSUserDefaults standardUserDefaults] setFloat: batteryLevel forKey: PCDeviceBatteryLevelDefaultsKey];
                   [[NSUserDefaults standardUserDefaults] synchronize];
                   
                   dispatch_async(dispatch_get_main_queue(),
                   ^{
                       [[NSNotificationCenter defaultCenter] postNotificationName: PCDeviceBatteryLevelDidChangeNotification
                                                                           object: nil];
                   });
               }
               
               PCDeviceBatteryState batteryState = [weakSelf batteryState];
               if (batteryState != [[NSUserDefaults standardUserDefaults] integerForKey: PCDeviceBatteryStateDefaultsKey])
               {
                   [[NSUserDefaults standardUserDefaults] setInteger: batteryState forKey: PCDeviceBatteryStateDefaultsKey];
                   [[NSUserDefaults standardUserDefaults] synchronize];
                   
                   dispatch_async(dispatch_get_main_queue(),
                   ^{
                       [[NSNotificationCenter defaultCenter] postNotificationName: PCDeviceBatteryStateDidChangeNotification
                                                                           object: nil];
                   });
               }
           }
       }
    });
}

#pragma mark ... ... Network Connection Methods
- (void)startMonitoringConnectionState
{
    __weak typeof(self) weakSelf = self;
    dispatch_queue_t connectionStateMonitoringQueue = dispatch_queue_create("PCDevice.connectionStateMonitoringQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(connectionStateMonitoringQueue,
    ^{
        [[NSUserDefaults standardUserDefaults] setInteger: [weakSelf connectionState] forKey: PCDeviceConnectionStateDefaultsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];

        for (; weakSelf; sleep(60))
        {
            if ([weakSelf isGeneratingConnectionStateNotifications])
            {
                PCDeviceConnectionState connectionState = [weakSelf connectionState];
                if (connectionState != [[NSUserDefaults standardUserDefaults] integerForKey: PCDeviceConnectionStateDefaultsKey])
                {
                    [[NSUserDefaults standardUserDefaults] setInteger: connectionState forKey: PCDeviceConnectionStateDefaultsKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                   
                    dispatch_async(dispatch_get_main_queue(),
                    ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName: PCDeviceConnectionStateDidChangeNotification
                                                                            object: nil];
                    });
                }
            }
        }
    });
}

#pragma mark - Responders
- (void)orientationDidChange: (NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName: PCDeviceOrientationDidChangeNotification
                                                        object: [notification object]];
}

- (void)batteryLevelDidChange: (NSNotification *)notification
{
    if ([self batteryMonitoringIsEnabled])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: PCDeviceBatteryLevelDidChangeNotification
                                                            object: [notification object]];
    }
}

- (void)batteryStateDidChange: (NSNotification *)notification
{
    if ([self batteryMonitoringIsEnabled])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: PCDeviceBatteryStateDidChangeNotification
                                                            object: [notification object]];
    }
}

@end