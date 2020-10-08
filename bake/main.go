package main

import (
	"fmt"

	"grandma.com/baking/dough/crust"
	"grandma.com/baking/filling/apple"
)

func main() {
	dough := crust.Crust("grandma's secret recipe")
	filling := apple.Apple("grannysmith")

	fmt.Println(dough.Layer())
	fmt.Println(filling.Fill())
	fmt.Println("Baking the pie at 375 degrees!")
}
