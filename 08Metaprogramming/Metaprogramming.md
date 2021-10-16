# Metaprogramming: The Process of Writing Code

## Build Systems

- Elements of a build system
  - dependencies
  - targets
  - rules

- Build systems avoid executing unnecessary rules for a targets whose dependencies haven't changed

- `make`: a common tool

  ```makefile
  paper.pdf: paper.tex plot-data.png
  	pdflatex paper.tex
  
  plot-%.png: %.dat plot.py
  	./plot.py -i $*.dat -o $@
  ```

  - Produce the left-hand side using the right-hand side
    - *Left-hand side*: target
    - *Right-hand side*: dependencies
    - *Indented blocks*: a sequence of programs to produce the target from those dependencies
    - *%*: the pattern to match, the requested `plot-foo.png` will use `foo.dat`

## Dependency Management

- Semantice Versioning: something like `1.3.7`
  - If a release does not change the API, like fixing a security issue, increase the patch version `1.3.8`
  - If you add to your API in a backwards-compatible way, increase the minor version `1.4.0`
  - If you change the API in a non-backwards-compatible way, increase the major version `2.0.0`

- **Lock files** lists the exact version you are currently depending on of each dependency
  - avoid unnecessary recompiles
  - have reproducible builds
  - not automatically update to the latest version
  - An extreme version: vendoring
    - copy all the code of your dependencies(transformers 4.1.0) into your own changes to it

## Continuous Integration Systems

- Continuous integration: "stuff that runs whenever your code changes"
  - Add a file to describe what should happen when various things happen to your repository
    - Travis CI
    - Azure Pipelines
    - Github Actions
  - The most common case: "when someone pushes code, run the test suite"
  - The class website is another example that runs the Jekyll blog software on every push to `master`

## Testing Terminology

- Test suite: a collective term for all the tests
- Unit test: a "micro-test" that tests a specific feature in isolation
- Integration test: a "macro-test" that runs a larger part of the system to check that different feature or components **work together**
- Regression test: a test that implements a particular pattern that previously caused a bug to ensure that bug does not resurface
- Mocking: to replace a function, module or type with a fake implementation to avoid testing unrelated functionality. 

