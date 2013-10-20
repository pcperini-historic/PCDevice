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

- (void) setGeneratesConnectionStateNotifications:(BOOL)generatesConnectionStateNotifications
{
    _generatesConnectionStateNotifications = generatesConnectionStateNotifications;
}

@end