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

    template <class T> T SIGMA(T x, int t, int k);

    template <class T> T sigma(T x, int t, int k);

    uint32_t K(int t, int k);

  public:

    void SHA224(uint8_t *in, uint8_t *out);

    void SHA256(uint8_t *in, uint8_t *out);

    void SHA384(uint8_t *in, uint8_t *out);

    void SHA512(uint8_t *in, uint8_t *out);

};

#endif
