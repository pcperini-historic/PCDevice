//
//  PCDevice.h
//  PCDevice
//
//  Created by Patrick Perini on 2/14/12.
//  Licensing information availabe in README.md
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import <sys/sysctl.h>

#if !TARGET_OS_IPHONE
    #import <IOKit/ps/IOPSKeys.h>
    #import <IOKit/ps/IOPowerSources.h>
    #import <SystemConfiguration/SystemConfiguration.h>
#endif


#pragma mark - External Constants
/*!
 *  DOCME
 */
extern  NSString *const PCDeviceOrientationDidChangeNotification;

/*!
 *  DOCME
 */
extern  NSString *const PCDeviceBatteryLevelDidChangeNotification;

/*!
 *  DOCME
 */
extern  NSString *const PCDeviceBatteryStateDidChangeNotification;

/*!
 *  DOCME
 */
extern  NSString *const PCDeviceConnectionStateDidChangeNotification;

/*!
 *  DOCME
 */
typedef enum
{
    PCUserInterfaceIdiomPhone,
    PCUserInterfaceIdiomTablet,
    PCUserInterfaceIdiomDesktop
} PCUserInterfaceIdiom;

/*!
 *  DOCME
 *  Thanks, Erica Sadun!
 */
typedef enum
{
    // Unknown
    PCDeviceUnknownPlatform = -1,
    
    // iPhones
    PCDeviceiPhonePlatform,
    PCDeviceiPhone3GPlatform,
    PCDeviceiPhone3GSPlatform,
    PCDeviceiPhone4Platform,
    PCDeviceiPhone4SPlatform,
    PCDeviceiPhone5Platform,
    PCDeviceiPhone5cPlatform,
    PCDeviceiPhone5sPlatform,
    
    // iPods Touch
    PCDevice1stGeniPodTouchPlatform,
    PCDevice2ndGeniPodTouchPlatform,
    PCDevice3rdGeniPodTouchPlatform,
    PCDevice4thGeniPodTouchPlatform,
    PCDevice5thGeniPodTouchPlatform,
    
    // iPads
    PCDeviceiPadPlatform,
    PCDeviceiPad2Platform,
    PCDeviceiPad3Platform,
    PCDevice4thGeniPadPlatform,
    
    // iPads Mini
    PCDeviceiPadMiniPlatform,
    
    // Macs
    PCDeviceiMacPlatform,
    PCDeviceMacBookAirPlatform,
    PCDeviceMacBookProPlatform,
    PCDeviceOtherMacPlatform
} PCDevicePlatform;

/*!
 *  DOCME
 */
typedef enum
{
    PCDeviceBatteryStateUnknown,
    PCDeviceBatteryStateUnplugged,
    PCDeviceBatteryStateCharging,
    PCDeviceBatteryStateFull,
} PCDeviceBatteryState;

/*!
 *  DOCME
 */
typedef enum
{
    PCDeviceOrientationUknown               = 0b00000000,
    PCDeviceOrientationPortrait             = 0b00000001,
    PCDeviceOrientationPortraitUpsideDown   = 0b00000010,
    PCDeviceOrientationLandscapeLeft        = 0b00000100,
    PCDeviceOrientationLandscapeRight       = 0b00001000,
    PCDeviceOrientationFaceUp               = 0b00010000,
    PCDeviceOrientationFaceDown             = 0b00100000
} PCDeviceOrientation;

/*!
 *  DOCME
 */
typedef enum
{
    PCDeviceConnectionStateUnknown,
    PCDeviceConnectionStateMobile,
    PCDeviceConnectionStateWiFi,
    PCDeviceConnectionStateDisconnected
} PCDeviceConnectionState;

#pragma mark - Macros
/*!
 *  DOCME
 */
#define PCDeviceOrientationIsPortrait(orientation)                \
        (orientation == PCDeviceOrientationPortrait            || \
         orientation == PCDeviceOrientationPortraitUpsideDown)

/*!
 *  DOCME
 */
#define PCDeviceOrientationIsLandscape(orientation)               \
        (orientation == PCDeviceOrientationLandscapeLeft       || \
         orientation == PCDeviceOrientationLandscapeRight)

@interface PCDevice : NSObject

#pragma mark - Singletons
+ (PCDevice *) currentDevice;

#pragma mark - Properties
/*!
 *  DOCME
 */
@property (nonatomic, readonly) NSString *name;

/*!
 *  DOCME
 */
@property (nonatomic, readonly) NSString *systemName;

/*!
 *  DOCME
 */
@property (nonatomic, readonly) NSString *systemVersion;

/*!
 *  DOCME
 */
@property (nonatomic, readonly) NSString *model;

/*!
 *  DOCME
 */
@property (nonatomic, readonly) NSString *uniqueIdentifier;

/*!
 *  DOCME
 */
@property (nonatomic, readonly) PCUserInterfaceIdiom userInterfaceIdiom;

/*!
 *  DOCME
 */
@property (nonatomic, readonly) PCDevicePlatform platform;

/*!
 *  DOCME
 */
@property (nonatomic, readonly) PCDeviceOrientation orientation;

/*!
 *  DOCME
 */
@property (nonatomic, getter = isGeneratingDeviceOrientationNotifications) BOOL generatesDeviceOrientationNotifications;

/*!
 *  DOCME
 */
@property (nonatomic, readonly, getter = multitaskingIsSupported) BOOL multitaskingSupported;

/*!
 *  DOCME
 */
@property (nonatomic, readonly, getter = pushNotificationsAreSupported) BOOL pushNotificationsSupported;

/*!
 *  DOCME
 */
@property (nonatomic, readonly, getter = iCloudKeyValSyncIsSupported) BOOL iCloudKeyValSyncSupported;

/*!
 *  DOCME
 */
@property (nonatomic, readonly, getter = iCloudFileSyncIsSupported) BOOL iCloudFileSyncSupported;

/*!
 *  DOCME
 */
@property (nonatomic, readonly) CGFloat batteryLevel;

/*!
 *  DOCME
 */
@property (nonatomic, getter = batteryMonitoringIsEnabled) BOOL batteryMonitoringEnabled;

/*!
 *  DOCME
 */
@property (nonatomic, readonly) PCDeviceBatteryState batteryState;

/*!
 *  DOCME
 */
@property (nonatomic, readonly) PCDeviceConnectionState connectionState;

/*!
 *  DOCME
 */
@property (nonatomic, getter = isGeneratingConnectionStateNotifications) BOOL generatesConnectionStateNotifications;

@end