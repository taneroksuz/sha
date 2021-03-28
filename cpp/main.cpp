#include "sha.h"
#include <fstream>
#include <iostream>

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
    printf("Hash: ");
    for (int i=0; i<num; i=i+1)
    {
        printf("%02x",in[i]);
    }
    printf("\n");
    printf("Correct: ");
    for (int i=0; i<num; i=i+1)
    {
        printf("%02x",out[i]);
    }
    printf("\n");
    printf("Hash ");
    if (res)
        printf("success!\n");
    else
        printf("failed!\n");
}

int main(int argc, char *argv[])
{
  ifstream data_file("data.txt", fstream::in);
  ifstream hash_file("hash.txt", fstream::in);

  int K = atoi(argv[1])/8;
  int W = atoi(argv[2]);

  uint8_t *dat = (uint8_t *) malloc(K*sizeof(uint8_t));
  uint8_t *has = (uint8_t *) malloc(K*sizeof(uint8_t));
  uint8_t *sha = (uint8_t *) malloc(K*sizeof(uint8_t));

  string data_str;
  string hash_str;

  for (int i=0; i<W; i++)
  {
      getline(data_file,data_str);
      getline(hash_file,hash_str);
      get(data_str,dat,K);
      get(hash_str,has,K);
      compare(dat,has,K);
  }

  return 0;
}
