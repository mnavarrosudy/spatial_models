function solveab(param, observe, dist, nobs, model)
    xtic = time()
    
    # Assign values from param and fund 
    alpha = param[1]
    theta = param[2]
    epsilon = param[3]
    L = observe[:, 1]
    w = observe[:, 2]
    H = observe[:, 3]
    LL = observe[1, 4]

    # Initializations
    a_i = ones(nobs) # Type: Vector{Float64}
    b_i = ones(nobs)
    tradesh = zeros(nobs, nobs)
    dtradesh = zeros(nobs)

    # Convergence indicator
    aconverge = 0.0
    bconverge = 0.0
    
    # Initializations
    a_i = ones(nobs)
    b_i = ones(nobs)
    
    # trade costs
    dd = dist .^ (-theta) # Check this step in the paper. # Type: Matrix{Float64}

    function loops(alpha, theta, epsilon, L, w, H, LL, a_i, b_i, tradesh, dtradesh, aconverge, bconverge, dd)
        xx = 1

        ######################################
        ### Start outer loop for amenities ###
        ######################################
        
        while xx < 2000

            #########################################
            ### Start inner loop for productivity ###
            #########################################

            x = 1
            while x < 2000
                # Trade share
                if (model == 1)
                    pwmat = a_i .* (w .^ (-theta)) * ones(1, nobs)
                elseif (model == 2)
                    pwmat = (L .* (a_i .^ theta) .* (w .^ (-theta))) * ones(Float64, 1, nobs)
                else
                    aconverge = 0.0
                    x = 10000
                    break
                end
                nummat = dd .* pwmat
                denom = sum(nummat, dims = 1)
                denommat = ones(nobs, 1) * denom
                tradesh .= nummat ./ denommat
            
                # Income equals expenditure
                income = w .* L
                expend = tradesh * income
            
                # Convergence criterion
                income_r = round.(income .* (10 .^ 6))
                expend_r = round.(expend .* (10 .^ 6))
            
                # Update loop
                if income_r == expend_r
                    x = 10000
                    aconverge = 1.0
                else
                    a_e = a_i .* (income ./ expend)
                    a_i = 0.25 .* a_e .+ 0.75 .* a_i
                    # Normalization
                    a_i = a_i ./ geomean(a_i)
                    aconverge = 0.0
                    x += 1
                end                
            end
            
            #######################################
            ### End inner loop for productivity ###
            #######################################

            if (model == 1)
                # Domestic trade share
                dtradesh .= diag(tradesh)
                num = b_i .* ((a_i ./ dtradesh) .^ (alpha .* epsilon ./ theta)) .* ((L ./ H) .^ (-epsilon .* (1 - alpha)))
            elseif (model == 2)
                # Domestic trade share
                dtradesh .= diag(tradesh)
                num = b_i .* (a_i .^ (alpha .* epsilon)) .* (H .^ (epsilon .* (1 - alpha))) .* (dtradesh .^ (-alpha .* epsilon ./ theta)) .* (L .^ (-(epsilon .* (1 - alpha) - alpha .* epsilon ./ theta)))
            else
                println("Exiting... Please check the model type. The input is inconsistent with the feasible values. For constant returns, use 1; for increasing returns, use 2.")
                xx = 10000
                break
            end

            L_e = num ./ sum(num)
            L_e = L_e .* LL
            
            # Convergence criterion
            L_r = round.(L .* (10 .^ 6))
            L_e_r = round.(L_e .* (10 .^ 6))
            
            # Update loop
            if L_r == L_e_r
                xx = 10000
                bconverge = 1.0
            else
                b_e = b_i .* (L ./ L_e)
                b_i = 0.25 * b_e .+ 0.75 * b_i
                # Normalization
                b_i = b_i ./ geomean(b_i)
                bconverge = 0.0
                xx += 1
            end
        end

        return a_i, b_i, tradesh, dtradesh, aconverge, bconverge

    end

    a, b, tradesh, dtradesh, aconverge, bconverge = loops(alpha, theta, epsilon, L, w, H, LL, a_i, b_i, tradesh, dtradesh, aconverge, bconverge, dd)
    xtic = time() - xtic;
    return a, b, tradesh, dtradesh, aconverge, bconverge, xtic
end