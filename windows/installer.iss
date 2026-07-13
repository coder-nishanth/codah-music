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
OutputBaseFilename=CodahMusic-Setup-1.0.0
SetupIconFile=runner\resources\app_icon.ico
VersionInfoVersion=1.0.0.0
VersionInfoCompany=coder-nishanth
VersionInfoDescription=CODAH MUSIC Installer
VersionInfoProductName=CODAH MUSIC
VersionInfoProductVersion=1.0.0
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\CODAH MUSIC"; Filename: "{app}\codah-music.exe"; IconFilename: "{app}\codah-music.exe"
Name: "{group}\Uninstall CODAH MUSIC"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\codah-music.exe"; Description: "Launch CODAH MUSIC"; Flags: postinstall nowait skipifsilent
