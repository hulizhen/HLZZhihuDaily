
HLZInfiniteScrollView
---------------------
This library provides a scroll view, which can be scrolled infinitely and automatically, by making use of UICollectionView.

![hlzinfinitescrollview](https://cloud.githubusercontent.com/assets/2831422/16691969/7bef5aec-4561-11e6-9163-2dae603c0635.gif)



# How to use

## Using CocoaPods

[CocoaPods Get Started](http://cocoapods.org/#get_started)

Create `Podfile`:

```ruby
platform :ios, '8.0'

target 'YourTarget' do

pod 'HLZInfiniteScrollView', '~>1.0'

end
```

If you are using Swift, add `use_frameworks!`:

```ruby
platform :ios, '8.0'
use_frameworks!
```

## Copying files into your project

Copy the interface and implementation files into your project and include the `HLZInfiniteScrollView.h`.

## Demo

```objective-c
#import "HLZInfiniteScrollView.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet HLZInfiniteScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *views = [[NSMutableArray alloc] init];
    for (int i = 0; i < N; ++i) {
        UIView *view = [[UIView alloc] init];
        
        ...
                
        [views addObject:view];
    }

    self.scrollView.pageControlEnabled = YES;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.autoScrollEnabled = YES;
    self.scrollView.autoScrollTimerInterval = 5.0;
    self.scrollView.autoScrollDirection = AutoScrollDirectionRight;
    self.scrollView.contentViews = imageViews;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.scrollView.currentPage = 0;
}

@end
```

Check out the demo project to see the details.
