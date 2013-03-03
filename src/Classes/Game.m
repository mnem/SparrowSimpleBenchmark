//
//  Game.m
//  AppScaffold
//

#import "Game.h" 

const BOOL ANIMATE = YES;
const int NUM_SPRITES = 500;

// --- private interface ---------------------------------------------------------------------------

@interface Game ()

- (void)setup;
- (void)onTouched:(SPTouchEvent *)event;

@property (nonatomic, strong) SPTexture* texture;
@property (nonatomic, strong) SPTextField* label;
@property (nonatomic, strong) SPTextField* fpsLabel;
@property (nonatomic) int spriteCount;

@end


// --- class implementation ------------------------------------------------------------------------

@implementation Game

@synthesize gameWidth  = mGameWidth;
@synthesize gameHeight = mGameHeight;

- (id)initWithWidth:(float)width height:(float)height
{
    if ((self = [super init]))
    {
        mGameWidth = width;
        mGameHeight = height;
        
        [self setup];
    }
    return self;
}

- (void)dealloc
{
    // release any resources here
    
    [Media releaseAtlas];
    [Media releaseSound];
    
}

- (void)setup
{
    [SPAudioEngine start];  // starts up the sound engine
    
    [Media initAtlas];      // loads your texture atlas -> see Media.h/Media.m
    [Media initSound];      // loads all your sounds    -> see Media.h/Media.m
    
    self.texture = [SPTexture textureWithContentsOfFile:@"blowfish.png"];
    
    SPQuad *background = [SPQuad quadWithWidth:mGameWidth height:mGameHeight color:0x000000];
    background.pivotX = background.width / 2;
    background.pivotY = background.height / 2;
    background.x = mGameWidth / 2;
    background.y = mGameHeight / 2;
    [self addChild:background];
    [background addEventListener:@selector(onTouched:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
    
    self.label = [[SPTextField alloc] initWithWidth:280 height:80 text:@"" fontName:@"Marker Felt" fontSize:18 color:0xffffff];
    self.label.x = (mGameWidth - self.label.width) / 2;
    self.label.y = (mGameHeight / 2) - 175;
    self.label.touchable = NO;
    [self addChild:self.label];
    
    self.fpsLabel = [[SPTextField alloc] initWithWidth:280 height:80 text:@"" fontName:@"Marker Felt" fontSize:18 color:0xffffff];
    self.fpsLabel.x = (mGameWidth - self.label.width) / 2;
    self.fpsLabel.y = (mGameHeight / 2) - 145;
    self.fpsLabel.touchable = NO;
    [self addChild:self.fpsLabel];
    
    [self addEventListener:@selector(onEnterFrame:) atObject:self forType:SP_EVENT_TYPE_ENTER_FRAME];
}

- (void)setupMovement:(SPImage*) sprite
{
    SPTween *nextTween = [SPTween tweenWithTarget:sprite time:rand() % 2 + 1];
    [nextTween moveToX:rand() % (int)mGameWidth y:rand() % (int)mGameHeight];
    [nextTween addEventListener:@selector(onMovementEnd:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
    [[SPStage mainStage].juggler addObject:nextTween];
}

- (void)onMovementEnd:(SPEvent*)event
{
    SPTween *tween = (SPTween*)event.target;
    SPImage *sprite = (SPImage*)tween.target;
    
    [self setupMovement:sprite];
}

- (void)onTouched:(SPTouchEvent *)event
{
    SPTouch *touch = [event.touches anyObject];
    if (touch.phase == SPTouchPhaseBegan)
    {
        for(int i = 0; i < NUM_SPRITES; i++)
        {
            SPImage *sprite = [SPImage imageWithTexture:self.texture];
            sprite.touchable = NO;
            sprite.pivotX = sprite.width / 2;
            sprite.pivotY = sprite.height / 2;
            
            // set random position
            sprite.x = rand() % (int)mGameWidth;
            sprite.y = rand() % (int)mGameHeight;
            
            if (ANIMATE)
            {
                // set continuous scaling
                sprite.scaleX = sprite.scaleY = 0;
                SPTween *tween = [SPTween tweenWithTarget:sprite time:rand() % 2 + 1];
                [tween scaleTo:3];
                tween.loop = SPLoopTypeReverse;
                [[SPStage mainStage].juggler addObject:tween];
                
                tween = [SPTween tweenWithTarget:sprite time:rand() % 2 + 1];
                [tween animateProperty:@"rotation" targetValue:SP_D2R(360)];
                tween.loop = SPLoopTypeRepeat;
                [[SPStage mainStage].juggler addObject:tween];
                
                [self setupMovement:sprite];
            }
            
            [self addChild:sprite atIndex:1];
            
            _spriteCount++;
        }
    
        self.label.text = [NSString stringWithFormat:@"Sprites: %d", _spriteCount];
    }
}

- (void)onEnterFrame:(SPEnterFrameEvent *)event
{
    static int frameCount = 0;
    static double totalTime = 0;
    totalTime += event.passedTime;
    if (++frameCount % 30 == 0)
    {
        self.fpsLabel.text = [NSString stringWithFormat:@"fps: %0.0f", (frameCount / totalTime)];
        frameCount = totalTime = 0;
    }
}

@end
