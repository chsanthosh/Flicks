//
//  MovieModel.h
//  Flicks
//
//  Created by  Imtiyaz Jariwala on 1/23/17.
//  Copyright © 2017 yahoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MovieModel : NSObject

- (instancetype) initWithDictionary:(NSDictionary *) otherDictionary;

@property (nonatomic) NSInteger movieId;
@property (nonatomic, strong) NSString *movieTitle;
@property (nonatomic, strong) NSString *movieDescription;
@property (nonatomic) NSInteger moviePopularity;
@property (nonatomic, strong) NSString *movieTime;
@property (nonatomic, strong) NSString *movieReleaseDate;
@property (nonatomic, strong) NSURL *movieThumbnailUrl;
@property (nonatomic, strong) NSURL *moviePosterUrl;

@end
