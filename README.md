# Athenaeum

A libre replacement for Steam

*In the modern period, the term "Athenaeum" is widely used in various countries for schools, libraries, museums, cultural centers, performance halls and theaters, periodicals, clubs and societies - all aspiring to fulfill a cultural function similar to that of the ancient Roman school.*

![Viewing 0 A.D. in Athenaeum.](https://matrix.org/_matrix/media/v1/download/matrix.org/AuGUNUQuBPRbnNDCTwCoovAQ)

## What Works

* Installing Games
* Running Games
* Uninstalling Games
* Updates (Only monolithic atm, individual to come)

## Getting Started

### Arch Users

Download just the `PKGBUILD` and use that.

Or get it from the AUR https://aur.archlinux.org/packages/athenaeum-git/

### Other Distros

Clone this repo.

### Prerequisites

Working list, in general you need python3, flatpak, qt5, pyqt5 and python-peewee.

Ubuntu 18.04

```
flatpak
pyqt5
python3-pyqt5
python3-pyqt5.qtquick
python3-peewee
python3-dateutil
python3-xdg
qml-module-qtquick2
qml-module-qtquick-layouts
qml-module-qtquick-controls2
qml-module-qtquick-window2
```

Arch

```
flatpak
python3
pyqt5-common
python-pyqt5
python-sip-pyqt5
python-peewee
python-dateutil
python-xdg
qt5-base
qt5-svg
qt5-quickcontrols2
qt5-declarative
```

### Installing Athenaeum

#### Arch

Use the `PKGBUILD` to build it then use pacman to install it.

Or get it from the AUR https://aur.archlinux.org/packages/athenaeum-git/

#### Other

Not currently supported, though you can probably do it with the `setup.py`

### Running Athenaeum

Arch

```
python athenaeum.py
```

Ubuntu

```
python3 athenaeum.py
```

## Running the tests

not supported atm

## Getting your game on Athenaeum

Athenaeum uses flatpak as its packaging system and pulls all data from flathub currently.

The best way to get your game on Athenaeum is to create a flatpak config and submit it to the flathub github repositrory.

https://github.com/flathub/flathub/wiki/App-Submission

Make sure your game appdata.xml contains the `project_license` field with a Free Software license and the `categories` field, with at least the category 'Game'.

## Built With

* Python3
* PyQt5
* Qt5
* PeeweeORM
* Python-Appstream
* LibreICONS

## Contributing

As you would any other project.

### Other ways

Find libre games, create flatpak manifests for them and submit them to flathub.

A good place to start finding games is LibreGameWiki.

https://libregamewiki.org/List_of_games

## License

GPLv3 or later (GPLv3+), any other code as licensed (python-appstream is lgplv2+).

Assets as licensed (LibreICONS is MIT).
