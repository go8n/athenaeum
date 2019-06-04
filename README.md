# Athenaeum

A libre replacement for Steam

*In the modern period, the term "Athenaeum" is widely used in various countries for schools, libraries, museums, cultural centers, performance halls and theaters, periodicals, clubs and societies - all aspiring to fulfill a cultural function similar to that of the ancient Roman school.*

Matrix Channel: [#athenaeum:matrix.org](https://riot.im/app/#/room/#athenaeum:matrix.org)

![Viewing 0 A.D. in Athenaeum.](https://matrix.org/_matrix/media/v1/download/matrix.org/ZkKaxgNZXNSwPbHtWFesRRjT)

## What Works

* Installing Games
* Running Games
* Uninstalling Games
* Updates (Only monolithic atm, individual to come)

## Installing Athenaeum

### Any

Get it from flathub!

https://flathub.org/apps/details/com.gitlab.librebob.Athenaeum

### Arch

Download just the `PKGBUILD` and use it to build the package. Once built install it with pacman.

Or get it from the AUR https://aur.archlinux.org/packages/athenaeum-git/

## Development

### Getting Started

Clone this repo.

### Prerequisites

Working list, in general you need python3, flatpak and pyqt5.

Ubuntu 18.04

```
flatpak
python3-pyqt5
python3-pyqt5.qtquick
python3-dateutil
qml-module-qtquick2
qml-module-qtquick-layouts
qml-module-qtquick-controls2
qml-module-qtquick-window2
qml-module-qtgraphicaleffects
```

Arch

```
flatpak
python-dateutil
python-pyqt5
qt5-svg
qt5-quickcontrols2
qt5-graphicaleffects
```

Fedora 29 (Comes with a lot of the dependencies by default)

```
python3-pip
pip3 install pyqt5
python3-dateutil
```

### Running Athenaeum

Arch

```
python athenaeum.py
```

Ubuntu / Fedora

```
python3 athenaeum.py
```

## Running the tests

Ubuntu / Fedora

```
$ cd test
$ python3 -m unittest
```

Arch

```
$ cd test
$ python -m unittest
```

## Getting your game on Athenaeum

Athenaeum uses flatpak as its packaging system and pulls all data from flathub currently.

The best way to get your game on Athenaeum is to create a flatpak config and submit it to the flathub github repository.

https://github.com/flathub/flathub/wiki/App-Submission

Make sure your game appdata.xml contains the `project_license` field with a Free Software license and the `categories` field, with at least the category 'Game'.

## Built With

* Python3
* PyQt5
* Qt5
* Python-Appstream
* LibreICONS

## Contributing

As you would any other project.

### Translations

#### Using Weblate.org

The kind people of weblate.org have provided Athenaeum with hosting for translations. Using their webapp makes translating a lot easier!

https://hosted.weblate.org/projects/athenaeum/translations/

#### Using QT tools

On Fedora you'll require the qt5-devel package for this.

Athenaeum leverages the QT translation classes and tools. To get started simply add a translation file to `athenaeum.pro` eg. `athenaeum/translations/athenaeum_ja.ts` then run `lupdate -verbose athenaeum.pro` to generate the file.

After that use `linguist` to edit the file adding your translations. Once there's some translations ` lrelease -verbose athenaeum.pro` will be used to generate the files that will be loaded at runtime.

The QT website explains this all better and in more detail.

https://doc-snapshots.qt.io/qt5-5.11/qtlinguist-hellotr-example.html

### Other ways

Find libre games, create flatpak manifests for them and submit them to flathub.

A good place to start finding games is LibreGameWiki.

https://libregamewiki.org/List_of_games

## License

GPLv3 or later (GPLv3+), any other code as licensed (python-appstream is LGPLv2+).

Assets as licensed (LibreICONS is MIT).
