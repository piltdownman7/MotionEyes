//
//  AppDelegate.h
//  MotionEyes
//
//  Created by Brett Graham on 2015-10-10.
//  Copyright © 2015 Brett Graham. All rights reserved.
//  ----------------------------------------------------------------------------
//  THE BEER-WARE LICENSE" (Revision 42):
//  <brett.s.graham@gmail.com> wrote this file.  As long as you retain this notice you
//  can do whatever you want with this stuff. If we meet some day, and you think
//  this stuff is worth it, you can buy me a beer in return.   Brett Graham
//  ----------------------------------------------------------------------------
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

