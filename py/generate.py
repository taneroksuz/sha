#!/usr/bin/env python3

import os
import argparse

import secrets
import codecs
import hashlib
import base64

parser = argparse.ArgumentParser()
parser.add_argument("-k","--key_length", help="length of key in bits", type=int)
parser.add_argument("-w","--word_number", help="number of words in bits", type=int)

args = parser.parse_args()

if (args.key_length != 224) and (args.key_length != 256) and (args.key_length != 384) and (args.key_length != 512):
    print("Key length: ",args.key_length," is invalid!")
    exit(1)
if (args.word_number is None) or (args.word_number<1):
    print("Word number: ",args.word_number," is invalid!")
    exit(1)


d = open("data.txt", "w")
e = open("hash.txt", "w")
for i in range(args.word_number):
    if args.key_length == 224:
        data = os.urandom(28)
        hash = hashlib.sha224(data.hex().encode())
    elif args.key_length == 256:
        data = os.urandom(32)
        hash = hashlib.sha256(data.hex().encode())
    elif args.key_length == 384:
        data = os.urandom(48)
        hash = hashlib.sha384(data.hex().encode())
    elif args.key_length == 512:
        data = os.urandom(64)
        hash = hashlib.sha512(data.hex().encode())
    d.writelines(data.hex()+"\n")
    e.writelines(hash.hexdigest()+"\n")
d.close()
e.close()
