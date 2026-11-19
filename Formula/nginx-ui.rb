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
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v3.0.6/nginx-ui-macos-64.tar.gz"
      sha256  "787a6b0ffc14b0dbcad705db0c135c295517c2f15ca697e00f1b81c782689edb"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v3.0.6/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "2f0fe76a127c4ea3d4a4022da1b55d73055eb692a2eb779ad6f12fa9d40e2626"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v3.0.6/nginx-ui-linux-64.tar.gz"
      sha256  "3373fbc0eb9b57def584c6c75e88f88b496e981ae69cb44c3f0adc2970c43d86"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v3.0.6/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "f9d2ce582dfc829bc30a308e5cf01d4bca81183e9f86041d1b9c14700dca4926"
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
