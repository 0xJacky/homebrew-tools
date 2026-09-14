class NginxUi < Formula
  desc     "Yet another Nginx Web UI"
  homepage "https://github.com/0xJacky/nginx-ui"
  license  "AGPL-3.0"

  on_macos do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.6.0/nginx-ui-macos-64.tar.gz"
      sha256  "ab29d1b8c89778ba7e919dcfe76aa9b63e4cf8df40a59b7c2be8d94f1af4032d"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.6.0/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "d8ba7943cb4358a180b60c33cb15e587a066179d6ff16e6166dbd0b2672d7852"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.6.0/nginx-ui-linux-64.tar.gz"
      sha256  "5b79261c05c30ce87e0a1c7d57af57d0479a515443e1dff2c85fffa5714b73c0"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.6.0/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "eb5cd8bbe640fb5505deaeb98c6a880f6bee85b917d3ab698097de1c0e303ea8"
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
