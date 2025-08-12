from typing import List, Dict, Tuple


def one_hot(tokens: List[str]) -> Tuple[list[list[int]], List[str], Dict[str, int]]:
    vocab = sorted(set(tokens))
    index = {w: i for i, w in enumerate(vocab)}
    matrix = []
    for t in tokens:
        row = [0] * len(vocab)
        row[index[t]] = 1
        matrix.append(row)
    return matrix, vocab, index


if __name__ == "__main__":
    sentence = "i like pizza"
    tokens = sentence.split()
    mat, vocab, idx = one_hot(tokens)
    print("vocab:", vocab)
    print("index:", idx)
    print("matrix:")
    for r in mat:
        print(r)
