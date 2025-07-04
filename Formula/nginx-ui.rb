class NginxUi < Formula
  desc     "Yet another Nginx Web UI"
  homepage "https://github.com/0xJacky/nginx-ui"
  version  "2.1.12"
  license  "AGPL-3.0"

  on_macos do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v#{version}/nginx-ui-macos-64.tar.gz"
      sha256  "21a0c2cd7437627214c40d4b55ccfa0e5300e16a3b541c61c09871c553743714"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v#{version}/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "31c0b0868750056a6e96640b99aca8dde13e609ec4b00c232058126d94f86814"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v#{version}/nginx-ui-linux-64.tar.gz"
      sha256  "72edc77ff39735b7b738047727ec14b384756c4a3b6c69e5c60e589974f778b3"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v#{version}/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "0a595234baed5350c0adf02a716814166e8ca2eecce36b78ab8dedab19a5bf87"
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

  def post_install
    # Ensure correct permissions
    (var/"nginx-ui").chmod 0755
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
