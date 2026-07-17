[Setup]
AppName=CODAH MUSIC
AppVersion=2.2.0
AppPublisher=Nishanth JP
DefaultDirName={autopf}\CODAH MUSIC
DefaultGroupName=CODAH MUSIC
OutputDir=..\release
OutputBaseFilename=Codah Music v2.2.0 Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
SetupIconFile=icons\app_icon.ico
UninstallDisplayIcon={app}\codah-music.exe
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "build\windows\x64\runner\Release\codah-music.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\CODAH MUSIC"; Filename: "{app}\codah-music.exe"
Name: "{group}\Uninstall CODAH MUSIC"; Filename: "{uninstallexe}"
Name: "{autodesktop}\CODAH MUSIC"; Filename: "{app}\codah-music.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional icons:"; Flags: checkedonce

[Run]
Filename: "{app}\codah-music.exe"; Description: "Launch CODAH MUSIC"; Flags: nowait postinstall skipifsilent
