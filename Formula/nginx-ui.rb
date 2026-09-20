class NginxUi < Formula
  desc     "Yet another Nginx Web UI"
  homepage "https://github.com/0xJacky/nginx-ui"
  license  "AGPL-3.0"

  on_macos do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.6.2/nginx-ui-macos-64.tar.gz"
      sha256  "810fb1c3c0f2755c8b2299c4ab4e38038fc4b86a5e7b83edd7537164a25ba34f"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.6.2/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "3ef4b1cb5abb61ae22e3880b2dfacbde96779464ee406492e390dc7ec48daa3b"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.6.2/nginx-ui-linux-64.tar.gz"
      sha256  "16bd711462cc3a24babfa43a4989f1823f1755046a428c4165a3eaa2d14d78a1"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.6.2/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "b57b0f19b4e98f6077ed093e8a9a38bccc290a6f3dd7c0650be18a69cfcafbf2"
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
