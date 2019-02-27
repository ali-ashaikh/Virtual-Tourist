# Virtual-Tourist
Udacity Final Project for iOS Developer Course

# Summary
This application was built for tourists to explore cities around the world. It gives the user the access to flicker images posted on the locations where the user drops the pin on.

# Implementation
There are two screens in the app. Main screen shows Google Map where the user can move to the desired location and drops a pin on it. In order to drop the pin, the user needs to long press on that location.
Once the pin is dropped, then, the user can select that pin to be moved to the next screen where Flicker images will be downladed and displayed. Those images are being saved locally in the device and the user is able to click once on each image to delete. Also, the user can click on "New Collection" button to get new set of images.

# How to build
In order to run this application, it is required to install Kingfisher framework by running the below command
  pod install
If pod file is not there, then it is necessary to run the below command in the project folder in the terminal
  pod init
 Then, update the pod file with below line
  pod 'Kingfisher', '~> 3.0'

# Requirements
This application runs perferctly on XCode 8 using Swift 3. It may work in higher versions but it may require some syntax conversion.
