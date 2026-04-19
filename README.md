
This tool uses the Objective-C runtime APIs to dump information about Objective-C classes that are visible to it.

To explore the classes in a framework or bundle, you need to either link against the target framework at build time, or use the `-L` argument with a full path to a file (either the .dylib or the object file within the framework or plugin bundle). 

Note that when you supply a file in `-L` argument the symbols in the loaded library will be added to the global namespace, so you will still need to supply an appropriate filter argument if you don't want to see every symbol in existence.

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
- (bool)isAnimating
- (bool)isPreview
- (void)drawRect:(CGRect)param0 
- (void)startAnimation
- (id)delegate
- (id)accessibilityRole
- (void)stopAnimation
- (id)accessibilityTitle
- (void).cxx_destruct
- (void)setDelegate:(id)param0 
- (bool)clipsToBounds
- (id)initWithFrame:(CGRect)param0 
- (bool)isAccessibilityElement
- (void)dealloc
- (bool)acceptsFirstMouse:(id)param0 
- (void)setIsAnimating:(bool)param0 
- (void)setPreview:(bool)param0 
- (void)_resetTimer
- (void)animateOneFrame
- (void)displayMessage:(id)param0 
- (bool)_needsAnimationTimer
- (void)_oneStep:(id)param0 
- (double)animationTimeInterval
- (id)configureSheet
- (bool)hasConfigureSheet
- (bool)hidEvent:(id)param0 
- (id)initWithFrame:(CGRect)param0  isPreview:(bool)param1 
- (bool)isKeyboardInteractive
- (bool)isMouseInteractive
- (void)prepareToAnimate
- (id)screenSaverModule
- (void)setAnimationTimeInterval:(double)param0 
- (void)setScreenSaverModule:(id)param0 
// Class Methods (4):
+ (unsigned long)backingStoreType
+ (bool)performGammaFade
+ (bool)performGammaFadeForModuleWithPath:(id)param0 
+ (bool)spansScreens
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
- (void)startAnimation
- (void)stopAnimation
- (void)invalidate
- (unsigned long)awakeFromRemoteView
- (bool)remoteViewSizeChanged:(CGSize)param0  transaction:(id)param1 
- (bool)didFirstResize
- (bool)initialAnimationState
- (void)setDidFirstResize:(bool)param0 
- (void)setInitialAnimationState:(bool)param0 
// Class Methods (0):
@end 

$ ./classdump -L /System/Library/ExtensionKit/Extensions/Flurry.appex/Contents/MacOS/Flurry -l '*Flurry*'
_TtC6FlurryP33_3703B36C8BDA00798659906BE625896D19ResourceBundleClass
AppleFlurry
Flurry.FlurryExtension
Flurry.FlurryConfigurationViewController
Flurry.FlurryViewController
AppleFlurryView
AppleFlurryOpenGLView

$ ./classdump -L /System/Library/ExtensionKit/Extensions/Flurry.appex/Contents/MacOS/Flurry 'AppleFlurryView'
@interface AppleFlurryView : ScreenSaverView {
// Ivars (5):
    AppleFlurryOpenGLView* _glView; // offset 592
    NSMutableArray* _flurries; // offset 600
    NSLock* _bgLock; // offset 608
    float _oldFrameTime; // offset 616
    bool _initTexture; // offset 620
}
// Properties (0):
// Class Properties (0):
// Methods (10):
- (id)initWithFrame:(CGRect)param0 isPreview:(bool)param1;
- (void)dealloc;
- (void)setFrameSize:(CGSize)param0;
- (void)drawRect:(CGRect)param0;
- (void)prepareToAnimate;
- (void)animateOneFrame;
- (void)reloadDefaults:(id)param0;
- (void)gl_init;
- (void)gl_display;
- (void)gl_reshape:(double)param0 :(double)param1;
// Class Methods (1):
+ (void)initialize;

```

Invoking the command with the `-a` flag will cause each method definition to include a comment with an the address
of the function implementing the method, and the path to the library that contains it.

