//
//  GSFormDataRequest.m
//  TwitPic Uploader
//
//  Created by Gurpartap Singh on 01/01/11.
//  Copyright 2011 Gurpartap Singh. All rights reserved.
//

#import "GSFormDataRequest.h"


@implementation GSFormDataRequest

@synthesize postData;
@synthesize postBody;
@synthesize fileData;
@synthesize userInfo;


- (id)init {
  if (self = [super init]) {
    
  }
  return self;
}


- (void)addPostValue:(id <NSObject>)value forKey:(NSString *)key {
	if (![self postData]) {
		[self setPostData:[NSMutableArray array]];
	}
	[[self postData] addObject:[NSDictionary dictionaryWithObjectsAndKeys:[value description], @"value", key, @"key", nil]];
  
  [self _buildMultipartFormDataPostBody];
}


- (void)setPostValue:(id <NSObject>)value forKey:(NSString *)key {
	// Remove any existing value
	NSUInteger i;
	for (i=0; i<[[self postData] count]; i++) {
		NSDictionary *val = [[self postData] objectAtIndex:i];
		if ([[val objectForKey:@"key"] isEqualToString:key]) {
			[[self postData] removeObjectAtIndex:i];
			i--;
		}
	}
	[self addPostValue:value forKey:key];
}


- (void)addFile:(NSString *)filePath forKey:(NSString *)key {
	[self addFile:filePath withFileName:nil andContentType:nil forKey:key];
}

- (void)addFile:(id)data withFileName:(NSString *)fileName andContentType:(NSString *)contentType forKey:(NSString *)key {
	if (![self fileData]) {
		[self setFileData:[NSMutableArray array]];
	}
	
	// If data is a path to a local file
	if ([data isKindOfClass:[NSString class]]) {
		BOOL isDirectory = NO;
		BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:(NSString *)data isDirectory:&isDirectory];
		if (!fileExists || isDirectory) {
			// File does not exist;
		}
    
		// If the caller didn't specify a custom file name, we'll use the file name of the file we were passed
		if (!fileName) {
			fileName = [(NSString *)data lastPathComponent];
		}
	}
	
	NSDictionary *fileInfo = [NSDictionary dictionaryWithObjectsAndKeys:data, @"data", contentType, @"contentType", fileName, @"fileName", key, @"key", nil];
	[[self fileData] addObject:fileInfo];
  
  [self _buildMultipartFormDataPostBody];
}


- (void)setFile:(NSString *)filePath forKey:(NSString *)key {
	[self setFile:filePath withFileName:nil andContentType:nil forKey:key];
}

- (void)setFile:(id)data withFileName:(NSString *)fileName andContentType:(NSString *)contentType forKey:(NSString *)key {
	// Remove any existing value
	NSUInteger i;
	for (i=0; i<[[self fileData] count]; i++) {
		NSDictionary *val = [[self fileData] objectAtIndex:i];
		if ([[val objectForKey:@"key"] isEqualToString:key]) {
			[[self fileData] removeObjectAtIndex:i];
			i--;
		}
	}
	[self addFile:data withFileName:fileName andContentType:contentType forKey:key];
}


- (void)addData:(NSData *)data forKey:(NSString *)key {
  [self addData:data withFileName:@"file" andContentType:nil forKey:key];
}


- (void)addData:(id)data withFileName:(NSString *)fileName andContentType:(NSString *)contentType forKey:(NSString *)key {
  if (![self fileData]) {
		[self setFileData:[NSMutableArray array]];
	}
  
	if (!contentType) {
		contentType = @"application/octet-stream";
	}
	
	NSDictionary *fileInfo = [NSDictionary dictionaryWithObjectsAndKeys:data, @"data", contentType, @"contentType", fileName, @"fileName", key, @"key", nil];
	[[self fileData] addObject:fileInfo];
  
  [self _buildMultipartFormDataPostBody];
}


- (void)setData:(NSData *)data forKey:(NSString *)key {
	[self setData:data withFileName:@"file" andContentType:nil forKey:key];
}


- (void)setData:(id)data withFileName:(NSString *)fileName andContentType:(NSString *)contentType forKey:(NSString *)key {
	// Remove any existing value
	NSUInteger i;
	for (i=0; i<[[self fileData] count]; i++) {
		NSDictionary *val = [[self fileData] objectAtIndex:i];
		if ([[val objectForKey:@"key"] isEqualToString:key]) {
			[[self fileData] removeObjectAtIndex:i];
			i--;
		}
	}
	[self addData:data withFileName:fileName andContentType:contentType forKey:key];
}


- (void)_buildMultipartFormDataPostBody {
	NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
	
	// Set your own boundary string only if really obsessive. We don't bother to check if post data contains the boundary, since it's pretty unlikely that it does.
	NSString *stringBoundary = @"0xKhTmLbOuNdArY";
	
  [self addValue:[NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@", charset, stringBoundary] forHTTPHeaderField:@"Content-Type"];
	
	[self appendPostString:[NSString stringWithFormat:@"--%@\r\n", stringBoundary]];
	
	// Adds post data
	NSString *endItemBoundary = [NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary];
	NSUInteger i = 0;
	for (NSDictionary *val in [self postData]) {
		[self appendPostString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", [val objectForKey:@"key"]]];
		[self appendPostString:[val objectForKey:@"value"]];
		i++;
		if (i != [[self postData] count] || [[self fileData] count] > 0) { //Only add the boundary if this is not the last item in the post body
			[self appendPostString:endItemBoundary];
		}
	}
	
	// Adds files to upload
	i = 0;
	for (NSDictionary *val in [self fileData]) {
    
		[self appendPostString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", [val objectForKey:@"key"], [val objectForKey:@"fileName"]]];
		[self appendPostString:[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", [val objectForKey:@"contentType"]]];
		
		id data = [val objectForKey:@"data"];
		if ([data isKindOfClass:[NSString class]]) {
			[self appendPostDataFromFile:data];
		} else {
			[self appendPostData:data];
		}
		i++;
		// Only add the boundary if this is not the last item in the post body
		if (i != [[self fileData] count]) { 
			[self appendPostString:endItemBoundary];
		}
	}
	
	[self appendPostString:[NSString stringWithFormat:@"\r\n--%@--\r\n", stringBoundary]];
  
  [self setHTTPMethod:@"POST"];
  [self setHTTPBody:[self postBody]];
}


- (void)setupPostBody {
  if (![self postBody]) {
    [self setPostBody:[[[NSMutableData alloc] init] autorelease]];
  }
}


- (void)appendPostString:(NSString *)string {
	[self appendPostData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}


- (void)appendPostData:(NSData *)data {
	[self setupPostBody];
	if ([data length] == 0) {
		return;
	}
  [[self postBody] appendData:data];
}


- (void)appendPostDataFromFile:(NSString *)file {
	[self setupPostBody];
	NSInputStream *stream = [[[NSInputStream alloc] initWithFileAtPath:file] autorelease];
	[stream open];
	NSUInteger bytesRead;
	while ([stream hasBytesAvailable]) {
		unsigned char buffer[1024*256];
		bytesRead = [stream read:buffer maxLength:sizeof(buffer)];
		if (bytesRead == 0) {
			break;
		}
    [[self postBody] appendData:[NSData dataWithBytes:buffer length:bytesRead]];
	}
	[stream close];
}


- (void)addRequestHeader:(NSString *)header value:(NSString *)value {
  [self setValue:value forHTTPHeaderField:header];
}


- (void)dealloc {
	[postData release];
  [postBody release];
	[fileData release];
  [userInfo release];
	[super dealloc];
}
@end
