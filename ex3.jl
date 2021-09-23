
using LinearAlgebra

# Find the matrix A, the column vector b and the row vector c
# such that the LP above can be expressed on matrix form:
# max Z = cx
# subjet to
# Ax <= b
# x >= 0
A = [1 4 3; 2 3 2; 2 4 1]
b=[4;21;5]
c=[2 3 2]

# Sub task B Find B, B−1 and cB corresponding to the following choice of basic variables:
# xB = [x3, x5, x1].
# Explain how you find B and cB.
# Notice: the order of the entries in B and CB should
# correspond to the order of the basic variables.

# Matrices and objective coefficients:
AI = [A I]
c0 = [c 0 0]

# We choose x3, x5, x1 as our basis, per the exercise;
# B:
B=AI[:,[3,5,1]]

# cB:
cB=c0[[3 5 1]]
