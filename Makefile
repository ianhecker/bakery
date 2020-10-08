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
