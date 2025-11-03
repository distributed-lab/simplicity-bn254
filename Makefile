build:
	bash scripts/build.sh

test: 
- all:
	bash scripts/test.sh
- file:
	bash scripts/test-file.sh $(name)


