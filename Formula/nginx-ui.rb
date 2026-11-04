class NginxUi < Formula
  desc     "Yet another Nginx Web UI"
  homepage "https://github.com/0xJacky/nginx-ui"
  license  "AGPL-3.0"

  on_macos do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.9.5/nginx-ui-macos-64.tar.gz"
      sha256  "198eb6d80081df8db3d821e35b63009f1b34a03af235ed4b9ef3611b783f9d97"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.9.5/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "8bdae637afd95440af669866ff325b52c29e721134d4cc03a5f9bb2222bc29d0"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.9.5/nginx-ui-linux-64.tar.gz"
      sha256  "24232b9c6096ed06e77815cc1e47adccee1348598de270fb79d367da8209f95a"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.9.5/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "4ac0d4a9464f8359aad1686a8cedf1686863dd8edbc774c46525fb22a23df58d"
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
