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

    template <class T> T ROTR(T x, int n);

    template <class T> T SHR(T x, int n);

    template <class T> T CH(T x, T y, T z);

    template <class T> T MAJ(T x, T y, T z);

    template <class T> T BIGSIGMA(T x, int t, int k);

    template <class T> T SMALLSIGMA(T x, int t, int k);

    template <class T> int MASSAGE_BLOCK(uint8_t *in, int length, T **massage);

    template <class T> void SHA_ALGORITHM(int N, T *H, T *M, T *K);

  public:

    void SHA256(uint8_t *in, int length, uint8_t *out);

    void SHA512(uint8_t *in, int length, uint8_t *out);

};

#endif
