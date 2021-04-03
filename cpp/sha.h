#ifndef AES_H
#define AES_H

#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <cstdio>
#include <cerrno>

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

    template <class T> T SIGMA0_256(T x);

    template <class T> T SIGMA1_256(T x);

    template <class T> T SIGMA0_512(T x);

    template <class T> T SIGMA1_512(T x);

    template <class T> T sigma0_256(T x);

    template <class T> T sigma1_256(T x);

    template <class T> T sigma0_512(T x);

    template <class T> T sigma1_512(T x);

    uint32_t K_1(int t);

    int massage_block_512(uint8_t *in, int length, uint32_t (**massage)[16]);

    int massage_block_1024(uint8_t *in, int length, uint64_t (**massage)[16]);

  public:

    void SHA1(uint8_t *in, int length, uint8_t *out);

    void SHA224(uint8_t *in, int length, uint8_t *out);

    void SHA256(uint8_t *in, int length, uint8_t *out);

    void SHA384(uint8_t *in, int length, uint8_t *out);

    void SHA512(uint8_t *in, int length, uint8_t *out);

};

#endif
