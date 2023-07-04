function realw(param, fund, L, dtradesh, model)
    
    # Parameters
    alpha = param[1]
    theta = param[2]
    
    # Assign values from fund to variables
    a = fund[:, 1]
    H = fund[:, 3]
    
    # Gamma function
    gammaf = gamma((theta + 1 - sigma) / theta)

    # Real wage
    if (model == 1)
        realwage = ((a ./ dtradesh) .^ (alpha / theta)) .* ((L ./ H) .^ (-(1 - alpha)))
        realwage = realwage ./ (alpha .* (gammaf .^ alpha) .* (((1 - alpha) / alpha) ^ (1 - alpha)))
            
    elseif (model == 2)
        realwage = ((L ./ (Hsigma * F * dtradesh)) .^ (alpha / theta)) .* (a .^ alpha) .* ((L ./ H) .^ (-(1 - alpha)))
        realwage = realwage ./ (alpha * (((1 - alpha) / alpha) ^ (1 - alpha)))

    else
        realwage = 0
        println("Exiting... Please check the model type. The input is inconsistent with the feasible values. For constant returns, use 1; for increasing returns, use 2.")
    end
    
    return realwage
end