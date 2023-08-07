# Download and Install Julia

- [Julia Download](https://julialang.org/downloads/)
- [Julia: How to install](https://julia.quantecon.org/getting_started_julia/getting_started.html#install-julia)

# Starting with Julia

- [Learning Julia](https://julialang.org/learning/)
- [QuantEcon Julia Lectures](https://julia.quantecon.org/intro.html)

# Iterations

- For loops, while loops,StepRange, neat nested loops, Comprhensions (squared = [y^2 for y in 1:2:11])

# Dot syntax: Broadcasting / Vectorization

- Vectorizing operations (e.g. applying it to a whole array or vector at once) is easy in Julia, just use dot syntax like you would in MATLAB, etc. When broadcasting, you might want to consider pre-allocating arrays
-  function show_vec_speed(x)
   out = [3x.^2 + 4x + 7x.^3 for i = 1:1]
 end
 function show_fuse_speed(x)
   out = @. [3x.^2 + 4x + 7x.^3 for i = 1:1]
 end


# Performance

- [Type stability](https://m3g.github.io/JuliaNotes.jl/stable/instability/)
Given an input into a function, operations on that input should maintain the type so Julia knows what its type will be throughout the full function call.

- [VS Code Profiler](https://www.julia-vscode.org/docs/dev/userguide/profiler/)
- [Performance tips](https://docs.julialang.org/en/v1/manual/performance-tips/)

# Profiler


