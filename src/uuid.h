#pragma once

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdint.h>

#define Uuid unsigned __int128

// Generate a UUID-v4
extern Uuid uuid_v4();

// Generate a UUID-v7
extern Uuid uuid_v7();

// Create a URN from a UUID
//
// The caller owns the returned URN and is expected
// to free it as soon as it is no longer needed.
extern uint8_t* to_urn(Uuid);

#ifdef __cplusplus
}
#endif
