"""
Minimal one-hot encoder example for NLP basics.

Run:
  pwsh> python .\03_ReferenceLibrary\02_AI-and-ML\04_NaturalLanguageProcessing\01_Basics\examples\one_hot.py
  pwsh> python .\03_ReferenceLibrary\02_AI-and-ML\04_NaturalLanguageProcessing\01_Basics\examples\one_hot.py "i like pizza"
"""

from typing import Dict, List, Tuple


def one_hot(tokens: List[str]) -> Tuple[List[List[int]], List[str], Dict[str, int]]:
    """Return a one-hot matrix for the given tokens with (matrix, vocab, index).

    - matrix: list of rows (one row per token in order)
    - vocab: sorted list of unique tokens
    - index: mapping token -> column index in the matrix
    """
    vocab = sorted(set(tokens))
    index = {w: i for i, w in enumerate(vocab)}
    matrix: List[List[int]] = []
    for t in tokens:
        row = [0] * len(vocab)
        row[index[t]] = 1
        matrix.append(row)
    return matrix, vocab, index


def demo(sentence: str = "i like pizza") -> None:
    tokens = sentence.lower().split()
    mat, vocab, idx = one_hot(tokens)
    print("vocab:", vocab)
    print("index:", idx)
    print("matrix:")
    for r in mat:
        print(r)


if __name__ == "__main__":
    import sys

    demo(" ".join(sys.argv[1:]) if len(sys.argv) > 1 else "i like pizza")
