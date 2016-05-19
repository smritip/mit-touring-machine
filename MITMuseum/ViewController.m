//
//  ViewController.m
//  MITMuseum
//
//  Created by Smriti Pramanick on 5/2/16.
//  Copyright © 2016 Smritasha. All rights reserved.
//

#import "ViewController.h"
#define RBL_SERVICE_UUID "F6B2BDBA-4C6C-4194-B992-3BDAFA96C66D"
#define RBL_SERVICE_UUID2 "713D0000-503E-4C75-BA94-3148F18D941E"
#define RBL_SERVICE_UUID3 "F3B57D2E-2CFB-415D-ADAC-DE6981C3176B"


@interface ViewController () {
    CMMotionManager *_motionManager;
    __weak IBOutlet UIButton *physicalTourButton;
    NSMutableArray *_hill;
    NSMutableArray *_phone;
    int count;
    NSString *location; // to determine which beacon we are at
    __weak IBOutlet UILabel *exhibitText;
    CLLocationManager *_mgr;
    double degrees;
    NSString *exhibit;
    __weak IBOutlet UIButton *learnMoreButton;
    __weak IBOutlet UILabel *exhibitName;
    __weak IBOutlet UILabel *exhibitInfo;
}
@end

@implementation ViewController {
    NSFileHandle *_f;
    
}

- (void)viewDidLoad {
    NSLog(@"View loaded");
    [super viewDidLoad];
    
    _mgr = [[CLLocationManager alloc] init];
    _mgr.delegate = self;
    _mgr.headingOrientation = CLDeviceOrientationPortrait;[_mgr startUpdatingHeading];
    
   // exhibitName.text = @"HALLO";
    
    //NSLog(@"%@", exhibitName.text);
    physicalTourButton.enabled = NO;
    learnMoreButton.enabled = YES;
    count = 0;
    location = @""; // not at a beacon yet
    degrees = 0; // degrees
    exhibit = @"";
    _hill = [[NSMutableArray alloc] init];
    _phone = [[NSMutableArray alloc] init];

    minAccelX = 0;
    minAccelY = 0;
    minAccelZ = -12.0;
    maxAccelX = 0;
    maxAccelY = 0;
    maxAccelZ = 3.0;
    
    minRotX = 0;
    minRotY = 0;
    minRotZ = 0;
    maxRotX = 0;
    maxRotY = 0;
    maxRotZ = 0;
    
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.gyroUpdateInterval = 1e-2;
    _motionManager.accelerometerUpdateInterval = 0.5;
    
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    _data = [[NSMutableData alloc] init];
    

    [_motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                 [self outputAccelerationData:accelerometerData.acceleration];
                                                 if(error){
                                                     
                                                     NSLog(@"%@", error);
                                                 }
                                             }];
    
    [_motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
                                    withHandler:^(CMGyroData *gyroData, NSError *error) {
                                        [self outputRotationData:gyroData.rotationRate];
                                    }];
    
    
    
    


}


- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
   // if (newHeading.headingAccuracy < 0)
     //   return;
    
    // Use the true heading if it is valid.
    CLLocationDirection  theHeading = ((newHeading.trueHeading > 0) ?
                                       newHeading.trueHeading : newHeading.magneticHeading);
    degrees = theHeading;
    NSLog(@"degrees %f", degrees);
}


-(void) outputAccelerationData:(CMAcceleration)acceleration {
    double zAccel = acceleration.z * 9.8;
}

