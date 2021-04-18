#ifndef AES_H
#define AES_H

#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <cstdio>
#include <cerrno>
#include <fstream>
#include <iostream>

using namespace std;

class SHA
{
  private:

    template <class T> T ROTL(T x, int n);

    template <class T> T ROTR(T x, int n);

    template <class T> T SHR(T x, int n);

    template <class T> T ADD(T x, T y);

    template <class T> T Ch(T x, T y, T z);

    template <class T> T Maj(T x, T y, T z);

    template <class T> T Parity(T x, T y, T z);

    template <class T> T f(T x, T y, T z, int t);

    template <class T> T SIGMA(T x, int t, int k);

    template <class T> T sigma(T x, int t, int k);

    uint32_t K_1(int t);

    template <class T> int massage_block(uint8_t *in, int length, T **massage);

    template <class T> void SHA_ALGORITHM(int N, T *H, T *M, T *K);

  public:

    void SHA1(uint8_t *in, int length, uint8_t *out);

    void SHA224(uint8_t *in, int length, uint8_t *out);

    void SHA256(uint8_t *in, int length, uint8_t *out);

    void SHA384(uint8_t *in, int length, uint8_t *out);

    void SHA512(uint8_t *in, int length, uint8_t *out);

    void SHA512_224(uint8_t *in, int length, uint8_t *out);

    void SHA512_256(uint8_t *in, int length, uint8_t *out);

};

#endif
