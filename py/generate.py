#!/usr/bin/env python3

import os
import argparse
import random
import string

from base64 import b64encode
import secrets
import codecs
import hashlib
import base64

parser = argparse.ArgumentParser()
parser.add_argument("-k","--key_length", help="length of key in bits", type=int)
parser.add_argument("-d","--data_length", help="length of data in bits", type=int)
parser.add_argument("-w","--word_number", help="number of words in bits", type=int)

args = parser.parse_args()

if (args.key_length != 160) and (args.key_length != 224) and (args.key_length != 256) and (args.key_length != 384) and (args.key_length != 512):
    print("Key length: ",args.key_length," is invalid!")
    exit(1)
if (args.word_number is None) or (args.word_number<1):
    print("Word number: ",args.word_number," is invalid!")
    exit(1)


d = open("data.txt", "w")
e = open("hash.txt", "w")
for i in range(args.word_number):
    data = ''.join(random.choices(string.ascii_letters + string.digits, k=args.data_length))
    if args.key_length == 160:
        hash = hashlib.sha1(data.encode('ascii'))
    elif args.key_length == 224:
        hash = hashlib.sha224(data.encode('ascii'))
    elif args.key_length == 256:
        hash = hashlib.sha256(data.encode('ascii'))
    elif args.key_length == 384:
        hash = hashlib.sha384(data.encode('ascii'))
    elif args.key_length == 512:
        hash = hashlib.sha512(data.encode('ascii'))
    d.writelines(data+"\n")
    e.writelines(hash.hexdigest()+"\n")
d.close()
e.close()
