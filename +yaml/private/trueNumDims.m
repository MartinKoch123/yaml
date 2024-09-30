function n = trueNumDims(A)

% Return the "real" number of dimensions of A, i.e., return 0 or 1, if it is a
% scalar or vector.

if isscalar(A)
    n = 0;
elseif isvector(A)
    n = 1;
else
    n = ndims(A);
end

end
