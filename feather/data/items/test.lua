ITEM.name = "Shipment"
ITEM.price = 100
ITEM.desc = "A shipment that contains soem itmes"
ITEM.model = "models/Items/item_item_crate.mdl"
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