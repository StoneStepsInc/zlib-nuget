This package contains static zLib libraries and header files for
Win32/x64 platforms. There are no dynamic libraries included.

The zLib static library appropriate for the platform and
configuration selected in a Visual Studio solution is explicitly
referenced within this package and will appear within the solution
folder tree after the package is installed. The solution may need
to be reloaded to make the library file visible. This library may
be moved into any solution folder after the installation.

Note that the zLib library path in this package will be selected
as Debug or Release based on the presence of the preprocessor
symbol NDEBUG, which is required to be defined for non-debug
builds (see C99, _7.2 Diagnostics <assert.h>). Do not install
this package if your projects do not define NDEBUG as described.

The static library is built with the stdcall calling convention.

The non-debug versions of the library are built with NDEBUG
defined, so assert calls work as intended for Debug and Release
configurations.
