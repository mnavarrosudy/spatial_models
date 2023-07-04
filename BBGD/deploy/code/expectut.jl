function expectut(param, fund, L, w, P, r, dtradesh, model)

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
    
    # Expected utility
    if (model == 1)
        EU = b .* (gammaf .^ (-alpha * epsilon)) .* (alpha .^ (-epsilon)) .* (((1 - alpha) ./ alpha) .^ (-epsilon * (1 - alpha)))
        EU = ((a ./ dtradesh) .^ (alpha * epsilon / theta)) .* ((L ./ H) .^ (-epsilon * (1 - alpha))) .* EU
        EU = deltaf .* (sum(EU) .^ (1 / epsilon))
    elseif (model == 2)
        EU = b .* (P .^ (-alpha * epsilon)) .* (r .^ (-(1 - alpha) * epsilon)) .* ((w / alpha) .^ epsilon)
        EU = deltaf * (sum(EU) ^ (1 / epsilon))
    else
        EU = 0
        println("Exiting... Please check the model type. The input is inconsistent with the feasible values. For constant returns, use 1; for increasing returns, use 2.")
    end
    
    return EU
end