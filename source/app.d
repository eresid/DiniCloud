import std.range;
import std.stdio;

void main(string[] args) {
    if (args.length > 1) {
        generateProject(args[1]);
        runProject();
    } else {
        writeln("Please select script, example: builder somescript.d");
    }
}

string fileToString(string filePath) {
    auto file = File(filePath);
    auto code = "";

    foreach (line; file.byLine()) {
        code ~= line ~ "\\n\\t";
    }

    return code;
}

void generateProject(string scriptPath) {
    import std.file;
    import std.process;
    import std.regex;
    import std.algorithm.searching;

    deleteFolder("project");

    auto pid = spawnShell("cp -R template project/");
    wait(pid);

    string genBlock = "GENCODE";

    auto projectFile = File("project/source/app.d");
    auto result = "";

    foreach (line; projectFile.byLine()) {
        if (canFind(line, genBlock)) {
            auto scriptFile = File(scriptPath);

            foreach (sline; scriptFile.byLine()) {
                result ~= "\t" ~ sline ~ "\n";
            }
        } else {
            result ~= line ~ "\n";
        }
    }

    log(result);

    write("project/source/app.d", result);
}

void runProject() {
    import std.process;

    auto pid2 = spawnShell("dub --root=project/");
    wait(pid2);
}

void deleteFolder(string value) {
    import std.process;
    import std.file;

    if (exists(value)) {
        spawnShell("rm -r " ~ value);
    }
}

void log(string msg) {
    debug {
        writeln(msg);
    }
}