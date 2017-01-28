//
//  MovieCell.h
//  Flicks
//
//  Created by  Imtiyaz Jariwala on 1/23/17.
//  Copyright © 2017 yahoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieListItem : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *movieThumbnail;
@property (weak, nonatomic) IBOutlet UILabel *movieTitle;
@property (weak, nonatomic) IBOutlet UILabel *movieOverview;

@end
