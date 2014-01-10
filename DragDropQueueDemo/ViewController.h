//
//  ViewController.h
//  DragDropQueueDemo
//
//  Created by Jack on 2/01/2014.
//  Copyright (c) 2014 salmonapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LineViewController;

@interface ViewController : UIViewController {
    NSMutableArray *_lines;
    UIView *_dragView;
    CGPoint _dragStartLocation;
    NSInteger _cellIndex;
    
}

@property (strong, nonatomic) LineViewController *sourceLine;
@property (strong, nonatomic) LineViewController *destnationLine;
@property (strong, nonatomic) NSString *draggingUserData;

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)sender;

@end
