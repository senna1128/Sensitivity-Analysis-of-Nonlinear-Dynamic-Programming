## This fucntion solves the nonlinear program as shown in paper
## Input:
  # N: temporal length
  # delta1, delta2: parameter in Objective
  # Id: indicator for function f()
    # Id = 1: f(x) = x
    # Id = 2: f(x) = x^2
    # Id = 3: f(x) = exp(x)
  # Jd: indicator for perturbation time
    # Jd = 1: t=1
	# Id = 2: t = 0.1
	# Id = 3: t = 0.01
  # d: demand variable
## Output:
  # xout: supply variables
  # uout: control variable

function NLP(N,delta1,delta2,Id,Jd, dd)
    # Perturbation
	if Jd == 1
		dd = dd;
	elseif Jd == 2
		dd = 0.1 * dd;
	else
		dd = 0.01 * dd;
	end

	# Solver
	m = Model(solver=IpoptSolver(tol = 1e-14, max_iter = 1000));
	@variable(m, x[1:(N+1)]);
	@variable(m, u[1:N]);
	@variable(m, d[1:N]);

	# set objective function
    @setNLObjective(m, Min, sum(delta1*(u[k]-d[k])^2-delta2*(x[k]-d[k])^2 for k = 1:N) - delta2*(x[N+1])^2)
    @constraint(m, eqcon[i=1:N], d[i] == dd[i]);
	@constraint(m, x[1] == 0);
    if Id == 1
        @NLconstraint(m, eqcon[i = 2:(N+1)], x[i] - (u[i-1] + d[i-1]) ==0)
#    elseif Id ==2
#        @NLconstraint(m, eqcon[i = 2:(N+1)], x[i] - (u[i-1] + d[i-1]^2) ==0)
    else
        @NLconstraint(m, eqcon[i = 2:(N+1)], x[i] - (u[i-1] + exp(d[i-1])-1) ==0)
    end

	# set initial value
	for i=1:N
        setValue(x[i],0);
        setValue(u[i],0);
        setValue(d[i],0);
    end
    setValue(x[N+1], 0);

	# solve problem
	status = solve(m);
	finalFunction=getObjectiveValue(m);
	print("This was the Final Objective Functions:\n")
	print(finalFunction)
	# Extracting the variables
	xout=getValue(x);
	uout=getValue(u);
    dout=getValue(d);

	# save directional derivative for x and u
	if Jd == 1
		xout = xout/1;
		uout = uout/1;
	elseif Jd == 2
		xout = xout/0.1;
		uout = uout/0.1;
	else
		xout = xout/0.01;
		uout = uout/0.01;
	end

	# return variable
#	Out = Array{Any}(3)
#	Out[1] = xout;
#	Out[2] = uout;
#	Out[3] = dout;
	return xout, uout, dout
end
