# Maintainer: librebob <librebob at protonmail dot com>
pkgname=athenaeum-git
_pkgdomain=com.gitlab.librebob.Athenaeum
pkgver=1.0.3.r1.g348a794
pkgrel=1
pkgdesc="A libre replacement for Steam"
arch=('any')
url="https://gitlab.com/librebob/athenaeum"
license=('GPL-3.0-or-later')
depends=('flatpak' 'python-pyqt5' 'python-dateutil' 'qt5-svg' 'qt5-quickcontrols2' 'qt5-graphicaleffects' 'python-numpy')
makedepends=('git' 'python-setuptools')
provides=("${pkgname%-git}")
conflicts=("${pkgname%-git}")
source=("git+https://gitlab.com/librebob/athenaeum.git")
sha256sums=('SKIP')

pkgver() {
    cd "$srcdir/${pkgname%-git}"
    git describe --long --tags | sed 's/^v//;s/\([^-]*-g\)/r\1/;s/-/./g'
}

build() {
	cd "$srcdir/${pkgname%-git}"
	python setup.py build
}

package() {
	cd "$srcdir/${pkgname%-git}"
	python setup.py install --root="$pkgdir/" --optimize=1 --skip-build
	for i in 16 32 48 64 96 128 256 512; do
		install -Dm644 "${pkgname%-git}/resources/icons/hicolor/${i}x${i}/$_pkgdomain.png" \
			"$pkgdir/usr/share/icons/hicolor/${i}x${i}/apps/$_pkgdomain.png"
	done
	install -Dm644 "${pkgname%-git}/resources/$_pkgdomain.desktop" \
		"$pkgdir/usr/share/applications/$_pkgdomain.desktop"
	install -Dm644 "${pkgname%-git}/resources/$_pkgdomain.appdata.xml" \
		"$pkgdir/usr/share/appdata/$_pkgdomain.appdata.xml"
}
