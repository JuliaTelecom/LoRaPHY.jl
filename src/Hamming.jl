function hammingEncode!(y,x)
    # --- Matrix encoder
    nL	= length(x)÷4;
    # --- 
    @inbounds @simd for iN = 1 : 1 : nL 
        # --- Spacing parameters 
        Δx  = (iN-1)*4;
        Δy  = (iN-1)*7;
        # --- Get 4 bits
        for n ∈ 1 : 4 
            y[ Δy + n] = x[Δx + n];
        end 
        # --- Add parity bits
        y[Δy  + 5] = x[Δx + 2] ⊻ x[Δx + 3] ⊻ x[Δx + 4];
        y[Δy  + 6] = x[Δx + 1] ⊻ x[Δx + 3] ⊻ x[Δx + 4];
        y[Δy  + 7] = x[Δx + 1] ⊻ x[Δx + 2] ⊻ x[Δx + 4];
    end
    return y;
end

function hammingDecode!(x,y)
    nL	= length(y)÷7
    cnt = 0
    @inbounds @simd for n ∈ 1 : 1 : nL 
        # --- Calculate 3 equations to deduce syndrome 
        s0 = y[ (n-1)*7 + 4] ⊻  y[ (n-1)*7 + 5] ⊻ y[ (n-1)*7 + 6] ⊻ y[ (n-1)*7 + 7]
        s1 = y[ (n-1)*7 + 2] ⊻  y[ (n-1)*7 + 3] ⊻ y[ (n-1)*7 + 6] ⊻ y[ (n-1)*7 + 7]
        s2 = y[ (n-1)*7 + 1] ⊻  y[ (n-1)*7 + 3] ⊻ y[ (n-1)*7 + 5] ⊻ y[ (n-1)*7 + 7]
        # --- Syndrome calculation 
        pos = s0 << 2 + s1 << 1 + s2
        # --- Switch is syndrome is non-null
        if pos > 0
            bitflip!(y,(n-1)*7 +pos)
            cnt += 1
        end
        for k ∈ 1 : 1 : 4
            x[(n-1)*4 + k] = y[(n-1)*7 + k]
        end
    end
    return cnt
end



function hammingDecode(y::Vector{T}) where T
    x = zeros(T,length(y)÷7*4);
    hammingDecode!(x,y);
    return x;
end
function hammingEncode(x::Vector{T}) where T
    y = zeros(T,length(x)÷4*7) 
    hammingEncode!(y,x)
    return y
end

@inline function bitflip!(in,index)
    in[index] == 1 ? in[index] = 0 : in[index]=1;
end

