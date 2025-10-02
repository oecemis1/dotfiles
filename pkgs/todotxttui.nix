{
  lib,
  python312Packages,
  fetchFromGitHub,
  makeWrapper,
}:

python312Packages.buildPythonApplication rec {
  pname = "todotxttui";
  version = "unstable-2025-10-02";

  format = "other";

  src = fetchFromGitHub {
    owner = "mdillondc";
    repo = "todo_txt_tui";
    rev = "main";
    sha256 = "0mcmchhl5kjhcflym1iz2ayrl07agfz0pzcm7b7bwj4qhc93dmqq";
  };

  patches = [
    ./todotxttui-search-fix.patch
  ];

  nativeBuildInputs = [ makeWrapper ];

  propagatedBuildInputs = with python312Packages; [
    urwid
    python-dateutil
    aiohttp
  ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
        runHook preInstall
        
        # Copy the entire repository structure to maintain imports
        mkdir -p $out/share/todotxttui
        cp -r . $out/share/todotxttui/
        
        # Create a Python script that serves as the entry point
        mkdir -p $out/bin
        cat > $out/bin/todotxttui <<EOF
    #!${python312Packages.python.interpreter}
    import sys
    sys.path.insert(0, "$out/share/todotxttui")
    from src.main import main

    if __name__ == "__main__":
        main()
    EOF
        chmod +x $out/bin/todotxttui
        
        runHook postInstall
  '';

  meta = with lib; {
    description = "A terminal-based UI for managing todo.txt format task lists with powerful keyboard shortcuts";
    homepage = "https://github.com/mdillondc/todo_txt_tui";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "todotxttui";
    platforms = platforms.unix;
  };
}
