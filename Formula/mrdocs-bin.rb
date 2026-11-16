class MrdocsBin < Formula
  desc "C++ reference documentation generator (prebuilt upstream binaries)"
  homepage "https://www.mrdocs.com"
  license "Apache-2.0" => { with: "LLVM-exception" }

  livecheck do
    url :stable
    strategy :github_latest
  end

  on_macos do
    on_arm do
      url "https://github.com/cppalliance/mrdocs/releases/download/2026.11.10/MrDocs-2026.11.10-Darwin.tar.xz"
      sha256 "43531f3071be4291c54e8fe0658fd9daafd2079c75584c4af76854d1df28a4b5"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/cppalliance/mrdocs/releases/download/2026.11.10/MrDocs-2026.11.10-Linux.tar.xz"
      sha256 "c7e24b9986ec27740582a01b8ca6f86efcda105d0eaedb5faf10d9acf563ef14"
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
