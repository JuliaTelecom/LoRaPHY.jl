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
Fs  = BW * 20 # Oversampling to have a fsampling supported by SDRs
# --- LoRa Encoding 
sig, bitSeq, bitEnc, bitInter = loraEncode(bitSeq, SF, BW, Fs, 0)
# --- Normalization 
sig .= sig * (1-2^-15)
# ----------------------------------------------------
# --- SDR configuration   
# ---------------------------------------------------- 
radio          = :pluto 
carrierFreq  = 868e6 
gain = 10 
samplingRate = Fs   # If your radio does not support low datarate use a Fs in LoRa that is a multiple of BW and compatible with your SDR 
kw = (;addr="usb:1.4.5") # Additionnal arguments such as SDR address, ...
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