//
//  ViewController.m
//  MotionEyes
//
//  Created by Brett Graham on 2015-10-10.
//  Copyright © 2015 Brett Graham. All rights reserved.
//
#import "EyesView.h"
#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

#define kBrightnessCutOff 0.5f

@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate>

// DEBUG
@property(weak, nonatomic) IBOutlet UIView *containerView;
@property(weak, nonatomic) IBOutlet UIImageView *diffView;
@property(weak, nonatomic) IBOutlet UISegmentedControl *mode;
@property (weak, nonatomic) IBOutlet UISwitch *flipSwitch;
@property (weak, nonatomic) IBOutlet UILabel *switchText;

//BUTTONS
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;


// EYES
@property(strong, nonatomic) IBOutlet EyesView *eyes;

@property(strong, nonatomic) AVCaptureDevice *device;
@property(strong, nonatomic) AVCaptureDeviceInput *input;
@property(strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property(strong, nonatomic) AVCaptureSession *session;
@property(strong, nonatomic) AVCaptureVideoPreviewLayer *preview;

// IMAGES
@property(strong, nonatomic) UIImage *last;
@property(strong, nonatomic) UIImage *delta;
@property(strong, nonatomic) UIImage *hotspot;

@property(nonatomic) CGPoint point;
@property(nonatomic) BOOL loop;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  if ([self isCameraAvailable]) {
    [self setupScanner];
  } else {
    [self setupNoCameraView];
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  //[self setUpEyes];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}
#pragma mark -
#pragma mark NoCamAvailable

- (void)setupNoCameraView;
{
  UILabel *labelNoCam = [[UILabel alloc] init];
  labelNoCam.text = @"No Camera available";
  labelNoCam.textColor = [UIColor whiteColor];
  [self.view addSubview:labelNoCam];
  [labelNoCam sizeToFit];
  labelNoCam.center = self.view.center;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations;
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate;
{
    return NO;
}

- (void)didRotateFromInterfaceOrientation:
    (UIInterfaceOrientation)fromInterfaceOrientation;
{
  if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait) {
    AVCaptureConnection *con = self.preview.connection;
    con.videoOrientation = AVCaptureVideoOrientationPortrait;
  } else if ([[UIDevice currentDevice] orientation] ==
             UIDeviceOrientationPortraitUpsideDown) {
    AVCaptureConnection *con = self.preview.connection;
    con.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
  }
}

#pragma mark -
#pragma mark - AVFoundationSetup

- (void)setupScanner;
{
  self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  self.input =
      [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];

  self.session = [[AVCaptureSession alloc] init];
  [self.session setSessionPreset:AVCaptureSessionPresetMedium];
  [self.session addInput:self.input];

  // Prepare an output for snapshotting
  self.stillImageOutput = [AVCaptureStillImageOutput new];
  [self.session addOutput:self.stillImageOutput];
  self.stillImageOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};

  // preview - uncomment if you have ploblems with the source images.
  //    self.preview = [AVCaptureVideoPreviewLayer
  //    layerWithSession:self.session];
  //    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
  //    self.preview.frame = self.containerView.bounds;
  //    [self.containerView.layer insertSublayer:self.preview atIndex:0];

  [self.session startRunning];
}

#pragma mark -
#pragma mark Action Methods
- (IBAction)btnBackAction:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Helper Methods

- (BOOL)isCameraAvailable;
{
  NSArray *videoDevices =
      [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
  return [videoDevices count] > 0;
}

- (void)startScanning;
{ [self.session startRunning]; }

- (void)stopScanning;
{ [self.session stopRunning]; }

- (void)setTorch:(BOOL)aStatus;
{
  AVCaptureDevice *device =
      [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  [device lockForConfiguration:nil];
  if ([device hasTorch]) {
    if (aStatus) {
      [device setTorchMode:AVCaptureTorchModeOn];
    } else {
      [device setTorchMode:AVCaptureTorchModeOff];
    }
  }
  [device unlockForConfiguration];
}

#pragma mark -
#pragma mark Capture

- (IBAction)start:(id)sender {
  self.loop = TRUE;
  self.mode.hidden = TRUE;
  self.flipSwitch.hidden = TRUE;
  self.switchText.hidden = TRUE;
  self.startButton.hidden = TRUE;
  [self preCapture];
  [self captureNow];
}

- (IBAction)end:(id)sender {
  self.loop = FALSE;
  self.mode.hidden = FALSE;
  self.switchText.hidden = FALSE;
  self.startButton.hidden = FALSE;
  self.flipSwitch.hidden = FALSE;
  self.diffView.image = nil;
}

- (void)preCapture {
  if (self.mode.selectedSegmentIndex == 0) {
    self.eyes.alpha = 1.0f;
    self.eyes.debugMode = FALSE;
  } else if (self.mode.selectedSegmentIndex == 1) {
    self.eyes.alpha = 1.0f;
    self.eyes.debugMode = TRUE;
  } else if (self.mode.selectedSegmentIndex == 2) {
    self.eyes.alpha = 0.5f;
    self.eyes.debugMode = TRUE;
  }
    
   if(self.flipSwitch.isOn)
   {
       self.eyes.transform = CGAffineTransformMakeScale(-1,1);
       self.diffView.transform = CGAffineTransformMakeScale(-1,1);
   }
   else
   {
       self.eyes.transform = CGAffineTransformIdentity;
       self.diffView.transform = CGAffineTransformIdentity;
   }
}

- (void)captureNow {
    
  //Connect
  AVCaptureConnection *videoConnection = nil;
  for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
    for (AVCaptureInputPort *port in [connection inputPorts]) {
      if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
        videoConnection = connection;
        break;
      }
    }
    if (videoConnection) {
      break;
    }
  }

  //capture frame
  __weak typeof(self) weakSelf = self;
  [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                     completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {

        __strong typeof(weakSelf) strongSelf = weakSelf;
                                                         
        if (strongSelf.loop) {
            
          //get image
          NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
          UIImage *image = [[UIImage alloc] initWithData:imageData];

            
          if (strongSelf.last) {
              
             //calculte delta
            strongSelf.delta = [ViewController differenceOfImage:image withImage:self.last];

            //dertermine point of greatest movement in the image
            CGPoint point = [strongSelf hotSpotsOfImage:strongSelf.delta];
            if (!CGPointEqualToPoint(point, CGPointZero)) {
                //trnslate that point to the entire screen size
               strongSelf.eyes.target = CGPointMake(
                  point.x / image.size.width * strongSelf.eyes.frame.size.width,
                  point.y / image.size.height * strongSelf.eyes.frame.size.height);
            }

            // debug
            if (self.mode.selectedSegmentIndex > 1) {
              strongSelf.diffView.image = strongSelf.delta;
            }
          }

          strongSelf.last = image;

           //repeat
          [strongSelf captureNow];
        }
    }];
}

#pragma mark -
#pragma mark Camera Helpers

+ (UIImage *)differenceOfImage:(UIImage *)top withImage:(UIImage *)bottom {
  CGImageRef topRef = [top CGImage];
  CGImageRef bottomRef = [bottom CGImage];

  // Dimensions
  CGRect bottomFrame = CGRectMake(0, 0, CGImageGetWidth(bottomRef), CGImageGetHeight(bottomRef));
  CGRect topFrame =  CGRectMake(0, 0, CGImageGetWidth(topRef), CGImageGetHeight(topRef));
  CGRect renderFrame = CGRectIntegral(CGRectUnion(bottomFrame, topFrame));

  // Create context
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  if (colorSpace == NULL) {
    printf("Error allocating color space.\n");
    return NULL;
  }

  CGContextRef context = CGBitmapContextCreate(NULL,
                                               renderFrame.size.width,
                                               renderFrame.size.height,
                                               8,
                                               renderFrame.size.width * 4,
                                               colorSpace,
                                               kCGImageAlphaPremultipliedLast);
  CGColorSpaceRelease(colorSpace);

  if (context == NULL) {
    printf("Context not created!\n");
    return NULL;
  }

  // Draw images
  CGContextSetBlendMode(context, kCGBlendModeNormal);
  CGContextDrawImage(context,
                     CGRectOffset(bottomFrame,
                     -renderFrame.origin.x,
                     -renderFrame.origin.y),
                     bottomRef);
    
  CGContextSetBlendMode(context, kCGBlendModeDifference);
  CGContextDrawImage(context,
                     CGRectOffset(topFrame, -renderFrame.origin.x, -renderFrame.origin.y),
                     topRef);

  // Create image from context
  CGImageRef imageRef = CGBitmapContextCreateImage(context);
  UIImage *image = [UIImage imageWithCGImage:imageRef];
  CGImageRelease(imageRef);

  CGContextRelease(context);

  return image;
}


- (CGPoint)hotSpotsOfImage:(UIImage *)input {
 //counters
  CGFloat x = 0;
  CGFloat y = 0;
  CGFloat count = 0;

 //convert image to bytes
  CGImageRef sourceImage = input.CGImage;
  CFDataRef theData;
  theData = CGDataProviderCopyData(CGImageGetDataProvider(sourceImage));
  UInt8 *pixelData = (UInt8 *)CFDataGetBytePtr(theData);

  //Byte mapping
  NSInteger red = 0;
  NSInteger green = 1;
  NSInteger blue = 2;

  NSInteger dataLength = CFDataGetLength(theData);
    
  //Loop through pixels
  for (NSInteger index = 0; index < dataLength; index += 4) {
      
    //Get RGB colours
    CGFloat redValue = pixelData[index + red] / 255.0f;
    CGFloat greenValue = pixelData[index + green] / 255.0f;
    CGFloat blueValue = pixelData[index + blue] / 255.0f;

    //convert to brightness
    CGFloat value = sqrt(0.299 * powf(redValue,2)
                         + 0.587 * powf(greenValue,2)
                         + 0.114 * powf(blueValue,2));

    //if higher then the brightness cutoff then add to to the counters
    if (value > kBrightnessCutOff) {
        
      //get position within frame
      NSInteger xPos = (index / 4) % (NSInteger)input.size.width;
      NSInteger yPos = (index / 4) / (NSInteger)input.size.width;

      //multiply by how much over the brightness cutoff (rank brighter pixels more than less bright)
      CGFloat multiplier = 5 * (value - kBrightnessCutOff) / (1.0f - kBrightnessCutOff);

      //add to counters
      x += xPos * multiplier;
      y += yPos * multiplier;
      count += multiplier;
    }
  }

  CFRelease(theData);

  //calculate average
  if (count > 0) {
    CGFloat xAveragePos = x / count;
    CGFloat yAveragePos = y / count;

    NSLog(@"Center : %f, %f", xAveragePos, yAveragePos);

    return CGPointMake(xAveragePos, yAveragePos);
  } else {
    return CGPointZero;
  }
}

@end
