[Setup]
AppName=CODAH MUSIC
AppVersion=1.1.0
AppVerName=CODAH MUSIC 1.1.0
AppPublisher=coder-nishanth
AppPublisherURL=https://github.com/coder-nishanth/codah-music
DefaultDirName={autopf}\CODAH MUSIC
DefaultGroupName=CODAH MUSIC
UninstallDisplayIcon={app}\codah-music.exe
UninstallDisplayName=CODAH MUSIC
Compression=lzma2
SolidCompression=yes
OutputDir=..\installers
OutputBaseFilename=CodahMusic-Setup-1.1.0
SetupIconFile=runner\resources\app_icon.ico
VersionInfoVersion=1.1.0.0
VersionInfoCompany=coder-nishanth
VersionInfoDescription=CODAH MUSIC Installer
VersionInfoProductName=CODAH MUSIC
VersionInfoProductVersion=1.1.0
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=dialog

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\CODAH MUSIC"; Filename: "{app}\codah-music.exe"; IconFilename: "{app}\codah-music.exe"
Name: "{group}\Uninstall CODAH MUSIC"; Filename: "{uninstallexe}"
Name: "{commondesktop}\CODAH MUSIC"; Filename: "{app}\codah-music.exe"; IconFilename: "{app}\codah-music.exe"

[Run]
Filename: "{app}\codah-music.exe"; Description: "Launch CODAH MUSIC"; Flags: postinstall nowait skipifsilent
