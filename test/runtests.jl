using LoRaPHY
using Test

const SFVect = [7;8;9;10;11;12]

# Test cases for Gray encoding
@testset "Gray Encoding Tests" begin
    @testset "Binary to Gray Encoding/Decoding" begin
        LoRaPHY.grayencode(1) == 1 
        LoRaPHY.grayencode(3) == 2
        for n ∈ 1:1024 
            @test n === LoRaPHY.graydecode(LoRaPHY.grayencode(n))
        end
    end
end


# Test for Hamming74 encoding
@testset "Hamming FEC scheme" begin 
    bitSeq = [1;1;0;1]
    bitEnc = LoRaPHY.hammingEncode(bitSeq)
    bitDec = LoRaPHY.hammingDecode(bitEnc)

    @test length(bitEnc) == 7
    @test length(bitDec) == 4
    @test all(bitSeq .== bitDec)

    bitEncFalse = bitEnc
    LoRaPHY.bitflip!(bitEncFalse,2)
    bitDec = LoRaPHY.hammingDecode(bitEncFalse)
    @test length(bitEncFalse) == 7
    @test length(bitDec) == 4
    @test all(bitSeq .== bitDec)

    # --- One error, we detect and correct one error 
    for n ∈ 1 : 7
        bitEncFalse = bitEnc
        LoRaPHY.bitflip!(bitEncFalse,n)
        bitDec2 = similar(bitDec)
        nbErr = LoRaPHY.hammingDecode!(bitDec2,bitEncFalse)
        @test nbErr == 1
        @test all(bitSeq .== bitDec2)
    end
end



@testset "Interleaver" begin 
    for SF in SFVect 
        N = SF*100;
        bitSeq = Int.(randn(4*N) .> 0)
        bitEnc = LoRaPHY.hammingEncode(bitSeq)
        bitInterl = LoRaPHY.interleaver(bitEnc,SF)[:]
        bitDeInterl = LoRaPHY.deInterleaver(bitInterl,SF)
        @test all(bitDeInterl[:] .== bitEnc[:])
    end
end


@testset "LoRa Tx//Rx" begin
    for SF in SFVect 
        N = 100;
        sig,bitSeq,bitEnc,bitInter = loraEncode(N,SF,1,1,0)
        bitDec,bitPreFec,bitPreInterl = loraDecode(sig,SF,1,1,0)
        @test all(bitSeq[:] .== bitDec[:])
        @test all(bitEnc[:] .== bitPreFec[:])
    end
end 