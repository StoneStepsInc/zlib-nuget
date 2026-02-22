## applib

This is an application-level static library project using zLib.

In the default configuration, this library is built with just
zLib references, relying on the project that links against this
library to include the zLib static library. If you would like
this application-level library to include all members of zLib,
use the `lib` tool, as shown below, in the _Post-Build Event_
within the project (on one line, without the `^` character).

    lib /OUT:$(OutDir)$(ProjectName).lib ^
      $(OutDir)$(ProjectName).lib ^
      $(ZLibDir)lib\$(Platform)\$(Configuration)\$(zLibName).lib

For debug configurations, add the suffix `d` to the zLib library
name: `$(zLibName)d.lib`.

Verify the resulting library with the `dumpbin` tool as shown below.

    dumpbin /symbols sample-zpipe\x64\Debug\applib.lib | findstr compressBound

When the application-level library is built with zLib references,
this command will produce output similar to that below, which shows
the zLib function `compressBound` referenced in `applib.lib` as
`UNDEF`, meaning that it is expected to be provided by the zLib
library during linking.

    3CF 00000000 UNDEF  notype ()    External     | compressBound

The same `dumpbin` command run against the application-level library
merged with zLib will produce output similar to that below, which
shows `compressBound` defined in one of the sections, so the main
project will link against the application-level library without
referencing zLib explicitly.

    3CF 00000000 UNDEF  notype ()    External     | compressBound
    00F 000003E0 SECT3  notype ()    External     | compressBound
    010 00000430 SECT3  notype ()    External     | compressBound_z
    02F 00000024 SECT4  notype       Static       | $unwind$compressBound
    030 00000030 SECT5  notype       Static       | $pdata$compressBound
    031 0000002C SECT4  notype       Static       | $unwind$compressBound_z
    032 0000003C SECT5  notype       Static       | $pdata$compressBound_z
