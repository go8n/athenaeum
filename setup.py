from setuptools import setup

setup(
    name="athenaeum",
    version='1.0.0',
    author='librebob',
    license='GPL-3.0-or-later',
    url='https://gitlab.com/librebob/athenaeum',
    include_package_data=True,
    packages=['athenaeum', 'athenaeum.appstream'],
    entry_points={
        'gui_scripts': [
            'athenaeum = athenaeum.athenaeum:main',
        ]
    },
    install_requires=[],
    description="A libre replacement for Steam",
    long_description="README.md",
)
