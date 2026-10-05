class NginxUi < Formula
  desc     "Yet another Nginx Web UI"
  homepage "https://github.com/0xJacky/nginx-ui"
  license  "AGPL-3.0"

  on_macos do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.8.3/nginx-ui-macos-64.tar.gz"
      sha256  "b6e87bc1bcd686d4a46692c90cbae90f82f11b97e3a3456003bfcf3ab791255d"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.8.3/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "f7e74c41ec07af2ae526073a932a387c96060a2ed7afc23ee4ae534d5aa05ea1"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.8.3/nginx-ui-linux-64.tar.gz"
      sha256  "c23c9121cd544f5acf01d24e26d561d20a8a77cd2af5b841ab10262c818a27cb"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.8.3/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "a3cb5f0f00a15da00262b03badf7abb22b0d1d375cf0daca3b31df6231314e3f"
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
