
function NewBrain()
	local b = {}
	local width = 4
	local depth = 3
	b.width = width
	b.depth = depth
	b.brain = {}
	b.inputs = {}
	b.outputs = {}
	b.givenTable = {}

	for i=1, width do
		b.brain[i] = {}
		for j=1, depth do
			b.brain[i][j] = NewNeuron(width)
		end
	end

	b.mutate = function (self)
		for i=1, self.width do
			for j=1, self.depth do
				self.brain[i][j]:mutate()
			end
		end
	end

	b.cycle = function (self, givenTable)
		local inputs = {}
		local finals = {}
		local outputs = {}
		self.givenTable = givenTable

        -- initialize all inputs in brain to {}
        -- initialize all ouptuts in brain 0
        -- for the first row of the table, set inputs to givenTable at that position
		for i=1, self.width do
			inputs[i] = {}
			outputs[i] = {}
			for j=1, self.depth do
				inputs[i][j] = {}
				outputs[i][j] = 0
			end

			for j=1, #givenTable[i] do
				inputs[i][1][j] = givenTable[i][j]
			end
		end

		for j=1, self.depth do
			for i=1, self.width do
                -- get output of this neuron
				local nret = self.brain[i][j]:output(inputs[i][j])
				outputs[i][j] = nret

                -- give output to next layer, or final output if last layer
				if j < self.depth then
					for k=1, self.width do
						table.insert(inputs[k][j+1], nret)
					end
				else
					table.insert(finals, nret)
				end
			end
		end

		self.inputs = inputs
		self.outputs = outputs

		return finals
	end

	b.draw = function (self)
        pushStyle()
        fontSize(fontSize() * rel * 1.5)
        local _, lineHeight = textSize("AZ!'g")
        				local sq = lineHeight * 2.25
        				local sep = lineHeight * 1.25
        local startText = WIDTH * 0.005
        textMode(CORNER)
        fill(76, 210, 233)
        stroke(fill())
		for i=1, self.width do
			for j=1, self.depth do
				local c = (128 + self.outputs[i][j]*128)-1
				c = math.min(c, 255)
				c = math.max(c, 0)

                local startX = WIDTH * 0.005

				SetColor(c,c,c)
                				local dx,dy = (i-1)*(sq+sep) + startX, (j-1)*(sq+sep) + (sep * 2)

                rect(dx,dy, sq,sq)
                fill(76, 210, 233)
				text(math.floor(self.outputs[i][j]*1000)/1000, dx+4,dy - (sq / 2))
			end
        		end
        local cTouch = CurrentTouch
            if cTouch then
            		local mx = math.floor(cTouch.x/56) + 1
            		local my = math.floor(cTouch.y/56) + 1

            		if mx <= self.width and my <= self.depth then
                text(tostring(self.inputs[mx][my]), 300, 100)
                text(tostring(self.brain[mx][my].bias).." --- "..tostring(self.brain[mx][my].weights), 300, 150)
            		end
        end
        local tableTextStart = (sq + sep) * 4
        		for i=1, #self.givenTable do
            			text(tostring(self.givenTable[i]), tableTextStart, 8 + i*16)
        		end
        popStyle()
    	end

	return b
end

function NewNeuron(weightCount)
	local n = {}
	n.weightCount = weightCount
	n.weights = {}
	n.bias = 0

	for i=1, weightCount do
		n.weights[i] = 0
	end

	n.mutate = function (self)
		if math.random() > 0.8 then
			for i=1, self.weightCount do
				if math.random() <= 0.25 then
					local mult = 0.125

					if math.random() <= 0.25 then
						mult = 2
					end

					self.weights[i] = self.weights[i] + math.random()*choose{1,-1}*0.25
				end

				local c = rand(1,20)
				if c == 20 then
					self.weights[i] = 1
				end
				if c == 19 then
					self.weights[i] = -1
				end
				if c == 18 then
					self.weights[i] = 0
				end
				if c == 17 then
					self.weights[i] = self.weights[i]*10
				end
			end
		end

		if math.random() > 0.8 then
			if math.random() > 0.5 then
				self.bias = self.bias + math.random()*choose{1,-1}*0.25
			end
			local c = rand(1,20)
			if c == 20 then
				self.bias = 1
			end
			if c == 19 then
				self.bias = -1
			end
			if c == 18 then
				self.bias = 0
			end
			if c == 17 then
				self.bias = self.bias*10
			end
		end
	end

	n.output = function (self, inputs)
		local adder = 0
		for i=1, math.min(#self.weights, #inputs) do
			adder = adder + self.weights[i]*inputs[i]
		end

		adder = adder + self.bias

		return 1/( 1+ (2.71828^(-1*adder)) )
	end

	return n
end