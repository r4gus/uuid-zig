#include "uuid.h"
#include <stdlib.h>
#include <stdio.h>

int main()
{
    Uuid v4;
    uint8_t* v4_urn;

    v4 = uuid_v4();
    v4_urn = to_urn(v4);
    if (!v4_urn) {
        printf("error: unable to allocate memory for v4_urn\n");
        return 1;
    }

    printf("%s\n", v4_urn);

    free(v4_urn);

    return 0;
}

