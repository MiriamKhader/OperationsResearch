using JuMP, GLPK

m = Model(GLPK.Optimizer)

@variable(m, x1 >= 0 )
@variable(m, x2 >= 0 )

@objective(m, Min, 5*x1 + 7*x2 )

@constraint(m, 3*x1 + 1*x2 >= 15 )
@constraint(m, 4*x1 + 2*x2 >= 5)
@constraint(m, 1*x1 + 3*x2 <= 5)


optimize!(m)

if termination_status(m) == MOI.OPTIMAL
    println("Objective value: ", JuMP.objective_value(m)) # 10
    println("x1 = ", JuMP.value(x1)) # 1.27
    println("x2 = ", JuMP.value(x2)) # 2.9
else
    println("Optimize was not succesful. Return code: ", termination_status(m))
end
