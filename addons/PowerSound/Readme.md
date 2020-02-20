


The intent of this application is to play a sound when the boot-up is completed. 

The application will launch when detecting that the Microsoft HD-3000 webcam is
plugged in. 

We don't use the "boot-up complete event" since it takes 25 seconds additional time
after the desktop  launch. 

To add listener for other devices you need to add the vid/pid of the usb device in
"res/xml/device_filter.xml"


