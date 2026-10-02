class NginxUi < Formula
  desc     "Yet another Nginx Web UI"
  homepage "https://github.com/0xJacky/nginx-ui"
  license  "AGPL-3.0"

  on_macos do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.8.2/nginx-ui-macos-64.tar.gz"
      sha256  "106c791cad843a43a31cb5856903274d769d5a61c06262d1031aa48196a01135"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.8.2/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "fc40c47935afbd78d4a7cd7002949722b15d9308e68e33e373f992bf247e3ade"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.8.2/nginx-ui-linux-64.tar.gz"
      sha256  "a11786d6bd25f23071939bccae21ee91c1e43b89f4d7bb9222c5666483f5114f"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.8.2/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "cc78be2854abb509899c6f3d2a3f1717767a275e6b89a6c10c61b60cf898c317"
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
