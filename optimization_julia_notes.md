# Notes on optimization algorithms in Julia
Several packages provide optimization tools in Julia. The most widely used are Optim.jl, JuMP.jl, BlackBoxOptim.jl, and NLopt.jl.

## Optim.jl
Focuses primarily on unconstrained optimization, with some support for box-constrained problems. The inclusion of constraints cannot be implemented exactly, but it is possible to use a penalty function method to discipline the optimization procedure.

## JuMP.jl 
Algebraic modeling language for mathematical optimization embedded in Julia. It focuses on constrained optimization and supports a broad range of problem types. However, JuMP is less suitable when: (i) the objective function is complex, or (ii) the objective is non-differentiable.

## BlackBoxOptim.jl 
Focuses on global optimization using heuristic and stochastic algorithms that do not require a differentiable objective function. It does not support the inclusion of constraints, but this drawback can be ameliorated through using a penalty function method.

## NLopt.jl 
Provides a common interface to various optimization algorithms for: (i) global and local optimization, (ii) derivative-free objectives, (iii) unconstrained and bound-constrained problems, and (iv) general nonlinear inequality/equality constraints.
For NLopt.jl, we have explored two main families of algorithms: (a) Local derivative-free optimization, and (b) Local gradient-based optimization.

Within the family (a), there are the following algorithms: COBYLA (Constrained Optimization BY Linear Approximations), BOBYQA, NEWUOA + bound constraints, PRAXIS (PRincipal AXIS), Nelder-Mead Simplex, and Sbplx (based on Sbplx). Among these algorithms, COBYLA is the only one that supports nonlinear inequality and equality constraints.

Within the family (b), there are the following algorithms: MMA (Method of Moving Asymptotes), SLSQP, Low-storage BFGS, Preconditioned truncated Newton, and Shifted limited-memory variable-metric. Among these algorithms, only MMA and SLSQP support arbitrary nonlinear constraints, and only SLSQP supports nonlinear equality constraints. The rest supports bound-constrained or unconstrained problems.

When the optimization involves a fairly complex objective function or there is no direct access to the analytic formula of the objective function’s gradient, there are two ways to provide gradients to these algorithms: (i) Automatic differentiation, and (ii) Finite differences.

For automatic differentiation, there are packages such as ForwardDiff.jl, Flux.jl, and NLSolverBase.jl. For finite differences, NLSolverBase.jl provides an option to compute numerical gradients.  

NLopt.jl also supports the Augmented Lagrangian algorithm. This method combines the objective function and the nonlinear inequality/equality constraints into a single function: the objective plus a “penalty” for any violated constraints. This modified objective function is then passed to another optimization algorithm with no nonlinear constraints. This algorithm can be used in combination with any of the local gradient-based optimization methods.

Penalty function method: Some optimization algorithms (e.g. Gradient Descent, (L-)BFGS, or Black box) do not explicitly allow to include constraints. We imperfectly include the constraint by using a penalty function method. The basic idea is to allo anything to be feasible, but alter the objective function so that it is ``painful'' to make choices that violate the constraints. Hence, this approach replaces constraints with continuous penalty functions and forms an unconstrained optimization problem.

For example, consider the following constrained problem:

$$\begin{align}
\underset{x}{\min}\quad  
&f(x) \\
\textnormal{subject to} \quad
&g(x) = a \\
&h(x) \leq b
\end{align}$$

We construct the penalty function problem:

$$\begin{align}
\underset{x}{\min}\quad  
&f(x) + \frac{1}{2} P \biggl(\sum_{i=1} (g^{i}(x) - a_{i})^{2} + \sum_{j=1} (\max [0, h^{j}(x) - b_{j}])^{2}\biggr),
\end{align}$$

where we use the squared function for equality constraints and the squared max function for inequality constraints. $P>0$ is the penalty parameter, and if P is sufficiently large, both problems above are equivalent. However, for $P$ large, we cannot directly solve the problem since the Hessian of $F$ ($F_{xx}$), is likely to be ill-conditioned at points away from the solution, leading to numerical imprecision and slow progress. Hence, the solution is to solve a sequence of problems, starting with a small choice of $P_{1}$, and get the solution $x^{1}$. Then, we use $x^{k}$ as the initial guess in the iteration $k+1$.

Sequential quadratic programming (SQP): It takes advantage of the fact that there are special methods that can be used to solve problems with quadratic objectives and linear constraints. Suppose that the current guesses are $(x^{k}, \lambda^{k}, \mu^{k})$, then the sequential quadratic method solves:

$$\begin{align}
\underset{s}{\min}\quad  
&(x^{k}-s)' \mathcal{L}_{xx}(x^{k},\lambda^{k},\mu^{k}) (x^{k}-s)  \\
\textnormal{subject to} \quad
&g_{x}(x^{k}) (x^{k}-s) = 0 \\
&h_{x}(x)(x^{k}-s) \leq 0,
\end{align}$$

for the step size $s^{k+1}$. This is a linear-quadratic problem formed from quadratic approaximations of the Lagrangian and linear approximations of the constraints. The next iterate is $x^{k+1} = x^{k}+s^{k+1}$ ($\lambda$ and $\mu$ are also updated, but we do not describe this here). The sequential quadratic method inherits many of the desirable properties of Newton's method, including local convergence, and can similarly use quasi-Newton and line search adaptations.

Augmented Lagrangian methods: They combine sequential quadratic methods and penalty function methods by adding penalty terms to the Lagrangian function. Solving the canonical constrained optimization above may be different from minimizing its Lagrangian, even using correct multipliers, but adding penalty terms can make the optimization problem similar to unconstrained minimization of the augmented Lagrangian. These extra terms help  
