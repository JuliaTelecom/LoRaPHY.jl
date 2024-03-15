module LoRaPHY

# using Parameters
using FFTW          # for Rx
using LinearAlgebra # for Rx
using QuadGK        # Theoretical expression (Metrics)
using Bessels       # Theoretical expression (Metrics)


include("Binaryops.jl")

# ----------------------------------------------------
# --- Hamming 7/4 encoding 
# ---------------------------------------------------- 
include("Hamming.jl")

# ----------------------------------------------------
# --- Interleaver 
# ---------------------------------------------------- 
include("Interleaver.jl")
# No export here, this function is internal 

# ----------------------------------------------------
# --- Transmitter  
# ---------------------------------------------------- 
include("Transmitter.jl")
export loraEncode 

# ----------------------------------------------------
# --- Receiver  
# ---------------------------------------------------- 
include("Receiver.jl")
export loraDecode 

# ----------------------------------------------------
# --- Theory  
# ---------------------------------------------------- 
include("Theory.jl")


end # module

