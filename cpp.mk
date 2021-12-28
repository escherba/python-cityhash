CXX := g++
CXXFLAGS := -std=c++11 -O3 -msse4.2
LDFLAGS :=
SRCEXT := cc
INC := -I include
LIB := -L lib

INPUT := ./data/sample_100k.txt

BINDIR := bin
SRCDIR := src
TESTDIR := tests
BUILDDIR := build
ALL_SOURCES := $(wildcard $(SRCDIR)/*.$(SRCEXT) $(TESTDIR)/*.$(SRCEXT))

RUN_SOURCES := $(wildcard $(SRCDIR)/*_main.$(SRCEXT) $(TESTDIR)/*_main.$(SRCEXT))
RUN_OBJECTS := $(patsubst %, $(BUILDDIR)/%, $(RUN_SOURCES:.$(SRCEXT)=.o))
RUN_TARGETS := $(patsubst $(BUILDDIR)/%.o, $(BINDIR)/%, $(RUN_OBJECTS))

TEST_SOURCES := $(wildcard $(TESTDIR)/test_*.$(SRCEXT))
TEST_OBJECTS := $(patsubst %, $(BUILDDIR)/%, $(TEST_SOURCES:.$(SRCEXT)=.o))
TEST_TARGETS := $(patsubst $(BUILDDIR)/%.o, $(BINDIR)/%, $(TEST_OBJECTS))

SOURCES := $(filter-out $(RUN_SOURCES) $(TEST_SOURCES), $(ALL_SOURCES))
OBJECTS := $(patsubst %, $(BUILDDIR)/%, $(SOURCES:.$(SRCEXT)=.o))

.SECONDARY: $(RUN_OBJECTS) $(TEST_OBJECTS) $(OBJECTS)

$(BUILDDIR)/%.o: %.$(SRCEXT)
	@mkdir -p $(dir $@)
	$(CC) $(INC) $(CXXFLAGS) -c $< -o $@

$(BINDIR)/%: $(BUILDDIR)/%.o $(OBJECTS)
	@mkdir -p $(dir $@)
	$(CXX) $(LIB) $(LDFLAGS) $^ -o $@

.PHONY: cpp-clean
cpp-clean:  ## clean up C++ project
	rm -rf ./$(BINDIR)/ ./$(BUILDDIR)/

.PHONY: cpp-run
cpp-run: $(RUN_TARGETS)  ## compile and run C++ program
	@for target in $(RUN_TARGETS); do \
		echo $$target >&2; \
		time ./$$target $(INPUT); \
		done

.PHONY: cpp-test
cpp-test: $(TEST_TARGETS)  ## run C++ tests
	@for target in $(TEST_TARGETS); do \
		echo $$target >&2; \
		./$$target; \
		done
