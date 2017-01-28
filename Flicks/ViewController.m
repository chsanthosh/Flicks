//
//  ViewController.m
//  Flicks
//
//  Created by  Imtiyaz Jariwala on 1/23/17.
//  Copyright © 2017 yahoo. All rights reserved.
//

#import "ViewController.h"
#import "MovieListItem.h"
#import "MovieGridItem.h"
#import "MovieModel.h"
#import "MovieDetailViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MBProgressHUD.h>

typedef NS_ENUM(NSInteger, MovieListType) {
    MovieListTypeNowPlaying,
    MovieListTypeTopRated,
};


@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UITableView *movieTableView;


@property (weak, nonatomic) IBOutlet UICollectionView *movieGridView;

@property (strong, nonatomic) NSArray<MovieModel *> *movies;
@property (nonatomic, assign) MovieListType type;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"top-rated.png"]];

    NSLog(@"ViewController viewDidLoad");

    [self.movieTableView setHidden:NO];
    [self.movieGridView setHidden:YES];
    [self.searchBar setHidden:NO];
    [self.errorView setHidden:YES];
    
    self.movieTableView.dataSource = self;
    self.movieTableView.delegate = self;
    self.movieGridView.dataSource = self;
    self.movieGridView.delegate = self;
    self.searchBar.delegate = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.movieTableView insertSubview:self.refreshControl atIndex:0];
    [self.movieGridView insertSubview:self.refreshControl atIndex:0];

    self.movieTableView.frame = self.movieGridView.frame = CGRectMake(0,
                                          self.navigationController.navigationBar.frame.size.height + self.searchBar.frame.size.height + 20,
                                          CGRectGetWidth(self.view.bounds),
                                          CGRectGetHeight(self.view.bounds) - 165);


    static NSDictionary<NSString *, NSNumber *> *restorationIdentifierToTypeMapping;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        restorationIdentifierToTypeMapping = @{
                                               @"now_playing": @(MovieListTypeNowPlaying),
                                               @"top_rated": @(MovieListTypeTopRated)
                                               };
    });
    self.type = restorationIdentifierToTypeMapping[self.restorationIdentifier].integerValue;
    
    [self fetchMovies];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.refreshControl endRefreshing];
}

