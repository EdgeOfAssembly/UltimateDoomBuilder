
BUILDTYPE ?= Release
CXX       ?= g++

# ---------------------------------------------------------------------------
# Build-tool detection: prefer msbuild (mono-project.com), fall back to xbuild
# (available as 'mono-xbuild' in Debian/Ubuntu package repos).
# ---------------------------------------------------------------------------
MSBUILD := $(shell command -v msbuild 2>/dev/null || command -v xbuild 2>/dev/null)

# ---------------------------------------------------------------------------
# Optional native-library dependency detection.
# The native library (libBuilderNative.so) enables the 3D rendering viewport.
# It requires a C++ compiler and X11 + OpenGL development headers.
# If any of these are absent the C# application still builds and runs, but
# the 3D view will not be available.
# ---------------------------------------------------------------------------
HAS_CXX    := $(shell command -v $(CXX) 2>/dev/null)
HAS_X11    := $(shell test -f /usr/include/X11/Xlib.h    && echo yes)
HAS_GL     := $(shell test -f /usr/include/GL/gl.h       && echo yes)
# Xfixes is optional: enables cursor hide/show in the 3D view.
HAS_XFIXES := $(shell test -f /usr/include/X11/extensions/Xfixes.h && echo yes)

CAN_BUILD_NATIVE := $(and $(HAS_CXX),$(HAS_X11),$(HAS_GL))

XFIXES_CFLAG  := $(if $(HAS_XFIXES),-DHAVE_XFIXES=1)
XFIXES_LDFLAG := $(if $(HAS_XFIXES),-lXfixes)

.PHONY: all linux mac builder native nativemac run

all: linux

run:
	cd Build && mono Builder.exe

linux: builder
	@if [ -n "$(CAN_BUILD_NATIVE)" ]; then \
		$(MAKE) native; \
	else \
		echo ""; \
		echo "NOTE: Skipping native rendering library (libBuilderNative.so)."; \
		echo "      3D rendering will not be available."; \
		echo "      To enable: sudo apt install g++ libx11-dev mesa-common-dev"; \
		echo ""; \
	fi

mac: builder nativemac

builder:
	@if [ -z "$(MSBUILD)" ]; then \
		echo "ERROR: No MSBuild-compatible build tool found."; \
		echo "       Minimum install (Ubuntu/Debian):"; \
		echo "         sudo apt install mono-complete mono-xbuild"; \
		echo "       Latest Mono with msbuild: https://www.mono-project.com/download/stable/"; \
		exit 1; \
	fi
	$(MSBUILD) BuilderMono.sln /nologo /verbosity:minimal /p:Configuration=$(BUILDTYPE)
	cp builder.sh Build/builder
	chmod +x Build/builder

nativemac:
	$(CXX) -std=c++14 -O2 --shared -g3 -o Build/libBuilderNative.so -fPIC \
		-I Source/Native \
		Source/Native/*.cpp \
		Source/Native/OpenGL/*.cpp \
		Source/Native/OpenGL/gl_load/*.c \
		-ldl

native:
	$(CXX) -std=c++14 -O2 --shared -g3 -o Build/libBuilderNative.so -fPIC \
		-I Source/Native \
		Source/Native/*.cpp \
		Source/Native/OpenGL/*.cpp \
		Source/Native/OpenGL/gl_load/*.c \
		-DUDB_LINUX=1 $(XFIXES_CFLAG) \
		-lX11 $(XFIXES_LDFLAG) -ldl
