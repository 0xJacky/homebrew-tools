class NginxUi < Formula
  desc     "Yet another Nginx Web UI"
  homepage "https://github.com/0xJacky/nginx-ui"
  license  "AGPL-3.0"

  bottle do
    root_url "https://ghcr.io/v2/0xjacky/tools"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "2dcc2c19bfd1380eca9327a004cfaa4e432deeb93138c9f60680998cee3c3e76"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "031ce432dd2c91c0e039dee92d82d1b3a58a2a73e14061d055229bee2d0a9c06"
  end

  on_macos do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v3.0.5/nginx-ui-macos-64.tar.gz"
      sha256  "94078a1fb0f102caa19e80846fe8cdae24412dfe18d367b5f7e146089e0ddd38"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v3.0.5/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "02ec7e7bf5c8d895af462a58c024839167ebc93356b8bfb01a0014388e1c5758"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v3.0.5/nginx-ui-linux-64.tar.gz"
      sha256  "1cc81a047de5d60e936b637332c94a18ffa56e6fb76bea71b4d50e138b9c056d"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v3.0.5/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "1748ff03b05c3db3e351a7d92a262f380d241cac0985000c5e04d16a5503c3b9"
    end
  end

  def install
    bin.install "nginx-ui"

    # Create configuration directory
    (etc/"nginx-ui").mkpath

    # Create default configuration file if it doesn't exist
    config_file = etc/"nginx-ui/app.ini"
    unless config_file.exist?
      config_file.write <<~EOS
        [app]
        PageSize = 10

        [server]
        Host = 0.0.0.0
        Port = 9000
        RunMode = release

        [cert]
        HTTPChallengePort = 9180

        [terminal]
        StartCmd = login
      EOS
    end

    # Create data directory
    (var/"nginx-ui").mkpath
  end

  post_install_steps do
    # Ensure correct permissions
    set_permissions "nginx-ui", "0755", base: :var, recursive: false
  end

  service do
    run [opt_bin/"nginx-ui", "serve", "--config", etc/"nginx-ui/app.ini"]
    keep_alive true
    working_dir var/"nginx-ui"
    log_path var/"log/nginx-ui.log"
    error_log_path var/"log/nginx-ui.err.log"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/nginx-ui --version")
  end
end
