function pindex(param, fund, L, w, dtradesh, F, model)

    # Parameters
    theta = param[2]
    sigma = param[4]
    Hsigma = param[5]
    
    # Assign values from fund to variables
    a = fund[:, 1]
    
    # Gamma function
    gammaf = gamma((theta + 1 - sigma) / theta)

    # Price index
    if (model == 1)
        P = ((gammaf .^ -theta) .* a .* (w .^ -theta) ./ dtradesh) .^ (-1 / theta)
    elseif (model == 2)
        P = (Hsigma / (Hsigma - 1)) .* (w ./ a) .* ((L ./ (Hsigma .* F .* dtradesh)).^(-1 / theta))
    else
        P = 0
        println("Exiting... Please check the model type. The input is inconsistent with the feasible values. For constant returns, use 1; for increasing returns, use 2.")
    end
    
    return P
end