class NginxUi < Formula
  desc     "Yet another Nginx Web UI"
  homepage "https://github.com/0xJacky/nginx-ui"
  license  "AGPL-3.0"

  bottle do
    root_url "https://ghcr.io/v2/0xjacky/tools"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "2dcc2c19bfd1380eca9327a004cfaa4e432deeb93138c9f60680998cee3c3e76"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "031ce432dd2c91c0e039dee92d82d1b3a58a2a73e14061d055229bee2d0a9c06"
  end

  on_macos do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v3.0.3/nginx-ui-macos-64.tar.gz"
      sha256  "aff1e394d145a271a43d3d22885ccdaf7040436755751f126d9f5554c6927528"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v3.0.3/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "6471e35202ea09069e9950406f87b3ad0798323701cbe5ae4eef5016d174dbe4"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v3.0.3/nginx-ui-linux-64.tar.gz"
      sha256  "da98fd4c7d65764d9fba02232d247fc3c858aff04bc4cbbe2509a8cc2e9ae8bc"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v3.0.3/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "c759971d3ec632e6a208a690d8edfc8a0000b1baf9fbd3bb1276ce98738694ad"
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
