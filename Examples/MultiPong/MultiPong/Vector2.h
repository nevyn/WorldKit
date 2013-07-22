typedef struct
{
	float x, y;
} Vec2;

Vec2 makeVec2(float x, float y);

typedef enum
{
	Vector2MemoryResponsibilityFree,
	Vector2MemoryResponsibilityCopy,
	Vector2MemoryResponsibilityNone
} Vector2MemoryResponsibility;

@interface Vector2 : NSObject <NSCopying, NSMutableCopying>
{
	float *v;
	Vector2MemoryResponsibility responsibility;
}

@property(readonly, nonatomic) float x;
@property(readonly, nonatomic) float y;

+ (Vector2*)zero;
+ (Vector2*)xAxis;
+ (Vector2*)yAxis;
+ (Vector2*)negativeXAxis;
+ (Vector2*)negativeYAxis;

- (instancetype)init;
- (instancetype)initWithX:(float)x y:(float)y;
- (instancetype)initWithMemory:(float*)vals memoryResponsibility:(Vector2MemoryResponsibility)responsibility_;
- (instancetype)initWithVector2:(Vector2*)vector;
- (instancetype)initWithVec2:(Vec2)vec;
- (instancetype)initWithScalar:(float)scalar;
- (instancetype)initWithPoint:(CGPoint)p;
- (instancetype)initWithRep:(NSDictionary*)rep;
- (NSDictionary*)rep;

- (void)dealloc;

+ (instancetype)vector;
+ (instancetype)vectorWithX:(float)x y:(float)y;
+ (instancetype)vectorWithMemory:(float*)vals memoryResponsibility:(Vector2MemoryResponsibility)responsibility_;
+ (instancetype)vectorWithVector2:(Vector2*)vector;
+ (instancetype)vectorWithVec2:(Vec2)vec;
+ (instancetype)vectorWithScalar:(float)scalar;
+ (instancetype)vectorWithPoint:(CGPoint)p;

- (instancetype)copyWithZone:(NSZone*)zone;
- (instancetype)mutableCopyWithZone:(NSZone*)zone;


- (BOOL)isEqual:(Vector2*)vector;
- (NSComparisonResult)compare:(Vector2*)vector;
- (NSUInteger)hash;

- (float)coord:(NSUInteger)coord;

- (const float*)coordsPtr;
- (const float*)coordsPtr:(NSUInteger)coord;
- (CGPoint)point;

- (instancetype)vectorByAddingVector:(Vector2*)rhs;
- (instancetype)vectorByAddingScalar:(float)rhs;
- (instancetype)vectorBySubtractingVector:(Vector2*)rhs;
- (instancetype)vectorBySubtractingScalar:(float)rhs;
- (instancetype)vectorByMultiplyingWithVector:(Vector2*)rhs;
- (instancetype)vectorByMultiplyingWithScalar:(float)rhs;
- (instancetype)vectorByDividingWithVector:(Vector2*)rhs;
- (instancetype)vectorByDividingWithScalar:(float)rhs;

- (instancetype)leftHandNormal;
- (instancetype)rightHandNormal;

- (float)dotProduct:(Vector2*)rhs;
- (float)crossProduct:(Vector2*)rhs;

- (instancetype)vectorByProjectingOnto:(Vector2*)other;

- (instancetype)invertedVector;
- (instancetype)normalizedVector;
- (instancetype)integralVector;

- (float)length;
- (float)squaredLength;
- (float)scalarProductWith:(Vector2*)other;

- (float)distance:(Vector2*)vector;
- (float)squaredDistance:(Vector2*)vector;

- (instancetype)reflect:(Vector2*)normal;
- (instancetype)midPoint:(Vector2*)vector;

// Anti-clockwise, in radians, 0° being vector pointing to the right.
-(double)angleFrom:(Vector2*)other;


- (NSString*)description;

@end

@interface MutableVector2 : Vector2
{
}

@property(readwrite, nonatomic) float x;
@property(readwrite, nonatomic) float y;

- (void)setCoord:(NSUInteger)coord value:(float)value;

- (float*)mutableCoordsPtr;
- (float*)mutableCoordsPtr:(NSUInteger)coord;

- (instancetype)addVector:(Vector2*)rhs;
- (instancetype)addScalar:(float)rhs;
- (instancetype)subtractVector:(Vector2*)rhs;
- (instancetype)subtractScalar:(float)rhs;
- (instancetype)multiplyWithVector:(Vector2*)rhs;
- (instancetype)multiplyWithScalar:(float)rhs;
- (instancetype)divideWithVector:(Vector2*)rhs;
- (instancetype)divideWithScalar:(float)rhs;

- (instancetype)invert;
- (instancetype)normalize;
- (instancetype)makeIntegral;

@end
