module Exercise2

using JuMP, GLPK
# Install packages with:
# Pkg.add(["CSV","DataFrames"])
using CSV, DataFrames

df = DataFrame(CSV.File("data.CSV"))
dfReq = DataFrame(CSV.File("Requirements.CSV"))
println("Data (df)")
println(df)

println("Requirements (dfReq)")
println(dfReq)

m = Model(GLPK.Optimizer)

(nFoods, nCols) = size(df)
(nNutrients, _) = size(dfReq)
# x[i] says how many servings of food i we are including in our daily diet.
@variable(m, x[1:nFoods] >= 0 )
# set the objective function to keep the price as lowa s possible
@objective(m, Min, sum(df[i,:Price]*x[i] for i=1:nFoods) )

# Add a constraint of min/max amount of food in the diet (4th/5th column):
for i in 1:nFoods
    @constraint(m, x[i] >= df[i,4])
    @constraint(m, x[i] <= df[i,5])
end
# add a constraint that diet should follow the requirements:
for j in 1:(nNutrients)
    # We shift the df column by 5
    # since the first 5 columns are not nutrient info
    @constraint(m, sum(df[i,j+5] * x[i] for i=1:nFoods) >= dfReq[j,:min])
    @constraint(m, sum(df[i,j+5] * x[i] for i=1:nFoods) <= dfReq[j,:max])
end

# Subtask C: Solve the model

optimize!(m)

if termination_status(m) == MOI.OPTIMAL
    println("Objective value: ", JuMP.objective_value(m))
    xVal = JuMP.value.(x)
    for i=1:nFoods
        if xVal[i] >= 0.001
            println(xVal[i], " servings of ", df[i,:Food], " (",df[i,:Serving],")")
        end
    end
else
    println("Optimize was not succesful. Return code: ", termination_status(m))
end

# Subtask D: Change the diet so it always includes at least 1 hamburger
# This can be achieved by setting the minimum for hamburger to 1;
println("NEW MODEL w HAMBURGER")
burgerRow = 44 # read from the data sheet;
# We give the constraint a name, so that we can delete and unregister it afterwards
@constraint(m, burgerConstraint, x[burgerRow] >= 1)
optimize!(m)

if termination_status(m) == MOI.OPTIMAL
    println("Objective value: ", JuMP.objective_value(m))
    xVal = JuMP.value.(x)
    for i=1:nFoods
        if xVal[i] >= 0.001
            println(xVal[i], " servings of ", df[i,:Food], " (",df[i,:Serving],")")
        end
    end
else
    println("Optimize was not succesful. Return code: ", termination_status(m))
end



# Subtask E: Rate the food, maximize 'deliciousness', keep costs below 4 dollars

println(" NEW MODEL w RATING")

# First, we delete the burger constraint from previous task
delete(m,burgerConstraint)
unregister(m, :burgerConstraint)

# Secondly, a list of a rating of the food is created here:
# 64 elements, one for each food.
foodRating = [2,3,0,0,3,1,1,1,2,1,1,1,4,4,3,0,3,4,4,0,5,3,1,2,5,1,0,3,1,5,4,5,2,3,3,0,2,2,1,4,5,4,5,5,3,4,0,5,2,2,0,4,0,0,3,0,3,5,5,0,4,0,3,4]

# Thirdly, we modify the objective function to maximize the sum of our rating
@objective(m, Max, sum(foodRating[i]*x[i] for i=1:nFoods) )
# Fourth, we add a constraint of the price being less than or equal to 4 dollars:
@constraint(m, sum(df[i,:Price]*x[i] for i=1:nFoods) <= 4)

# Lastly, solve the model:
optimize!(m)

if termination_status(m) == MOI.OPTIMAL
    println("Objective value: ", JuMP.objective_value(m))
    xVal = JuMP.value.(x)
    for i=1:nFoods
        if xVal[i] >= 0.001
            print(xVal[i], " servings of ", df[i,:Food], " (",df[i,:Serving],")")
            println(". rating was: ", foodRating[i])
        end
    end
    println("Price is: ",sum(df[i,:Price]*xVal[i] for i=1:nFoods))
else
    println("Optimize was not succesful. Return code: ", termination_status(m))
end



end
