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
    int D = atoi(argv[2]);
    int W = atoi(argv[3]);

    uint8_t *data = (uint8_t *) malloc(D*sizeof(uint8_t));
    uint8_t *hash = (uint8_t *) malloc(K*sizeof(uint8_t));
    uint8_t *res = (uint8_t *) malloc(K*sizeof(uint8_t));

    string data_str;
    string hash_str;

    SHA *s = new SHA();

    for (int i=0; i<W; i++)
    {
        getline(data_file,data_str);
        getline(hash_file,hash_str);
        get_string(data_str,data,D);
        get(hash_str,hash,K);
        cout << "Data Length: " << D << endl;
        cout << "Data: ";
        for (int i=0; i<D; i++)
            printf("%02x",data[i]);
        cout << endl;
        if (K==20)
        {
            s->SHA1(data,D,res);
        }
        else if (K==28)
        {
            s->SHA224(data,D,res);
        }
        else if (K==32)
        {
            s->SHA256(data,D,res);
        }
        else if (K==48)
        {
            s->SHA384(data,D,res);
        }
        else if (K==64)
        {
            s->SHA512(data,D,res);
        }
        cout << "Key Length: " << K << endl;
        compare(res,hash,K);
    }

    return 0;
}
