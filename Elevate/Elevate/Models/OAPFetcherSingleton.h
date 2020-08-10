//
//  OAPFetcherSingleton.h
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/31/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OAPFetcherSingleton : NSObject

+ (OAPFetcherSingleton *)sharedObject;
- (void) fetchStatusLevel;

@end

NS_ASSUME_NONNULL_END
