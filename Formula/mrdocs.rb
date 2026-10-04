class Mrdocs < Formula
  desc "C++ reference documentation generator"
  homepage "https://www.mrdocs.com"
  license "BSL-1.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  on_macos do
    on_arm do
      url "https://github.com/cppalliance/mrdocs/releases/download/2026.9.29/MrDocs-2026.9.29-Darwin.tar.xz"
      sha256 "b393adf3df2180fc00edd50d6a976a79de3a1b9fbab0e93844495e4faa1c8435"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/cppalliance/mrdocs/releases/download/2026.9.29/MrDocs-2026.9.29-Linux.tar.xz"
      sha256 "9d96e42f303046fb0b221aa9071eabccc40b9683e0b7af2b02a929d15476ca6a"
    end
  end

  # Upstream only ships prebuilt binaries for Apple Silicon and Linux x86_64.
  depends_on arch: :arm64 if OS.mac?

  def install
    # mrdocs locates share/mrdocs (addons, bundled headers) relative to bin/,
    # so keep the upstream layout intact.
    prefix.install Dir["*"]
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
    assert_match "hello", Dir[testpath/"out/**/*"].select { |f| File.file?(f) }.map { |f| File.read(f) }.join
  end
end
