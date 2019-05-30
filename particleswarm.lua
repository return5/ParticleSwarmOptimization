function getParts(equation)
	--breaks equation into an array. each term is an element in array
	for c in equation:gmatch("[%+?%-?%s?]*%S*") do
		table.insert(EQ.parts,c)
	end
end

function iterateEquation()
	--iterate through equation_parts
	for index,value in pairs(EQ.parts) do
		--extracts coefficients and places them in EQ.num
		table.insert(EQ.nums,index,getNum(value))
		--extracts exponenets and places them in order in EQ.expo
		table.insert(EQ.expo,index,getExpo(value))
		--extracts each x term and places it in EQ.x 
		table.insert(EQ.x,index,getX(value))
	end
end

--find any exponent and return the number, if no exponent it returns 1
function getExpo(str) 
	--if str isnt nil and has a number preceded by a '^''
	if str ~= nil and str:match("%^%d+") then
		str = str:match("%^%d+") --gets substring which is '^ + number'
		str = str:match("%d+")  -- gets just the number from '^ + number'
		return tonumber(str)
	else
		return 1;
	end
end

--extrac numeric values from item
function getNum(str)
	--if str isnt nil and it has a number not preceded by a '^'' in it
	if str ~= nil and (str:match("[^%^]+%d+") or str:match("^%d+")) then
		str = str:match("[%-%+%s%.]*%d+") --extract sub string which has number in it
		local neg = getNeg(str)
		str = str:match("%.*%d+") --get just the number from str
		return tonumber(str * neg)
	--if str isnt nil and has a character in it not preceded by a '^'
	elseif str ~= nil and str:match("[^%^]+%a") then
		str = str:match("[^%^]*%a+")  --extract substring which doesnt have a '^' in it
		local neg = tonumber(getNeg(str))
		return 1 * neg
	else
		return 1
	end
end

--determines if number is negative or not
function getNeg(str)
	--if str isnt nil and has a negative sign in it
	if str ~= nil and str:match("%s*%-%s*%S*") then
		return -1
	else
		return 1
	end
end	

--returns 1 if item has a variable in it, otherwise returns 0
function getX(str)
	--if str isnt nil and has a character in it
	if str ~= nil and str:match("%s*%d*%a") then
		return 1
	else
		return 0
	end
end

--multiply x value by its exponent and its coefficient 
function multiplyByExpo(x,index)
	if EQ.x[index] == 1 then
		local sum  = math.pow(x,EQ.expo[index])
		if EQ.nums[index] ~= 0 then
			sum = sum * EQ.nums[index]
		end
		return sum
	else
		return math.pow(EQ.nums[index],EQ.expo[index])
	end
end

--sum all values in the equation using particle's current x value then return sum
function sumFx(x)
	local sum = 0
	for index,value in pairs(EQ.parts) do
		sum = sum + multiplyByExpo(x,index)
	end
	return sum
end

--make table to hold equation 
function makeTable()
	local table = {} 
	table["parts"] = {} --hold the whole equation, each item a seperate element in "parts"
	table["x"] = {} --holds 1 if item has x, 0 if it doesnt
	table["expo"] = {}  --holds value of exponenet, or 1 if no exponenet given
	table["nums"] = {} --holds value of coefficients
	return table
end

--checks if user entered equation in correct format
function checkFormat(equation)
	local previous = "10x^100000"  --holds exponent value of previous element in equation. ridiculously large value to sart with as a precaution.
	local space_count = 0  --holds number of items. 

	--if neither a '-'' nor '+'' sign appears in equation, return false
	if equation:match("[%-%+]+") == nil then
		io.write("\nerror, no items appear which have a '-' or '+' in them \n")
		return false
	end
	--if equation has a '=' return false
	if equation:match("=+") ~= nil then
		io.write("\nerror, equation should not have a '=' in it.\n")
		return false
	end	
	--if term appears as '(ax+b)^c'	or similar,return false
	if equation:match("%(.*%)%^") then
		io.write("\nerror, must expand all terms.\n")
		return false
	end

	--iterates through each item in equation
	for c in equation:gmatch("[^%-%+]+") do
		--counts items in an equation by counting spaces between items
		if c:match("%s+") then
			space_count = space_count + 1
		end
		--if higher order expo apears after one which is lower order, return false
		if getExpo(c) > getExpo(previous) then
			io.write("\nerror, lower order exponenet appears before a higher order one.\n")
			return false
		end
		--if variable name is more than one character, return false
		if c:match("%a%a+") then
			io.write("\nerror,please keep variable names ot single character\n")
			return false
		end
		previous = c
	end
	--if no spaces between items, return false
	if space_count < 1 then 
		io.write("\nerror, too few spaces or possibly too few items in equation.\n")
		return false
	end
	return true
end

--asks user if they want to try another guess. if so, then takes new guess and sovles again
function tryNewGuess()
	io.write("would you like to try again using a diffrent starting values(yes/no)?\n")
	local answer = string.lower(io.read())
	if answer == "yes" or answer == "y" then
		initValues()
		SWARM = {}
		makeSwarm()
		solve()
	end
end

