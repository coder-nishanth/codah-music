[Setup]
AppName=CODA MUSIC
AppVersion=1.0.0
AppVerName=CODA MUSIC 1.0.0
AppPublisher=coder-nishanth
AppPublisherURL=https://github.com/coder-nishanth/coda-music
DefaultDirName={autopf}\CODA MUSIC
DefaultGroupName=CODA MUSIC
UninstallDisplayIcon={app}\coda-music.exe
UninstallDisplayName=CODA MUSIC
Compression=lzma2
SolidCompression=yes
OutputDir=..\installers
OutputBaseFilename=coda-music-Setup-1.0.0
SetupIconFile=runner\resources\app_icon.ico
VersionInfoVersion=1.0.0.0
VersionInfoCompany=coder-nishanth
VersionInfoDescription=CODA MUSIC Installer
VersionInfoProductName=CODA MUSIC
VersionInfoProductVersion=1.0.0
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\CODA MUSIC"; Filename: "{app}\coda-music.exe"; IconFilename: "{app}\coda-music.exe"
Name: "{group}\Uninstall CODA MUSIC"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\coda-music.exe"; Description: "Launch CODA MUSIC"; Flags: postinstall nowait skipifsilent
