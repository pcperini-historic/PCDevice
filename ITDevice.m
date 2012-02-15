//
//  ITDevice.m
//  ITDevice
//
//  Created by Patrick Perini on 2/14/12.
//  Licensing information availabe in README.md
//

#import "ITDevice.h"

#pragma mark - Global Constants
NSString *const ITDeviceOrientationDidChangeNotification     = @"ITDeviceOrientationDidChangeNotification";
NSString *const ITDeviceBatteryLevelDidChangeNotification    = @"ITDeviceBatteryLevelDidChangeNotification";
NSString *const ITDeviceBatteryStateDidChangeNotification    = @"ITDeviceBatteryStateDidChangeNotification";
NSString *const ITDeviceConnectionStateDidChangeNotification = @"ITDeviceConnectionStateDidChangeNotification";
static ITDevice *device;

#pragma mark - Private Implementation
@implementation ITDevice (Private)

#pragma mark ... Private Local Constants
NSString *const ITDeviceBatteryLevelDefaultsKey    = @"ITDeviceBatteryLevelDefaultsKey";
NSString *const ITDeviceBatteryStateDefaultsKey    = @"ITDeviceBatteryStateDefaultsKey";
NSString *const ITDeviceConnectionStateDefaultsKey = @"ITDeviceConnectionStateDefaultsKey";

#pragma mark ... Instance Methods
#pragma mark ... ... Orientation Methods
- (void)orientationDidChange: (NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName: ITDeviceOrientationDidChangeNotification
                                                        object: notification.object];
}

#pragma mark ... ... Battery Methods
- (void)batteryLevelDidChange: (NSNotification *)notification
{
    if (_batteryMonitoringEnabled)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: ITDeviceBatteryLevelDidChangeNotification
                                                            object: notification.object];
    }
}

- (void)batteryStateDidChange: (NSNotification *)notification
{
    if (_batteryMonitoringEnabled)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: ITDeviceBatteryStateDidChangeNotification
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
        [[NSUserDefaults standardUserDefaults] setFloat: [self batteryLevel] forKey: ITDeviceBatteryLevelDefaultsKey];
        [[NSUserDefaults standardUserDefaults] setInteger: [self batteryState] forKey: ITDeviceBatteryStateDefaultsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        for (; self; sleep(60))
        {
            if (_batteryMonitoringEnabled)
            {
                float batteryLevel = [self batteryLevel];
                if (batteryLevel != [[NSUserDefaults standardUserDefaults] floatForKey: ITDeviceBatteryLevelDefaultsKey])
                {
                    [[NSUserDefaults standardUserDefaults] setFloat: batteryLevel forKey: ITDeviceBatteryLevelDefaultsKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    dispatch_async(dispatch_get_main_queue(),
                    ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName: ITDeviceBatteryLevelDidChangeNotification object: nil];
                    });
                }
                
                ITDeviceBatteryState batteryState = [self batteryState];
                if (batteryState != [[NSUserDefaults standardUserDefaults] integerForKey: ITDeviceBatteryStateDefaultsKey])
                {
                    [[NSUserDefaults standardUserDefaults] setInteger: batteryState forKey: ITDeviceBatteryStateDefaultsKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    dispatch_async(dispatch_get_main_queue(),
                    ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName: ITDeviceBatteryStateDidChangeNotification object: nil];
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
        [[NSUserDefaults standardUserDefaults] setInteger: [self connectionState] forKey: ITDeviceConnectionStateDefaultsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        for (; self; sleep(60))
        {
            if (_generateConnectionStateNotifications)
            {
                ITDeviceConnectionState connectionState = [self connectionState];
                if (connectionState != [[NSUserDefaults standardUserDefaults] integerForKey: ITDeviceConnectionStateDefaultsKey])
                {
                    [[NSUserDefaults standardUserDefaults] setInteger: connectionState forKey: ITDeviceConnectionStateDefaultsKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    dispatch_async(dispatch_get_main_queue(),
                    ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName: ITDeviceConnectionStateDidChangeNotification object: nil];
                    });
                }
            }
        }
    });
}

@end

#pragma mark - Public Implementation
@implementation ITDevice

#pragma mark ... Local Constants
NSString *const ITUniqueIdentifierDefaultsKey         = @"ITUniqueIdentifierDefaultsKey";
char     *const ITDeviceConnectionExternalHostAddress = "www.google.com";

#pragma mark ... Class Methods
+ (void)initialize
{
    if (self == [ITDevice class])
    {
        static dispatch_once_t initializeOnce;
        dispatch_once(&initializeOnce,
        ^{
            device = [ITDevice alloc];
            
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

+ (ITDevice *)currentDevice
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
    NSString *uid = [[NSUserDefaults standardUserDefaults] stringForKey: ITUniqueIdentifierDefaultsKey];
    
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
        
        [[NSUserDefaults standardUserDefaults] setValue: uid forKey: ITUniqueIdentifierDefaultsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return uid;
}

#pragma mark ... ... System State Information
#pragma mark ... ... ... User Interface Idiom Methods
- (ITUserInterfaceIdiom)userInterfaceIdiom
{
    #if TARGET_OS_IPHONE
        return (ITUserInterfaceIdiom)[[UIDevice currentDevice] userInterfaceIdiom];
    #else
        return ITUserInterfaceIdiomDesktop;
    #endif
}

#pragma mark ... ... ... Orientation Methods
- (ITDeviceOrientation)orientation
{
    #if TARGET_OS_IPHONE
        return (ITDeviceOrientation)[[UIDevice currentDevice] orientation];
    #else
        return ITDeviceOrientationPortrait;
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

- (ITDeviceBatteryState)batteryState
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
                return ITDeviceBatteryStateFull;
            }
            else if (pluggedIn && !charged)
            {
                return ITDeviceBatteryStateCharging;
            }
            else if (!pluggedIn)
            {
                return ITDeviceBatteryStateUnplugged;
            }
        }
    
        return ITDeviceBatteryStateUnknown;
    #endif
}

#pragma mark ... ... ... Network Connection Methods
- (ITDeviceConnectionState)connectionState
{
    SCNetworkReachabilityFlags reachabilityFlags;
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, ITDeviceConnectionExternalHostAddress);
    SCNetworkReachabilityGetFlags(reachability, &reachabilityFlags);
    CFRelease(reachability);
    
    if (reachabilityFlags & kSCNetworkReachabilityFlagsConnectionRequired)
    {
        return ITDeviceConnectionStateDisconnected;
    }
    else if (reachabilityFlags & kSCNetworkReachabilityFlagsReachable)
    {
        #if TARGET_OS_IPHONE
            if (reachabilityFlags & kSCNetworkReachabilityFlagsIsWWAN)
            {
                return ITDeviceConnectionStateMobile;
            }
        #endif
        
        return ITDeviceConnectionStateWiFi;
    }
    
    return ITDeviceConnectionStateUnknown;
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