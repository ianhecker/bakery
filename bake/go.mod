module grandma.com/baking/bake

go 1.14

require (
	grandma.com/baking/dough v0.0.0
	grandma.com/baking/filling v0.0.0
)

replace grandma.com/baking/filling v0.0.0 => ../filling

replace grandma.com/baking/dough v0.0.0 => ../dough
