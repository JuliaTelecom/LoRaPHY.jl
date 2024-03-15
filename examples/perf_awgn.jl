using LoRaPHY
using ProgressMeter
import DigitalComm: addNoise
using PGFPlotsX
using ColorSchemes


# Bandwidth and frequency used 
# < Note that the value are not that important, this is Fs/B that matters >
Fs = 125e3
BW = Fs

""" Single realisation for N LoRa symbol for a given SNR. Returns current SNR value, number of erroneous bits and number of bits 
"""
function atomic_ber(N, SF, Fs, BW, snr)
    # --- LoRa Encoding 
    sig, bitSeq, bitEnc, bitInter = loraEncode(N, SF, BW, Fs, 0)
    # --- Channel 
    sigNoise, _ = addNoise(sig, snr)
    # --- LoRa Decoding 
    bitDec, bitPreFec, bitPreInterl = loraDecode(sigNoise, SF, BW, Fs, 0)
    # --- Performance metrics 
    # BER 
    nbBits = length(bitSeq)
    nbErr = sum(xor.(bitDec, bitSeq))
    return (snr, nbErr, nbBits)
end

""" Monte Carlo BER calculation for different SNR values in `snrVect`. LoRa is parametrized by its spreading factor `SF`, the bandwidth and the sampling frqeuency 
"""
function BER_AWGN(snrVect, SF, Fs, BW)
    # Symbol per iteration 
    N = 128
    # Stopping criterion 
    nb_err_max = 1e4
    nb_bit_max = 1e6
    berV = zeros(Float64, length(snrVect)) # Bit Error Rate 
    perV = zeros(Float64, length(snrVect)) # Packet Error Rate 
    @showprogress Threads.@threads for iSnr in eachindex(snrVect)
        # Current SNR 
        snr = snrVect[iSnr]
        # Counters 
        c_b = 0 # Bits 
        c_be = 0 # Bits with error
        # MC run 
        while (c_be < nb_err_max)
            # Atomic run 
            (snr, nbErr, nbBits) = atomic_ber(N, SF, Fs, BW, snr)
            # Update counter 
            c_b += nbBits
            c_be += nbErr
            # Break if we have enough bits 
            (c_b > nb_bit_max) && break
        end
        berV[iSnr] = c_be / c_b
    end
    return berV
end
# --- Define SNR 
snrVect = range(-30, stop=-5, length=55)
# --- Define Spreading factor
sfVect = [7; 8; 9; 10; 11; 12]


@pgf a = Axis({
    height = "3in",
    width = "4in",
    ymode = "log",
    grid,
    ymin = 1e-6,
    xmin = snrVect[1],
    xmax = snrVect[end],
    xlabel = "SNR [dB]",
    ylabel = "Bit Error Rate ",
    legend_style = "{at={(0,0)},anchor=south west,legend cell align=left,align=left,draw=white!15!black}"
},
)
dictColor   = ColorSchemes.tableau_superfishel_stone
dictMarker  = ["square*","triangle*","diamond*","*","pentagon*","o","otimes","triangle*"];


for (iSf,sf) in enumerate(sfVect)
    @info "Processing SF = $sf"
    # --- Calculate BER 
    ber = BER_AWGN(snrVect, sf, Fs, BW)
    # -- Theoretical PER 
    per_theo = [LoRaPHY.AWGN_SEP_theo_hamming74(sf, 5, snr) for snr in snrVect]
    ber_theo = (2^(sf - 1)) / (2^sf - 1) * per_theo
    # Update plot 
    @pgf push!(a, Plot({color = dictColor[iSf], mark = dictMarker[iSf]}, Table([snrVect, ber])))
    @pgf push!(a, LegendEntry("SF = $sf"))
    @pgf push!(a, Plot({color = "black",forget_plot}, Table([snrVect, ber_theo])))
    display(a)
end







