//
//  M3U8Kit2Tests_tvOS.m
//  M3U8Kit2Tests tvOS
//
//  Created by Don on 6/29/16.
//  Copyright © 2016 Allen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "M3U8Kit.h"

@interface M3U8Kit2Tests_tvOS : XCTestCase

@end

@implementation M3U8Kit2Tests_tvOS

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    NSTimeInterval begin = [NSDate timeIntervalSinceReferenceDate];
    
    NSError *error;
    M3U8PlaylistModel *medel = [[M3U8PlaylistModel alloc] initWithURL:@"http://localhost:8002/playlist.m3u8" error:&error];
    
    if (error) {
        NSLog(@"error: %@", error);
    }
    
    
    NSUInteger count = medel.mainMediaPl.segmentList.count;
    for (int i = 0; i < count; i ++) {
        M3U8SegmentInfo *inf = [medel.mainMediaPl.segmentList segmentInfoAtIndex:i];
        NSLog(@"%@", inf);
    }

    NSString *m3u8Path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"str.m3u8"];
    error = nil;
    [medel savePlaylistsToPath:m3u8Path error:&error];
    if (error) {
        NSLog(@"playlists save error: %@", error);
    }
    
    NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"spend time = %f", end - begin);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