- (void) fetchMovies {
    NSString *apiKey = @"e48bc01f52c3e59d7e0a039037ea2a37";
    NSString *typePathComponent;
    switch (self.type) {
        case MovieListTypeNowPlaying:
            typePathComponent = @"now_playing";
            break;
        case MovieListTypeTopRated:
            typePathComponent = @"top_rated";
        break;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    NSString *urlString = [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@?api_key=%@", typePathComponent, apiKey];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                  delegate:nil
                             delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                if (!error) {
                                                    NSError *jsonError = nil;
                                                    NSDictionary *responseDictionary =
                                                    [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:kNilOptions
                                                                                      error:&jsonError];
                                                    
                                                    //NSLog(@"Response: %@", responseDictionary);
                                                    
                                                    NSArray *results = responseDictionary[@"results"];
                                                    NSMutableArray *models = [NSMutableArray array];
                                                    NSDictionary *resultModel = [[NSDictionary alloc] init];
                                                    [models removeAllObjects];
                                                    for (NSDictionary *result in results) {
                                                        if (self.searchBar.text.length > 0) {
                                                            if ([result[@"title"] containsString: self.searchBar.text]) {
                                                                resultModel = result;
                                                            }
                                                            else {
                                                                resultModel = nil;
                                                            }
                                                        }
                                                        else {
                                                            resultModel = result;
                                                        }
                                                        
                                                        if (resultModel != nil) {
                                                            MovieModel *model = [[MovieModel alloc] initWithDictionary:resultModel];
                                                            [models addObject:model];
                                                        }
                                                        
                                                        //NSLog(@"Model - %@", model);
                                                    }
                                                    self.movies = models;
                                                    [self.movieTableView reloadData];
                                                    [self.movieGridView reloadData];
                                                    
                                                } else {
                                                    NSLog(@"An error occurred: %@", error.description);
                                                    [self.errorView setHidden:NO];
                                                    [self.errorMessage setText:error.localizedDescription];
                                                    [self.movieTableView setHidden:YES];
                                                    [self.movieGridView setHidden:YES];
                                                    [self.searchBar setHidden:YES];
                                                }
                                            }];
    [task resume];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MovieListItem *movieList = [tableView dequeueReusableCellWithIdentifier:@"movieCell" forIndexPath:indexPath];
    movieList.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //set movie data for the row
    MovieModel *model = [self.movies objectAtIndex:indexPath.row];
    [movieList.movieTitle setText:model.movieTitle];
    [movieList.movieOverview setText:model.movieDescription];
    movieList.movieThumbnail.contentMode = UIViewContentModeScaleAspectFill;
    [movieList.movieThumbnail setImageWithURL:model.movieThumbnailUrl];
    
    return movieList;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    MovieGridItem *gridCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"gridCell" forIndexPath:indexPath];
    
    //set movie data for the cell
    MovieModel *model = [self.movies objectAtIndex:indexPath.row];
    [gridCell.movieTitle setText:model.movieTitle];
    gridCell.movieThumbnail.contentMode = UIViewContentModeScaleAspectFill;
    [gridCell.movieThumbnail setImageWithURL:model.movieThumbnailUrl];
    
    return gridCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *indexPath;
    if ([self.movieGridView isHidden]) {
        indexPath = [self.movieTableView indexPathForCell:sender];
    }
    else {
        indexPath = [self.movieGridView indexPathForCell:sender];
    }
    
    MovieModel *model = [self.movies objectAtIndex:indexPath.row];
    
    MovieDetailViewController *movieDetailController = segue.destinationViewController;
    [movieDetailController setMovieDetail: model];

    /*
    if ([[segue identifier] isEqualToString:@"segue_now_playing"]) {
        NSLog(@"IN now playing segue");
    }
    else if ([[segue identifier] isEqualToString:@"segue_top_rated"]) {
        NSLog(@"IN top rated segue");
    }
    */
}

- (void)onRefresh {

    NSLog(@"-- onRefresh --");
    NSString *apiKey = @"e48bc01f52c3e59d7e0a039037ea2a37";
    NSString *typePathComponent;
    switch (self.type) {
        case MovieListTypeNowPlaying:
            typePathComponent = @"now_playing";
            break;
        case MovieListTypeTopRated:
            typePathComponent = @"top_rated";
            break;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@?api_key=%@", typePathComponent, apiKey];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                  delegate:nil
                             delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
        if (!error) {
            NSError *jsonError = nil;
            NSDictionary *responseDictionary =
            [NSJSONSerialization JSONObjectWithData:data
                                            options:kNilOptions
                                              error:&jsonError];
            
            NSArray *results = responseDictionary[@"results"];
            NSMutableArray *models = [NSMutableArray array];
            for (NSDictionary *result in results) {
                MovieModel *model = [[MovieModel alloc] initWithDictionary:result];
                [models addObject:model];
                //NSLog(@"Model - %@", model);
            }
            self.movies = models;
            [self.movieTableView reloadData];
            [self.movieGridView reloadData];
            
        } else {
            NSLog(@"An error occurred: %@", error.description);
            [self.errorView setHidden:NO];
            [self.errorMessage setText:error.localizedDescription];
            [self.movieTableView setHidden:YES];
            [self.movieGridView setHidden:YES];
            [self.searchBar setHidden:YES];
        }

        [self.refreshControl endRefreshing];
    }];
    
    [task resume];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self fetchMovies];
}

- (IBAction)onTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}


#pragma mark SEGMENT
- (IBAction)segmentSelectionChanged:(UISegmentedControl *)sender {
    
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self.movieTableView setHidden:NO];
            [self.movieGridView setHidden:YES];
            break;
        case 1:
            [self.movieTableView setHidden:YES];
            [self.movieGridView setHidden:NO];
            break;
        default:
            break;
    }
}


@end
