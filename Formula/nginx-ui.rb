class NginxUi < Formula
  desc     "Yet another Nginx Web UI"
  homepage "https://github.com/0xJacky/nginx-ui"
  license  "AGPL-3.0"

  on_macos do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.5.2/nginx-ui-macos-64.tar.gz"
      sha256  "7c9292c8c36faa249d0216e0cbb74cf9c3ace828f8ee545044cb530edfa441ba"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.5.2/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "3be19e19ac7da461d587a461336503a8f8e06db4e499bbfb155344290017c49a"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.5.2/nginx-ui-linux-64.tar.gz"
      sha256  "1b53e43e3d7a1b10827bc79935e54aabf809e1dcb0c9c5d29e11fd2c09699fd4"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.5.2/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "9423e51f15eaeae5eff81914f3703812d6cec27f39ccc2b4d996f61fa2994b9f"
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

  def post_install
    # Ensure correct permissions
    (var/"nginx-ui").chmod 0755
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
