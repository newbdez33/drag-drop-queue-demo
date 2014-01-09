//
//  ViewController.m
//  DragDropQueueDemo
//
//  Created by Jack on 2/01/2014.
//  Copyright (c) 2014 salmonapps. All rights reserved.
//

#import "ViewController.h"
#import "LineLayout.h"
#import "LineViewController.h"
#import "NSIndexPath+PSTCollectionViewAdditions.h"

#define LINE_COUNT  4
#define TOP_OFFSET  100

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _data = [NSMutableArray array];
    for (int lc=0; lc<LINE_COUNT; lc++) {
        NSMutableArray *la = [NSMutableArray array];
        for (int i=0; i<30; i++) {
            [la addObject:[NSString stringWithFormat:@"%i|%i", lc, i]];
        }
        [_data addObject:la];
    }
    
    //初始化排队
    _lines = [[NSMutableArray alloc] initWithCapacity:LINE_COUNT];
    LineLayout* lineLayout = [[LineLayout alloc] init];
    for (int i=0; i<LINE_COUNT; i++) {
        LineViewController *line = [[LineViewController alloc] initWithCollectionViewLayout:lineLayout];
        line.data = [NSMutableArray arrayWithArray:[_data objectAtIndex:i]];
        //为什么320才显示正常？
        [line.view setFrame:CGRectMake(10, TOP_OFFSET + 150 * i, self.view.frame.size.width - 20, 325)];
        [_lines addObject:line];
        [self.view addSubview:line.view];
    }
    
    //手势
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self.view addGestureRecognizer:longPressGesture];
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)sender {
    
    
    //找到当前的Line
    LineViewController *selectedLine = nil;
    CGPoint locationInCollectionView = CGPointZero;
    for (int i=0; i<_lines.count; i++) {
        LineViewController *l = [_lines objectAtIndex:i];
        CGPoint p = [sender locationInView:l.collectionView];
        if (CGRectContainsPoint(l.collectionView.frame, p)) {   //找到CollectionView
            selectedLine = l;
            locationInCollectionView = [sender locationInView:selectedLine.collectionView];
        }
    }
    
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        if (selectedLine==nil) {
            return;
        }
        
        //找到Cell index
        NSIndexPath *selectedIndex = [selectedLine.collectionView indexPathForItemAtPoint:locationInCollectionView];
        if (selectedIndex) {
            
            //抽出cell object
            self.selectedCellObject = [selectedLine.data objectAtIndex:selectedIndex.item];
            _cellIndex = selectedIndex.item;
            self.originLine = selectedLine;
            
            //抽出cell view
            PSTCollectionViewCell *cell = [selectedLine.collectionView cellForItemAtIndexPath:selectedIndex];
            _dragView = [cell.contentView viewWithTag:cell.tag];
            [_dragView removeFromSuperview];
            [self.view addSubview:_dragView];
            
            //移除cell
            [selectedLine.data removeObjectAtIndex:selectedIndex.item];
            [selectedLine.collectionView performBatchUpdates:^{
                [selectedLine.collectionView deleteItemsAtIndexPaths:@[selectedIndex]];
            } completion:^(BOOL finished) {
            }];
            
            //TODO center可以优化
            _dragView.center = [self.view convertPoint:locationInCollectionView fromView:selectedLine.collectionView];
            _dragStartLocation = _dragView.center;
            [self.view bringSubviewToFront:_dragView];
            return;
        }
        

    }
    
    if (sender.state == UIGestureRecognizerStateChanged) {
        if (!_dragView) {
            return;
        }
        
        CGPoint location = [sender locationInView:self.view];
        _dragView.center = location;
        [self.view bringSubviewToFront:_dragView];
        
        //挪到哪个line，高亮
        [self highlightLine:selectedLine];
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self highlightLine:nil];
        if (!_dragView) {
            _dragView = nil;
            return;
        }
        
        NSIndexPath *selectedIndex = nil;
        
        if(!selectedLine) { //没拖到line上的情况
            selectedLine = self.originLine;
            selectedIndex = [NSIndexPath indexPathForItem:_cellIndex inSection:0];
        }else {
            //找到Cell index
            selectedIndex = [selectedLine.collectionView indexPathForItemAtPoint:locationInCollectionView];
        }

        [selectedLine.data insertObject:self.selectedCellObject atIndex:selectedIndex.item];
        [selectedLine.collectionView performBatchUpdates:^{
            [selectedLine.collectionView insertItemsAtIndexPaths:@[selectedIndex]];
        } completion:^(BOOL finished) {
            //[selectedLine.collectionView reloadItemsAtIndexPaths:@[selectedIndex]];
            [selectedLine.collectionView reloadData];
        }];
        [_dragView removeFromSuperview];
        _dragView = nil;
    }
    

}

- (void)highlightLine:(LineViewController *)selected {
    
    for (int i=0; i<_lines.count; i++) {
        LineViewController *l = [_lines objectAtIndex:i];
        l.view.backgroundColor = [UIColor clearColor];
    }
    
    if (selected) {
        [selected.view setBackgroundColor:[UIColor yellowColor]];
    }
}

@end
