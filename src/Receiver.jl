"""
"""
function demodulation(sigrecu::Vector{Complex{T}},SF,BW,Fs,num_samples,inverse) where T
    # inverse = 1;
    lora_total_sym = length(sigrecu) ÷ num_samples
    out_reverse =  modulation(0,SF,BW,Fs,1-inverse)
    decoded_out = similar(sigrecu)
    Symbols = zeros(Int64,lora_total_sym);
    result = zeros(Complex{T},num_samples)
    win = similar(result)
    plan = plan_fft(result;flags=FFTW.PATIENT)
    container_abs = zeros(T,num_samples)
    for m = 1:1:lora_total_sym
        win =  sigrecu[((m-1)*num_samples) .+ (1 : num_samples)] .* out_reverse
        decoded_out[ ((m-1)*num_samples) .+ (1:num_samples) ] .= win
        mul!(result,plan,win) # THIS IS AN FFT
        container_abs .=  abs2.( result )
        posindex = argmax(container_abs) - 1 
        Symbols[m] = posindex
    end
    
    return Symbols
end

"""
"""
function loraDecode(sigrecu::Vector{Complex{T}},SF,BW,Fs,inverse) where T
    num_samples = Int64(floor(Fs*(2^SF)/BW))
    data_received = demodulation(sigrecu,SF,BW,Fs,num_samples,inverse) # symbols after CSS demodulation
    # Output = dec2gray(data_received); # symbols after Gray decoding
    output = graydecode.(data_received)[:]
    bitPreInterl = dec2bin(output,SF)[:] # zeros(Int, length(Output), SF)
    N = Int(length(output)/7)
    bitPreFec = deInterleaver(bitPreInterl,SF) # De-interleaving
    bitDec = hammingDecode(bitPreFec) # Hamming decoding
    return bitDec,bitPreFec,bitPreInterl
end


