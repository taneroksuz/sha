#include "sha.h"

using namespace std;

uint32_t K_256[64] = {
0x428a2f98,0xd807aa98,0xe49b69c1,0x983e5152,0x27b70a85,0xa2bfe8a1,0x19a4c116,0x748f82ee,
0x71374491,0x12835b01,0xefbe4786,0xa831c66d,0x2e1b2138,0xa81a664b,0x1e376c08,0x78a5636f,
0xb5c0fbcf,0x243185be,0x0fc19dc6,0xb00327c8,0x4d2c6dfc,0xc24b8b70,0x2748774c,0x84c87814,
0xe9b5dba5,0x550c7dc3,0x240ca1cc,0xbf597fc7,0x53380d13,0xc76c51a3,0x34b0bcb5,0x8cc70208,
0x3956c25b,0x72be5d74,0x2de92c6f,0xc6e00bf3,0x650a7354,0xd192e819,0x391c0cb3,0x90befffa,
0x59f111f1,0x80deb1fe,0x4a7484aa,0xd5a79147,0x766a0abb,0xd6990624,0x4ed8aa4a,0xa4506ceb,
0x923f82a4,0x9bdc06a7,0x5cb0a9dc,0x06ca6351,0x81c2c92e,0xf40e3585,0x5b9cca4f,0xbef9a3f7,
0xab1c5ed5,0xc19bf174,0x76f988da,0x14292967,0x92722c85,0x106aa070,0x682e6ff3,0xc67178f2};

uint64_t K_512[80] = {
0x428a2f98d728ae22,0x3956c25bf348b538,0xd807aa98a3030242,0x72be5d74f27b896f,
0xe49b69c19ef14ad2,0x2de92c6f592b0275,0x983e5152ee66dfab,0xc6e00bf33da88fc2,
0x27b70a8546d22ffc,0x650a73548baf63de,0xa2bfe8a14cf10364,0xd192e819d6ef5218,
0x19a4c116b8d2d0c8,0x391c0cb3c5c95a63,0x748f82ee5defb2fc,0x90befffa23631e28,
0xca273eceea26619c,0x06f067aa72176fba,0x28db77f523047d84,0x4cc5d4becb3e42b6,
0x7137449123ef65cd,0x59f111f1b605d019,0x12835b0145706fbe,0x80deb1fe3b1696b1,
0xefbe4786384f25e3,0x4a7484aa6ea6e483,0xa831c66d2db43210,0xd5a79147930aa725,
0x2e1b21385c26c926,0x766a0abb3c77b2a8,0xa81a664bbc423001,0xd69906245565a910,
0x1e376c085141ab53,0x4ed8aa4ae3418acb,0x78a5636f43172f60,0xa4506cebde82bde9,
0xd186b8c721c0c207,0x0a637dc5a2c898a6,0x32caab7b40c72493,0x597f299cfc657e2a,
0xb5c0fbcfec4d3b2f,0x923f82a4af194f9b,0x243185be4ee4b28c,0x9bdc06a725c71235,
0x0fc19dc68b8cd5b5,0x5cb0a9dcbd41fbd4,0xb00327c898fb213f,0x06ca6351e003826f,
0x4d2c6dfc5ac42aed,0x81c2c92e47edaee6,0xc24b8b70d0f89791,0xf40e35855771202a,
0x2748774cdf8eeb99,0x5b9cca4f7763e373,0x84c87814a1f0ab72,0xbef9a3f7b2c67915,
0xeada7dd6cde0eb1e,0x113f9804bef90dae,0x3c9ebe0a15c9bebc,0x5fcb6fab3ad6faec,
0xe9b5dba58189dbbc,0xab1c5ed5da6d8118,0x550c7dc3d5ffb4e2,0xc19bf174cf692694,
0x240ca1cc77ac9c65,0x76f988da831153b5,0xbf597fc7beef0ee4,0x142929670a0e6e70,
0x53380d139d95b3df,0x92722c851482353b,0xc76c51a30654be30,0x106aa07032bbd1b8,
0x34b0bcb5e19b48a8,0x682e6ff3d6b2b8a3,0x8cc702081a6439ec,0xc67178f2e372532b,
0xf57d4f7fee6ed178,0x1b710b35131c471b,0x431d67c49c100d4c,0x6c44198c4a475817};

uint64_t H_1[5] = {
0x67452301,
0xefcdab89,
0x98badcfe,
0x10325476,
0xc3d2e1f0};

uint64_t H_224[8] = {
0xc1059ed8,
0x367cd507,
0x3070dd17,
0xf70e5939,
0xffc00b31,
0x68581511,
0x64f98fa7,
0xbefa4fa4};

