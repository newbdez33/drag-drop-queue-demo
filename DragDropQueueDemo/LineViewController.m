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

- (NSInteger)collectionView:(PSTCollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return _data.count;
}

- (PSTCollectionViewCell *)collectionView:(PSTCollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    Cell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
    cell.label.text = [_data objectAtIndex:indexPath.item];
    return cell;
}

@end
