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

#define LINE_COUNT  3
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
    LineViewController *selectedLine = NULL;
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
        
        if (selectedLine==NULL) {
            return;
        }
        
        if (CGRectContainsPoint(selectedLine.collectionView.frame, locationInCollectionView)) {   //找到CollectionView
            NSIndexPath *idx = [selectedLine.collectionView indexPathForItemAtPoint:locationInCollectionView];    //找到Cell index
            if (idx) {
                
                //抽出cell view
                PSTCollectionViewCell *cell = [selectedLine.collectionView cellForItemAtIndexPath:idx];
                _dragView = [cell.contentView viewWithTag:cell.tag];
                [_dragView removeFromSuperview];
                [self.view addSubview:_dragView];
                
                //移除cell
                [selectedLine.data removeObjectAtIndex:idx.item];
                [selectedLine.collectionView deleteItemsAtIndexPaths:@[idx]];
                
                //TODO center可以优化
                _dragView.center = [self.view convertPoint:locationInCollectionView fromView:selectedLine.collectionView];
                _dragStartLocation = _dragView.center;
                [self.view bringSubviewToFront:_dragView];
                return;
            }
            
        }

    }
    
    if (sender.state == UIGestureRecognizerStateChanged) {
        if (!_dragView) {
            return;
        }
        
        CGPoint location = [sender locationInView:self.view];
        _dragView.center = location;
        [self.view bringSubviewToFront:_dragView];
        
        //挪到哪个line，哪个变色玩玩
        [self highlightLine:selectedLine];
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self highlightLine:nil];
        if (!_dragView || !selectedLine) {
            _dragView = NULL;
            return;
        }
        _dragView = NULL;
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
