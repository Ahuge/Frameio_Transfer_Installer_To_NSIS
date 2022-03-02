# Frameio_Transfer_Installer_To_NSIS
Converting the Frame.io Transfer Installer to an actually decent NSIS installer

## Usage
The `build.ps1` should install NSIS, Python3 and build the NSIS installer for you.  
However you may want to customize it, the `squirrel-to-nsis.py` file will build a `setup.nsi` file similar to the one existing in this repo.
After that point, you can just run `makensis` passing it the path to the `setup.nsi` file. You will want to have the decompressed data from the Frame.io Transfer installer in a folder called `source` beside the `setup.nsi` file.  

It's often just easier to run the build script.
