classdump: Makefile classdump.mm
	clang++ -fobjc-link-runtime -std=c++20 -framework ScreenSaver classdump.mm -o classdump

clean: 
	rm classdump

