# Encoder–Decoder Architecture

The **encoder–decoder** (seq2seq) architecture maps input sequences to output sequences via two main components:

## 1. Components

- **Encoder:** Processes the input sequence \(x = (x_1, ..., x_T)\) and encodes it into a context vector or sequence of hidden states.
- **Decoder:** Generates the output sequence \(y = (y_1, ..., y_{T'})\) by conditioning on the encoder’s output and its own previous outputs.

## 2. Workflow

1. **Encoding Stage:**  
   - The encoder (e.g., RNN, LSTM, GRU, or Transformer encoder) ingests each input token and updates its hidden state.  
   - For RNN variants, the final hidden state serves as the context vector. For Transformers, all encoder outputs are passed to the decoder.
2. **Decoding Stage:**  
   - The decoder (RNN/Transformer decoder) uses the context vector or cross-attention over encoder outputs to produce one token at a time.  
   - Teacher forcing is often used during training: the ground-truth token is fed as input instead of the predicted token.

## 3. Attention Mechanism

- **Purpose:** Allows the decoder to focus on relevant parts of the input sequence at each time step.
- **Types:** Bahdanau (additive) attention, Luong (multiplicative/scaled dot-product) attention.

## 4. Transformer Variation

- Replaces recurrence with multi-head self-attention in both encoder and decoder.  
- Enables parallel processing of entire sequences and captures long-range dependencies efficiently.

## 5. Applications

- **Machine Translation:** Translating text between languages (e.g., English to French).  
- **Summarization:** Generating concise summaries from long documents.  
- **Image Captioning:** Encoding image features (via CNN) and decoding text descriptions.  
- **Speech Recognition:** Converting audio features into text sequences.

## 6. Advantages and Considerations

- **Advantages:** Flexibility for variable-length input/output, strong performance with attention.  
- **Limitations:** Computational cost for long sequences (mitigated by Transformers), exposure bias during decoding.
