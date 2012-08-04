#define ProtoAssert(sck, condition, ...) ({ \
	if(!(condition)) { \
		NSLog(@"Protocol assertion failed in %@: " #condition ": %@", NSStringFromSelector(_cmd), [NSString stringWithFormat:__VA_ARGS__]);\
		[sck disconnect];\
		return; \
	} \
})

#define $protoCast(remote, klass, thing) ({ \
	klass *thing2 = (klass*)(thing); \
	ProtoAssert(remote, [thing isKindOfClass:[klass class]], @"Unexpected type"); \
	thing2; \
})