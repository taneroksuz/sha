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
parser.add_argument("-d","--msg_length", help="length of data in bits", type=int)
parser.add_argument("-w","--case_number", help="number of words in bits", type=int)

args = parser.parse_args()

if (args.key_length != 0) and (args.key_length != 1) and (args.key_length != 2):
    print("Key length: ",args.key_length," is invalid!")
    exit(1)
if (args.case_number is None) or (args.case_number<1):
    print("Word number: ",args.case_number," is invalid!")
    exit(1)


d = open("data.txt", "w")
e = open("hash.txt", "w")
for i in range(args.case_number):
    data = ''.join(random.choices(string.ascii_letters + string.digits, k=args.msg_length))
    if args.key_length == 0:
        hash = hashlib.sha1(data.encode('ascii'))
    elif args.key_length == 1:
        hash = hashlib.sha256(data.encode('ascii'))
    elif args.key_length == 2:
        hash = hashlib.sha512(data.encode('ascii'))
    d.writelines(data+"\n")
    e.writelines(hash.hexdigest()+"\n")
d.close()
e.close()
