function effective_distance(tt0, tt1, N, nobs)

    ##########################
    ### Effective distance ###
    ##########################

    # Transportation network in period 0
    tau0 = fill(tt0, N, N);
    tau0[6:11, 6] .= tt1;
    tau0[6, :] .= tt1;
    tau0

    # Transportation network in period 1
    tau1 = fill(tt0, N, N);
    tau1[:, 6] .= tt1;
    tau1[6, :] .= tt1;
    tau1

    # Initialize effective distance
    dist0 = zeros(nobs, nobs);
    dist1 = zeros(nobs, nobs);

    # Calculate effective distance
    for z in 1:nobs
        seed = falses(N, N)
        seed[z] = true

        temp = distance_transform(feature_transform(seed))
        dist0[z, :] = reshape(temp.*tau0, 1, nobs)

        temp = distance_transform(feature_transform(seed))
        dist1[z, :] = reshape(temp.*tau1, 1, nobs)
    end

    dist0[diagind(dist0)] .= 1;
    dist1[diagind(dist0)] .= 1;

    return dist0, dist1
end