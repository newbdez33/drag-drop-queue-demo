//
//  ViewController.h
//  DragDropQueueDemo
//
//  Created by Jack on 2/01/2014.
//  Copyright (c) 2014 salmonapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
    NSMutableArray *_lines;
    UIView *_dragView;
    CGPoint _dragStartLocation;
    NSMutableArray *_data;
    NSObject *_cellObject;
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)sender;

@end
