/*
 *
 *	Added (Vector2*) cast to get rid of Methods with same name warning
 *	--Per 100222
 *
 */

#import "Vector2.h"
#import <SPSuccinct/SPSuccinct.h>

#import <math.h>
#import <memory.h>

Vec2 makeVec2(float x, float y)
{
	Vec2 v;
	v.x = x;
	v.y = y;
	
	return v;
}

static Vector2 *zero;
static Vector2 *xAxis;
static Vector2 *yAxis;
static Vector2 *negativeXAxis;
static Vector2 *negativeYAxis;

#define X v[0]
#define Y v[1]

@implementation Vector2

- (float)x;
{
	return X;
}

- (float)y;
{
	return Y;
}

+ (void)initialize;
{
	zero = [[Vector2 alloc] init];
	xAxis = [[Vector2 alloc] initWithX:1 y:0];
	yAxis = [[Vector2 alloc] initWithX:0 y:1];
	negativeXAxis = [[Vector2 alloc] initWithX:-1 y:0];
	negativeYAxis = [[Vector2 alloc] initWithX:0 y:-1];
}

+ (Vector2*)zero;
{
	return zero;
}

+ (Vector2*)xAxis;
{
	return xAxis;
}

+ (Vector2*)yAxis;
{
	return yAxis;
}

+ (Vector2*)negativeXAxis;
{
	return negativeXAxis;
}

+ (Vector2*)negativeYAxis;
{
	return negativeYAxis;
}

- (instancetype)init;
{
	return [self initWithX:0 y:0];
}

- (instancetype)initWithX:(float)x y:(float)y;
{
    if(!(self = [super init])) return nil;
    
	float *vals = malloc(sizeof (float) * 2);
	vals[0] = x;
	vals[1] = y;
	
	if (![self initWithMemory:vals memoryResponsibility:Vector2MemoryResponsibilityFree])
	{
		free(vals);
		return nil;
	}
	
	return self;
}

- (instancetype)initWithMemory:(float*)vals memoryResponsibility:(Vector2MemoryResponsibility)responsibility_;
{
	responsibility = responsibility_;
	
	if (responsibility == Vector2MemoryResponsibilityCopy)
		return [self initWithX:vals[0] y:vals[1]];
	
	v = vals;
	
	return self;
}

- (instancetype)initWithVector2:(Vector2*)vector;
{
	return [self initWithX:vector->X y:vector->Y];
}

- (instancetype)initWithVec2:(Vec2)vec;
{
	return [self initWithX:vec.x y:vec.y];
}

- (instancetype)initWithScalar:(float)scalar;
{
	return [self initWithX:scalar y:scalar];
}

- (instancetype)initWithPoint:(CGPoint)p;
{
    return [self initWithX:p.x y:p.y];
}

- (instancetype)initWithRep:(NSDictionary*)rep;
{
    return [self initWithX:[[rep objectForKey:@"x"] floatValue] y:[[rep objectForKey:@"y"] floatValue]];
}
- (NSDictionary*)rep;
{
    return $dict(@"x", $numf(X), @"y", $numf(Y));
}

- (void)dealloc;
{
	if (responsibility == Vector2MemoryResponsibilityFree)
		free(v);
	
	[super dealloc];
}

+ (instancetype)vector;
{
	return [[[[self class] alloc] init] autorelease];
}

+ (instancetype)vectorWithX:(float)x y:(float)y;
{
	return [[[[self class] alloc] initWithX:x y:y] autorelease];
}

+ (instancetype)vectorWithMemory:(float*)vals memoryResponsibility:(Vector2MemoryResponsibility)responsibility_;
{
	return [[[[self class] alloc] initWithMemory:vals memoryResponsibility:responsibility_] autorelease];
}

+ (instancetype)vectorWithVector2:(Vector2*)vector;
{
	return [[[[self class] alloc] initWithVector2:vector] autorelease];
}

+ (instancetype)vectorWithVec2:(Vec2)vec;
{
	return [[[[self class] alloc] initWithVec2:vec] autorelease];
}

+ (instancetype)vectorWithScalar:(float)scalar;
{
	return [[[[self class] alloc] initWithScalar:scalar] autorelease];
}

+ (instancetype)vectorWithPoint:(CGPoint)p;
{
    return [[[[self class] alloc] initWithPoint:p] autorelease];
}

- (instancetype)copyWithZone:(NSZone*)zone;
{
	return [self retain];
}

- (instancetype)mutableCopyWithZone:(NSZone*)zone;
{
	return [[MutableVector2 alloc] initWithVector2:self];
}

- (BOOL)isEqual:(Vector2*)vector;
{
    if(![vector isKindOfClass:[Vector2 class]])
        return NO;
	return X == vector->X && Y == vector->Y;
}

- (NSComparisonResult)compare:(Vector2*)vector;
{
    if(![vector isKindOfClass:[Vector2 class]])
        return NSOrderedAscending;
    
	float l = [self squaredLength];
	float r = [vector squaredLength];
	
	if (l < r)
		return NSOrderedAscending;
	else if (l > r)
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}
- (NSUInteger)hash
{
    return [@(X) hash] ^ [@(Y) hash];
}

- (float)coord:(NSUInteger)coord;
{
	NSAssert(2 > coord, @"Illegal coordinate");
	return *(v + coord);
}

- (const float*)coordsPtr;
{
	return v;
}

- (const float*)coordsPtr:(NSUInteger)coord;
{
	NSAssert(2 > coord, @"Illegal coordinate");
	return (v + coord);
}

- (CGPoint)point
{
    return CGPointMake(self.x, self.y);
}

- (instancetype)vectorByAddingVector:(Vector2*)rhs;
{
	return [[self class] vectorWithX:X + rhs->X y:Y + rhs->Y];
}

