import sys
import numpy as np

fname = sys.argv[1]
chl = int(sys.argv[2])
nch = int(sys.argv[3])
bit = int(sys.argv[4])

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
    print(f"nvars({bits}).")
    for chunk in gen:
        v = "posObs" if chunk[0] else "negObs"
        s = 's'+ch2s(prev)
        print(f"{v}({s}).")
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

forEspresso(fname)

