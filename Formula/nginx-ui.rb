class NginxUi < Formula
  desc     "Yet another Nginx Web UI"
  homepage "https://github.com/0xJacky/nginx-ui"
  license  "AGPL-3.0"

  on_macos do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v3.0.8/nginx-ui-macos-64.tar.gz"
      sha256  "9a88028a616c778a73888803141bafc4ff6b45a77274a59db51f170f60ccdf75"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v3.0.8/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "3d4d4b5710412cf82b03824fbdbef93d5dd4ee6d19d2b6082aee36a705bfc22e"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v3.0.8/nginx-ui-linux-64.tar.gz"
      sha256  "c05ea874a5706c394c91044ba9fe0dd53ceb519745a16a559ab67c74b8ed3279"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v3.0.8/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "aeb25dad61ccd7622710925b2b9e31ec2116574ea945b3a7e4c80dd53a89de2c"
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
