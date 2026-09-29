class NginxUi < Formula
  desc     "Yet another Nginx Web UI"
  homepage "https://github.com/0xJacky/nginx-ui"
  license  "AGPL-3.0"

  on_macos do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.8.0/nginx-ui-macos-64.tar.gz"
      sha256  "44af0c4f0988d1f38b59274b52f758da4ba315dcbf0ca043892843fe77d628d2"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.8.0/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "1532d81375a5d3363008b8d69e757d6f9c5aead814986075fb4c0e1ec2eb7786"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.8.0/nginx-ui-linux-64.tar.gz"
      sha256  "f402d062f9ee5e81ef249c2b96e9488c68aff4e799a6996e38ff78037a68afb9"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.8.0/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "8d012ec97b901c70921d687e102aefe7a1e8bc282ea1b2213c11d7716499753d"
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
