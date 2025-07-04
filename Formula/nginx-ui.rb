class NginxUi < Formula
  desc     "Yet another Nginx Web UI"
  homepage "https://github.com/0xJacky/nginx-ui"
  version  "2.1.10"
  license  "AGPL-3.0"

  on_macos do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v#{version}/nginx-ui-macos-64.tar.gz"
      sha256  "90270f94adfacdc6c75329a7dbe9b4af9eb1a13009f4bdcc20cb254b6a9e7ee1"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v#{version}/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "41f5d373f044e08e9b1bdbb39ede42b8ba0f3101fdf532b89add1a6c8a80cc94"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v#{version}/nginx-ui-linux-64.tar.gz"
      sha256  "eed8faf8f4a6968f02ce5549ba80e2d138b4635fae174fd2288e27174adf97d4"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v#{version}/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "4af7fca83dca006061aed4195270e6ea4e1e1c5cc8a94c4368523e9c19bfac49"
    end
  end

  def install
    bin.install "nginx-ui"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/nginx-ui --version")
  end
end
