[Setup]
AppName=Codah Music
AppVersion=2.2.0
AppPublisher=Nishanth JP
DefaultDirName={autopf}\Codah Music
DefaultGroupName=Codah Music
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
Name: "{group}\Codah Music"; Filename: "{app}\codah-music.exe"
Name: "{group}\Uninstall Codah Music"; Filename: "{uninstallexe}"
Name: "{autodesktop}\Codah Music"; Filename: "{app}\codah-music.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional icons:"; Flags: checkedonce

[Run]
Filename: "{app}\codah-music.exe"; Description: "Launch Codah Music"; Flags: nowait postinstall skipifsilent
