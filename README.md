This example will demonstrate how to setup your own multimodule monorepo.
The replace statements on the modules make this a semver-free multimodule repo.

Let's say you have a repository about baking. It has modules: filling, crust, and bake. And a few packages, but we'll touch on those in a bit.
```bash
mkdir -p \
 baking/filling/apple \
 baking/dough/crust \
 baking/bake
touch Makefile
```

Should get us to:
```
tree ./
.
├── bake
├── dough
│   ├── crust
├── filling
│   ├── apple
└── Makefile
```

You can already guess that our bake module will require our filling and dough modules as imports. 
Let's initialize our modules.
```bash
cd baking
(cd filling && go mod init grandma.com/baking/filling)
(cd dough && go mod init grandma.com/baking/dough)
(cd bake && go mod init grandma.com/baking/bake)
cat filling/go.mod
```
output:
```
module grandma.com/baking/filling

go 1.14
```
Let's add some require statements to import across our modules.
```bash
(cd bake && \
go mod edit -require=grandma.com/baking/filling@v0.0.0)
(cd bake && \
go mod edit -require=grandma.com/baking/dough@v0.0.0)
cat bake/go.mod
```
output:
```
module grandma.com/baking/bake

go 1.14

require (
       grandma.com/baking/dough v0.0.0
       grandma.com/baking/filling v0.0.0
)
```

Now for the replace statements. These will point to our local disk directory, rather than remote urls.
```bash
(cd bake/ && \
go mod edit -replace=grandma.com/baking/filling@v0.0.0=../filling)
(cd bake/ && \
go mod edit -replace=grandma.com/baking/dough@v0.0.0=../dough)
cat bake/go.mod
```
output:
```
module grandma.com/baking/bake

go 1.14

require (
        grandma.com/baking/dough v0.0.0
        grandma.com/baking/filling v0.0.0
)

replace grandma.com/baking/filling v0.0.0 => ../filling

replace grandma.com/baking/dough v0.0.0 => ../dough
```
Let's drop in some code.
```golang
cat <<EOF >dough/crust/crust.go
package crust

type Crust string

func (c Crust) Layer() string {
  return "Layering crust made with " + string(c) + "!"
}
EOF
```
```golang
cat <<EOF >filling/apple/apple.go
package apple

type Apple string

func (a Apple) Fill() string {
  return "Filling with sliced " + string(a) + " apples!"
}
EOF
```
```golang
cat <<EOF >bake/main.go
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
EOF
```

Now, run it with this command and see the output:
```bash
(cd bake && go run .)
```
output:
```
Layering crust made with grandma's secret recipe!
Filling with sliced grannysmith apples!
Baking the pie at 375 degrees!
```

You may have noticed at this point that i often use bash subshells for Golang commands inside modules.
Because our modules exist one directory deeper than the main monorepo directory, this is a handy trick to avoid cd'ing into modules for commands.
Here's a copy-paste Makefile. Remember to properly space with tabs.

```makefile
GO=go
GOBUILD=$(GO) build
GOMOD=$(GO) mod
GOTEST=$(GO) test -count=1 -v
GOTIDY=$(GOMOD) tidy

BAKE_DIR=bake
DOUGH_DIR=dough
FILLING_DIR=filling

BAKER=binary
BAKERY=bin

default: run

run: build
	./$(BAKERY)/$(BAKER)

bin:
	mkdir $(BAKERY)

clean:
	rm -rf $(BAKERY)

test: test-dough test-filling

test-dough:
	(cd $(DOUGH_DIR) && \
		$(GOTEST) ./... && \
		$(GOTIDY))

test-filling:
	(cd $(FILLING_DIR) && \
		$(GOTEST) ./... && \
		$(GOTIDY))

build: test bin
	(cd $(BAKE_DIR) && \
		$(GOBUILD) \
		-o ../$(BAKERY)/$(BAKER) ./)

```

I will mention one "gotcha" with bash subshells and changing directory into modules: you have to update paths accordingly.
Notice how for build we point back one directory for the output with `-o ../$(BAKERY)/$(BAKER)`.

Another "gotcha" to pay attention to is the order of go mod tidy.
Make sure you go test and go mod tidy modules in the order that they import each other  in.
From the bottom up to the top of the import tree.

Running `$ make` should get you this:

```bash
make
```
output:
```
(cd dough && \
        go test -count=1 -v ./... && \
        go mod tidy)
?       grandma.com/baking/dough/crust  [no test files]
(cd filling && \
        go test -count=1 -v ./... && \
        go mod tidy)
?       grandma.com/baking/filling/apple        [no test files]
mkdir bin
(cd bake && \
        go build \
        -o ../bin/binary ./)
./bin/binary
Layering crust made with grandma's secret recipe!
Filling with sliced grannysmith apples!
Baking the pie at 375 degrees!
```
There you have it! Hopefully this helps you with multimodule monorepos!