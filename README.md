#ITDevice#



Inherits From:    NSObject

Declared In:      ITDevice.h


##Overview##

The `ITDevice` class provides a singleton instance representing the current device. From this instance you can obtain information about the device such as assigned name, device model, and operating-system name and version.

You also use the `ITDevice` instance to detect changes in the device’s characteristics, such as physical orientation. You get the current orientation using the orientation property or receive change notifications by registering for the `ITDeviceOrientationDidChangeNotification` notification. Before using either of these techniques to get orientation data, you must enable data delivery by setting the `generatesDeviceOrientationNotifications` property to `YES`. When you no longer need to track the device orientation, set the `generatesDeviceOrientationNotifications` property to `NO` to disable the delivery of notifications.

Similarly, you can use the `ITDevice` instance to obtain information and notifications about changes to the battery’s charge state (described by the `batteryState` property) and charge level (described by the `batteryLevel` property). The `ITDevice` instance also provides access to the network connection state (described by the `connectionState` property). The network connection state represents the availability of Internet communication and whether the device is connected via a mobile data connection. Enable battery monitoring or connection monitoring only when you need it.

More documentation will be added when possible.

##Tasks##

###Getting the Shared Device Instance###
    + currentDevice
    ITCurrentDevice

###Determining Available Features###
    multitaskingSupported (property)

###Identifying the Device and Operating System###
    name             (property)
    systemName       (property)
    systemVersion    (property)
    model            (property)
    uniqueIdentifier (property)

###Getting the Device Orientation###
    orientation                              (property)
    generatesDeviceOrientationNotificiations (property)

###Getting the Device Battery State###
    batteryLevel             (property)
    batteryMonitoringEnabled (property)
    batteryState             (property)

###Getting the Device Network Connection State###
    connectionState                       (property)
    generatesConnectionStateNotifications (property)
    
##Properties##

**batteryLevel**

> The battery charge level for the device.

    @property(nonatomic, readonly) float batteryLevel
    
> *Discussion*

>> Battery level ranges from 0.0 (fully discharged) to 1.0 (100% charged). Before accessing this property, ensure that battery monitoring is enabled.
>> If battery monitoring is not enabled, battery state is `ITDeviceBatteryStateUnknown` and the value of this property is -1.0.
    
**batteryMonitoringEnabled**

> A Boolean value indicating whether battery monitoring is enabled (`YES`) or not (`NO`).

    @property(nonatomic, getter = isBatteryMonitoringEnabled) BOOL batteryMonitoringEnabled
    
> *Discussion*

>> Enable battery monitoring if you need to be notified of changes to the battery state, or if you want to check the battery charge level.
>> The default value of this property is `NO`, which:

>> - Disables the posting of battery-related notifications
>> - Disables the ability to read battery charge level and battery state

**batteryState**

> The battery state for the device.

    @property(nonatomic, readonly) ITDeviceBatteryState batteryState
    
> *Discussion*

>> The value for `batteryState` is one of the constants in `ITDeviceBatteryState`.
>> If battery monitoring is not enabled, the value of this property is `ITDeviceBatteryStateUnknown`.

**generatesDeviceOrientationNotifications**

> A Boolean value that indicates whether the receiver generates orientation notifications (`YES`) or not (`NO`).

    @property (nonatomic, getter = isGeneratingDeviceOrientationNotifications) BOOL generatesDeviceOrientationNotifications

> *Discussion*

>> If the value of this property is `YES`, the shared `ITDevice` object posts an `ITDeviceOrientationDidChangeNotification` notification when the device changes orientation.
>> If the value is `NO`, it generates no orientation notifications. This property has no effect in the Mac OS X environment.

**model**

> The model of the device.

    @property (nonatomic, readonly, retain) NSString *model
    
**multitaskingSupported**

> A Boolean value indicating whether multitasking is supported on the current device.

    @property (nonatomic, readonly, getter = isMultitaskingSupported) BOOL multitaskingSupported
    
**name**

> The name identifying the device.

    @property (nonatomic, readonly, retain) NSString *name

#License#

License Agreement for Source Code provided by Inspyre Technologies

This software is supplied to you by Inspyre Technologies in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this software constitutes acceptance of these terms. If you do not agree with these terms, please do not use, install, modify or redistribute this software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Inspyre Technologies grants you a personal, non-exclusive license, to use, reproduce, modify and redistribute the software, with or without modifications, in source and/or binary forms; provided that if you redistribute the software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the software, and that in all cases attribution of Inspyre Technologies as the original author of the source code shall be included in all such resulting software products or distributions. Neither the name, trademarks, service marks or logos of Inspyre Technologies may be used to endorse or promote products derived from the software without specific prior written permission from Inspyre Technologies. Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Inspyre Technologies herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the software may be incorporated.

The software is provided by Inspyre Technologies on an "AS IS" basis. Inspyre Technologies MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL Inspyre Technologies BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF Inspyre Technologies HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.