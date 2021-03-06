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
#import "Cell.h"

#define LINE_COUNT  15
#define TOP_OFFSET  100

@implementation UIView (OPCloning)

- (id) clone {
    NSData *archivedViewData = [NSKeyedArchiver archivedDataWithRootObject: self];
    id clone = [NSKeyedUnarchiver unarchiveObjectWithData:archivedViewData];
    return clone;
}

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Init data...");
    
    //初始化排队
    _lines = [[NSMutableArray alloc] initWithCapacity:LINE_COUNT];
    for (int i=0; i<LINE_COUNT; i++) {
        LineLayout* lineLayout = [[LineLayout alloc] init];
        LineViewController *line = [[LineViewController alloc] initWithCollectionViewLayout:lineLayout];
        line.name = [NSString stringWithFormat:@"L%i", i];
//        switch(i) {
//            case 0:
//                line.view.backgroundColor = [UIColor redColor];
//                break;
//            case 1:
//                line.view.backgroundColor = [UIColor orangeColor];
//                break;
//            case 2:
//                line.view.backgroundColor = [UIColor greenColor];
//                break;
//            case 3:
//                line.view.backgroundColor = [UIColor blueColor];
//                break;
//        }
        
        line.data = [NSMutableArray array];
        for (int j=0; j<30; j++) {
            [line.data addObject:[NSString stringWithFormat:@"%i|%i", i, j]];
        }
        
        //为什么320才显示正常？
        [line.view setFrame:CGRectMake(10, TOP_OFFSET + 80 * i, self.scrollView.frame.size.width - 20, 325)];
        [_lines addObject:line];
        [self.scrollView addSubview:line.view];
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, line.view.frame.origin.y + 100)];
    }
    
    //手势
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self.scrollView addGestureRecognizer:longPressGesture];
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)sender {
    
    scrollFlagForV = stop;
    scrollFlagForH = stop;
    
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        self.sourceLine = nil;
        CGPoint locationInCollectionView = CGPointZero;
        for (int i=0; i<_lines.count; i++) {
            LineViewController *l = [_lines objectAtIndex:i];
            CGPoint p = [sender locationInView:l.collectionView];
            p.x -= l.collectionView.contentOffset.x;
            if (CGRectContainsPoint(l.collectionView.frame, p)) {   //找到CollectionView
                self.sourceLine = l;
                locationInCollectionView = [sender locationInView:self.sourceLine.collectionView];
                l = nil;
                break;
            }
            l = nil;
        }
        
        if (self.sourceLine==nil) {
            NSLog(@"没有按在collectionView上。");
            return;
        }
        NSLog(@"%@ is selected", self.sourceLine.name);
        
        //找到Cell index
        NSIndexPath *selectedIndex = [self.sourceLine.collectionView indexPathForItemAtPoint:locationInCollectionView];
        if (selectedIndex) {
            
            //抽出cell view
            Cell *cell = (Cell *)[self.sourceLine.collectionView cellForItemAtIndexPath:selectedIndex];
            
            _cellIndex = selectedIndex.item;
            self.draggingUserData = cell.userData;
            
            NSLog(@"拿起:%@ at:%i", cell.userData, selectedIndex.item);
            UIView *cellView = [cell.contentView viewWithTag:cell.tag];
            _dragView = [cellView clone];
            [self.scrollView addSubview:_dragView];
            
            //不移除cell了
            [self.sourceLine.data removeObjectAtIndex:selectedIndex.item];
            [self.sourceLine.collectionView performBatchUpdates:^{
                [self.sourceLine.collectionView deleteItemsAtIndexPaths:@[selectedIndex]];
            } completion:^(BOOL finished) {
                NSLog(@"删除后计：:%i", self.sourceLine.data.count);
                //[self.sourceLine.collectionView reloadData];
            }];
            
            _dragView.center = [self.scrollView convertPoint:locationInCollectionView fromView:self.sourceLine.collectionView];
            _dragStartLocation = _dragView.center;
            [self.scrollView bringSubviewToFront:_dragView];
            
            return;
        }else {
            NSLog(@"没找按下的cell Index.");
        }
        

    }

    if (sender.state == UIGestureRecognizerStateChanged) {
        if (!_dragView) {
            return;
        }
        
        self.destnationLine = nil;
        for (int i=0; i<_lines.count; i++) {
            LineViewController *l = [_lines objectAtIndex:i];
            CGPoint p = [sender locationInView:l.collectionView];
            p.x -= l.collectionView.contentOffset.x;
            if (CGRectContainsPoint(l.collectionView.frame, p)) {
                //找到CollectionView
                self.destnationLine = l;
                //left and right scroll
                if ((_dragView.frame.origin.x - _dragView.frame.size.width < self.scrollView.frame.origin.x) && [self.destnationLine.collectionView numberOfItemsInSection:0]>15) {
                    
                    scrollFlagForH = up;
                    [self scrollToH];
                    
                }
                if((_dragView.frame.origin.x + _dragView.frame.size.width > self.scrollView.frame.origin.x + self.scrollView.frame.size.width) && [self.destnationLine.collectionView numberOfItemsInSection:0]>15){
                    scrollFlagForH = down;
                    [self scrollToH];
                }

                // end by sjk
                l = nil;
                break;
            }
            l = nil;
        }

        
        CGPoint location = [sender locationInView:self.scrollView];
        //location.x -= selectedLine.collectionView.contentOffset.x;
        _dragView.center = location;
        [self.scrollView bringSubviewToFront:_dragView];
        
        //挪到哪个line，高亮
        [self highlightLine:self.destnationLine];
        
        //top and buttom scroll
     
        if(_dragView.frame.origin.y -_dragView.frame.size.height - self.scrollView.contentOffset.y  < self.scrollView.frame.origin.y){
            scrollFlagForV = up;
            [self scrollToV];
        }
        if(_dragView.frame.origin.y + _dragView.frame.size.height > self.scrollView.frame.size.height + self.scrollView.frame.origin.y){
            scrollFlagForV = down;
            [self scrollToV];
        }
        // end by sjk
        return;
    }

    if (sender.state == UIGestureRecognizerStateEnded) {
        [self highlightLine:nil];
        if (!_dragView) {
            _dragView = nil;
            return;
        }
        
        self.destnationLine = nil;
        CGPoint locationInCollectionView = CGPointZero;
        for (int i=0; i<_lines.count; i++) {
            LineViewController *l = [_lines objectAtIndex:i];
            CGPoint p = [sender locationInView:l.collectionView];
            p.x -= l.collectionView.contentOffset.x;
            if (CGRectContainsPoint(l.collectionView.frame, p)) {   //找到CollectionView
                self.destnationLine = l;
                locationInCollectionView = [sender locationInView:self.destnationLine.collectionView];
                l = nil;
                break;
            }
            l = nil;
        }
        NSIndexPath *selectedIndex = [self.destnationLine.collectionView indexPathForItemAtPoint:locationInCollectionView];
        //insert item after a cell
        UIView *cell = [self.destnationLine.collectionView cellForItemAtIndexPath:selectedIndex];
        if (locationInCollectionView.x > cell.center.x) {
            NSInteger numCount = [self.destnationLine.collectionView  numberOfItemsInSection:0];
            selectedIndex = [NSIndexPath indexPathForRow:numCount inSection:0];
        }
        if(!self.destnationLine || !selectedIndex) { //没拖到line上的情况
            selectedIndex = [NSIndexPath indexPathForItem:_cellIndex inSection:0];
            self.destnationLine = self.sourceLine;
        }
        
        if (!selectedIndex) {
            _dragView = nil;
            return;
        }

        [self.destnationLine.collectionView performBatchUpdates:^{
            [self.destnationLine.data insertObject:self.draggingUserData atIndex:selectedIndex.item];
            [self.destnationLine.collectionView insertItemsAtIndexPaths:@[selectedIndex]];
        } completion:^(BOOL finished) {
            NSLog(@"插入后计:%i", self.destnationLine.data.count);
            [self.destnationLine.collectionView reloadItemsAtIndexPaths:@[selectedIndex]];
            //[selectedLine.collectionView reloadData];
        }];
        [_dragView removeFromSuperview];
        _dragView = nil;
    }
    

}

