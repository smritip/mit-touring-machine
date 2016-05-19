//
//  ViewController.h
//  MITMuseum
//
//  Created by Smriti Pramanick on 5/2/16.
//  Copyright © 2016 Smritasha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

double minAccelX;
double minAccelY;
double minAccelZ;
double maxAccelX;
double maxAccelY;
double maxAccelZ;

double minRotX;
double minRotY;
double minRotZ;
double maxRotX;
double maxRotY;
double maxRotZ;


@interface ViewController : UIViewController

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *discoveredPeripheral;
@property (strong, nonatomic) NSMutableData *data;


@end

