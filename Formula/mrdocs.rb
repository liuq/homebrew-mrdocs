class Mrdocs < Formula
  desc "C++ reference documentation generator"
  homepage "https://www.mrdocs.com"
  url "https://github.com/cppalliance/mrdocs.git",
      tag:      "2026.9.29",
      revision: "6a984f66cf770ee5808bc0f53614c522c68fa507"
  license "Apache-2.0" => { with: "LLVM-exception" }

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "python@3.14" => :build
  depends_on "llvm"

  conflicts_with "mrdocs-bin", because: "both install the same files"

  # Versions and build options follow utils/bootstrap/recipes/*.json;
  # the CMake packaging comes from utils/bootstrap/patches/*.
  resource "lua" do
    url "https://github.com/lua/lua/archive/refs/tags/v5.4.8.tar.gz"
    sha256 "d85b70a65f43c5d2254944d58d625e822c8e2e10d9c6a3bd9b5b657e46376a19"
  end

  resource "jerryscript" do
    url "https://github.com/jerryscript-project/jerryscript/archive/refs/tags/v3.0.0.tar.gz"
    sha256 "4d586d922ba575d95482693a45169ebe6cb539c4b5a0d256a6651a39e47bf0fc"
  end

  # Missing explicit instantiation; the link fails when the compiler inlines
  # the implicit one (e.g. with Homebrew's LLVM 23.1).
  patch :DATA

  def install
    llvm = Formula["llvm"]
    deps = buildpath/"deps"
    patches = buildpath/"utils/bootstrap/patches"

    resource("lua").stage do
      cp_r Dir[patches/"lua/*"], "."
      system "cmake", "-S", ".", "-B", "build", "-G", "Ninja", *std_cmake_args(install_prefix: deps/"lua")
      system "cmake", "--build", "build", "--target", "install"
    end

    resource("jerryscript").stage do
      cp_r Dir[patches/"jerryscript/*"], "."
      system "cmake", "-S", ".", "-B", "build", "-G", "Ninja",
             "-DJERRY_PROFILE=es.next",
             "-DJERRY_EXTERNAL_CONTEXT=ON",
             "-DJERRY_CPOINTER_32_BIT=ON",
             "-DJERRY_PORT=ON",
             "-DJERRY_LIBC=OFF",
             "-DJERRY_LTO=OFF",
             *std_cmake_args(install_prefix: deps/"jerryscript")
      system "cmake", "--build", "build", "--target", "install"
    end

    args = %W[
      -DCMAKE_C_COMPILER=#{llvm.opt_bin}/clang
      -DCMAKE_CXX_COMPILER=#{llvm.opt_bin}/clang++
      -DLLVM_ROOT=#{llvm.opt_prefix}
      -Djerryscript_ROOT=#{deps}/jerryscript
      -DLua_ROOT=#{deps}/lua
      -DPYTHON_EXECUTABLE=#{which("python3.14")}
      -DMRDOCS_BUILD_TESTS=OFF
      -DMRDOCS_BUILD_DOCS=OFF
      -DMRDOCS_PACKAGE=OFF
    ]
    system "cmake", "-S", ".", "-B", "build", "-G", "Ninja", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    assert_match "Release: #{version}", shell_output("#{bin}/mrdocs --version")

    (testpath/"hello.hpp").write <<~CPP
      /** A greeting function. */
      int hello();
    CPP
    (testpath/"mrdocs.yml").write <<~YAML
      source-root: .
      input: [.]
      file-patterns: ["*.hpp"]
      generator: adoc
      multipage: false
      output: out
    YAML
    (testpath/"compile_commands.json").write <<~JSON
      [{"directory": "#{testpath}", "file": "#{testpath}/hello.hpp",
        "arguments": ["clang++", "-std=c++20", "-x", "c++-header", "#{testpath}/hello.hpp"]}]
    JSON
    system bin/"mrdocs", "mrdocs.yml", "compile_commands.json"
    assert_match "hello", (testpath/"out/reference.adoc").read
  end
end

__END__
diff --git a/src/mrdocs/AST/ASTVisitor.cpp b/src/mrdocs/AST/ASTVisitor.cpp
--- a/src/mrdocs/AST/ASTVisitor.cpp
+++ b/src/mrdocs/AST/ASTVisitor.cpp
@@ -1713,6 +1713,13 @@ populate<std::uint64_t>(
     clang::Expr const* E,
     llvm::APInt const& V);
 
+template
+void
+ASTVisitor::
+populate<std::uint64_t>(
+    ConstantExprInfo<std::uint64_t>& I,
+    clang::Expr const* E);
+
 
 void
 ASTVisitor::
