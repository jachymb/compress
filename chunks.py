import sys
from itertools import zip_longest, count
from functools import reduce, partial
from operator import add, sub
from collections import Counter

def diff(l):
    return map(sub, l[1:], l)

def shufmod(b, n):
    return reduce(add, (b[i::n] for i in range(n)))

def iterbits(b):
    bits = 0b1, 0b10, 0b100, 0b1000, 0b10000, 0b100000, 0b1000000, 0b10000000
    for c in b:
        yield from (bit & c > 0 for bit in bits)

def grouper(n, iterable, fillvalue=None):
    args = [iter(iterable)] * n
    return zip_longest(fillvalue=fillvalue, *args)

def checkrestarts(data, l):
    g = grouper(l, data, 0)
    s = {}
    for i, (ch1, ch2) in enumerate(grouper(2, g)):
        if not s:
            yield ch1, 0
        if ch1 in s and s[ch1] != ch2:
            yield ch2, i
        else:
            s[ch1] = ch2
    return s

def checkl(data, l):
    g = grouper(l, data, 0)
    s = set()
    #for i, ch in enumerate(g):
    for ch in g:
        if ch in s:
            return False
        s.add(ch)
    return True

def checklc(data, l):
    g = grouper(l, data, 0)
    s = Counter()
    #for i, ch in enumerate(g):
    for ch in g:
        s[ch] += 1
    return s

def findl(data):
    #return next(filter(partial(checkl, data), count(1)))
    for l in count(1):
        if checkl(data, l):
            return l

with open(sys.argv[1], 'rb') as f:
    data = f.read()

#results = []
#for c in count(1):
#    r = checkrestarts(iterbits(data), c)
#    l = sum(1 for _ in r)
#    print(c, l)
#    results.append(l)
#print(findl(data))