uint64_t H_256[8] = {
0x6a09e667,
0xbb67ae85,
0x3c6ef372,
0xa54ff53a,
0x510e527f,
0x9b05688c,
0x1f83d9ab,
0x5be0cd19};

uint64_t H_384[8] = {
0xcbbb9d5dc1059ed8,
0x629a292a367cd507,
0x9159015a3070dd17,
0x152fecd8f70e5939,
0x67332667ffc00b31,
0x8eb44a8768581511,
0xdb0c2e0d64f98fa7,
0x47b5481dbefa4fa4};

uint64_t H_512[8] = {
0x6a09e667f3bcc908,
0xbb67ae8584caa73b,
0x3c6ef372fe94f82b,
0xa54ff53a5f1d36f1,
0x510e527fade682d1,
0x9b05688c2b3e6c1f,
0x1f83d9abfb41bd6b,
0x5be0cd19137e2179};

uint64_t H_512_224[8] = {
0x8C3D37C819544DA2,
0x73E1996689DCD4D6,
0x1DFAB7AE32FF9C82,
0x679DD514582F9FCF,
0x0F6D2B697BD44DA8,
0x77E36F7304C48942,
0x3F9D85A86A1D36C8,
0x1112E6AD91D692A1};

uint64_t H_512_256[8] = {
0x22312194FC2BF72C,
0x9F555FA3C84C64C2,
0x2393B86B6F53B151,
0x963877195940EABD,
0x96283EE2A88EFFE3,
0xBE5E1E2553863992,
0x2B0199FC2C85B8AA,
0x0EB72DDC81C52CA2};

template <class T> T SHA::ROTL(T x, int n)
{
    return ((x << n) | (x >> (8*sizeof(T) - n)));
}

template <class T> T SHA::ROTR(T x, int n)
{
    return ((x >> n) | (x << (8*sizeof(T) - n)));
}

template <class T> T SHA::SHR(T x, int n)
{
    return (x >> n);
}

template <class T> T SHA::ADD(T x, T y)
{
    return (x + y);
}

template <class T> T SHA::Ch(T x, T y, T z)
{
    return (x & y) ^ (~x & z);
}

template <class T> T SHA::Maj(T x, T y, T z)
{
    return (x & y) ^ (x & z) ^ (y & z);
}

template <class T> T SHA::Parity(T x, T y, T z)
{
    return (x ^ y ^ z);
}

template <class T> T SHA::f(T x, T y, T z, int t)
{
    if (t >=0 && t<=19)
    {
        return CH(x,y,z);
    }
    else if (t >=20 && t<=39)
    {
        return PARITY(x,y,z);
    }
    else if (t >=40 && t<=59)
    {
        return MAJ(x,y,z);
    }
    else
    {
        return PARITY(x,y,z);
    }
}

template <class T> T SHA::SIGMA(T x, int t, int k)
{
    if (k==256)
    {
        if (t == 0)
        {
            return ROTR(x,2) ^ ROTR(x,13) ^ ROTR(x,22);
        }
        else
        {
            return ROTR(x,6) ^ ROTR(x,11) ^ ROTR(x,25);
        }
    }
    else
    {
        if (t == 0)
        {
            return ROTR(x,28) ^ ROTR(x,34) ^ ROTR(x,39);
        }
        else
        {
            return ROTR(x,14) ^ ROTR(x,18) ^ ROTR(x,41);
        }
    }
}

template <class T> T SHA::sigma(T x, int t, int k)
{
    if (k==256)
    {
        if (t == 0)
        {
            return ROTR(x,7) ^ ROTR(x,18) ^ SHR(x,3);
        }
        else
        {
            return ROTR(x,17) ^ ROTR(x,19) ^ SHR(x,10);
        }
    }
    else
    {
        if (t == 0)
        {
            return ROTR(x,1) ^ ROTR(x,8) ^ SHR(x,7);
        }
        else
        {
            return ROTR(x,19) ^ ROTR(x,61) ^ SHR(x,6);
        }
    }
}

uint32_t SHA::K_1(int t, int k)
{
    if (t >=0 && t<=19)
    {
        return 0x5a827999;
    }
    else if (t >=20 && t<=39)
    {
        return 0x6ed9eba1;
    }
    else if (t >=40 && t<=59)
    {
        return 0x8f1bbcdc;
    }
    else
    {
        return 0xca62c1d6;
    }
}

