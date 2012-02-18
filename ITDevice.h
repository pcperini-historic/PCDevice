//
//  ITDevice.h
//  ITDevice
//
//  Created by Patrick Perini on 2/14/12.
//  Licensing information availabe in README.md
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SCNetworkReachability.h>

#if !TARGET_OS_IPHONE
    #import <sys/sysctl.h>
    #import <IOKit/ps/IOPSKeys.h>
    #import <IOKit/ps/IOPowerSources.h>
    #import <SystemConfiguration/SystemConfiguration.h>
#endif


#pragma mark - Global Constants
#define ITCurrentDevice [ITDevice currentDevice]
extern  NSString *const ITDeviceOrientationDidChangeNotification;
extern  NSString *const ITDeviceBatteryLevelDidChangeNotification;
extern  NSString *const ITDeviceBatteryStateDidChangeNotification;
extern  NSString *const ITDeviceConnectionStateDidChangeNotification;

#pragma mark - Global Enumerations
typedef enum
{
    ITUserInterfaceIdiomPhone,
    ITUserInterfaceIdiomPad,
    ITUserInterfaceIdiomDesktop
} ITUserInterfaceIdiom;

typedef enum
{
    ITDeviceBatteryStateUnknown,
    ITDeviceBatteryStateUnplugged,
    ITDeviceBatteryStateCharging,
    ITDeviceBatteryStateFull,
} ITDeviceBatteryState;

typedef enum
{
    ITDeviceOrientationUknown,
    ITDeviceOrientationPortrait,
    ITDeviceOrientationPortraitUpsideDown,
    ITDeviceOrientationLandscapeLeft,
    ITDeviceOrientationLandscapeRight,
    ITDeviceOrientationFaceUp,
    ITDeviceOrientationFaceDown
} ITDeviceOrientation;

typedef enum
{
    ITDeviceConnectionStateUnknown,
    ITDeviceConnectionStateMobile,
    ITDeviceConnectionStateWiFi,
    ITDeviceConnectionStateDisconnected
} ITDeviceConnectionState;

#pragma mark - Global Macros
#define ITDeviceOrientationIsPortrait(orientation)                \
        (orientation == ITDeviceOrientationPortrait            || \
         orientation == ITDeviceOrientationPortraitUpsideDown)

#define ITDeviceOrientationIsLandscape(orientation)               \
        (orientation == ITDeviceOrientationLandscapeLeft       || \
         orientation == ITDeviceOrientationLandscapeRight)

#pragma mark - Public Interface
@interface ITDevice : NSObject
{
    #pragma mark ... Instance Variables
    @private
    BOOL _batteryMonitoringEnabled;
    BOOL _generateConnectionStateNotifications;
}

#pragma mark ... Class Methods
+ (ITDevice *) currentDevice;

#pragma mark ... Instance Properties
#pragma mark ... ... System Identification Information
@property (nonatomic, readonly, retain)                                    NSString *name;
@property (nonatomic, readonly, retain)                                    NSString *systemName;
@property (nonatomic, readonly, retain)                                    NSString *systemVersion;
@property (nonatomic, readonly, retain)                                    NSString *model;
@property (nonatomic, readonly, retain)                                    NSString *uniqueIdentifier;
#pragma mark ... ... System State Information
#pragma mark ... ... ... User Interface Idiom Information
@property (nonatomic, readonly)                                            ITUserInterfaceIdiom userInterfaceIdiom;
#pragma mark ... ... ... Orientation Information
@property (nonatomic, readonly)                                            ITDeviceOrientation orientation;
@property (nonatomic, getter = isGeneratingDeviceOrientationNotifications) BOOL generatesDeviceOrientationNotifications;
#pragma mark ... ... ... Multitasking Information
@property (nonatomic, readonly, getter = isMultitaskingSupported)          BOOL multitaskingSupported;
#pragma mark ... ... ... Push Notification Information
@property (nonatomic, readonly, getter = arePushNotificationsSupported)    BOOL pushNotificationsSupported;
#pragma mark ... ... ... Batter Information
@property (nonatomic, readonly)                                            float batteryLevel;
@property (nonatomic, getter = isBatteryMonitoringEnabled)                 BOOL batteryMonitoringEnabled;
@property (nonatomic, readonly)                                            ITDeviceBatteryState batteryState;
#pragma mark ... ... ... Network Connection Information
@property (nonatomic, readonly)                                            ITDeviceConnectionState connectionState;
@property (nonatomic, getter = isGeneratingConnectionStateNotifications)   BOOL generatesConnectionStateNotifications;

@end