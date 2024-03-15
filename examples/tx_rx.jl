using LoRaPHY
import DigitalComm: addNoise



# Number of LoRa symbols to transmit 
N = 128 
# Spreading factor used in LoRa 
SF = 7 
# Bandwidth and frequency used 
# < Note that the value are not that important, this is Fs/B that matters>
BW  = 125e3
Fs  = BW
snr = 0 # In dB
# --- LoRa Encoding 
sig,bitSeq,bitEnc,bitInter = loraEncode(N,SF,BW,Fs,0)
# --- Channel 
sigNoise,_ = addNoise(sig,snr)
# --- LoRa Decoding 
bitDec,bitPreFec,bitPreInterl = loraDecode(sigNoise,SF,BW,Fs,0)
# --- BER calculation 
ber = sum(xor.(bitDec,bitSeq)) / length(bitSeq)