
function marcumq(a,b,v) #Mercum-Q function of order v
    f = x -> ((x^v) * exp(-((x^2)+(a^2))/2) * besseli((v-1),(a*x)))
    Q = 1-((1/(a^(v-1))) * quadgk(f, 0, b)[1])
    return Q
end


"""
Theoretical expression of Symbol Error Rate in an AWGN channel without Hamming code correction
"""
function AWGN_SEP_theo_noFEC(SF,DL,SNRdB)
    #Compute the Symbole Error Probability for a LoRa transmission in an AWGN channel
    SEP_theo=0;
    RSB=10^(SNRdB/10);
    N=2^SF;
    z_c1=2*log(N-1);
    tau=cbrt((N-4)*(N-5)/((N-1)*(N-2)*(N-3)^3)-sqrt(2)*(N-4)/((N-1)*((N-2)*(N-3))^(1.5)));
    z_c3=-2*log(tau-(N-4)/(tau*(N-2)*(N-3)^2)+1/(N-3));
    alpha0=(3*exp(-z_c1/2)-exp(-z_c3/2))/2;
    alpha1=(exp(-z_c3/2)-exp(-z_c1/2))/2;
    z_c=-2*log(alpha1*DL+alpha0);
    for j=1:DL+1
        SEP_theo = SEP_theo + (-1)^j*binomial(N,j)*exp(-N*RSB*(j-1)/j)*marcumq(sqrt(2*N*RSB/j),sqrt(j*z_c),1);
    end
    SEP_theo = 1+SEP_theo/N;
    return SEP_theo
end

"""
"""
function AWGN_SEP_theo_hamming74(SF,DL,SNRdB)
    BEP_noFEC = AWGN_SEP_theo_noFEC(SF,DL,SNRdB) ./ 2
    return 1 .- (1 .- BEP_noFEC).^6 .* (1 .+ 6 .* BEP_noFEC)
end
