


function interleaver(bitSeq::AbstractVector{T},SF) where T
    # reshape per symbol 
    nbBit = length(bitSeq)
    @assert mod(nbBit,7) == 0 "Number of bits after hamming should be divisible by 7 [$(nbBit) is not]"
    nbWord = nbBit ÷ 7  # Number of symbols 
    nbSymb = nbWord ÷ SF
    matSymb = reshape(bitSeq,7,nbWord)
    matInter= zeros(T,nbSymb*7,SF)
    for k ∈ 1:nbSymb # interleaver
        matInter[(k-1)*7 + 1 : 7*k,:] = matSymb[:,SF*(k-1) + 1 : SF*k]
    end
    return matInter 
end


function deInterleaver(bitInter::AbstractVector{T},SF) where T
    nbWord = length(bitInter) ÷ 7 # Number of symbols
    nbSymb = nbWord ÷ SF  
    output  = zeros(T, 7, nbWord)
    bitInterM = reshape(bitInter,nbSymb*7,SF)
    for k ∈ 1 : nbSymb #deinterleave
        output[:,SF*(k-1) + 1 : SF*k] = bitInterM[(k-1)*7 + 1 : 7*k,:]
    end
    return output[:]
end
