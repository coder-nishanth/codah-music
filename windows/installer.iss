[Setup]
AppName=Codah Music
AppVersion=1.0.0
AppVerName=Codah Music 1.0.0
AppPublisher=coder-nishanth
AppPublisherURL=https://github.com/coder-nishanth/codah-music
DefaultDirName={autopf}\Codah Music
DefaultGroupName=Codah Music
UninstallDisplayIcon={app}\codah-music.exe
UninstallDisplayName=Codah Music
Compression=lzma2
SolidCompression=yes
OutputDir=..\installers
OutputBaseFilename=Codah-Music-Setup-1.0.0
SetupIconFile=runner\resources\app_icon.ico
VersionInfoVersion=1.0.0.0
VersionInfoCompany=coder-nishanth
VersionInfoDescription=Codah Music Installer
VersionInfoProductName=Codah Music
VersionInfoProductVersion=1.0.0
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\Codah Music"; Filename: "{app}\codah-music.exe"; IconFilename: "{app}\codah-music.exe"
Name: "{group}\Uninstall Codah Music"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\codah-music.exe"; Description: "Launch Codah Music"; Flags: postinstall nowait skipifsilent