int SHA::massage_block_512(uint8_t *in, int length, uint32_t (*massage)[16])
{
    uint8_t word[4];
    uint32_t w;
    int index;
    int rest;
    int n = 0;
    int i,j = 0;
    uint32_t size = 0;
    bool stop = false;
    massage = (uint32_t (*)[16]) malloc(sizeof(uint32_t[16]));
    while(1)
    {
        i = 0;
        while(i<16)
        {
            if (stop)
            {
                rest = 448 - (i*32 % 512);
                if (rest > 0)
                {
                    w = 0;
                }
                else if (rest == 0)
                {
                    w = 0;
                }
                else
                {
                    w = size;
                }
            }
            else
            {
                word[0] = 0;
                word[1] = 0;
                word[2] = 0;
                word[3] = 0;
                j = 0;
                while(j<4)
                {
                    index = 16*n+4*i+j;
                    if (index == length)
                    {
                        word[j] = 0x80;
                        stop = true;
                        break;
                    }
                    else
                    {
                        word[j] = in[index];
                        size = size + 8;
                    }
                    j = j + 1;
                }
                w = word[3];
                w <<= 8;
                w |= word[2];
                w <<= 8;
                w |= word[1];
                w <<= 8;
                w |= word[0];
            }
            massage[n][i] = w;
            printf("%08x\n",w);
            i = i + 1;
        }
        if (stop)
        {
            break;
        }
        else
        {
            n = n + 1;
            massage = (uint32_t (*)[16]) realloc(massage,sizeof(uint32_t[16])*(n+1));
        }
    }
    return n+1;
}

int SHA::massage_block_1024(uint8_t *in, int length, uint64_t (*massage)[16])
{
    uint8_t word[8];
    uint64_t w;
    int index;
    int rest;
    int n = 0;
    int i,j = 0;
    uint64_t size = 0;
    bool stop = false;
    massage = (uint64_t (*)[16]) malloc(sizeof(uint64_t[16]));
    while(1)
    {
        i = 0;
        while(i<16)
        {
            if (stop)
            {
                rest = 896 - (i*64 % 1024);
                if (rest > 0)
                {
                    w = 0;
                }
                else if (rest == 0)
                {
                    w = 0;
                }
                else
                {
                    w = size;
                }
            }
            else
            {
                word[0] = 0;
                word[1] = 0;
                word[2] = 0;
                word[3] = 0;
                word[4] = 0;
                word[5] = 0;
                word[6] = 0;
                word[7] = 0;
                j = 0;
                while(j<8)
                {
                    index = 16*n+8*i+j;
                    if (index == length)
                    {
                        word[j] = 0x80;
                        stop = true;
                        break;
                    }
                    else
                    {
                        word[j] = in[index];
                        size = size + 8;
                    }
                    j = j + 1;
                }
                w = word[7];
                w <<= 8;
                w |= word[6];
                w <<= 8;
                w |= word[5];
                w <<= 8;
                w |= word[4];
                w <<= 8;
                w |= word[3];
                w <<= 8;
                w |= word[2];
                w <<= 8;
                w |= word[1];
                w <<= 8;
                w |= word[0];
            }
            massage[n][i] = w;
            printf("%016lx\n",w);
            i = i + 1;
        }
        if (stop)
        {
            break;
        }
        else
        {
            n = n + 1;
            massage = (uint64_t (*)[16]) realloc(massage,sizeof(uint64_t[16])*(n+1));
        }
    }
    return n+1;
}

void SHA::SHA1(uint8_t *in, int length, uint8_t *out)
{
    int N;
    uint32_t (*massage)[16];
    N = massage_block_512(in,length,massage);
    printf("N: %i\n",N);
    free(massage);
}

void SHA::SHA224(uint8_t *in, int length, uint8_t *out)
{
    int N;
    uint64_t (*massage)[16];
    N = massage_block_1024(in,length,massage);
    printf("N: %i\n",N);
    free(massage);
}

void SHA::SHA256(uint8_t *in, int length, uint8_t *out)
{
    int N;
    uint64_t (*massage)[16];
    N = massage_block_1024(in,length,massage);
    printf("N: %i\n",N);
    free(massage);
}

void SHA::SHA384(uint8_t *in, int length, uint8_t *out)
{
    int N;
    uint64_t (*massage)[16];
    N = massage_block_1024(in,length,massage);
    printf("N: %i\n",N);
    free(massage);
}

void SHA::SHA512(uint8_t *in, int length, uint8_t *out)
{
    int N;
    uint64_t (*massage)[16];
    N = massage_block_1024(in,length,massage);
    printf("N: %i\n",N);
    free(massage);
}
