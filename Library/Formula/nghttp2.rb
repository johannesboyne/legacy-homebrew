class Nghttp2 < Formula
  desc "HTTP/2 C Library"
  homepage "https://nghttp2.org/"
  url "https://github.com/tatsuhiro-t/nghttp2/releases/download/v1.3.0/nghttp2-1.3.0.tar.xz"
  sha256 "85be1e859cf310bd13204c58d1e4539cfb1d74eb5ef6b0146063fa2907d7b3f2"

  bottle do
    sha256 "751dbe954087d3661543aa13a8647ca0ebd4bc3aecf2445a89d739f35e349e23" => :yosemite
    sha256 "0c1ba68f5f99042b204222fe8c35e4ae15ebe3a18773ad1a44d2a1e080bef7d4" => :mavericks
    sha256 "bbd07e612494f14e60b9e74d23979ec2aa664d75953c55d2f226be7ccf8eb264" => :mountain_lion
  end

  head do
    url "https://github.com/tatsuhiro-t/nghttp2.git"

    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
    depends_on "libxml2" # Needs xml .m4 available
  end

  option "with-examples", "Compile and install example programs"
  option "without-docs", "Don't build man pages"
  option "with-python3", "This is required for enabling the python bindings"

  depends_on :python => :build if MacOS.version <= :snow_leopard && build.with?("docs")
  depends_on :python3 => :optional
  depends_on "libxml2" if MacOS.version <= :lion
  depends_on "pkg-config" => :build
  depends_on "cunit" => :build
  depends_on "libev"
  depends_on "openssl"
  depends_on "libevent"
  depends_on "jansson"
  depends_on "boost"
  depends_on "spdylay" => :recommended

  resource "sphinx" do
    url "https://pypi.python.org/packages/source/S/Sphinx/Sphinx-1.3.1.tar.gz"
    sha256 "1a6e5130c2b42d2de301693c299f78cc4bd3501e78b610c08e45efc70e2b5114"
  end

  resource "sphinx_rtd_theme" do
    url "https://pypi.python.org/packages/source/s/sphinx_rtd_theme/sphinx_rtd_theme-0.1.8.tar.gz"
    sha256 "74f633ed3a61da1d1d59c3185483c81a9d7346bf0e7b5f29ad0764a6f159b68a"
  end

  resource "docutils" do
    url "https://pypi.python.org/packages/source/d/docutils/docutils-0.12.tar.gz"
    sha256 "c7db717810ab6965f66c8cf0398a98c9d8df982da39b4cd7f162911eb89596fa"
  end

  resource "pygments" do
    url "https://pypi.python.org/packages/source/P/Pygments/Pygments-2.0.2.tar.gz"
    sha256 "7320919084e6dac8f4540638a46447a3bd730fca172afc17d2c03eed22cf4f51"
  end

  resource "jinja2" do
    url "https://pypi.python.org/packages/source/J/Jinja2/Jinja2-2.8.tar.gz"
    sha256 "bc1ff2ff88dbfacefde4ddde471d1417d3b304e8df103a7a9437d47269201bf4"
  end

  resource "markupsafe" do
    url "https://pypi.python.org/packages/source/M/MarkupSafe/MarkupSafe-0.23.tar.gz"
    sha256 "a4ec1aff59b95a14b45eb2e23761a0179e98319da5a7eb76b56ea8cdc7b871c3"
  end

  resource "alabaster" do
    url "https://pypi.python.org/packages/source/a/alabaster/alabaster-0.7.6.tar.gz"
    sha256 "309d33e0282c8209f792f3527f41ec04e508ff837c61fc1906dde988a256deeb"
  end

  resource "babel" do
    url "https://pypi.python.org/packages/source/B/Babel/Babel-1.3.tar.gz"
    sha256 "9f02d0357184de1f093c10012b52e7454a1008be6a5c185ab7a3307aceb1d12e"
  end

  resource "snowballstemmer" do
    url "https://pypi.python.org/packages/source/s/snowballstemmer/snowballstemmer-1.2.0.tar.gz"
    sha256 "6d54f350e7a0e48903a4e3b6b2cabd1b43e23765fbc975065402893692954191"
  end

  resource "six" do
    url "https://pypi.python.org/packages/source/s/six/six-1.9.0.tar.gz"
    sha256 "e24052411fc4fbd1f672635537c3fc2330d9481b18c0317695b46259512c91d5"
  end

  resource "pytz" do
    url "https://pypi.python.org/packages/source/p/pytz/pytz-2015.4.tar.bz2"
    sha256 "a78b484d5472dd8c688f8b3eee18646a25c66ce45b2c26652850f6af9ce52b17"
  end

  resource "Cython" do
    url "https://pypi.python.org/packages/source/C/Cython/Cython-0.23.1.tar.gz"
    sha256 "bdfd12d6a2a2e34b9a1bbc1af5a772cabdeedc3851703d249a52dcda8378018a"
  end

  # https://github.com/tatsuhiro-t/nghttp2/issues/125
  # Upstream requested the issue closed and for users to use gcc instead.
  # Given this will actually build with Clang with cxx11, just use that.
  needs :cxx11

  def install
    ENV.cxx11

    if build.with? "docs"
      ENV.prepend_create_path "PYTHONPATH", buildpath+"sphinx/lib/python2.7/site-packages"
      resources.each do |r|
        r.stage do
          system "python", *Language::Python.setup_install_args(buildpath/"sphinx")
        end unless r.name == "Cython"
      end
      ENV.prepend_path "PATH", (buildpath/"sphinx/bin")
    end

    if build.with? "python3"
      ENV.prepend_create_path "PYTHONPATH", buildpath/"cython/lib/python#{Language::Python.major_minor_version "python3"}/site-packages"
      resource("Cython").stage do
        system "python3", *(Language::Python.setup_install_args(buildpath/"cython") << "--install-scripts=#{buildpath}/cython/bin")
      end
    end

    args = %W[
      --prefix=#{prefix}
      --disable-silent-rules
      --enable-app
      --with-boost=#{Formula["boost"].opt_prefix}
      --enable-asio-lib
    ]

    args << "--enable-examples" if build.with? "examples"
    args << "--with-spdylay" if build.with? "spdylay"
    if build.with? "python3"
      args << "--enable-python-bindings" << "PYTHON=python3" << "CYTHON=#{buildpath}/cython/bin/cython" << "PYTHON_EXTRA_LDFLAGS=-undefined dynamic_lookup"
    else
      args << "--disable-python-bindings"
    end

    system "autoreconf", "-ivf" if build.head?
    system "./configure", *args
    system "make"
    system "make", "check"

    # Currently this is not installed by the make install stage.
    if build.with? "docs"
      system "make", "html"
      doc.install Dir["doc/manual/html/*"]
    end

    system "make", "install"
    libexec.install "examples" if build.with? "examples"
  end

  test do
    system bin/"nghttp", "-nv", "https://nghttp2.org"
  end
end
