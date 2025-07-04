class NginxUi < Formula
  desc     "Yet another Nginx Web UI"
  homepage "https://github.com/0xJacky/nginx-ui"
  version  "2.1.11"
  license  "AGPL-3.0"

  on_macos do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v#{version}/nginx-ui-macos-64.tar.gz"
      sha256  "3d7c3b01d0e51f22a1ab0af837ab652005b113fce53c3388f8b8dd3cd69f9dcf"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v#{version}/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "348ec2509687fcbd6634b911a9ef0d049f9027e7f16334598edf89db08858e25"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v#{version}/nginx-ui-linux-64.tar.gz"
      sha256  "9b1efa41a0d7c9bbadd77f25cd1e9870d601954cb9977606df09a5b58b5114dc"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v#{version}/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "bd6068991a62eeaee60b57eb76055719008fe6af689abd42b25d8ecf13b82658"
    end
  end

  def install
    bin.install "nginx-ui"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/nginx-ui --version")
  end
end
