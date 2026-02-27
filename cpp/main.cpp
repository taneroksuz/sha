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

void get_string(string in,uint8_t *out, int num)
{
    for (int i=0; i<num; i=i+1)
    {
        out[i] = (uint8_t) in[i];
    }
}

void compare(uint8_t *in,uint8_t *out, int num)
{
    bool res = true;
    for (int i=0; i<num; i=i+1)
    {
        if (in[i] != out[i])
        {
            res = false;
            break;
        }
    }
    if (num == 32)
    {
        printf("\x1B[1;34m[SHA256] HASH:\x1B[0m ");
        for (int i=0; i<num; i=i+1)
        {
            printf("%02x",in[i]);
        }
        printf("\n");
        printf("\x1B[1;34m[SHA256] ORIG:\x1B[0m ");
        for (int i=0; i<num; i=i+1)
        {
            printf("%02x",out[i]);
        }
    }
    else
    {
        printf("\x1B[1;34m[SHA512] HASH:\x1B[0m ");
        for (int i=0; i<num; i=i+1)
        {
            printf("%02x",in[i]);
        }
        printf("\n");
        printf("\x1B[1;34m[SHA512] ORIG:\x1B[0m ");
        for (int i=0; i<num; i=i+1)
        {
            printf("%02x",out[i]);
        }
    }
    printf("\n");
    if (res)
        printf("\x1B[1;32mTEST SUCCEEDED\x1B[0m\n");
    else
        printf("\x1B[1;31mTEST FAILED\x1B[0m\n");
}

int main(int argc, char *argv[])
{
    ifstream data_file("./out/plaintext.hex", fstream::in);
    ifstream sha256_hash_file("./out/sha256.hex", fstream::in);
    ifstream sha512_hash_file("./out/sha512.hex", fstream::in);

    int D = atoi(argv[1]);

    uint8_t *data = (uint8_t *) malloc(D*sizeof(uint8_t));

    string data_str;

    getline(data_file,data_str);
    get(data_str,data,D);

    SHA *s = new SHA();

    int K = 32;

    uint8_t *sha256_hash = (uint8_t *) malloc(K*sizeof(uint8_t));
    uint8_t *sha256_res = (uint8_t *) malloc(K*sizeof(uint8_t));

    string sha256_hash_str;

    getline(sha256_hash_file,sha256_hash_str);
    get(sha256_hash_str,sha256_hash,K);
    s->SHA256(data,D,sha256_res);
    compare(sha256_res,sha256_hash,K);

    K = 64;

    uint8_t *sha512_hash = (uint8_t *) malloc(K*sizeof(uint8_t));
    uint8_t *sha512_res = (uint8_t *) malloc(K*sizeof(uint8_t));

    string sha512_hash_str;

    getline(sha512_hash_file,sha512_hash_str);
    get(sha512_hash_str,sha512_hash,K);
    s->SHA512(data,D,sha512_res);
    compare(sha512_res,sha512_hash,K);

    return 0;
}
