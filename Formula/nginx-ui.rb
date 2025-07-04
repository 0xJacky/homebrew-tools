
class NginxUi < Formula
  desc     "Yet another Nginx Web UI"
  homepage "https://github.com/0xJacky/nginx-ui"
  version  "2.1.11"
  license  "AGPL-3.0"

  on_macos do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v#{version}/nginx-ui-macos-64.tar.gz"
      sha256  "32b302624e0470a415682f8aedbb18934f89536f06e1744714fdf6a72d2fff49"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v#{version}/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "fa84fdb5547397aa9ef9be58106233188d2651cf1e67b813ecf61dde769750cc"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v#{version}/nginx-ui-linux-64.tar.gz"
      sha256  "5a16df80e3a808e4be59ef60aaafc76c8809b82dd5b6453b035cff19d31c6a85"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v#{version}/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "2c7d0fbaafacf1fcf713604dc31bad232a03214191e79cb02fbb38f3469c263e"
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
    (var/"nginx-ui/ca").mkpath
    (var/"log/nginx-ui").mkpath
  end

  def post_install
    # Ensure correct permissions
    (var/"nginx-ui").chmod 0755
  end

  service do
    run [opt_bin/"nginx-ui", "serve", "--config", etc/"nginx-ui/app.ini"]
    keep_alive true
    working_dir var/"nginx-ui"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/nginx-ui --version")
  end
end
