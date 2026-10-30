class NginxUi < Formula
  desc     "Yet another Nginx Web UI"
  homepage "https://github.com/0xJacky/nginx-ui"
  license  "AGPL-3.0"

  on_macos do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.9.2/nginx-ui-macos-64.tar.gz"
      sha256  "440419cae4a294bf1f44a22da3b8a11b94cac550306062712c741de4114dc997"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.9.2/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "3dbbff6e1b877bcc6e7463d21c8e8c62095d1f951231aff15137e248edb50a55"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.9.2/nginx-ui-linux-64.tar.gz"
      sha256  "4983e72129500b392733fc005bee73074db4e1b10d37ed3fab392ac0af02df4c"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.9.2/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "2720fb07a43e69e14e62d8aa264d09c609aa9a18d5ee466f7f9866a17dd38509"
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
