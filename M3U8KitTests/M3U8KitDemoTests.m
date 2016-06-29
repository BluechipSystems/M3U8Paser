//
//  M3U8KitDemoTests.m
//  M3U8KitDemoTests
//
//  Created by Sun Jin on 4/22/14.
//  Copyright (c) 2014 iLegendsoft. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface M3U8KitDemoTests : XCTestCase

@end

@implementation M3U8KitDemoTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    NSTimeInterval begin = [NSDate timeIntervalSinceReferenceDate];
    
    NSString *baseURL = @"https://hls.ted.com/";
    NSString *path = [[NSBundle mainBundle] pathForResource:@"769" ofType:@"m3u8"];
    NSError *error;
    NSString *str = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"error: %@", error);
    }
    
    M3U8PlaylistModel *medel = [[M3U8PlaylistModel alloc] initWithString:str baseURL:baseURL error:NULL];
    
    NSLog(@"segments names: %@", [medel segmentNamesForPlaylist:medel.audioPl]);
    
    NSString *m3u8Path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"str.m3u8"];
    error = nil;
    [medel savePlaylistsToPath:m3u8Path error:&error];
    if (error) {
        NSLog(@"playlists save error: %@", error);
    }
    
    NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"spend time = %f", end - begin);

}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
