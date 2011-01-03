//
//  GSFormDataRequest.h
//  TwitPic Uploader
//
//  Created by Gurpartap Singh on 01/01/11.
//  Copyright 2011 Gurpartap Singh. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GSFormDataRequest : NSMutableURLRequest {
  // Parameters that will be POSTed to the url
  NSMutableArray *postData;
  
  // Compiled POST parameters
  NSMutableData *postBody;
  
  // Files that will be POSTed to the url
  NSMutableArray *fileData;
  
  NSDictionary *userInfo;
}

@property (nonatomic, retain) NSMutableArray *postData;
@property (nonatomic, retain) NSMutableData *postBody;
@property (nonatomic, retain) NSMutableArray *fileData;
@property (nonatomic, retain) NSDictionary *userInfo;

// Add a POST variable to the request
- (void)addPostValue:(id <NSObject>)value forKey:(NSString *)key;

// Set a POST variable for this request, clearing any others with the same key
- (void)setPostValue:(id <NSObject>)value forKey:(NSString *)key;

// Add the contents of a local file to the request
- (void)addFile:(NSString *)filePath forKey:(NSString *)key;

// Same as above, but you can specify the content-type and file name
- (void)addFile:(id)data withFileName:(NSString *)fileName andContentType:(NSString *)contentType forKey:(NSString *)key;

// Add the contents of a local file to the request, clearing any others with the same key
- (void)setFile:(NSString *)filePath forKey:(NSString *)key;

// Same as above, but you can specify the content-type and file name
- (void)setFile:(id)data withFileName:(NSString *)fileName andContentType:(NSString *)contentType forKey:(NSString *)key;

// Add the contents of an NSData object to the request
- (void)addData:(NSData *)data forKey:(NSString *)key;

// Same as above, but you can specify the content-type and file name
- (void)addData:(id)data withFileName:(NSString *)fileName andContentType:(NSString *)contentType forKey:(NSString *)key;

// Add the contents of an NSData object to the request, clearing any others with the same key
- (void)setData:(NSData *)data forKey:(NSString *)key;

// Same as above, but you can specify the content-type and file name
- (void)setData:(id)data withFileName:(NSString *)fileName andContentType:(NSString *)contentType forKey:(NSString *)key;

- (void)addRequestHeader:(NSString *)header value:(NSString *)value;

- (void)_buildMultipartFormDataPostBody;
- (void)appendPostString:(NSString *)string;
- (void)appendPostData:(NSData *)data;
- (void)appendPostDataFromFile:(NSString *)file;

@end
