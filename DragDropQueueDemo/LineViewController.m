//
//  Line.m
//  DragDropQueueDemo
//
//  Created by Jack on 3/01/2014.
//  Copyright (c) 2014 salmonapps. All rights reserved.
//

#import "LineViewController.h"
#import "Cell.h"

@implementation LineViewController

-(void)viewDidLoad
{
	[super viewDidLoad];
    [self.collectionView registerClass:[Cell class] forCellWithReuseIdentifier:@"MY_CELL"];
    self.collectionView.backgroundView.backgroundColor = [UIColor clearColor];
    self.collectionView.backgroundColor = [UIColor clearColor];
}

-(NSInteger)numberOfSectionsInCollectionView:(PSTCollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(PSTCollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    NSLog(@"%@ count:%i", self.name, self.data.count);
    return self.data.count;
}

- (PSTCollectionViewCell *)collectionView:(PSTCollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    
    Cell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
    if(self.data.count > indexPath.item) {
        cell.label.text = [self.data objectAtIndex:indexPath.item];
        NSString *userData = [self.data objectAtIndex:indexPath.item];
        cell.userData = userData;
    }else {
        NSLog(@"%@数组越界：%i, %i", self.name, self.data.count, indexPath.item);
        cell.label.text = @"N/A";
    }
    
    return cell;
}



@end
