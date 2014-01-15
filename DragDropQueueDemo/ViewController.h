//
//  ViewController.h
//  DragDropQueueDemo
//
//  Created by Jack on 2/01/2014.
//  Copyright (c) 2014 salmonapps. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef  enum{
    up =1,
    down = 2,
    stop = 0,
}ScrollFlag;

@class LineViewController;

@interface ViewController : UIViewController {
    NSMutableArray *_lines;
    UIView *_dragView;
    CGPoint _dragStartLocation;
    NSInteger _cellIndex;
    
    NSInteger scrollFlagForV;       //垂直滚动标识
    NSInteger scrollFlagForH;       //水平滚动标识
    
}

@property (strong, nonatomic) LineViewController *sourceLine;
@property (strong, nonatomic) LineViewController *destnationLine;
@property (strong, nonatomic) NSString *draggingUserData;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)sender;

@end
