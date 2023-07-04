function solveLw(param, fund, dist, nobs, model)
    xtic = time()

    # Assign values from param and fund 
    alpha = param[1]
    theta = param[2]
    epsilon = param[3]
    a = fund[:, 1]
    b = fund[:, 2]
    H = fund[:, 3]
    LL = fund[1, 4]

    # Initializations
    w_i = ones(nobs) # Type: Vector{Float64}
    L_i = ones(nobs) .* (LL / nobs)
    tradesh = zeros(nobs, nobs)
    dtradesh = zeros(nobs)

    # Convergence indicator
    wconverge = 0.0
    Lconverge = 0.0

    # Trade costs
    dd = dist .^ (-theta) # Check this step in the paper. # Type: Matrix{Float64}

    function loops(alpha, theta, epsilon, a, b, H, LL, L_i, w_i, tradesh, dtradesh, wconverge, Lconverge, dd) # ::Tuple{Vector{Float64}, Vector{Float64}, Matrix{Float64}, Vector{Float64}, Float64, Float64}
        xx = 1

        ##################################
        ### Start outer loop for wages ###
        ##################################

        while xx < 2000

            ##################################
            ### Start inner loop for wages ###
            ##################################

            x = 1
            while x < 2000
                # Trade share
                if (model == 1)
                    pwmat = (a .* (w_i .^ (-theta))) * ones(1, nobs) # Type: Matrix{Float64}
                elseif (model == 2)
                    pwmat = L_i .* (a .^ theta) .* (w_i .^ (-theta)) * ones(1, nobs)
                else
                    wconverge = 0.0
                    x = 10000
                    break
                end
                nummat = dd .* pwmat
                denom = sum(nummat, dims = 1)
                denommat = ones(nobs, 1) * denom
                tradesh .= nummat ./ denommat

                # Income equals expenditure
                income = w_i .* L_i
                expend = tradesh * income
                
                # Convergence criterion
                income_r = round.(Int, income .* (10 .^ 6))
                expend_r = round.(Int, expend .* (10 .^ 6))

                # Update loop
                if income_r == expend_r
                    x = 10000
                    wconverge = 1.0
                else
                    w_e = w_i .* (expend ./ income) .^ (1 / theta)
                    w_i = 0.25 * w_e + 0.75 * w_i # Type: Vector{Float64}
                    # Normalization
                    w_i = w_i ./ geomean(w_i) # Type: Vector{Float64}
                    wconverge = 0.0
                    x += 1
                end
            end

            ################################
            ### End inner loop for wages ###
            ################################

            # Population
            if (model == 1)
                # Domestic trade share
                dtradesh .= diag(tradesh)
                num = b .* ((a ./ dtradesh) .^ (alpha * epsilon / theta)) .* ((L_i ./ H) .^ (-epsilon * (1 - alpha)))
            elseif (model == 2)
                # Domestic trade share
                dtradesh .= diag(tradesh)
                num = b .* (a .^ (alpha * epsilon)) .* (H .^ (epsilon * (1 - alpha))) .* (dtradesh .^ (-alpha * epsilon / theta)) .* (L_i .^ (-(epsilon * (1 - alpha) - alpha * epsilon / theta)))
            else
                println("Exiting... Please check the model type. The input is inconsistent with the feasible values. For constant returns, use 1; for increasing returns, use 2.")
                xx = 10000
                break
            end
            
            L_e = num ./ sum(num)
            L_e = L_e .* LL

            # Convergence criterion
            L_i_r = round.(Int, L_i .* (10 .^ 6))
            L_e_r = round.(Int, L_e .* (10 .^ 6))
                
            # Update loop
            if L_i_r == L_e_r
                xx = 10000
                Lconverge = 1.0
            else
                L_e = L_i .* ((L_e ./ L_i) .^ (1 / (epsilon * (1 - alpha))))
                L_i = 0.25 * L_e .+ 0.75 * L_i
                Lconverge = 0.0
                xx += 1
            end        
        end
        
        return w_i, L_i, tradesh, dtradesh, Lconverge, wconverge
    
    end
    w, L, tradesh, dtradesh, Lconverge, wconverge = loops(alpha, theta, epsilon, a, b, H, LL, L_i, w_i, tradesh, dtradesh, wconverge, Lconverge, dd)
    xtic = time() - xtic;
    return w, L, tradesh, dtradesh, Lconverge, wconverge, xtic
end