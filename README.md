#ITDevice#



Inherits From:    NSObject

Declared In:      ITDevice.h


##Overview##

The `ITDevice` class provides a singleton instance representing the current device. From this instance you can obtain information about the device such as assigned name, device model, and operating-system name and version.

You also use the `ITDevice` instance to detect changes in the device’s characteristics, such as physical orientation. You get the current orientation using the orientation property or receive change notifications by registering for the `ITDeviceOrientationDidChangeNotification` notification. Before using either of these techniques to get orientation data, you must enable data delivery by setting the `generatesDeviceOrientationNotifications` property to `YES`. When you no longer need to track the device orientation, set the `generatesDeviceOrientationNotifications` property to `NO` to disable the delivery of notifications.

Similarly, you can use the `ITDevice` instance to obtain information and notifications about changes to the battery’s charge state (described by the batteryState property) and charge level (described by the batteryLevel property). The `ITDevice` instance also provides access to the network connection state (described by the `connectionState` property). The network connection state represents the availability of Internet communication and whether the device is connected via a mobile data connection. Enable battery monitoring or connection monitoring only when you need it.

Full documentation will be added when possible.


#License#

License Agreement for Source Code provided by Inspyre Technologies

This software is supplied to you by Inspyre Technologies in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this software constitutes acceptance of these terms. If you do not agree with these terms, please do not use, install, modify or redistribute this software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Inspyre Technologies grants you a personal, non-exclusive license, to use, reproduce, modify and redistribute the software, with or without modifications, in source and/or binary forms; provided that if you redistribute the software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the software, and that in all cases attribution of Inspyre Technologies as the original author of the source code shall be included in all such resulting software products or distributions. Neither the name, trademarks, service marks or logos of Inspyre Technologies may be used to endorse or promote products derived from the software without specific prior written permission from Inspyre Technologies. Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Inspyre Technologies herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the software may be incorporated.

The software is provided by Inspyre Technologies on an "AS IS" basis. Inspyre Technologies MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL Inspyre Technologies BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF Inspyre Technologies HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.