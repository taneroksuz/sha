#include "sha.h"

using namespace std;

uint32_t K_256[64] = {
0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2};

uint64_t K_512[80] = {
0x428a2f98d728ae22, 0x7137449123ef65cd, 0xb5c0fbcfec4d3b2f, 0xe9b5dba58189dbbc, 0x3956c25bf348b538,
0x59f111f1b605d019, 0x923f82a4af194f9b, 0xab1c5ed5da6d8118, 0xd807aa98a3030242, 0x12835b0145706fbe,
0x243185be4ee4b28c, 0x550c7dc3d5ffb4e2, 0x72be5d74f27b896f, 0x80deb1fe3b1696b1, 0x9bdc06a725c71235,
0xc19bf174cf692694, 0xe49b69c19ef14ad2, 0xefbe4786384f25e3, 0x0fc19dc68b8cd5b5, 0x240ca1cc77ac9c65,
0x2de92c6f592b0275, 0x4a7484aa6ea6e483, 0x5cb0a9dcbd41fbd4, 0x76f988da831153b5, 0x983e5152ee66dfab,
0xa831c66d2db43210, 0xb00327c898fb213f, 0xbf597fc7beef0ee4, 0xc6e00bf33da88fc2, 0xd5a79147930aa725,
0x06ca6351e003826f, 0x142929670a0e6e70, 0x27b70a8546d22ffc, 0x2e1b21385c26c926, 0x4d2c6dfc5ac42aed,
0x53380d139d95b3df, 0x650a73548baf63de, 0x766a0abb3c77b2a8, 0x81c2c92e47edaee6, 0x92722c851482353b,
0xa2bfe8a14cf10364, 0xa81a664bbc423001, 0xc24b8b70d0f89791, 0xc76c51a30654be30, 0xd192e819d6ef5218,
0xd69906245565a910, 0xf40e35855771202a, 0x106aa07032bbd1b8, 0x19a4c116b8d2d0c8, 0x1e376c085141ab53,
0x2748774cdf8eeb99, 0x34b0bcb5e19b48a8, 0x391c0cb3c5c95a63, 0x4ed8aa4ae3418acb, 0x5b9cca4f7763e373,
0x682e6ff3d6b2b8a3, 0x748f82ee5defb2fc, 0x78a5636f43172f60, 0x84c87814a1f0ab72, 0x8cc702081a6439ec,
0x90befffa23631e28, 0xa4506cebde82bde9, 0xbef9a3f7b2c67915, 0xc67178f2e372532b, 0xca273eceea26619c,
0xd186b8c721c0c207, 0xeada7dd6cde0eb1e, 0xf57d4f7fee6ed178, 0x06f067aa72176fba, 0x0a637dc5a2c898a6,
0x113f9804bef90dae, 0x1b710b35131c471b, 0x28db77f523047d84, 0x32caab7b40c72493, 0x3c9ebe0a15c9bebc,
0x431d67c49c100d4c, 0x4cc5d4becb3e42b6, 0x597f299cfc657e2a, 0x5fcb6fab3ad6faec, 0x6c44198c4a475817};

uint32_t H_1[5] = {
0x67452301,
0xefcdab89,
0x98badcfe,
0x10325476,
0xc3d2e1f0};

uint32_t H_224[8] = {
0xc1059ed8,
0x367cd507,
0x3070dd17,
0xf70e5939,
0xffc00b31,
0x68581511,
0x64f98fa7,
0xbefa4fa4};

