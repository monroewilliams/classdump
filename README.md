
This tool uses the Objective-C runtime APIs to dump information about Objective-C classes that are visible to it.

To explore the classes in a framework, you need to link against the target framework at build time.

Its outout is an approximation of what you'd need to put in a header file to be able to reference the target class.

Some examples:

```
$ make
clang++ -fobjc-link-runtime -std=c++20 -framework ScreenSaver classdump.mm -o classdump
$ ./classdump -l '*' |wc -l
   55160
$ ./classdump -l '*' |head -30
__NSGenericDeallocHandler
__NSAtom
_NSZombie_
__NSMessageBuilder
Object
CKSQLiteUnsetPropertySentinel
JSExport
NSProxy
NSPrintPreviewGraphicsContext
NSThemeDocumentButtonPopUpMenuProxy
NSImageRepGeometryProxy
NSAutounbinder
_NSObjectAnimator
_NSPageControllerAnimator
_NSLayoutConstraintAnimator
_NSTitlebarAccessoryAnimator
_NSObjectAnimator_NSSplitViewItem
_NSWindowAnimator
_NSTouchBarAnimator
_NSSplitViewItemAccessoryAnimator
_NSViewAnimator
_NSViewAnimator_NSCollectionView
_NSViewAnimator_NSStackView
_NSViewAnimator_NSScrollView
_NSViewAnimator__NSSliderTouchBarItemView
_NSViewAnimator_NSProgressIndicator
_NSTableViewAnimator
_NSOutlineViewAnimator
_NSViewAnimator_NSFunctionRowBackgroundColorView
_NSViewAnimator_NSClipView

$ ./classdump -l 'ScreenSaver*'
ScreenSaverPhotoChooser
ScreenSaverExtensionManager
ScreenSaverMessage
ScreenSaverExtension
ScreenSaverMessageTracerLogger
ScreenSaverController
ScreenSaverDefaultsManager
ScreenSaverModules
ScreenSaverModule
ScreenSaverExtensionModule
ScreenSaverDefaults
ScreenSaverHostExtensionContext
ScreenSaverExtensionContext
ScreenSaverEngine
ScreenSaverWindow
ScreenSaverRemoteViewController
ScreenSaverConfigurationViewController
ScreenSaverViewController
ScreenSaverView
ScreenSaverExtensionView

$ ./classdump ScreenSaverView ScreenSaverViewController
@interface ScreenSaverView : NSView {
// Ivars (7):
    NSTimer* _animationTimer; // offset 536
    double _timeInterval; // offset 544
    bool _isPreview; // offset 552
    void* _reserved1; // offset 560
    void* _reserved2; // offset 568
    void* _reserved3; // offset 576
    <ScreenSaverViewDelegate>* _delegate; // offset 584
}
// Properties (6):
@property (weak, nonatomic) <ScreenSaverViewDelegate>* delegate;
@property double animationTimeInterval;
@property (readonly, getter=isAnimating) bool animating;
@property (readonly) bool hasConfigureSheet;
@property (readonly) NSWindow* configureSheet;
@property (readonly, getter=isPreview) bool preview;
// Class Properties (6):
@property (class, weak, nonatomic) <ScreenSaverViewDelegate>* delegate;
@property (class) double animationTimeInterval;
@property (class, readonly, getter=isAnimating) bool animating;
@property (class, readonly) bool hasConfigureSheet;
@property (class, readonly) NSWindow* configureSheet;
@property (class, readonly, getter=isPreview) bool preview;
// Methods (33):
- (bool)isAnimating;  // image lookup -v --address 0x1db964728
- (bool)isPreview;  // image lookup -v --address 0x1db966e00
- (void)drawRect:(CGRect);  // image lookup -v --address 0x1db96473c
- (void)startAnimation;  // image lookup -v --address 0x1db9659e0
- (id)delegate;  // image lookup -v --address 0x1db966f24
- (id)accessibilityRole;  // image lookup -v --address 0x1db966e48
- (void)stopAnimation;  // image lookup -v --address 0x1db965d2c
- (id)accessibilityTitle;  // image lookup -v --address 0x1db966e7c
- (void).cxx_destruct;  // image lookup -v --address 0x1db966f48
- (void)setDelegate:(id);  // image lookup -v --address 0x1db966f34
- (bool)clipsToBounds;  // image lookup -v --address 0x1db9667b0
- (id)initWithFrame:(CGRect);  // image lookup -v --address 0x1db9667a0
- (bool)isAccessibilityElement;  // image lookup -v --address 0x1db966e40
- (void)dealloc;  // image lookup -v --address 0x1db9667b8
- (bool)acceptsFirstMouse:(id);  // image lookup -v --address 0x1db9667a8
- (void)setIsAnimating:(bool);  // image lookup -v --address 0x1db966914
- (void)setPreview:(bool);  // image lookup -v --address 0x1db966e28
- (void)_resetTimer;  // image lookup -v --address 0x1db965a58
- (void)animateOneFrame;  // image lookup -v --address 0x1db966d9c
- (void)displayMessage:(id);  // image lookup -v --address 0x1db966da0
- (bool)_needsAnimationTimer;  // image lookup -v --address 0x1db966864
- (void)_oneStep:(id);  // image lookup -v --address 0x1db966928
- (double)animationTimeInterval;  // image lookup -v --address 0x1db965b60
- (id)configureSheet;  // image lookup -v --address 0x1db966df8
- (bool)hasConfigureSheet;  // image lookup -v --address 0x1db966df0
- (bool)hidEvent:(id);  // image lookup -v --address 0x1db966e38
- (id)initWithFrame:(CGRect) isPreview:(bool);  // image lookup -v --address 0x1db9644ec
- (bool)isKeyboardInteractive;  // image lookup -v --address 0x1db966580
- (bool)isMouseInteractive;  // image lookup -v --address 0x1db966588
- (void)prepareToAnimate;  // image lookup -v --address 0x1db966d98
- (id)screenSaverModule;  // image lookup -v --address 0x1db966e10
- (void)setAnimationTimeInterval:(double);  // image lookup -v --address 0x1db965884
- (void)setScreenSaverModule:(id);  // image lookup -v --address 0x1db9658a8
// Class Methods (4):
+ (unsigned long)backingStoreType;  // image lookup -v --address 0x1db96634c
+ (bool)performGammaFade;  // image lookup -v --address 0x1db966344
+ (bool)performGammaFadeForModuleWithPath:(id);  // image lookup -v --address 0x1db966340
+ (bool)spansScreens;  // image lookup -v --address 0x1db9663c4
@end 

@interface ScreenSaverViewController : NSServiceViewController {
// Ivars (2):
    bool _initialAnimationState; // offset 136
    bool _didFirstResize; // offset 137
}
// Properties (2):
@property bool initialAnimationState;
@property bool didFirstResize;
// Class Properties (2):
@property (class) bool initialAnimationState;
@property (class) bool didFirstResize;
// Methods (9):
- (void)startAnimation;  // image lookup -v --address 0x1db96ba44
- (void)stopAnimation;  // image lookup -v --address 0x1db96bb40
- (void)invalidate;  // image lookup -v --address 0x1db96b7ac
- (unsigned long)awakeFromRemoteView;  // image lookup -v --address 0x1db96b700
- (bool)remoteViewSizeChanged:(CGSize) transaction:(id);  // image lookup -v --address 0x1db96b804
- (bool)didFirstResize;  // image lookup -v --address 0x1db96bc60
- (bool)initialAnimationState;  // image lookup -v --address 0x1db96bc3c
- (void)setDidFirstResize:(bool);  // image lookup -v --address 0x1db96bc74
- (void)setInitialAnimationState:(bool);  // image lookup -v --address 0x1db96bc50
// Class Methods (0):
@end 

```

Method descriptions include a comment with an lldb command you can use to get information about the implementation method,
including what library it's located in.

The easiest way to make use of this is to run the tool under the debugger, set a breakpoint at the end of main(),
and copy/paste the `image lookup` command from the output into the debugger console when you stop at the breakpoint.

