#pragma once

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdint.h>

#define Uuid unsigned __int128

extern Uuid uuid_v4();
extern Uuid uuid_v7();
extern uint8_t* to_urn(Uuid);

#ifdef __cplusplus
}
#endif