uint32_t H_256[8] = {
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
    return (x & y) ^ ((~x) & z);
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
        return Ch(x,y,z);
    }
    else if (t >=20 && t<=39)
    {
        return Parity(x,y,z);
    }
    else if (t >=40 && t<=59)
    {
        return Maj(x,y,z);
    }
    else
    {
        return Parity(x,y,z);
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

uint32_t SHA::K_1(int t)
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

template <class T> int SHA::massage_block(uint8_t *in, int length, T **massage)
{
    uint8_t word[sizeof(T)];
    T w;
    int rest;
    int index = 0;
    int div = (sizeof(T) == 8) ? 128 : 64;
    int n = length/div + (((div-(length%div)) <= 2*sizeof(T)) ? 2 : 1);
    int i,j,k = 0;
    T size = 0;
    *massage = (T *) malloc(n*div);
    for (i=0; i<n; i++)
    {
        for (j=0; j<16;j++)
        {
            if (index>length && i==(n-1))
            {
                rest = (112*sizeof(T)) - (8*sizeof(T)*j);
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
                for(k=0; k<sizeof(T); k++)
                {
                    word[k] = 0;
                }
                for(k=0; k<sizeof(T); k++)
                {
                    if (index == length)
                    {
                        word[k] = 0x80;
                    }
                    else if (index < length)
                    {
                        word[k] = in[index];
                        size = size + 8;
                    }
                    index = index + 1;
                }
                w = word[0];
                for(k=1; k<sizeof(T); k++)
                {
                    w <<= 8;
                    w |= word[k];
                }
            }
            (*massage)[16*i+j] = w;
        }
    }
    return n;
}

template <class T> void SHA::SHA_ALGORITHM(int N, T *H, T *M, T *K)
{
    int Tmax = sizeof(T) == 4 ? 64 : 80;
    int Bits = sizeof(T) == 4 ? 256 : 512;
    T W[Tmax];
    for (int i=0; i<N; i++)
    {
        for (int t=0; t<Tmax; t++)
        {
            if (t<16)
            {
                W[t] = M[16*i+t];
            }
            else
            {
                W[t] = sigma(W[t-2],1,Bits) + W[t-7] + sigma(W[t-15],0,Bits) + W[t-16];
            }

            // cout << "W[" << dec << t << "]: " << hex << W[t] << endl;
        }

        T a = H[0];
        T b = H[1];
        T c = H[2];
        T d = H[3];
        T e = H[4];
        T f = H[5];
        T g = H[6];
        T h = H[7];

        // cout << "a: " << hex << a << endl;
        // cout << "b: " << hex << b << endl;
        // cout << "c: " << hex << c << endl;
        // cout << "d: " << hex << d << endl;
        // cout << "e: " << hex << e << endl;
        // cout << "f: " << hex << f << endl;
        // cout << "g: " << hex << g << endl;
        // cout << "h: " << hex << h << endl;

        for (int t=0; t<Tmax; t++)
        {
            T T1 = h + SIGMA(e,1,Bits) + Ch(e,f,g)+ K[t] + W[t];
            T T2 = SIGMA(a,0,Bits) + Maj(a,b,c);
            h = g;
            g = f;
            f = e;
            e = d + T1;
            d = c;
            c = b;
            b = a;
            a = T1 + T2;

            // cout << "a: " << hex << a << endl;
            // cout << "b: " << hex << b << endl;
            // cout << "c: " << hex << c << endl;
            // cout << "d: " << hex << d << endl;
            // cout << "e: " << hex << e << endl;
            // cout << "f: " << hex << f << endl;
            // cout << "g: " << hex << g << endl;
            // cout << "h: " << hex << h << endl;
        }

        H[0] = a + H[0];
        H[1] = b + H[1];
        H[2] = c + H[2];
        H[3] = d + H[3];
        H[4] = e + H[4];
        H[5] = f + H[5];
        H[6] = g + H[6];
        H[7] = h + H[7];
    }
}

void SHA::SHA1(uint8_t *in, int length, uint8_t *out)
{
    int N;
    uint32_t *M;
    uint32_t W[80];
    uint32_t H[5] = {H_1[0],H_1[1],H_1[2],H_1[3],H_1[4]};

    N = massage_block(in,length,&M);

    for (int i=0; i<N; i++)
    {
        for (int t=0; t<80; t++)
        {
            if (t<16)
            {
                W[t] = M[16*i+t];
            }
            else
            {
                W[t] = ROTL((W[t-3] ^ W[t-8] ^ W[t-14] ^ W[t-16]),1);
            }
        }

        uint32_t a = H[0];
        uint32_t b = H[1];
        uint32_t c = H[2];
        uint32_t d = H[3];
        uint32_t e = H[4];

        for (int t=0; t<80; t++)
        {
            uint32_t T = ROTL(a,5) + f(b,c,d,t) + e + K_1(t) + W[t];
            e = d;
            d = c;
            c = ROTL(b,30);
            b = a;
            a = T;
        }

        H[0] = a + H[0];
        H[1] = b + H[1];
        H[2] = c + H[2];
        H[3] = d + H[3];
        H[4] = e + H[4];
    }

    for (int i=0; i<5; i++)
    {
        out[4*i] = (H[i] >> 24) & 0xFF;
        out[4*i+1] = (H[i] >> 16) & 0xFF;
        out[4*i+2] = (H[i] >> 8)  & 0xFF;
        out[4*i+3] = H[i]  & 0xFF;
    }

    free(M);
}

void SHA::SHA224(uint8_t *in, int length, uint8_t *out)
{
    int N;
    uint32_t *M;
    uint32_t H[8] = {H_224[0],H_224[1],H_224[2],H_224[3],H_224[4],H_224[5],H_224[6],H_224[7]};

    N = massage_block(in,length,&M);

    SHA_ALGORITHM(N,&H[0],&M[0],&K_256[0]);

    for (int i=0; i<7; i++)
    {
        out[4*i] = (H[i] >> 24)  & 0xFF;
        out[4*i+1] = (H[i] >> 16)  & 0xFF;
        out[4*i+2] = (H[i] >> 8)  & 0xFF;
        out[4*i+3] = H[i]  & 0xFF;
    }

    free(M);
}

void SHA::SHA256(uint8_t *in, int length, uint8_t *out)
{
    int N;
    uint32_t *M;
    uint32_t W[64];
    uint32_t H[8] = {H_256[0],H_256[1],H_256[2],H_256[3],H_256[4],H_256[5],H_256[6],H_256[7]};

    N = massage_block(in,length,&M);

    SHA_ALGORITHM(N,&H[0],&M[0],&K_256[0]);

    for (int i=0; i<8; i++)
    {
        out[4*i] = (H[i] >> 24)  & 0xFF;
        out[4*i+1] = (H[i] >> 16)  & 0xFF;
        out[4*i+2] = (H[i] >> 8)  & 0xFF;
        out[4*i+3] = H[i]  & 0xFF;
    }

    free(M);
}

void SHA::SHA384(uint8_t *in, int length, uint8_t *out)
{
    int N;
    uint64_t *M;
    uint64_t H[8] = {H_384[0],H_384[1],H_384[2],H_384[3],H_384[4],H_384[5],H_384[6],H_384[7]};

    N = massage_block(in,length,&M);

    SHA_ALGORITHM(N,&H[0],&M[0],&K_512[0]);

    for (int i=0; i<6; i++)
    {
        out[8*i] = (H[i] >> 56)  & 0xFF;
        out[8*i+1] = (H[i] >> 48)  & 0xFF;
        out[8*i+2] = (H[i] >> 40)  & 0xFF;
        out[8*i+3] = (H[i] >> 32)  & 0xFF;
        out[8*i+4] = (H[i] >> 24)  & 0xFF;
        out[8*i+5] = (H[i] >> 16)  & 0xFF;
        out[8*i+6] = (H[i] >> 8)  & 0xFF;
        out[8*i+7] = H[i]  & 0xFF;
    }

    free(M);
}

void SHA::SHA512(uint8_t *in, int length, uint8_t *out)
{
    int N;
    uint64_t *M;
    uint64_t H[8] = {H_512[0],H_512[1],H_512[2],H_512[3],H_512[4],H_512[5],H_512[6],H_512[7]};

    N = massage_block(in,length,&M);

    SHA_ALGORITHM(N,&H[0],&M[0],&K_512[0]);

    for (int i=0; i<8; i++)
    {
        out[8*i] = (H[i] >> 56)  & 0xFF;
        out[8*i+1] = (H[i] >> 48)  & 0xFF;
        out[8*i+2] = (H[i] >> 40)  & 0xFF;
        out[8*i+3] = (H[i] >> 32)  & 0xFF;
        out[8*i+4] = (H[i] >> 24)  & 0xFF;
        out[8*i+5] = (H[i] >> 16)  & 0xFF;
        out[8*i+6] = (H[i] >> 8)  & 0xFF;
        out[8*i+7] = H[i]  & 0xFF;
    }

    free(M);
}

void SHA::SHA512_224(uint8_t *in, int length, uint8_t *out)
{
    int N;
    uint64_t *M;
    uint64_t H[8] = {H_512_224[0],H_512_224[1],H_512_224[2],H_512_224[3],H_512_224[4],H_512_224[5],H_512_224[6],H_512_224[7]};

    N = massage_block(in,length,&M);

    SHA_ALGORITHM(N,&H[0],&M[0],&K_512[0]);

    for (int i=0; i<3; i++)
    {
        out[8*i] = (H[i] >> 56)  & 0xFF;
        out[8*i+1] = (H[i] >> 48)  & 0xFF;
        out[8*i+2] = (H[i] >> 40)  & 0xFF;
        out[8*i+3] = (H[i] >> 32)  & 0xFF;
        out[8*i+4] = (H[i] >> 24)  & 0xFF;
        out[8*i+5] = (H[i] >> 16)  & 0xFF;
        out[8*i+6] = (H[i] >> 8)  & 0xFF;
        out[8*i+7] = H[i]  & 0xFF;
    }

    out[24] = (H[3] >> 56)  & 0xFF;
    out[25] = (H[3] >> 48)  & 0xFF;
    out[26] = (H[3] >> 40)  & 0xFF;
    out[27] = (H[3] >> 32)  & 0xFF;

    free(M);
}


void SHA::SHA512_256(uint8_t *in, int length, uint8_t *out)
{
    int N;
    uint64_t *M;
    uint64_t H[8] = {H_512_256[0],H_512_256[1],H_512_256[2],H_512_256[3],H_512_256[4],H_512_256[5],H_512_256[6],H_512_256[7]};
    N = massage_block(in,length,&M);

    SHA_ALGORITHM(N,&H[0],&M[0],&K_512[0]);

    for (int i=0; i<4; i++)
    {
        out[8*i] = (H[i] >> 56)  & 0xFF;
        out[8*i+1] = (H[i] >> 48)  & 0xFF;
        out[8*i+2] = (H[i] >> 40)  & 0xFF;
        out[8*i+3] = (H[i] >> 32)  & 0xFF;
        out[8*i+4] = (H[i] >> 24)  & 0xFF;
        out[8*i+5] = (H[i] >> 16)  & 0xFF;
        out[8*i+6] = (H[i] >> 8)  & 0xFF;
        out[8*i+7] = H[i]  & 0xFF;
    }

    free(M);
}
