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

    printf("v4: %s\n", v4_urn);


    Uuid v5;
    uint8_t* v5_urn;

    v5 = uuid_v5(v4, "Some name, this could be any pointer to a null terminated array of bytes");
    v5_urn = to_urn(v5);
    if (!v5_urn) {
        printf("error: unable to allocate memory for v5_urn\n");
        return 1;
    }

    printf("v5: %s\n", v5_urn);

    free(v4_urn);
    free(v5_urn);
    return 0;
}

