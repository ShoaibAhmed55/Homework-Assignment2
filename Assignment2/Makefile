COMPONENT=Assignment2AppC
BUILD_EXTRA_DEPS=SenseResponseMsg.class
CLEAN_EXTRA = *.class SenseResponseMsg.java SenseRequestMsg.java
SenseResponseMsg.class: SenseResponseMsg.java
	javac SenseResponseMsg.java
SenseResponseMsg.java:
	mig java -target=null -java-classname=SenseResponseMsg SenseResponseMsg.h SenseResponseMsg -o SenseResponseMsg.java
BUILD_EXTRA_DEPS+=SenseRequestMsg.class
SenseRequestMsg.class: SenseRequestMsg.java
	javac SenseRequestMsg.java
SenseRequestMsg.java:
	mig java -target=null -java-classname=SenseRequestMsg SenseRequestMsg.h SenseRequestMsg -o SenseRequestMsg.java
BUILD_EXTRA_DEPS+=Communicate.class
Communicate.class: Communicate.java
	javac Communicate.java
include $(MAKERULES)