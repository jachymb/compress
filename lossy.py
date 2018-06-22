import numpy as np
from scipy.stats import entropy

with open("/home/jachym/Downloads/enwik8", "rb") as f:
    data = np.fromiter(f.read(2**16), dtype=np.uint8)

def compress(data, drop):
    return np.array(np.fft.fft(data)[:len(data)-drop], np.complex128)

def decompress(data, origlen):
    return np.array(np.round(np.abs(np.fft.ifft(np.concatenate((data, np.zeros(origlen-len(data), dtype=np.complex128)))))), dtype=np.uint8)

def centropy(compressed, orig):
    recovered = decompress(compressed, len(orig))
    return entropy(np.bincount(recovered-orig, minlength=256), base=256)

def quality(compressed, orig):
    h = centropy(compressed, orig)
    return len(compressed)/len(orig) + h

def permute(data, permutation=None):
    new = np.empty(len(data), dtype=np.uint8)
    if permutation is None:
        permutation = np.array(np.random.permutation(256), np.uint8)
    for i, b in enumerate(data):
        new[i] = permutation[b]
    return new, permutation

def heurperm(data):
    return np.array(np.argsort(np.bincount(data,minlength=256)), dtype=np.uint8)

def experiment(data):
    best = np.inf, np.arange(256, dtype=np.uint8)
    while True:
        orig, permutation = permute(data)
        compressed = compress(data, 65280)
        h = quality(compressed, orig)
        if h < best[0]:
            best = h, permutation
            print(best)

