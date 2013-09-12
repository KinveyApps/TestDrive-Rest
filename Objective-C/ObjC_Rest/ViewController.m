//
//  ViewController.m
//  Kinvey Quickstart
//
//  Copyright 2013 Kinvey, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ViewController.h"
#import "TestObject.h"

#define APP_KEY @"<#APP KEY#>"
#define APP_SECRET @"<#APP SECRET#>"

#define CREATE_NEW_ENTITY_ALERT_VIEW 100

@interface ViewController ()
@property (nonatomic, strong) NSArray* objects;
@property (nonatomic, strong) NSString* kinveyToken;
@end

@implementation ViewController

- (IBAction)add:(id)sender
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Create a New Entity"
                                                    message:@"Enter a title for the new entity"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Save", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = CREATE_NEW_ENTITY_ALERT_VIEW;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == CREATE_NEW_ENTITY_ALERT_VIEW) {
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            // Define an instance of our test object
            TestObject *testObject = [[TestObject alloc] init];
            
            // This is the data we'll save
            testObject.name = [[alertView textFieldAtIndex:0] text];
            
            // Create a POST endpoint for the `testObjects` collection
            NSString* endpoint = [NSString stringWithFormat:@"https://baas.kinvey.com/appdata/%@/testObjects", APP_KEY];
            
            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:endpoint]];
            request.HTTPMethod = @"POST";
            
            //need to convert native object to NSDictionary
            NSData* bodyData = [NSJSONSerialization dataWithJSONObject:[testObject jsonObject] options:0 error:NULL];
            request.HTTPBody = bodyData;
            [request addValue:@"3" forHTTPHeaderField:@"X-Kinvey-API-Version"];
            [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            
            NSString* authHeader = [NSString stringWithFormat:@"Kinvey %@", self.kinveyToken];
            [request addValue:authHeader forHTTPHeaderField:@"Authorization"];
            
            
            NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                // Right now just pop-up an alert about what we got back from Kinvey during
                // the save.  Normally you would want to implement more code here
                if (error == nil && data != nil) {
                    if ([(NSHTTPURLResponse*)response statusCode] >= 400) { //error response
                        NSDictionary* errorDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                        NSLog(@"error creating user: %@", errorDictionary);
                        //Excercise for reader: handle 4/500's
                        return;
                    }

                    
                    NSDictionary* backendObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                    TestObject* convertedObject = [[TestObject alloc] initWithJsonObject:backendObject];
                    
                    //save is successful!
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save worked!"
                                                                    message:[NSString stringWithFormat:@"Saved: '%@'",[convertedObject name]]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                    
                    [alert show];
                    
                    self.objects = [@[convertedObject] arrayByAddingObjectsFromArray:_objects];
                    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                } else {
                    //save failed
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save failed"
                                                                    message:[error localizedDescription]
                                                                   delegate:self
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                    
                    [alert show];
                    
                }
                
            }];
            [task resume];
           
        }
    }
}


- (IBAction)load:(id)sender
{
    // Create a GET endpoint for the `testObjects` collection
    NSString* endpoint = [NSString stringWithFormat:@"https://baas.kinvey.com/appdata/%@/testObjects", APP_KEY];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:endpoint]];
    [request addValue:@"3" forHTTPHeaderField:@"X-Kinvey-API-Version"];
    NSString* authHeader = [NSString stringWithFormat:@"Kinvey %@", self.kinveyToken];
    [request addValue:authHeader forHTTPHeaderField:@"Authorization"];

    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [sender endRefreshing];
        // Right now just pop-up an alert about what we got back from Kinvey during
        // the load.  Normally you would want to implement more code here
        if (error == nil && data != nil) {
            NSArray* backendObjects = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            NSMutableArray* appObjects = [NSMutableArray arrayWithCapacity:backendObjects.count];
            for (NSDictionary* jsonObj in backendObjects) {
                [appObjects addObject:[[TestObject alloc] initWithJsonObject:jsonObj]];
            }
            //load is successful!
            _objects = appObjects;
            [self.tableView reloadData];
        } else {
            //load failed
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Load failed"
                                                            message:[error localizedDescription]
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            
            [alert show];
            
        }

        
    }];
    [task resume];
}

#pragma mark - View Controller

- (void)viewDidLoad
{
    [super viewDidLoad];
    _objects = @[];
    [self.refreshControl addTarget:self
                            action:@selector(load:)
                  forControlEvents:UIControlEventValueChanged];
}

- (void) createNewUser
{
    // Create a POST endpoint for the `user` collection
    NSString* endpoint = [NSString stringWithFormat:@"https://baas.kinvey.com/user/%@", APP_KEY];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:endpoint]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:@{} options:0 error:NULL];
    [request addValue:@"3" forHTTPHeaderField:@"X-Kinvey-API-Version"];
    
    NSString* appAuth = [NSString stringWithFormat:@"%@:%@",APP_KEY, APP_SECRET];
    NSData* authData = [appAuth dataUsingEncoding:NSUTF8StringEncoding];
    NSString* authHeader = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    [request addValue:authHeader forHTTPHeaderField:@"Authorization"];
    
    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            //load failed
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"User creation failed"
                                                            message:[error localizedDescription]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            [alert show];
        } else {
            if ([(NSHTTPURLResponse*)response statusCode] < 300) { //ok response
                NSDictionary* userDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                self.kinveyToken = [userDictionary valueForKeyPath:@"_kmd.authtoken"];
                //Excercise for reader: handle no auth token
                [self load:nil];
            } else {
                 NSDictionary* errorDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                NSLog(@"error creating user: %@", errorDictionary);
                //Excercise for reader: handle 4/500's
            }
        }

    }];
    [task resume];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createNewUser];
}


#pragma mark - Table View Stuff

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"aCell"];
    cell.textLabel.text = [_objects[indexPath.row] name];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
#if NEVER
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        TestObject* objToDelete = [_objects objectAtIndex:indexPath.row];
        NSMutableArray* newObjects  = [_objects mutableCopy];
        [newObjects removeObjectAtIndex:indexPath.row];
        self.objects = newObjects;
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        // Get a reference to a backend collection called "testObjects", which is filled with
        // instances of TestObject
        KCSCollection *testObjects = [KCSCollection collectionFromString:@"testObjects" ofClass:[TestObject class]];
        
        // Create a data store connected to the collection, in order to save and load TestObjects
        KCSAppdataStore *store = [KCSAppdataStore storeWithCollection:testObjects options:nil];
        
        // Remove our instance from the store
        [store removeObject:objToDelete withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
            if (errorOrNil == nil && objectsOrNil != nil) {
                //delete is successful!
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete successful!"
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
                
                [alert show];
            } else {
                //delete failed
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete failed"
                                                                message:[errorOrNil localizedDescription]
                                                               delegate:self
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
                
                [alert show];
                
            }
            
        } withProgressBlock:nil];
    }
#endif
}

@end
