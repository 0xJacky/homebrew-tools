class NginxUi < Formula
  desc     "Yet another Nginx Web UI"
  homepage "https://github.com/0xJacky/nginx-ui"
  license  "AGPL-3.0"

  on_macos do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.9.0/nginx-ui-macos-64.tar.gz"
      sha256  "28a5dcce07920c95d836039bc862b89275e8faffe122f4d6014842f051cc463b"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.9.0/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "6491b0797568961a70634d82d3c0d03c3edfb828f8d00cbd39d6f33d4908866f"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.9.0/nginx-ui-linux-64.tar.gz"
      sha256  "c850933332965fd06df3bcbe4b6c8bfb72f8bf1e923eadd165e56992397d048e"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.9.0/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "8c28cbfa56c079a701176a28d300cb3db57c2abfc214e0060fade6be0e5ce06a"
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