-(void) outputRotationData:(CMRotationRate)rotation {
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    
    if (central.state == CBCentralManagerStatePoweredOn) {
        // Scan for devices
        NSArray *services = @[[CBUUID UUIDWithString:@RBL_SERVICE_UUID], [CBUUID UUIDWithString:@RBL_SERVICE_UUID2], [CBUUID UUIDWithString:@RBL_SERVICE_UUID3]];
        
        [_centralManager scanForPeripheralsWithServices:services options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
        NSLog(@"Scanning started");
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    physicalTourButton.enabled = YES;
    //NSLog(@"Peripheral Discovered: %@", peripheral.name);
    //NSLog(@"Strength: %ld", (long)RSSI.integerValue);
    NSNumber *strength = [NSNumber numberWithInteger:RSSI.integerValue];
    //NSLog(@"s %@", strength);
    if ([peripheral.name  isEqual: @"my-peripheral"]) {
        [_phone addObject:strength];
        //NSLog(@"p %@", _phone);
    }
    else if ([peripheral.name  isEqual: @"HILL5"]) {
        [_hill addObject:strength];
        //NSLog(@"h %@", _hill);
    }
    int lenHill = [_hill count];
    int lenPhone = [_phone count];
    if (lenHill + lenPhone == 50) {
        int sumHill = 0;
        for (NSNumber * num in _hill) {
            if (num.integerValue < 0) {
                sumHill += num.integerValue;
                //NSLog(@"hill num %@", num);
            }
        }
        double avgHill = (double)sumHill / lenHill;
        int sumPhone = 0;
        for (NSNumber * num in _phone) {
            if (num.integerValue < 0) {
                sumPhone += num.integerValue;
                //NSLog(@"phone num %@", num);
            }
        }
        double avgPhone = (double)sumPhone / lenPhone;
        NSLog(@"hill avg: %f", avgHill);
        NSLog(@"phone avg: %f", avgPhone);
        if (!isnan(avgPhone) && avgPhone > avgHill) {
            NSLog(@"at phone");
            location = @"phone";
            if (degrees < 61 || degrees > 299) { //facing north
                exhibit = @"north";
                exhibitText.text = @"Phonebooth";
                learnMoreButton.enabled = YES;
                exhibitName.text = @"Phonebooth";
                exhibitInfo.text = @"This bright red phone booth lives right by the Gate tower elevators. Step inside and you will find that there is room for one to work, relax, watch tv, or even sleep!";
            }
            else if (degrees > 119 && degrees < 241) { //facing south
                exhibit = @"south";
                exhibitText.text = @"Cranes for Collier";
                learnMoreButton.enabled = YES;
                exhibitName.text = @"Cranes for Collier";
                exhibitInfo.text = @"Officer Collier lost his life protecting our campus in April 2013. A year later, the MIT community came together to install this hack to honor Officer Collier. More than five thousand cranes were made.";
            }
            else {
                _phone.removeAllObjects;
                _hill.removeAllObjects;
                exhibitText.text = @"Exhibit loading...";
            }
        }
        else {
            NSLog(@"at hill");
            location = @"hill";
            if (degrees < 61 || degrees > 299) { //facing north
                exhibit = @"north";
                exhibitText.text = @"Stanford Cam";
                learnMoreButton.enabled = YES;
                exhibitName.text = @"Stanford Cam";
                exhibitInfo.text = @"This historical video camera and this conferencing setup has allowed for MIT students to communicate with Stanford students for years! Stanford has its video camera in a cafe as well.";
            }
            else if (degrees > 119 && degrees < 241) { //facing south
                exhibit = @"south";
                exhibitText.text = @"Fire Hydrant";
                learnMoreButton.enabled = YES;
                exhibitName.text = @"Fire Hydrant";
                exhibitInfo.text = @"A former MIT President once said, 'Getting an Education from MIT is like taking a drink from a Fire Hose,' a sentiment that many students share. In 1991, some hackers brought this simile to life by turning the fire hydrant into a drinking fountain, right outside 26-100!";
            }
            else {
                _phone.removeAllObjects;
                _hill.removeAllObjects;
                exhibitText.text = @"Exhibit loading...";
            }
        }
    }
}
//- (IBAction)takePhysicalTour:(id)sender {
//    if ([location  isEqual: @"phone"]) {
//        if ([exhibit  isEqual: @"north"]) {
//            exhibitText.text = @"phonebooth";
//            learnMoreButton.enabled = YES;
//        }
//        else if ([exhibit  isEqual: @"south"]) {
//            exhibitText.text = @"cranes";
//            learnMoreButton.enabled = YES;
//        }
//    }
//    else if ([location  isEqual: @"hill"]) {
//        if ([exhibit  isEqual: @"north"]) {
//            exhibitText.text = @"cam";
//            learnMoreButton.enabled = YES;
//        }
//        else if ([exhibit  isEqual: @"south"]) {
//            exhibitText.text = @"fire";
//            learnMoreButton.enabled = YES;
//        }
//    }
//}
- (IBAction)updateMyLocation:(id)sender {
    _phone.removeAllObjects;
    _hill.removeAllObjects;
    exhibitText.text = @"Exhibit loading...";
    learnMoreButton.enabled = NO;
}

- (IBAction)learnMorePressed:(id)sender {
    if ([location  isEqual: @"phone"]) {
        if ([exhibit  isEqual: @"north"]) {
           // exhibitName.text = @"phonebooth";
            learnMoreButton.enabled = NO;
        }
        else if ([exhibit  isEqual: @"south"]) {
           // exhibitName.text = @"cranes";
            learnMoreButton.enabled = NO;
        }
    }
    else if ([location  isEqual: @"hill"]) {
        if ([exhibit  isEqual: @"north"]) {
           // exhibitName.text = @"cam";
            learnMoreButton.enabled = NO;
        }
        else if ([exhibit  isEqual: @"south"]) {
           // NSLog(@"hello here");
            //exhibitName.text = @"fire";
            learnMoreButton.enabled = NO;
        }
    }
    
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"disconnected");
    physicalTourButton.enabled = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
