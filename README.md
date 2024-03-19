# LoRaPHY.jl: Physical Layer Package for Long Range Communication in Julia

This Julia package provides a comprehensive implementation of a LoRA (Long Range) Physical Layer (PHY) with Hamming encoding, interleaving, CSS modulation, and associated decoding algorithms. LoRA technology is known for its efficient long-range communication capabilities, making it ideal for IoT (Internet of Things) and other low-power, wide-area network applications.

## Installation

You can install this package by using the Julia package manager. From the Julia REPL (Read-Eval-Print Loop), type the following in Pgk mode

```julia
] add LoRaPHY
```

or equally

```julia
julia> using Pkg; Pkg.add("LoRaPHY")
```

## Usage

A minimal transmitter-receiver can be found in `example/tx_rx.jl`

```
# Number of LoRa symbols to transmit 
N = 128 
# Spreading factor used in LoRa 
SF = 7 
# Bandwidth and frequency used 
# < Note that the values are not that important; this is Fs/B that matters>
BW  = 125e3
Fs  = BW 
snr = 0 # In dB
# --- LoRa Encoding 
sig, bitSeq, bitEnc, bitInter = loraEncode(N, SF, BW, Fs, 0)
# --- Channel 
sigNoise, _ = addNoise(sig, snr)
# --- LoRa Decoding 
bitDec, bitPreFec, bitPreInterl = loraDecode(sigNoise, SF, BW, Fs, 0)
# --- BER calculation 
ber = sum(xor.(bitDec, bitSeq)) / length(bitSeq)
```

This creates a binary sequence, modulates with LoRa, and applies some additive white Gaussian noise. The Bit Error Rate can be deduced by calculating the number of differences between the emitted sequence and the received one.

The important LoRa parameters are as follows:
- `SF` is the Spreading Factor as defined in the LoRa norm: a value between 7 and 12.
- `BW` is the bandwidth: The LoRa devices can use 125, 250, or 500kHz, but the LoRaWAN standard mandates 125k for data rates 1 to 5, and 250k for DR6
- `Fs` sampling frequency: this should be a multiple of `BW` (or Fs=BW to have no oversampling)

### Modulation

If you already have a binary sequence `bitSeq` (an array of 0 and 1) and you want to modulate this binary sequence, you can do the following:

```
# Spreading factor used in LoRa 
SF = 7 
# Number of LoRa symbols to transmit 
N = 128 
# Number of bits to transmit 
nbBits = N * SF 
bitSeq = Int.(randn(nbBits) .> 0) #  A vector of binary elements
# Bandwidth and frequency used 
BW  = 125e3
Fs  = BW
# --- LoRa Encoding 
sig, bitSeq, bitEnc, bitInter = loraEncode(bitSeq, SF, BW, Fs, 0)
```

The output parameters are:
- `sig`: LoRa signal as a complex vector in the time domain.
- `bitSeq`: Binary sequence (info bits) used for generation (of size `N x SF`)
- `bitEnc`: Sequence of bits after Hamming74 encoding (of size `N / 4 x 7`)
- `bitInter`: Sequence of bits after Hamming74 encoding and interleaver (of size `N / 4 x 7`)

### Demodulation

To decode a received signal, follow these steps:

```
# Number of LoRa symbols to transmit 
# Spreading factor used in LoRa 
SF = 7 
# Bandwidth and frequency used 
BW  = 125e3
Fs  = BW
bitDec, bitPreFec, bitPreInterl = loraDecode(sigNoise, SF, BW, Fs, 0)
```

The output parameters are:
- `bitDec`: Decoded binary sequence (matches `bitSeq` if no noise)
- `bitDec`: Binary sequence before Hamming74 decoder (matches `bitEnc` if no noise)
- `bitPreInterl`: Binary sequence before Deinterleaver (matches `bitInter` if no noise)

### Example for Bit Error Rate Calculation

An example of a Bit Error Rate calculation versus signal-to-noise ratio (SNR) in an additive white Gaussian noise (AWGN) process is given in `example/perf_awgn.jl`

Performance matches the theory (theoretical Symbol Error Rate (SER) formula is given in `src/Theoretical.jl`) from [1,2]. This script requires `DigitalComm.jl` for noise application and `PGFPLotsX.jl` for displaying the results.

Simulated performance matches theory as demonstrated by the following performance 

![](./examples/Lora_BER_SF.pdf)


[1] J. Courjault, B. Vrigneau, O. Berder and M. R. Bhatnagar, "A Computable Form for LoRa Performance Estimation: Application to Ricean and Nakagami Fading," in IEEE Access, vol. 9, pp. 81601-81611, 2021, doi: 10.1109/ACCESS.2021.3074704.
[2] J. Courjault, B. Vrigneau, M. Gautier and O. Berder, "Accurate LoRa Performance Evaluation Using Marcum Function," 2019 IEEE Global Communications Conference (GLOBECOM), Waikoloa, HI, USA, 2019, pp. 1-5, doi: 10.1109/GLOBECOM38437.2019.9014148.



### Use with Software Defined Radio 


If you want to transmit a LoRa signal with a Software Defined Radio, you can use `AbstractSDRs.jl` with a compatible device 

```
# --- Dependencies
using LoRaPHY 
using AbstractSDRs
# ----------------------------------------------------
# --- LoRa configuration   
# ---------------------------------------------------- 
# Spreading factor used in LoRa 
SF = 7 
# Number of LoRa symbols to transmit 
N = SF*4*2 
bitSeq = Int.(randn(N) .> 0) #  A vector of binary elements
# Bandwidth and frequency used 
BW  = 125e3
Fs  = BW * 20
# --- LoRa Encoding 
sig, bitSeq, bitEnc, bitInter = loraEncode(bitSeq, SF, BW, Fs, 0)
# --- Normalization 
sig .= sig * (1-2^-15) # With some radio signal has to be normalized but < 1. Ensure this can be a Q(16,0,15)
# ----------------------------------------------------
# --- SDR configuration   
# ---------------------------------------------------- 
radio          = :pluto 
carrierFreq  = 868e6 
gain = 10 
samplingRate = Fs   # If your radio does not support low datarate use a Fs in LoRa that is a multiple of BW and compatible with your SDR 
kw = (;) # Additionnal arguments such as SDR address, ...
sdr = openSDR(radio,carrierFreq,samplingRate,gain;kw...)   
# ----------------------------------------------------
# --- Transmit    
# ---------------------------------------------------- 
nbB = 0
try 
    @info "Type <c-c> to interrupt"
    while true 
        send(sdr,sig)
        global nbB += 1 
    end
    catch exception 
        @info "Interruption"
        display(exception)
end
close(sdr)
@info "Transmit $(nbB) LoRa bursts"
```
