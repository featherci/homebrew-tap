class Featherci < Formula
  desc "Lightweight self-hosted CI/CD system"
  homepage "https://github.com/featherci/featherci"
  version "0.1.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/featherci/featherci/releases/download/v#{version}/featherci-darwin-arm64.tar.gz"
      sha256 "53d591469c699fc07589ea3c175103f9aa7230e1ce4eb1dc70ce9c598553dfda"
    else
      url "https://github.com/featherci/featherci/releases/download/v#{version}/featherci-darwin-amd64.tar.gz"
      sha256 "50975749d6b13ce01d43adca6ecd37f78ecbcd0777bc1ac2c8e77c44fad04840"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/featherci/featherci/releases/download/v#{version}/featherci-linux-arm64.tar.gz"
      sha256 "0c0c6d50883bbc72e649acda156bb6d7c8d33d9d439a541993fba204213aaf55"
    else
      url "https://github.com/featherci/featherci/releases/download/v#{version}/featherci-linux-amd64.tar.gz"
      sha256 "da7d05fc0081398a9e11d071fc0638d75c691e1cd5e1624b8b49da339ce89341"
    end
  end

  depends_on "docker" => :optional

  def install
    bin.install "featherci"
    (share/"featherci").install "config.yaml.example"
  end

  def post_install
    (var/"featherci").mkpath
    (var/"log/featherci").mkpath
  end

  def caveats
    <<~EOS
      To start FeatherCI, first generate an encryption key:
        featherci --generate-key

      Then create a config file at #{etc}/featherci/config.yaml:
        mkdir -p #{etc}/featherci
        cp #{opt_share}/featherci/config.yaml.example #{etc}/featherci/config.yaml

      Edit the config file with your settings (secret key, OAuth, admins).

      Start the service:
        brew services start featherci

      Or run manually:
        featherci --config #{etc}/featherci/config.yaml
    EOS
  end

  service do
    run [opt_bin/"featherci", "--config", etc/"featherci/config.yaml"]
    keep_alive true
    working_dir var/"featherci"
    log_path var/"log/featherci/featherci.log"
    error_log_path var/"log/featherci/featherci.error.log"
  end

  test do
    assert_match "FeatherCI", shell_output("#{bin}/featherci --version")
  end
end