- (instancetype)vectorByAddingScalar:(float)rhs;
{
	return [[self class] vectorWithX:X + rhs y:Y + rhs];
}

- (instancetype)vectorBySubtractingVector:(Vector2*)rhs;
{
	return [[self class] vectorWithX:X - rhs->X y:Y - rhs->Y];
}

- (instancetype)vectorBySubtractingScalar:(float)rhs;
{
	return [[self class] vectorWithX:X - rhs y:Y - rhs];
}

- (instancetype)vectorByMultiplyingWithVector:(Vector2*)rhs;
{
	return [[self class] vectorWithX:X * rhs->X y:Y * rhs->Y];
}

- (instancetype)vectorByMultiplyingWithScalar:(float)rhs;
{
	return [[self class] vectorWithX:X * rhs y:Y * rhs];
}

- (instancetype)vectorByDividingWithVector:(Vector2*)rhs;
{
	return [[self class] vectorWithX:X / rhs->X y:Y / rhs->Y];
}

- (instancetype)vectorByDividingWithScalar:(float)rhs;
{
	return [[self class] vectorWithX:X / rhs y:Y / rhs];
}

- (instancetype)leftHandNormal;
{
	return [[Vector2 vectorWithX:-[self y] y:[self x]] normalizedVector];
}
- (instancetype)rightHandNormal;
{
	return [[Vector2 vectorWithX:[self y] y:-[self x]] normalizedVector];
}

- (float)dotProduct:(Vector2*)rhs;
{
	return X * rhs->X + Y * rhs->Y;
}

- (float)crossProduct:(Vector2*)rhs;
{
	return X * rhs->Y - Y * rhs->X;
}

- (instancetype)vectorByProjectingOnto:(Vector2*)other
{
    return
        [other vectorByMultiplyingWithScalar:
            [other scalarProductWith:self]/
            ([other length]*[other length])
         ];
}

- (instancetype)invertedVector;
{
	return [[self class] vectorWithX:-X y:-Y];
}

- (instancetype)normalizedVector;
{
	float invLen = 1.0 / [self length];
	return [[self class] vectorWithX:X * invLen y:Y * invLen];
}
- (instancetype)integralVector
{
    return [[self class] vectorWithX:floor(self.x) y:floor(self.y)];
}

- (float)length;
{
	return sqrtf(X * X + Y * Y);
}

- (float)squaredLength;
{
	return X * X + Y * Y;
}

- (float)scalarProductWith:(Vector2*)other;
{
    float sum = 0.0;
    for(unsigned i = 0; i < 2; i++)
        sum += v[i]*other->v[i];
    
    return sum;
}

- (float)distance:(Vector2*)vector;
{
	return [(Vector2*)[self vectorBySubtractingVector:vector] length];
}

- (float)squaredDistance:(Vector2*)vector;
{
	return [[self vectorBySubtractingVector:vector] squaredLength];
}

- (instancetype)reflect:(Vector2*)normal;
{
	return [self vectorBySubtractingVector:[normal vectorByMultiplyingWithScalar:([self dotProduct:normal] * 2)]];
}

- (instancetype)midPoint:(Vector2*)vector;
{
	return [[self class] vectorWithX:(X + vector->X) * 0.5 y:(Y + vector->Y) * 0.5];
}

-(double)angleFrom:(Vector2*)other;
{
    return acos([[self normalizedVector] dotProduct:[other normalizedVector]]);
}


- (NSString*)description;
{
	return [NSString stringWithFormat:@"(%.4f, %.4f)", X, Y];
}

@end

@implementation MutableVector2

@dynamic x;
@dynamic y;

- (void)setX:(float)x;
{
	X = x;
}

- (void)setY:(float)y;
{
	Y = y;
}

- (void)setCoord:(NSUInteger)coord value:(float)value;
{
	NSAssert(2 > coord, @"Illegal coordinate");
	*(v + coord) = value;
}

- (float*)mutableCoordsPtr;
{
	return v;
}

- (float*)mutableCoordsPtr:(NSUInteger)coord;
{
	NSAssert(2 > coord, @"Illegal coordinate");
	return v + coord;
}

- (instancetype)addVector:(Vector2*)rhs;
{
	X += rhs->X;
	Y += rhs->Y;
	
	return self;
}

- (instancetype)addScalar:(float)rhs;
{
	X += rhs;
	Y += rhs;
	
	return self;
}

- (instancetype)subtractVector:(Vector2*)rhs;
{
	X -= rhs->X;
	Y -= rhs->Y;
	
	return self;
}

- (instancetype)subtractScalar:(float)rhs;
{
	X -= rhs;
	Y -= rhs;
	
	return self;
}

- (instancetype)multiplyWithVector:(Vector2*)rhs;
{
	X *= rhs->X;
	Y *= rhs->Y;
	
	return self;
}

- (instancetype)multiplyWithScalar:(float)rhs;
{
	X *= rhs;
	Y *= rhs;
	
	return self;
}

- (instancetype)divideWithVector:(Vector2*)rhs;
{
	X /= rhs->X;
	Y /= rhs->Y;
	
	return self;
}

- (instancetype)divideWithScalar:(float)rhs;
{
	X /= rhs;
	Y /= rhs;
	
	return self;
}

- (instancetype)invert;
{
	X = -X;
	Y = -Y;
	
	return self;
}

- (instancetype)normalize;
{
	float invLen = 1.0 / [self length];
	
	X *= invLen;
	Y *= invLen;
	
	return self;
}
- (instancetype)makeIntegral;
{
    X = floor(X);
    Y = floor(Y);
    
    return self;
}

@end
