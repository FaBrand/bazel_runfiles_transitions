# Description
Bazel seems to compile a dependency with the wrong configuration, if a binary depends on multiple binaries, that implement transitions, through runfiles.

# Example to reproduce it
A source file is compiled with different flags.
The flags are set via transitions.

One configuration is buildable and the other is not:

- For one configuration (variant_a) the included header can be found.
- For one configuration (variant_b) the included header can not be found.

The header is included only if a copt `-DVARIANTA/B` is set.
To use different compiled versions of the "library" transitions define the flag accordingly.

Another target depends on these two binaries that are built with different configurations through runfiles.

# Error
If a rule adds two binaries with different transitions, one is built with the wrong set of flags.
This is expressed by the compilation failing because of the missing header.

To get the error, run or build "//:consumer"

```
bazel run //:consumer
```

If only one of the targets is a dependency, the build succeeds.
If the binaries are not added as runfiles, the build succeeds, but the run fails because of missing runfiles.
