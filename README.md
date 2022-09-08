# Akuvox-Elan-Driver

### Introduction
**[Akuvox](https://www.akuvox.com/)** is a is a global leading provider of Smart Intercom products and solutions. We are committed to unleashing the power of technologies to improve people's lives with better communication, greater security and more convenience. The IP-based intercom devices are meant for the access control and custom install market in both the residential and commercial sectors.

**[Elan](https://elancontrolsystems.com/)** is a home automation platform with an integration API. ELAN is the industry leader in smart home & business technology solutions.Integration of Akuvox intercoms via SIP-based communication is done via the intercom internal settings, and thus will not be outlined in this repository. The aim of this driver is to integrate Akuovox's relay control to Elan via the Elan driver development API. 

### How to Integrate
* Download the **Akuvox_Relay_Control.EDRVC** file from this repository.
* In the Elan configurator, navigate to the Input/Output tab.
* Right + Click **Relay Outputs** and **Add New Output Controller**.
* In the list as shown below, click on the **Search Folder** button, navigate to the folder where the file was downloaded, then press ok.

![image](https://user-images.githubusercontent.com/50086268/189106842-078b7957-e30d-4dbc-a659-2461962ec477.png)

* Highlight the Akuvox Relay Control, then press OK.
* Add IP address, User Name and Password as set up in the Akuvox Intercom.

![image](https://user-images.githubusercontent.com/50086268/189108016-08a3d1cf-3def-4c32-97f1-ad64ddacf464.png)

* You'd be able to tell if connection was successful if the intercom Model, MAC address and Firmware version populate automatically in their respective fields.
