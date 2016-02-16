# Average-Guy

## General
This repository holds the source files for a fully functioning and complete version of a game made for iOS and published by Andriy Suden and Viktor Kornyeyev throughout the 2013-2014 years. The game was taken down at the discretion of the developers, and the source code is made available through this repository. Although the intended use for the code is for learning purposes, it may be used, changed, and redistributed so far as the licensing on the product stays the same. Although the code and the graphics were made by the Developers, the 00 Starmap Truetype font and the POL-clouds-castle-short sound file are not original works and were downloaded from online repositories.

## Usage
This code is written for the iOS platform, and is intended to be compiled with the XCODE IDE. Although the source files are given, additional setup is needed and will be described here. Should any problems arise in the building the project, feel free to leave an issue request. The indended device family is iPhones, iOS7+ (Developed for iOS7). 

The project is not fully optimized, and performance issues might arise in the simulator. Lower performance is generally the case for simulations, and should not be mistaken for actual performance quality on a device. To show the frames per second count during execution, go to the ViewController.m file and add the following line of code in the viewDidLoad function, after initializing skView:

    skView.showsFPS = YES;
This value should be 60 on a physical device, and can range from 1 to 60 on the simulator depending on resource availability and the performance of the hardware accelerator.

## Setup
1. Open a new XCODE window, and hit 'Create a New XCODE project'
2. Under iOS->Application, hit 'Game'
3. For product name, type 'Average-Guy'. Organization name and identifier could be anything. In our case, we can use 'Game-Example' as the former and 'ex' as the latter. For language, choose Objective-C. Game Technology: SpriteKit. Devices: iPhone. Hit continue, and save the project somewhere.
4. First, we want to add the linked libraries (Note that in some versions of XCODE, this may not be required). To do so, hit the project settings file in the left hand side of the screen (the thumbnail is a blueprint page). Click on the 'Average-Guy' button under Targets, and scroll to the bottom until you see 'Linked Frameworks and Libraries'. Hit the plus button, and add each of the following:
  - AudioToolbox.framework
  - QuartzCore.framework
  - AVFoundation.framework
  - CoreGraphics.framework
  - UIKit.framework
  - SpriteKit.framework
  - Foundation.framework
  Note that some of these may already be added by default (Such as Foundation.framework). There is no need to add a framework twice.
5. For each pair of the following Class Files (.h file & .m file), replace its contents with its corresponding file from /Average-Guy/Average-Guy folder that you cloned.
  - AppDelegate.h/m
  - GameScene.h/m
  - ViewController.h/m
6. Delete the following XCODE generated files:
  - GameScene.sks
  - LaunchScreen.storyboard
  - main.storyboard
  - assets.xcassets
7. Into the main folder of your project, where the source files are located, add the following files from the /Average-Guy cloned folder.
  - MainMenuScene.h
  - MainMenuScene.m
  - POL.plist
  - TutorialScene.h
  - TutorialScene.m
  - Images.xcassets
  - Main.storyboard
8. XCODE generated a folder titled 'Supporting Files'. Copy all of the contents of /Average-Guy/ that have the following extensions into this folder:
  - .png
  - .atlas
  - .ttf
  - .sks
  - .wav
These files are images, sound files, and particle files that are used within the game. If, during execution, a red 'x' on a white background is seen, then one of these was not copied correctly.
9. Go back to the project settings tab on the left hand side of the screen. Again, under Targets, hit Average-Guy. Edit the following:
  - In the Deployment Info section, select only Portrait and Upside Down
  - Under App Icons and Launch Images, hit the 'use assets' button and select AppIcon and LaunchImage, respectively. (In some cases, this     might not work on the first try, in which case you might need to hit 'don't use assets catalog' before doing this step)

After all of the above steps are completed, do the following to build and run the project:
1. Press 'Command+B' to build the project.
2. Select the simulator or device to run the project on by hitting and holding the device name on the top left of the screen. This should be to the right of the project name.
3. Press the run button, located directly to the left of the simulator button.

## Issues
1. In certain versions of XCODE, the following will be continuously printed as output in the console:

    *CUICatalog: Invalid Request: requesting subtype without specifying idiom*
  
  This is a known bug in XCODE, and is harmless to the execution of the app.
