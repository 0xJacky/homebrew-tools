class NginxUi < Formula
  desc     "Yet another Nginx Web UI"
  homepage "https://github.com/0xJacky/nginx-ui"
  license  "AGPL-3.0"

  on_macos do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.9.4/nginx-ui-macos-64.tar.gz"
      sha256  "3dd79ff4e9847010c3de2f5bf23904553fd3b96a6d1805ff23f5eff6ce076a1e"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.9.4/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "c78245c07bbe776448c92ce36c3b03eb994f0bfb9ca01cb14814855fd5eb93d9"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.9.4/nginx-ui-linux-64.tar.gz"
      sha256  "0b75ad32d675f8e38fb3d4864cf3f87928bfa7edc122fe64bad382cff7a0af04"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.9.4/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "ca2bbe71693286161227eda2362c10ec160e133653d14a45c9f8ccc6c583e58a"
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
