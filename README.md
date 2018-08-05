# Athenaeum

A libre replacement for Steam

![Viewing 0 A.D. in Athenaeum.](https://matrix.org/_matrix/media/v1/download/matrix.org/rcSvHcbxTbTqmJOlMWRZGpYc)

## Getting Started

clone this repo

### Prerequisites

Working list, in general you need python3, flatpak, pyqt5 and python-peewee.

Arch

```
flatpak
python3
pyqt5-common
python-pyqt5
python-sip-pyqt5
python-peewee
qt5-base
qt5-svg
qt5-quickcontrols2
qt5-declarative
```

### Installing

not supported atm

### Running Athenaeum

Arch

```
python main.py
```

Ubuntu

```
python3 main.py
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
* LibreICONS

## Contributing

As you would any other project.

### Other ways

Find libre games and create flatpak configs and submit them to flathub.

A good place to start is LibreGameWiki.

https://libregamewiki.org/List_of_games

## License

GPLv3 or later (GPLv3+), any other code as licensed (python-appstream is lgplv2+).

Assets as licensed (LibreICONS is MIT).
