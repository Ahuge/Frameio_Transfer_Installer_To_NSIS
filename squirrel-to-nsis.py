from typing import Dict, IO, List

import argparse
import shutil
import subprocess
import tempfile
import zipfile
import os

from pathlib import Path, PureWindowsPath
from xml.etree import ElementTree


UNINST_ROOT: str = 'Software/Microsoft/Windows/CurrentVersion/Uninstall'
NSIS_BIN_DIR = "C:\\Program Files (x86)\\NSIS\\Bin"


class Nuspec:
    def __init__(self, file: IO):
        ns: Dict[str, str] = {
            'nuspec': 'http://schemas.microsoft.com/packaging/2011/08/nuspec.xsd'
        }
        metadata = ElementTree.fromstring(file.read()).find('nuspec:metadata', ns)
        self.iden: str = metadata.find('nuspec:id', ns).text
        self.version: str = metadata.find('nuspec:version', ns).text
        self.title: str = metadata.find('nuspec:title', ns).text
        self.authors: str = metadata.find('nuspec:authors', ns).text
        self.description: str = metadata.find('nuspec:description', ns).text


def write_nsi(nuspec: Nuspec, folder: str, subdir: str):
    with open(Path(folder, 'setup.nsi'), 'w') as nsi_file:
        uninst_key: str = PureWindowsPath(UNINST_ROOT, nuspec.iden)
        nsi_file.write('Unicode True\n')
        nsi_file.write('Name "{}"\n'.format(nuspec.title))
        nsi_file.write('Outfile "{} Setup.exe"\n'.format(nuspec.iden))
        nsi_file.write('Icon "img\icon.ico"\n'.format(nuspec.iden))
        nsi_file.write('UninstallIcon "img\icon.ico"\n'.format(nuspec.iden))
        nsi_file.write('InstallDir "$PROGRAMFILES\\{}"\n'.format(nuspec.title))
        nsi_file.write('Section\n')
        nsi_file.write('SetOutPath "$INSTDIR"\n')
        nsi_file.write('File /r {}\n'.format(subdir + os.sep + "*.*"))
        nsi_file.write('CreateShortcut "$SMPROGRAMS\\{title}.lnk" \
                 "$INSTDIR\\{title}.exe"\n'
                 .format(title=nuspec.title)
        )
        nsi_file.write('WriteUninstaller "$INSTDIR\\uninstall.exe"\n')
        nsi_file.write('WriteRegStr HKLM "{}" "DisplayName" "{}"\n'
                 .format(uninst_key, nuspec.title))
        nsi_file.write('WriteRegStr HKLM "{}" \
                 "UninstallString" "$\\"$INSTDIR\\uninstall.exe$\\" "\n'
                 .format(uninst_key))
        nsi_file.write('WriteRegStr HKLM "{}" \
                 "QuietUninstallString" "$\\"$INSTDIR\\uninstall.exe$\\" /S"\n'
                 .format(uninst_key))
        nsi_file.write('SectionEnd\n')
        nsi_file.write('Section "Uninstall"\n')
        nsi_file.write('Delete "$INSTDIR\\uninstall.exe"\n')
        nsi_file.write('Delete "$SMPROGRAMS\\{}.lnk"\n'.format(nuspec.iden))
        nsi_file.write('RMDir /r "$INSTDIR"\n')
        nsi_file.write('DeleteRegKey HKLM "{}"\n'
                 .format(uninst_key))
        nsi_file.write('SectionEnd\n')


def external_unzip(path, outpath):
    import subprocess
    if not os.path.exists(outpath):
        os.makedirs(outpath)

    seven_zip_path = 'C:\\Program Files\\7-Zip\\7z.exe'

    proc = subprocess.Popen(
        [
            seven_zip_path, "x", path, "-o{}".format(outpath), "-y"
        ], stdout=subprocess.PIPE
    )
    out, err = proc.communicate()

    releases_file = os.path.join(outpath, "RELEASES")
    if not os.path.exists(releases_file):
        raise RuntimeError("Could not find expected RELEASES file in extracted squirrel archive")

    with open(releases_file) as fh:
        package = fh.read().split()[1]
        name = package.rsplit("-", maxsplit=2)[0]

    package_file = os.path.join(outpath, package)
    if not os.path.exists(package_file):
        raise RuntimeError("Could not find nupkg file: {}".format(package_file))

    package_extract_path = outpath
    proc = subprocess.Popen([seven_zip_path, "x", package_file, "-o{}".format(package_extract_path)], stdout=subprocess.PIPE)
    proc.communicate()

    nuspec_path = os.path.join(package_extract_path, name+".nuspec")
    if not os.path.exists(nuspec_path):
        raise RuntimeError("Could not find nuspec file: {}".format(nuspec_path))

    with open(nuspec_path, "r", encoding="UTF-8", errors="ignore") as fh:
        nuspec = Nuspec(fh)
    return nuspec


def native_unzip(path, tempdir):
    with zipfile.ZipFile(path) as container:
        name: str
        package: str
        with container.open('RELEASES') as releases:
            package = releases.read().split()[1].decode()
            name = package.rsplit('-', maxsplit=2)[0]
        with zipfile.ZipFile(container.open(package)) as nupkg:
            with nupkg.open(name + '.nuspec') as nuspecfile:
                nuspec = Nuspec(nuspecfile)
            for file in nupkg.namelist():
                if file.startswith('lib/net45/') and file.lstrip('lib/net45/') \
                             not in ['', 'squirrel.exe']:
                    print("Extracting {} to {}".format(file, tempdir))
                    nupkg.extract(file, path=tempdir)
    return nuspec


def main(squirrel: str, nsis: str):
    nuspec: Nuspec
    # tempdir = tempfile.TemporaryDirectory(delete=False)
    tempdir = tempfile.mkdtemp()
    # with tempfile.TemporaryDirectory() as tempdir:
    try:
        nuspec = native_unzip(squirrel, tempdir)
    except Exception as err:
        nuspec = external_unzip(squirrel, tempdir)
    print("folder: {}".format(tempdir))
    # TODO: Copy all files from 'lib/net45' into source directory
    os.makedirs(os.path.join(tempdir, 'source'))
    for filename in os.listdir(os.path.join(tempdir, 'lib', 'net45')):
        shutil.move(os.path.join(tempdir, 'lib', 'net45', filename), os.path.join(tempdir, 'source', filename))
    shutil.copytree('img', os.path.join(tempdir, 'img'))

    write_nsi(nuspec=nuspec, folder=tempdir, subdir='source')
    subprocess.run([os.path.join(NSIS_BIN_DIR, 'makensis.exe'), os.path.join(tempdir, 'setup.nsi')])
    if os.path.exists(os.path.join(tempdir, "{} Setup.exe".format(nuspec.iden))):
        shutil.move(Path(tempdir, '{} Setup.exe'.format(nuspec.iden)), Path(nsis))
        shutil.rmtree(tempdir)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('squirrel-setup-exe')
    parser.add_argument('nsis-output-path')
    args = parser.parse_args()
    main(getattr(args, "squirrel-setup-exe"), getattr(args, "nsis-output-path"))
