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
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v3.0.4/nginx-ui-macos-64.tar.gz"
      sha256  "9289385e341b35c702075afee51e344b99edc0135419d99656f193cf6ddfe81a"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v3.0.4/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "1a83ba406b4ebb062450a6f6b2dca2073a8bda3dd4e2192452a51b0b9bd8b47c"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v3.0.4/nginx-ui-linux-64.tar.gz"
      sha256  "bb85700b8d15e3bb21d91d62fe888c385732b30e23c7882c1d34054898c1c6c0"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v3.0.4/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "86e39b5c7fe85198b9275d2d04b5c9f562fbd114070d503e127c9723f457dd34"
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
