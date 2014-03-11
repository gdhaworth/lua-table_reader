{
	["foo"] = "simple string", --[==[long comment 1]==]
	["bar"] = "string with an \"escape\"",
	-- short comment 1
	--[==[long comment 2]==] ["baz"] = [=[one [[two]] one]=],
	["empty"] = false,
	--
	to_english = {
		[1] = "one", -- short comment 2
		--[=
		[2] = "two",
		--[[ [3] = "three", ]]
		-- [4] = "four",
	},
}
