package apple

type Apple string

func (a Apple) Fill() string {
	return "Filling with sliced " + string(a) + " apples!"
}
