function landprice(param, fund, L, w)

    # Parameters
    alpha = param[1]
    
    # Assign values from fund to variables
    H = fund[:, 3]
    
    # Land price
    r = ((1 - alpha) / alpha) .* ((w .* L) ./ H)
    
    return r
end