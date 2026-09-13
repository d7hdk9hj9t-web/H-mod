TARGET := iphone:clang:latest:15.0
ARCHS := arm64
INSTALL_TARGET_PROCESSES := agar.io

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := HALANQI
HALANQI_FILES := Tweak.xm HALANQI/HalanqiMenu.m HALANQI/HalanqiGameBridge.m
HALANQI_CFLAGS := -fobjc-arc
HALANQI_FRAMEWORKS := UIKit Foundation QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
