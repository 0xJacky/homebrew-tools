class NginxUi < Formula
  desc     "Yet another Nginx Web UI"
  homepage "https://github.com/0xJacky/nginx-ui"
  license  "AGPL-3.0"

  on_macos do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.8.1/nginx-ui-macos-64.tar.gz"
      sha256  "d22007cffa99c33b3321bd4320d99a8021ab57a8a5e3b60b9aa909b96df3a957"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.8.1/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "e5ddc112ede49f6df7b6b799efda6a15fc0794aeffa70a9bfdf89ed12ba431d7"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.8.1/nginx-ui-linux-64.tar.gz"
      sha256  "83e8c1c4589b70f14ed404f20c18fabac86aa55e1c413c1c9692f2449ecc6177"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.8.1/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "d656c73555eee031be0e7c9549e156e74d3c53d00a88b95e75fc9f6456f32517"
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
