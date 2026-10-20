GCC_FLAGS= -m32 -mtune=i386 
AS_FLAGS= --32 
all: bin/telemetry

obj/telemetry.o:	src/telemetry.s
	as $(AS_FLAGS) src/telemetry.s -o obj/telemetry.o
obj/itoa.o:	src/itoa.s	obj/telemetry.o	
	as $(AS_FLAGS) src/itoa.s -o obj/itoa.o
obj/newLine.o:	src/newLine.s	obj/itoa.o	
	as $(AS_FLAGS) src/newLine.s -o obj/newLine.o
obj/strcmp.o:	src/strcmp.s	obj/newLine.o
	as $(AS_FLAGS) src/strcmp.s -o obj/strcmp.o
obj/searchId.o:	src/searchId.s	obj/strcmp.o	
	as $(AS_FLAGS) src/searchId.s -o obj/searchId.o
obj/date_elaboration.o: src/date_elaboration.s	obj/searchId.o	
	as $(AS_FLAGS) src/date_elaboration.s -o obj/date_elaboration.o
obj/print.o: src/print.s	obj/date_elaboration.o	
	as $(AS_FLAGS) src/print.s -o obj/print.o
obj/str2num.o: src/str2num.s	obj/print.o	
	as $(AS_FLAGS) src/str2num.s -o obj/str2num.o
obj/main.o: src/main.c	obj/str2num.o	
	gcc  $(GCC_FLAGS) -c src/main.c -o obj/main.o
bin/telemetry:	obj/main.o
	gcc $(GCC_FLAGS) obj/main.o obj/telemetry.o obj/strcmp.o obj/newLine.o obj/itoa.o obj/date_elaboration.o obj/str2num.o obj/print.o obj/searchId.o -o bin/telemetry

clean:
	rm -f obj/* bin/*
