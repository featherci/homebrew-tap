class Featherci < Formula
  desc "Lightweight self-hosted CI/CD system"
  homepage "https://github.com/featherci/featherci"
  version "0.6.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/featherci/featherci/releases/download/v#{version}/featherci-darwin-arm64.tar.gz"
      sha256 "f55bdabde5d4030baea4531faca8c39e0580920a9ef4c6afd0fc9c8165a0e2d5"
    else
      url "https://github.com/featherci/featherci/releases/download/v#{version}/featherci-darwin-amd64.tar.gz"
      sha256 "dbc54b67ae90d25d632dd12e9216128b0b6c8d8354351ebca620b2c904541aa5"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/featherci/featherci/releases/download/v#{version}/featherci-linux-arm64.tar.gz"
      sha256 "bce7c6af3a129d06b52db12503347d384f7e0edfce0f8074b4b47f17ceabb505"
    else
      url "https://github.com/featherci/featherci/releases/download/v#{version}/featherci-linux-amd64.tar.gz"
      sha256 "7305088a9dcd3269760478e68219b306b91895c25c45b02352202b22e5d3ddcc"
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
