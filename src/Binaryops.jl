
"""" 
g = grayencode(n)\\
Convert the integer `n` as its value with Gray encoding \\
Inputs : 
- n : Input integer 
Outputs : 
- g : Gray-coded integer
Example: grayencode(2) = 3
"""
grayencode(n::Integer) = n ⊻ (n >> 1)


"""
n = graydecode(n) 
Convert the gray encoded word `n` back
Inputs : 
- g : Gray-coded integer
Outputs : 
- n : Input integer 
"""
function graydecode(n::Integer)
    r = n
    while (n >>= 1) != 0
        r ⊻= n
    end
    return r
end

""" 
n = bin2dec(data)
Convert a binary vector into its integer representation. The input should be a vector with the first element the MSB and the last element the LSB. \\
Example : bin2dec([0;0;1]) = 1; bin2dec([1;0;1;0])=10 \\
If the input is a matrix, the conversion is down per line (e.g bin2dec([1 0 1 0 ; 1 1 1 0]) = [10;14]
"""
function bin2dec(data::AbstractMatrix)
    pow2 = [2^(k-1) for k in (size(data,2)):-1:1]
    dataout = [sum(data[k,:] .* pow2) for k ∈ 1:size(data,1)]
    return dataout
end
bin2dec(data::AbstractVector) = bin2dec(data')

"""
Binary representation of Int on a given number of bits. MSB in pos 1 and LSB at end 
"""
function dec2bin(input::Vector{Int},n::Int)
    Output_bin = zeros(Int, length(input), n)
    for i ∈ eachindex(input)
        c = bitstring(input[i])
        data = [Int(c[j]-48) for j ∈ length(c)-(n-1):length(c)]
        Output_bin[i,:] = data
    end
    return Output_bin
end
