/*
	['uniqueid'] = {
		name = 'SHIPMENT'

		price = 100,
		--desc = 'A Shipment that contains items' '** generic string decs.

		desc = function(data)
			return Format("A Shipment that contains %s of %s", data.amount, data.class)
		end,

		data = {
			entity = true,
			amount = 10,
			class = 'item_healthkit',
			price = 1000, -- data price overrides default price.
		},

		funcs = {
			onUse = {
			name = GetLang"use",
			cond = true, -- it could be function.
			func = function() 
				-- Shipment use func
				return true
			end},

			onDrop = {
			name = GetLang"drop",
			cond = true,
			func = function()
				-- Don't drop item.
				return true, false -- first arg is consume item, second arg is drop item.
			end},

			-- can add more.
		}
	}
*/
ITEM.name = "Shipment"
ITEM.price = 100
ITEM.desc = "A shipment that contains soem itmes"
ITEM.accessible = {
	
} -- dunno, maybe a class based things?
ITEM.data = {
	entity = true, 
	amount = 10,
	class = "item_healthkit",
	price = 1000,
}
ITEM.funcs = {
	Use = {
		name = "Use",
		cond = true,
		func = function()

		end,
	},

	Drop = {
		name = "Use",
		cond = true,
		func = function()

		end,
	},
}
print("Loaded "..ITEM.name)