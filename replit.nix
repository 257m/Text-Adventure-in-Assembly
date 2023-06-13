{ pkgs }: {
	deps = [
		pkgs.nasm
		pkgs.clang_12
		pkgs.gdb
		pkgs.gnumake
	];
}