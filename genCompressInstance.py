import sys
import numpy as np
from itertools import chain

fname = sys.argv[1]
chl = int(sys.argv[2])
nch = int(sys.argv[3])
bit = int(sys.argv[4])
hidden = int(sys.argv[5])

bits = 8*chl
assert bit < bits

nlen = len(str(2**bits-1))

def bytes2bits(b):
    return np.unpackbits(np.fromiter(b, dtype=np.uint8))

def chunks(fname, nch, chl):
    with open(fname, 'rb') as f:
        for _ in range(nch):
            yield bytes2bits(f.read(chl))
            #state = sum(0xFF**i * byte for i,byte in enumerate(chunk))
            #yield state, chunk[0] >= 0x80

def ch2s(ch):
 return "".join(map(str, ch))

def forAsp(fname):
    gen = chunks(fname, nch+1, chl)
    prev = next(gen)
    print(f"nvars({bits+hidden}).")
    print(f"hidden({hidden}).")
    for i, chunk in enumerate(gen):
        v = "obs" if chunk[bit] else "-obs"
        s = 's'+ch2s(prev)
        print(f"{v}({s}).")
        for i,b in enumerate(reversed(prev)):
            s2 = 'bit' if b==1 else '-bit'
            print(f"{s2}({s},{i}).")
        prev = chunk

def forAspMulti(fname):
    gen = chunks(fname, nch+1, chl)
    prev = next(gen)
    print(f"nvars({bits+hidden}).")
    print(f"hidden({hidden}).")
    for i, chunk in enumerate(gen):
        s = f'o{i}'
        for bit in range(bits):
            v = "obs" if chunk[bit] else "-obs"
            print(f"{v}({s},{bit}).")
        for i,b in enumerate(reversed(prev)):
            s2 = 'bit' if b==1 else '-bit'
            print(f"{s2}({s},{i}).")
        prev = chunk


def forEspresso(fname):
    gen = chunks(fname, nch+1, chl)
    prev = next(gen)
    print(f".i {bits}")
    print(f".o 1")
    print(f".p {nch}")
    for chunk in gen:
        print(f"{ch2s(prev)}|{chunk[bit]}")
        prev = chunk
    print(".e")

def forMealyBit(fname):
    assert chl == 1
    gen = chain.from_iterable(chunks(fname, (nch+1)//8, chl))
    print(f"symbolRepresentationBits(1).")
    print(f"iterations({nch}).")
    for i, bit in enumerate(gen):
        if bit:
            print(f"desired({i+1}).")

forMealyBit(fname)

