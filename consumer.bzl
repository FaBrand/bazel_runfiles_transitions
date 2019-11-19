def _consumer_impl(ctx):
    if ctx.attr.is_windows:
        runfiles_for_batch = ['for /f "tokens=1,2" %%G in (MANIFEST) do set %%G=%%H']
        content = "\n".join(runfiles_for_batch + ["CALL %{}/{}%".format(ctx.workspace_name, f.short_path) for f in ctx.files.srcs])
        extension = ".bat"
    else:
        content = "\n".join(["./{}".format(f.short_path) for f in ctx.files.srcs])
        extension = ""

    out = ctx.actions.declare_file(ctx.label.name + extension)
    ctx.actions.write(output = out, content = content)

    runfiles = ctx.runfiles(files = ctx.files.srcs)

    return DefaultInfo(
        executable = out,
        runfiles = runfiles,
        files = depset(direct = [out]),
    )

_consumer = rule(
    implementation = _consumer_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "is_windows": attr.bool(),
    },
    executable = True,
)

def consumer(**kwargs):
    kwargs.setdefault("is_windows", select({
        "@bazel_tools//src/conditions:host_windows": True,
        "//conditions:default": False,
    }))
    _consumer(**kwargs)
