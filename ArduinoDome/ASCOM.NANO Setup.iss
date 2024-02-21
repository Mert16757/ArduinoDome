;
; Script generated by the ASCOM Driver Installer Script Generator 6.6.0.0
; Generated by Lammertus de Vries on 21/02/2024 (UTC)
;
[Setup]
AppID={{4f91e8d8-063f-43e9-a9f2-6609eb355498}
AppName=ASCOM ASCOM.NANO Dome Driver
AppVerName=ASCOM ASCOM.NANO Dome Driver 6.6
AppVersion=6.6
AppPublisher=Lammertus de Vries <DeveloperTalk>
AppPublisherURL=mailto:DeveloperTalk
AppSupportURL=https://ascomtalk.groups.io/g/Help
AppUpdatesURL=https://ascom-standards.org/
VersionInfoVersion=1.0.0
MinVersion=6.1.7601
DefaultDirName="{cf}\ASCOM\Dome"
DisableDirPage=yes
DisableProgramGroupPage=yes
OutputDir="."
OutputBaseFilename="ASCOM.NANO Setup"
Compression=lzma
SolidCompression=yes
; Put there by Platform if Driver Installer Support selected
WizardImageFile="C:\Program Files (x86)\ASCOM\Platform 6 Developer Components\Installer Generator\Resources\WizardImage.bmp"
LicenseFile="C:\Program Files (x86)\ASCOM\Platform 6 Developer Components\Installer Generator\Resources\CreativeCommons.txt"
; {cf}\ASCOM\Uninstall\Dome folder created by Platform, always
UninstallFilesDir="{cf}\ASCOM\Uninstall\Dome\ASCOM.NANO"

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Dirs]
Name: "{cf}\ASCOM\Uninstall\Dome\ASCOM.NANO"
; TODO: Add subfolders below {app} as needed (e.g. Name: "{app}\MyFolder")

[Files]
Source: "E:\Arduino projects\ArduinoDome\ArduinoDome\ASCOM.NANO.exe"; DestDir: "{app}" ;AfterInstall: RegASCOM()
; Require a read-me HTML to appear after installation, maybe driver's Help doc
Source: "E:\Arduino projects\ArduinoDome\ArduinoDome\DOME-sketch-ino.txt"; DestDir: "{app}"; Flags: isreadme
; TODO: Add other files needed by your driver here (add subfolders above)

;Only if COM Local Server
[Run]
Filename: "{app}\ASCOM.NANO.exe"; Parameters: "/regserver"




;Only if COM Local Server
[UninstallRun]
Filename: "{app}\ASCOM.NANO.exe"; Parameters: "/unregserver"



;  DCOM setup for COM local Server, needed for TheSky
[Registry]
; TODO: If needed set this value to the Dome CLSID of your driver (mind the leading/extra '{')
#define AppClsid "{{41305059-cddb-43fc-953d-b281d585b4c5}"

; set the DCOM access control for TheSky on the Dome interface
Root: HKCR; Subkey: CLSID\{#AppClsid}; ValueType: string; ValueName: AppID; ValueData: {#AppClsid}
Root: HKCR; Subkey: AppId\{#AppClsid}; ValueType: string; ValueData: "ASCOM ASCOM.NANO Dome Driver"
Root: HKCR; Subkey: AppId\{#AppClsid}; ValueType: string; ValueName: AppID; ValueData: {#AppClsid}
Root: HKCR; Subkey: AppId\{#AppClsid}; ValueType: dword; ValueName: AuthenticationLevel; ValueData: 1
; set the DCOM key for the executable as a whole
Root: HKCR; Subkey: AppId\ASCOM.NANO.exe; ValueType: string; ValueName: AppID; ValueData: {#AppClsid}
; CAUTION! DO NOT EDIT - DELETING ENTIRE APPID TREE WILL BREAK WINDOWS!
Root: HKCR; Subkey: AppId\{#AppClsid}; Flags: uninsdeletekey
Root: HKCR; Subkey: AppId\ASCOM.NANO.exe; Flags: uninsdeletekey

[Code]
const
   REQUIRED_PLATFORM_VERSION = 6.2;    // Set this to the minimum required ASCOM Platform version for this application

//
// Function to return the ASCOM Platform's version number as a double.
//
function PlatformVersion(): Double;
var
   PlatVerString : String;
begin
   Result := 0.0;  // Initialise the return value in case we can't read the registry
   try
      if RegQueryStringValue(HKEY_LOCAL_MACHINE_32, 'Software\ASCOM','PlatformVersion', PlatVerString) then 
      begin // Successfully read the value from the registry
         Result := StrToFloat(PlatVerString); // Create a double from the X.Y Platform version string
      end;
   except                                                                   
      ShowExceptionMessage;
      Result:= -1.0; // Indicate in the return value that an exception was generated
   end;
end;

//
// Before the installer UI appears, verify that the required ASCOM Platform version is installed.
//
function InitializeSetup(): Boolean;
var
   PlatformVersionNumber : double;
 begin
   Result := FALSE;  // Assume failure
   PlatformVersionNumber := PlatformVersion(); // Get the installed Platform version as a double
   If PlatformVersionNumber >= REQUIRED_PLATFORM_VERSION then	// Check whether we have the minimum required Platform or newer
      Result := TRUE
   else
      if PlatformVersionNumber = 0.0 then
         MsgBox('No ASCOM Platform is installed. Please install Platform ' + Format('%3.1f', [REQUIRED_PLATFORM_VERSION]) + ' or later from https://www.ascom-standards.org', mbCriticalError, MB_OK)
      else 
         MsgBox('ASCOM Platform ' + Format('%3.1f', [REQUIRED_PLATFORM_VERSION]) + ' or later is required, but Platform '+ Format('%3.1f', [PlatformVersionNumber]) + ' is installed. Please install the latest Platform before continuing; you will find it at https://www.ascom-standards.org', mbCriticalError, MB_OK);
end;

// Code to enable the installer to uninstall previous versions of itself when a new version is installed
procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
  UninstallExe: String;
  UninstallRegistry: String;
begin
  if (CurStep = ssInstall) then // Install step has started
	begin
      // Create the correct registry location name, which is based on the AppId
      UninstallRegistry := ExpandConstant('Software\Microsoft\Windows\CurrentVersion\Uninstall\{#SetupSetting("AppId")}' + '_is1');
      // Check whether an extry exists
      if RegQueryStringValue(HKLM, UninstallRegistry, 'UninstallString', UninstallExe) then
        begin // Entry exists and previous version is installed so run its uninstaller quietly after informing the user
          MsgBox('Setup will now remove the previous version.', mbInformation, MB_OK);
          Exec(RemoveQuotes(UninstallExe), ' /SILENT', '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode);
          sleep(1000);    //Give enough time for the install screen to be repainted before continuing
        end
  end;
end;

//
// Register and unregister the driver with the Chooser
// We already know that the Helper is available
//
procedure RegASCOM();
var
   P: Variant;
begin
   P := CreateOleObject('ASCOM.Utilities.Profile');
   P.DeviceType := 'Dome';
   P.Register('ASCOM.NANO.Dome', 'Arduino Dome');
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
   P: Variant;
begin
   if CurUninstallStep = usUninstall then
   begin
     P := CreateOleObject('ASCOM.Utilities.Profile');
     P.DeviceType := 'Dome';
     P.Unregister('ASCOM.NANO.Dome');
  end;
end;
