//
//  X.m
//  Kinvey Test Drive
//
//  Created by Michael Katz on 9/12/13.
//  Copyright (c) 2013 Kinvey. All rights reserved.
//

#import "X.h"

@implementation X

- (void) y
{
    NSString* endpoint;
    id testObject;
    
    
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:endpoint]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:testObject options:0 error:NULL];
    [request addValue:@"3" forHTTPHeaderField:@"X-Kinvey-API-Version"];
    
    
    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [session dataTaskWithRequest:request];
}
@end
