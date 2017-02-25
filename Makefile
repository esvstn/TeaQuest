JAVA_HOME=/lib/jvm/java-7-openjdk
ANDROID_HOME=~/android-sdk-linux
DEV_HOME=$(shell pwd)

AAPT_PATH=$(ANDROID_HOME)/build-tools/25.0.2/aapt
DX_PATH=$(ANDROID_HOME)/build-tools/25.0.2/dx
ANDROID_JAR=$(ANDROID_HOME)/platforms/android-25/android.jar
ADB=$(ANDROID_HOME)/platform-tools/adb

PACKAGE_PATH=com/example/teaquest
PACKAGE=com.example.teaquest
MAIN_CLASS=MainActivity 

all: 
	@echo
	@echo ==================== ENVIRONMENT ====================
	@echo JAVA_HOME = $(JAVA_HOME)
	@echo ANDROID_HOME = $(ANDROID_HOME)
	@echo DEV_HOME = $(DEV_HOME)
	@echo =====================================================
	@echo

	$(AAPT_PATH) package -f -m -S $(DEV_HOME)/res -J $(DEV_HOME)/src -M $(DEV_HOME)/AndroidManifest.xml -I $(ANDROID_JAR)
	
	mkdir -p $(DEV_HOME)/obj
	$(JAVA_HOME)/bin/javac -d $(DEV_HOME)/obj -cp $(ANDROID_JAR) -sourcepath $(DEV_HOME)/src $(DEV_HOME)/src/$(PACKAGE_PATH)/*.java

	mkdir -p $(DEV_HOME)/bin
	$(DX_PATH) --dex --output=$(DEV_HOME)/bin/classes.dex $(DEV_HOME)/obj

	$(AAPT_PATH) package -f -M $(DEV_HOME)/AndroidManifest.xml -S $(DEV_HOME)/res -I $(ANDROID_JAR) -F $(DEV_HOME)/bin/TeaQuest.unsigned.apk $(DEV_HOME)/bin

	$(JAVA_HOME)/bin/keytool -genkey -validity 10000 -dname "CN=AndroidDebug, O=Android, C=US" -keystore $(DEV_HOME)/TeaQuest.keystore -storepass android -keypass android -alias androiddebugkey -keyalg RSA -v -keysize 2048
	$(JAVA_HOME)/bin/jarsigner -sigalg SHA1withRSA -digestalg SHA1 -keystore $(DEV_HOME)/TeaQuest.keystore -storepass android -keypass android -signedjar $(DEV_HOME)/bin/TeaQuest.apk $(DEV_HOME)/bin/TeaQuest.unsigned.apk androiddebugkey

clean:
	rm -rfv $(DEV_HOME)/{obj,bin}
	rm -fv $(DEV_HOME)/src/$(PACKAGE_PATH)/R.java
	rm $(DEV_HOME)/*.keystore
