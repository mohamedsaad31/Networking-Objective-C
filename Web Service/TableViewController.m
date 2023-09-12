//
//  TableViewController.m
//  Web Service
//
//  Created by mohamed saad on 30/08/2023.
//


#import "TableViewController.h"

@interface TableViewController ()

@property (nonatomic, strong) NSMutableArray *productsArray;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.productsArray = [NSMutableArray new];
    
    NSString *urlString = @"https://dummyjson.com/products";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSError *jsonError = nil;
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError) {
                NSLog(@"JSON Error: %@", jsonError);
            } else {
                NSArray *products = responseDict[@"products"];
                [self.productsArray addObjectsFromArray:products];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }
    }];
    
    [dataTask resume];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.productsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary *product = self.productsArray[indexPath.row];
    cell.textLabel.text = product[@"title"];
    
    NSString *thumbnailURLString = product[@"thumbnail"];
    NSURL *thumbnailURL = [NSURL URLWithString:thumbnailURLString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *thumbnailData = [NSData dataWithContentsOfURL:thumbnailURL];
        UIImage *thumbnailImage = [UIImage imageWithData:thumbnailData];
        
        // Resize the image to a fixed size
        CGSize newSize = CGSizeMake(80, 80);
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
        [thumbnailImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.imageView.image = resizedImage;
            [cell setNeedsLayout];
        });
    });
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *selectedProduct = self.productsArray[indexPath.row];
    
// Extract the details you need from the Product dictionary
    NSString *title = selectedProduct[@"title"];
    NSString *description = selectedProduct[@"description"];
    NSString *price = selectedProduct[@"price"];
    NSString *brand = selectedProduct[@"brand"];
    NSString *imageURLString = selectedProduct[@"image"];
    NSString *rating = selectedProduct[@"rating"];
    
    NSString *alertMessage = [NSString stringWithFormat:@"Title: %@\n\nDescription: %@\n\nPrice: %@\n\nBrand: %@\n\nRating: %@", title, description, price, brand, rating];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Product Details" message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end

