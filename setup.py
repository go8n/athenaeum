from setuptools import setup

setup(
    name="athenaeum",
    version='0.1',
    author='librebob',
    license='GPL-3.0-or-later',
    url='https://gitlab.com/librebob/athenaeum',
    include_package_data=True,
    packages=['athenaeum', 'athenaeum.appstream', 'athenaeum.notify2'],
    entry_points={
        'gui_scripts': [
            'athenaeum = athenaeum.athenaeum:main',
        ]
    },
    install_requires=[],
    description="A libre replacement for Steam",
    long_description="README.md",
)
