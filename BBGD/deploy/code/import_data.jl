function import_data()

    dist0 = Matrix(CSV.read("/Users/mnavarrosudy/Dropbox/bridges_bangladesh/dist0.csv", DataFrame, header=false))
    dist1 = Matrix(CSV.read("/Users/mnavarrosudy/Dropbox/bridges_bangladesh/dist1.csv", DataFrame, header=false))
    a = Matrix(CSV.read("/Users/mnavarrosudy/Dropbox/bridges_bangladesh/a.csv", DataFrame, header=false))
    b = Matrix(CSV.read("/Users/mnavarrosudy/Dropbox/bridges_bangladesh/b.csv", DataFrame, header=false))

    return dist0, dist1, a, b
end