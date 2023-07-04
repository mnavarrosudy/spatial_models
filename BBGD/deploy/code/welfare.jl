function welfare(param, fund, L, dtradesh, model)

    # Parameters
    alpha = param[1]
    theta = param[2]
    epsilon = param[3]
    
    # Assign values from fund to variables
    a = fund[:, 1]
    b = fund[:, 2]
    H = fund[:, 3]
    
    # Delta function
    deltaf = gamma((epsilon - 1) / epsilon)
    
    # Gamma function
    gammaf = gamma((theta + 1 - sigma) / theta)
    
    # Welfare
    if (model == 1)
        welf = deltaf .* (b .^ (1 / epsilon)) .* ((a ./ dtradesh) .^ (alpha / theta)) .* (H .^ (1 - alpha)) .* (L .^ (-(1 / epsilon + 1 - alpha)))
        welf = welf / (alpha * (((1 - alpha) / alpha) ^ (1 - alpha)) * (gammaf ^ alpha) * (LL ^ (-1 / epsilon)))
            
    elseif (model == 2)
        welf = deltaf * (b .^ (1 / epsilon)) .* (a .^ alpha) .* ((1 ./ dtradesh) .^ (alpha / theta)) .* (H .^ (1 - alpha))
        welf = welf .* (L .^ (-(1 / epsilon + 1 - alpha - alpha / theta)))
        welf = welf ./ (alpha * (((1 - alpha) / alpha) ^ (1 - alpha)) * ((Hsigma / (Hsigma - 1)) ^ alpha) * ((Hsigma * F) ^ (alpha / theta)))
        welf = welf ./ (LL .^ (-1 / epsilon))
    else
        welf = 0
        println("Exiting... Please check the model type. The input is inconsistent with the feasible values. For constant returns, use 1; for increasing returns, use 2.")
    end
    
    return welf
end