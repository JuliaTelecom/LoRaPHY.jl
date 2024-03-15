# module Tx
function loraEncode(bitSeq::AbstractVector,SF,BW,Fs,inverse=0)
    # Ensure that number of symbols is divided by 4 
    @assert mod(length(bitSeq),4) == 0 "Bit sequence should have length with mutiple of 4 and given size is $(length(bitSeq))"
    @assert mod(length(bitSeq),SF) == 0 "Bit sequence should have length with mutiple of SF ($SF) and given size is $(length(bitSeq))"
    # Hamming encoding 
    bitEnc = hammingEncode(bitSeq) 
    # Interleaver 
    bitInter = interleaver(bitEnc,SF)
    # Gray encoding 
    symbols   = grayencode.(bin2dec(bitInter))
    nbSymbols = length(symbols) 
    # Modulation 
    num_samples = Int64(floor(Fs*(2^SF)/BW));  # Number of samples
    sig = zeros(ComplexF64,Int(num_samples * nbSymbols))
    for k ∈ 1 : nbSymbols
        _sig = modulation(symbols[k],SF,BW,Fs,inverse)
        sig[ (k-1)*num_samples .+ (1:num_samples)] .= _sig 
    end 
    return sig,bitSeq,bitEnc,bitInter
end


"""
Generate LoRa symbols 
sig,bitSeq,bitEnc,bitInter = loraEncode(N,SF,BW,Fs,inverse)
# Input
- N: Number of block to transmit, a block correspond to SF LoRa symbols
- SF: Spreading factor of the CSS modulation
- BW: Bandwidth used for transmission
- Fs: sampling frequency
- inverse: 0 to send upchirp, 1 for downchirp
# Output
- sig : Baseband  signal emitted from the transmitter (complex form)
- bitSeq : randomly generated binary data (Payload message)
- bitEnc : Binary sequence after Hamming encoding 
- bitInterl : Binary sequence after interleaving

Dispatch method : 
sig,bitSeq,bitEnc,bitInter = lora_encode(bitSeq,SF,BW,Fs,inverse) \\
- Uses a payload message bitSeq (must be of size N x SF x 4)
"""
function loraEncode(nbSymb::Int,SF,BW,Fs,inverse=0)
    N       = SF*nbSymb;
    bitSeq  = Int.(randn(4*N) .> 0)
    sig,bitSeq,bitEnc,bitInter     = loraEncode(bitSeq::AbstractVector,SF,BW,Fs,inverse)
    return sig,bitSeq,bitEnc,bitInter
end



"""
Do the CSS modulation
"""
function modulation(symbol,SF,BW,Fs,inverse)
    num_samples = Int64(floor(Fs*(2^SF)/BW));  # Number of samples
    #initialization
    phase = 0;
    Frequency_Offset = (Fs/2) - (BW/2);

    shift = symbol;
    out_preamble = zeros(ComplexF64,num_samples);

    for k = 1:num_samples
        # output the complex signal
        out_preamble[k] = cos(phase) + 1im*sin(phase);
    
        # Frequency from cyclic shift
        f = BW*shift/(2^SF);
        if(inverse == 1)
               f = BW - f;
        end
    
        # apply Frequency offset away from DC
        f = f + Frequency_Offset;
    
        # Increase the phase according to frequency
        phase = phase + 2*pi*f/Fs;
        if phase > pi
            phase = phase - 2*pi;
        end
    
        # update cyclic shift
        shift = shift + BW/Fs;
        if shift >= (2^SF)
            shift = shift - 2^SF;
        end
    end
    return out_preamble
end

