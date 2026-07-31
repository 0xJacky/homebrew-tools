class NginxUi < Formula
  desc     "Yet another Nginx Web UI"
  homepage "https://github.com/0xJacky/nginx-ui"
  license  "AGPL-3.0"

  on_macos do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.5.3/nginx-ui-macos-64.tar.gz"
      sha256  "29f31da9811b2de5b3eb593433c87487054e7bb991459ce9620a08d7f4dfd262"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.5.3/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "6d6b1a0c78b8c54891a8401294a4cc8373aa3e3079c3bd59df42146a6c70b4b6"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.5.3/nginx-ui-linux-64.tar.gz"
      sha256  "4ebbfdb6f0b0fb31e9042b8d3ab5eaefd5632e12c5e4e8b127adc1940e0f202c"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.5.3/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "83543fa944db645225a091f873215184feaee65b90a1f074b7a33575030f0c92"
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
