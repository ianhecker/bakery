package crust

type Crust string

func (c Crust) Layer() string {
	return "Layering crust made with " + string(c) + "!"
}
