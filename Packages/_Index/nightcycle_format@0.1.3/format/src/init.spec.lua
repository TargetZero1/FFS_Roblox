
return function ()
	describe("Markdown", function()
		it("should boot", function()
			local Format = require(script.Parent)
			expect(Format).to.be.ok()
		end)
		it("should solve", function()
			local Format = require(script.Parent)
			local output = Format("Oh my ***god***")
	
			expect(Format).to.be.ok()
		end)
	end)
end