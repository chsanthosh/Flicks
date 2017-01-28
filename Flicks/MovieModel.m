//
//  MovieModel.m
//  Flicks
//
//  Created by  Imtiyaz Jariwala on 1/23/17.
//  Copyright © 2017 yahoo. All rights reserved.
//

#import "MovieModel.h"

@implementation MovieModel

- (instancetype)initWithDictionary:(NSDictionary *) dictionary {

    self = [super init];
    if (self) {
        self.movieId = [dictionary[@"id"] integerValue];
        self.movieTitle = dictionary[@"original_title"];
        self.movieDescription = dictionary[@"overview"];
        
        self.moviePopularity = [dictionary[@"popularity"] integerValue];
        self.movieTime = @"2 hr 36 mins";
        self.movieReleaseDate = @"January 31, 2017";
        
        NSString *urlString = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/w342%@", dictionary[@"poster_path"]];
        self.movieThumbnailUrl = [NSURL URLWithString:urlString];
        
        urlString = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/original%@", dictionary[@"poster_path"]];
        self.moviePosterUrl = [NSURL URLWithString:urlString];
    }
    return self;
}

@end
