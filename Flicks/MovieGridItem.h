//
//  MovieGridItem.h
//  Flicks
//
//  Created by  Imtiyaz Jariwala on 1/25/17.
//  Copyright © 2017 yahoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieGridItem : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *movieThumbnail;
@property (weak, nonatomic) IBOutlet UILabel *movieTitle;

@end
