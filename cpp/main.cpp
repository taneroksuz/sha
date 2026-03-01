#include "sha.h"

using namespace std;

uint8_t hex(char c)
{
    uint8_t res = (uint8_t) c;
    if (c <= '9' && c >= '0')
    {
        res = res - 48;
    }
    else if (c <= 'f' && c >= 'a')
    {
        res = res - 87;
    }
    else if (c <= 'F' && c >= 'A')
    {
        res = res - 55;
    }
    return res;
}

void get(string in,uint8_t *out, int num)
{
    for (int i=0; i<num; i=i+1)
    {
        out[i] = hex(in[2*i]);
        out[i] <<= 0x4;
        out[i] += hex(in[2*i+1]);
    }
}


void compare(uint8_t *computed, uint8_t *expected, int num, const char *label)
{
    bool res = true;
    for (int i = 0; i < num; i++)
    {
        if (computed[i] != expected[i])
        {
            res = false;
            break;
        }
    }

    printf("\x1B[1;34m[%s] HASH:\x1B[0m ", label);
    for (int i = 0; i < num; i++)
        printf("%02x", computed[i]);
    printf("\n");

    printf("\x1B[1;34m[%s] ORIG:\x1B[0m ", label);
    for (int i = 0; i < num; i++)
        printf("%02x", expected[i]);
    printf("\n");

    if (res)
        printf("\x1B[1;32mTEST SUCCEEDED\x1B[0m\n");
    else
        printf("\x1B[1;31mTEST FAILED\x1B[0m\n");

    printf("\n");
}

int main(int argc, char *argv[])
{
    if (argc < 2)
    {
        fprintf(stderr, "Usage: %s <PLAINTEXT_BYTES>\n", argv[0]);
        return 1;
    }

    int D = atoi(argv[1]);

    ifstream data_file       ("./out/plaintext.hex", fstream::in);
    ifstream sha256_hash_file("./out/sha256.hex",    fstream::in);
    ifstream sha512_hash_file("./out/sha512.hex",    fstream::in);

    if (!data_file.is_open())        { fprintf(stderr, "Error: cannot open ./out/plaintext.hex\n"); return 1; }
    if (!sha256_hash_file.is_open()) { fprintf(stderr, "Error: cannot open ./out/sha256.hex\n");    return 1; }
    if (!sha512_hash_file.is_open()) { fprintf(stderr, "Error: cannot open ./out/sha512.hex\n");    return 1; }

    uint8_t *data = (uint8_t *) malloc(D * sizeof(uint8_t));
    string data_str;
    getline(data_file, data_str);
    get(data_str, data, D);

    SHA *s = new SHA();

    int K;
    string hash_str;
    uint8_t *hash_ref;
    uint8_t *hash_res;

    K        = 32;
    hash_ref = (uint8_t *) malloc(K * sizeof(uint8_t));
    hash_res = (uint8_t *) malloc(K * sizeof(uint8_t));
    getline(sha256_hash_file, hash_str);
    get(hash_str, hash_ref, K);
    s->SHA256(data, D, hash_res);
    compare(hash_res, hash_ref, K, "SHA256");
    free(hash_ref); free(hash_res);

    K        = 64;
    hash_ref = (uint8_t *) malloc(K * sizeof(uint8_t));
    hash_res = (uint8_t *) malloc(K * sizeof(uint8_t));
    getline(sha512_hash_file, hash_str);
    get(hash_str, hash_ref, K);
    s->SHA512(data, D, hash_res);
    compare(hash_res, hash_ref, K, "SHA512");
    free(hash_ref); free(hash_res);

    free(data);
    delete s;

    return 0;
}
