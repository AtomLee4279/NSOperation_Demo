//
//  ViewController.m
//  NSOperation_Demo
//
//  Created by 李一贤 on 2019/7/10.
//  Copyright © 2019 李一贤. All rights reserved.
//

#import "ViewController.h"
#import "NSOpearationChildrenClass.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addPriority];
//    [self addDependency];
    // Do any additional setup after loading the view.
}

//使用子类NSInvocationOperation:系统在当前线程同步执行task1，不会新开线程
-(void)useInvocationOperation {
    //1.创建NSInvocationOperation对象
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];
    //2.调用start方法开始执行
    [op start];
}

-(void)task1 {
    
    for (int i = 0; i<2; i++) {
        [NSThread sleepForTimeInterval:2];//模拟耗时操作
        NSLog(@"task1===%@",[NSThread currentThread]);//打印当前线程
    }
}

//使用子类NSBlockOpertaion:系统在当前线程同步执行，不会新开线程
-(void)useBlockOperation {
    
    //1.创建NSBlockOperation对象
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        
        //只执行1个for循环操作时，在主线程中执行
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    //2.调用start方法开始执行
    [op start];
}

//使用子类NSBlockOpertaion执行多操作时，blockOperationWithBlock和addExecutionBlock都将开启多线程执行，具体开启数量由系统决定
- (void)useBlockOpertaionWithMultTasks {
    
    // 1.创建NSBlockOperation 对象
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        //添加额外操作1
        for (int i =0; i<2; i++) {
            //模拟耗时操作
            [NSThread sleepForTimeInterval:2];
            //打印当前线程
            NSLog(@"1---%@",[NSThread currentThread]);
        }
    }];
    
    //2.添加额外的操作2
    [op addExecutionBlock:^{
        
        for (int i = 0; i<2; i++) {
            //模拟耗时操作
            [NSThread sleepForTimeInterval:2];
            //打印当前线程
            NSLog(@"2---%@",[NSThread currentThread]);
        }
        
    }];
    
    //3.添加额外操作3
    [op addExecutionBlock:^{
        
        for (int i = 0 ; i<2; i++) {
            //模拟耗时操作
            [NSThread sleepForTimeInterval:2];
            //打印当前线程
            NSLog(@"3---%@",[NSThread currentThread]);
            
        }
        
    }];
    
    //4. 调用start方法开始执行操作
    [op start];
    
}
//使用NSOperation子类进行线程操作，没有使用NSOperationQueue：在主线程下执行操作，并没有新开线程
- (void)useCustomOperation {
    //1.创建自定义NSOperation子类对象
    NSOpearationChildrenClass *op = [[NSOpearationChildrenClass alloc] init];
    //2.调用start方法开始执行操作
    [op start];
}

//各种NSOperation子类（系统自带子类/自定义子类）+ NSOperationQueue，实现多线程操作

//步骤：1.创建队列；2.创建操作；3.把操作添加到队列中
- (void)operationWithQueue {
    
    //1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    //2.创建操作
    //2.1使用NSInvocationOperation 创建操作1
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];
    //2.2使用NSBlockOperation创建操作
    //创建操作2.2.1
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2.2.1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
//    创建操作2.2.2
    [op2 addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2.2.2---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    //3.把操作添加到队列中
    [queue addOperation:op1];
    [queue addOperation:op2];
    
    
    
}

//直接用NSOperationQueue方法：addOperationWithBlock添加操作
- (void)addOperationWithBlockToQueue {
    
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //maxConcurrentOperationCount：最大并发操作数，默认是-1，表示不进行限制，可进行并发操作
    queue.maxConcurrentOperationCount = -1;
    
    // 2.使用 addOperationWithBlock: 添加操作到队列中
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"3---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
}

//添加NSOperation操作依赖（适用于同一操作队/不同操作队列）
- (void) addDependency {
    
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 2.创建操作
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    // 3.添加依赖
    [op2 addDependency:op1]; // 让op2 依赖于 op1，则先执行完op1，再执行op2
    
    // 4.添加操作到队列中
    [queue addOperation:op1];
    [queue addOperation:op2];
}

//添加操作优先级属性（仅适用于同一操作队列。同一操作队列里，操作依赖的影响也优先于优先级属性的影响。）、
- (void)addPriority {
    NSLog(@"addPriority");
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 2.创建操作
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
//        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
//        }
    }];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
//        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
//        }
    }];
    // 3.添加操作到队列中
    [queue addOperation:op1];
    
    [queue addOperation:op2];
    //设置优先级：这里发现设置“NSOperationQueuePriorityVeryLow”、、“NSOperationQueuePriorityVeryHigh”这一类枚举值无效；设置都为正值也无效
    //4.1 设置最高优先级
    op1.queuePriority = -1;
    //4.2 设置最低优先级
    op2.queuePriority = 10;
}

@end