--gets equation from user
function getEquation()
	io.write("please input equation you wish to find roots of using particle swarm optimization.\n")
	io.write("equation must be in format 'ax^n + bx^n-1 .... + k'\n")
	local equation = io.read()
	if checkFormat(equation) == false then
		io.write("equation is in wrong format. plese try again\n")
		return getEquation()
	else
		return equation
	end

end

--gets initial guess for x value from user
function getGuess()
	io.write("please enter your intial guess\n")
	local guess = tonumber(io.read())
	if type(guess) ~= "number" then
		io.write("error, guess isnt a number. try again\n")
		return getGuess()
	else
		return guess
	end
end

--gets minimum possible value to check for x from user
function getMin()
	io.write("please enter min value\n")
	local min = tonumber(io.read())
	if type(min) ~= "number" then
		io.write("error, min isnt a number. try again\n")
		getMin()
	else
		MIN = min
	end
end

--gets maximum possible value to check for x from user
function getMax()
	io.write("please enter max value\n")
	local max = tonumber(io.read())
	if type(max) ~= "number" then
		io.write("error, max isnt a number. try again\n")
		getMax()
	else
		MAX = max
	end
end

--gets number of particles from user
function getSwarmSize()
	io.write("please enter number of particles\n")
	local particles = tonumber(io.read())
	if type(particles) ~= "number" then
		io.write("error, that isnt a number. try again\n")
		getSwarmSize()
	else
		SWARM_SIZE = particles
	end
end

--gets values for min, max, and swarm size.
function initValues()
	getMin()
	getMax()
	getSwarmSize()
end

--checks particles current local best against the swarms global best
function checkGlobalBest(i)
	--if a particle's best result is closer to zero than globalbest, set globalbest to that particle's result. 
	--also set value of globalbestx to particle's curent x value
	if math.abs(SWARM[i].best_result) < math.abs(GLOBALBESTRESULT) then
		GLOBALBESTX = SWARM[i].best_x
		GLOBALBESTRESULT = SWARM[i].best_result
	end
end

--checks a particles current value against its all time best 
function checkLocalBest(i)
	--if the current result is close to zero than particle's all time best result, then set best result to current result
	--also set value of particles best x value to current x value
	if math.abs(SWARM[i].current_result) < math.abs(SWARM[i].best_result) then
		SWARM[i].best_x = SWARM[i].current_x
		SWARM[i].best_result = SWARM[i].current_result 
	end
end

--create individual particle
function makeParticle()
	local x = math.random(MIN,MAX)  --get random value within range of possible x values.
	local val = sumFx(x) --call sumFun with random x value to get initial starting value for particle
	particle = {}
	particle.best_x = x  --initialize particle's starting best x value with the random x value from above
	particle.current_x = x --initialize particle's starting x value with the random x value from above
	particle.velocity = math.random(0,2) * .5 + .01  --set initial velocity of particle
	particle.best_result = val --initialize particle's best result with val
	particle.current_result = val --set oarticle's current result to val
	return particle
end

--create the particle swarm
function makeSwarm()
	for i = 0,SWARM_SIZE,1 do
		SWARM[i] = makeParticle()
		checkGlobalBest(i)
	end
end

--gets new velocity for individual particle. 
function getNewV(i)
	SWARM[i].velocity = (INERTIAL_W * SWARM[i].velocity ) + (C_1 * math.random(0,20) *.05 * (SWARM[i].best_x - SWARM[i].current_x)) + (C_2 * math.random(0,20) * .05 * (GLOBALBESTX - SWARM[i].current_x))
end

--get new x value for individual particle.
function getNewX(i)
	local x = SWARM[i].current_x + SWARM[i].velocity 
	if x < MIN then
		SWARM[i].current_x = MIN
	elseif x > MAX then
		SWARM[i].current_x = MAX
	else
		SWARM[i].current_x = x
	end
end

--solves eqution user entered
function solve()
	GLOBALBESTX = getGuess()  --gets users initial guess for x value
	GLOBALBESTRESULT = sumFx(GLOBALBESTX)  --initialize globalbestresult
	local loop_count = 0  --counts how many iterations loop goes through to get to solution
	while(math.abs(GLOBALBESTRESULT) > .000001 and loop_count < 10000) do
		for i,v in pairs(SWARM) do
			getNewV(i)
			getNewX(i)
			SWARM[i].current_result = sumFx(SWARM[i].current_x)
			checkLocalBest(i)
			checkGlobalBest(i)
		end
		loop_count = loop_count + 1
	end
	io.write("global best is x = ",GLOBALBESTX, " \nwith results y = ", GLOBALBESTRESULT," \nit took ", loop_count," iterations\n")
	tryNewGuess()
end

--function gets everything moving
function startSolving()
	local equation = getEquation()
	EQ = makeTable()
	getParts(equation)
	iterateEquation()
	initValues()
	makeSwarm()
	solve()
end

EQ = {}  --table for equation
INERTIAL_W = .8		--inertial coefficient
C_1 = 1.7	--cognitive coefficient
C_2 = 1.7	--social coefficient
MAX = 1  --sets upper bound for x values
MIN = -1 --sets lower bound for x values
SWARM_SIZE = 1
GLOBALBESTX = 0	--globalbest value for x
GLOBALBESTRESULT = 0
SWARM = {}
math.randomseed(os.time())
startSolving()
