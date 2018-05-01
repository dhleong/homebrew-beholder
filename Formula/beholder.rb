
class Beholder < Formula
  desc "CLI tool for D&D players"
  homepage "https://github.com/dhleong/beholder"
  url "https://github.com/dhleong/beholder/archive/1.1.0.tar.gz"
  sha256 "77f35c4e568c38acc5bc4ede34632f834aee48a6cedcac0c6b07351fc36bdc5c"

  depends_on "go" => :build
  depends_on "dep" => :build

  def install
    ENV["GOPATH"] = buildpath

    # NOTE: I may be doing this way wrong here, but if I just use
    # ln_s to link the `github.com/dhleong/beholder` into GOPATH,
    # homebrew doesn't seem to want to use it. In a similar config,
    # `dep` doesn't recognize it as a project root. So, let's do
    # this the hard way.

    # 1. move our actual src dir out of the way
    mv "src", "beholder-src"

    # 2. create a project path in the GOPATH
    (buildpath/"src/github.com/dhleong/beholder").mkpath

    # 2. mv the src directory in (.install barfs on folders)
    mv "beholder-src", (buildpath/"src/github.com/dhleong/beholder/src")

    # 4. .install other important files (again, ln_s doesn't cooperate here)
    (buildpath/"src/github.com/dhleong/beholder/").install Dir["{*.go,Gopkg.*}"]

    # 5. finally, go there and build
    cd "src/github.com/dhleong/beholder" do
      system "dep", "ensure"
      system "go", "build", "-o", "beholder"
      bin.install "beholder"
    end
  end

  test do
    system "#{bin}/beholder", "--version"
  end
end
