#import "ViewController.h"
#import <mach/mach.h>
#import <IOSurface/IOSurfaceRef.h>
#import <CoreFoundation/CoreFoundation.h>

@interface ViewController ()
@property (nonatomic, strong) UITextView *consoleView;
@property (nonatomic, strong) UIButton *btnMach;
@property (nonatomic, strong) UIButton *btnIOSurface;
@property (nonatomic, strong) UIButton *btnClear;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"XNU Kernel Lab 🔬";
    self.view.backgroundColor = [UIColor colorWithRed:0.06 green:0.09 blue:0.15 alpha:1.0];
    
    [self setupUI];
    [self log:@"[+] Sẵn sàng. Chọn bài kiểm thử Kernel bên dưới:"];
}

- (void)setupUI {
    CGFloat w = self.view.bounds.size.width;
    
    // Nút 1: Mach Port Allocator
    self.btnMach = [self makeButtonWithTitle:@"1. Test Mach IPC Ports" color:[UIColor systemBlueColor] y:110 action:@selector(testMachPorts)];
    [self.view addSubview:self.btnMach];
    
    // Nút 2: IOSurface Driver Allocation
    self.btnIOSurface = [self makeButtonWithTitle:@"2. Test IOSurface Kernel Driver" color:[UIColor systemOrangeColor] y:170 action:@selector(testIOSurfaceDriver)];
    [self.view addSubview:self.btnIOSurface];

    // Nút Xoá Log
    self.btnClear = [self makeButtonWithTitle:@"Xoá Console" color:[UIColor systemGrayColor] y:230 action:@selector(clearConsole)];
    [self.view addSubview:self.btnClear];

    // Console Log View
    self.consoleView = [[UITextView alloc] initWithFrame:CGRectMake(16, 290, w - 32, self.view.bounds.size.height - 310)];
    self.consoleView.backgroundColor = [UIColor colorWithRed:0.02 green:0.04 blue:0.08 alpha:1.0];
    self.consoleView.textColor = [UIColor colorWithRed:0.22 green:0.74 blue:0.97 alpha:1.0];
    self.consoleView.font = [UIFont fontWithName:@"Menlo" size:12];
    self.consoleView.layer.borderColor = [UIColor colorWithRed:0.15 green:0.2 blue:0.3 alpha:1.0].CGColor;
    self.consoleView.layer.borderWidth = 1.0;
    self.consoleView.layer.cornerRadius = 8.0;
    self.consoleView.editable = NO;
    [self.view addSubview:self.consoleView];
}

- (UIButton *)makeButtonWithTitle:(NSString *)title color:(UIColor *)color y:(CGFloat)y action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(16, y, self.view.bounds.size.width - 32, 48);
    btn.backgroundColor = color;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
    btn.layer.cornerRadius = 10.0;
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)log:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.consoleView.text = [self.consoleView.text stringByAppendingFormat:@"\n> %@", msg];
        NSRange bottom = NSMakeRange(self.consoleView.text.length - 1, 1);
        [self.consoleView scrollRangeToVisible:bottom];
    });
}

- (void)clearConsole {
    self.consoleView.text = @"> Đã xoá nhật ký.";
}

// 1. Kiểm thử Mach Ports IPC
- (void)testMachPorts {
    [self log:@"--- KIỂM TRA MACH IPC SUBSYSTEM ---"];
    mach_port_t port = MACH_PORT_NULL;
    kern_return_t kr = mach_port_allocate(mach_task_self(), MACH_PORT_RIGHT_RECEIVE, &port);
    if (kr != KERN_SUCCESS) {
        [self log:[NSString stringWithFormat:@"[-] Lỗi cấp phát Mach Port: 0x%x", kr]];
        return;
    }
    [self log:[NSString stringWithFormat:@"[+] Cấp phát thành công Receive Right: 0x%x", port]];

    kr = mach_port_insert_right(mach_task_self(), port, port, MACH_MSG_TYPE_MAKE_SEND);
    if (kr == KERN_SUCCESS) {
        [self log:@"[+] Thêm thành công quyền Send Right (Port Pair hoàn chỉnh)"];
    }

    mach_port_destroy(mach_task_self(), port);
    [self log:@"[+] Giải phóng Mach Port an toàn qua mach_port_destroy()."];
}

// 2. Kiểm thử IOSurface Kernel Shared Memory
- (void)testIOSurfaceDriver {
    [self log:@"--- THĂM DÒ DRIVER IOSurfaceRoot ---"];
    NSDictionary *properties = @{
        (id)kIOSurfaceWidth: @(100),
        (id)kIOSurfaceHeight: @(100),
        (id)kIOSurfaceBytesPerElement: @(4),
        (id)kIOSurfacePixelFormat: @(0x32343838) // BGRA
    };

    IOSurfaceRef surface = IOSurfaceCreate((CFDictionaryRef)properties);
    if (surface) {
        [self log:@"[+] TẠO THÀNH CÔNG ĐỐI TƯỢNG IOSURFACE KERNEL!"];
        [self log:[NSString stringWithFormat:@"  -> ID: %u", (unsigned int)IOSurfaceGetID(surface)]];
        [self log:[NSString stringWithFormat:@"  -> Kích thước cấp phát: %zu bytes", IOSurfaceGetAllocSize(surface)]];
        [self log:@"  => Bộ nhớ chia sẻ Kernel <-> UserClient hoạt động bình thường!"];
        CFRelease(surface);
        [self log:@"[+] Đã giải phóng Surface Ref an toàn."];
    } else {
        [self log:@"[-] Không thể tạo IOSurface (Driver từ chối hoặc bị Sandbox giới hạn)."];
    }
}

@end
