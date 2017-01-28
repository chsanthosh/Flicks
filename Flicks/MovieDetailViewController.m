//
//  MovieDetailViewController.m
//  Flicks
//
//  Created by  Imtiyaz Jariwala on 1/24/17.
//  Copyright © 2017 yahoo. All rights reserved.
//

#import "MovieDetailViewController.h"
#import "MovieModel.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface MovieDetailViewController ()
{
    MovieModel *movieModel;
}

@property (weak, nonatomic) IBOutlet UIImageView *moviePosterImage;
@property (weak, nonatomic) IBOutlet UIScrollView *movieDetailScrollView;
@property (weak, nonatomic) IBOutlet UIView *cardView;

@property (weak, nonatomic) IBOutlet UILabel *movieTitle;
@property (weak, nonatomic) IBOutlet UILabel *releaseDate;
@property (weak, nonatomic) IBOutlet UILabel *popularity;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *movieDescription;

@property (weak, nonatomic) IBOutlet UIImageView *calendarImage;
@property (weak, nonatomic) IBOutlet UIImageView *popularityImage;
@property (weak, nonatomic) IBOutlet UIImageView *timeImage;


@end

@implementation MovieDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    CGFloat xMargin = 40;
    CGFloat cardHeight = 250;
    CGFloat bottomPadding = 64;
    CGFloat cardOffset = cardHeight * 0.70;
    self.movieDetailScrollView.frame = CGRectMake(xMargin, // x
                                       CGRectGetHeight(self.view.bounds) - cardHeight - bottomPadding, // y
                                       CGRectGetWidth(self.view.bounds) - 2 * xMargin, // width
                                       cardHeight); // height
    
    self.cardView.frame = CGRectMake(0, cardOffset, CGRectGetWidth(self.movieDetailScrollView.bounds), cardHeight);
    
    // content height is the height of the card plus the offset we want
    CGFloat contentHeight =  cardHeight + cardOffset;
    self.movieDetailScrollView.contentSize = CGSizeMake(self.movieDetailScrollView.bounds.size.width, contentHeight);
    
    [self.movieTitle setText:movieModel.movieTitle];
    [self.movieDescription setText:movieModel.movieDescription];
    [self.movieDescription sizeToFit];
    [self.moviePosterImage setImageWithURL:movieModel.movieThumbnailUrl];
    [self.popularity setText:[NSString stringWithFormat:@"%ld%%", movieModel.moviePopularity]];
    [self.releaseDate setText:movieModel.movieReleaseDate];
    [self.time setText:movieModel.movieTime];
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:movieModel.moviePosterUrl];
    [self.moviePosterImage setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        if (response != nil) {
            self.moviePosterImage.alpha = 0.0;
            self.moviePosterImage.image = image;
            [UIView animateWithDuration:0.3 animations:^{
                self.moviePosterImage.alpha = 1;
            }];
        }
        else {
            self.moviePosterImage.image = image;
        }
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        NSLog(@"Poster image couldn't be loaded");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) setMovieDetail: (MovieModel *) model {
    movieModel = model;
}

@end
