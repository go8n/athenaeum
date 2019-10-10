from setuptools import setup

setup(
    name="athenaeum",
    version='1.1.0',
    author='librebob',
    license='GPL-3.0-or-later',
    use_scm_version=True,
    setup_requires=['setuptools_scm'],
    url='https://gitlab.com/librebob/athenaeum',
    include_package_data=True,
    packages=['athenaeum', 'athenaeum.appstream', 'athenaeum.stemming'],
    entry_points={
        'gui_scripts': [
            'athenaeum = athenaeum.athenaeum:main',
        ]
    },
    install_requires=['python-dateutil', 'numpy', 'PyQt5'],
    description="A libre replacement for Steam",
    long_description="README.md",
)