#pragma -mark direct diferent scroll view

//垂直滚动
- (void)scrollToV {
    CGPoint next;
    
    switch (scrollFlagForV) {
        case stop:
            return;
            break;
        case up:
            next = CGPointMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y-1);
            if (next.y<0)
            {
                return;
            }
            break;
        case down:
            next = CGPointMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y+1);
            if (next.y > self.scrollView.frame.size.height-100)
            {
                return;
            }
            break;
        default:
            break;
    }
    
    
    NSLog(@"next:%@", NSStringFromCGPoint(next));
    self.scrollView.contentOffset = next;
    [self performSelector:@selector(scrollToV) withObject:nil afterDelay:0.1];
    
}

//水平滚动
- (void)scrollToH {
    CGPoint next;
    
    switch (scrollFlagForH) {
        case stop:
            return;
            break;
        case up:
            next = CGPointMake(self.destnationLine.collectionView.contentOffset.x-3,self.destnationLine.collectionView.contentOffset.y);
            if (next.x<0)
            {
                return;
            }
            break;
        case down:
            next = CGPointMake(self.destnationLine.collectionView.contentOffset.x+3,self.destnationLine.collectionView.contentOffset.y);
            if (next.x > self.destnationLine.collectionView.frame.size.width)
            {
                return;
            }
            break;
        default:
            break;
    }
    
    NSLog(@"next:%@", NSStringFromCGPoint(next));
    self.destnationLine.collectionView.contentOffset = next;
    [self performSelector:@selector(scrollToH) withObject:nil afterDelay:0.1];
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

- (BOOL)shouldAutorotate {
    return YES;
}

@end
