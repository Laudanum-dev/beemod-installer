;--------------------------------
; Includes

!include "MUI2.nsh"
!include "logiclib.nsh"

;--------------------------------
; Custom defines
!define NAME "BEE2.4.40.2"                          ; the name to be displayed
!define APPFILE "BEE2.exe"                          ; executable to be launched when user presses the shortcut
!define ICON "BEE2.ico"                             ; icon to be displayed in installer
!define LICENSE "license.txt"                       ; path to license

; url the app will be downloaded from
!define URL_APP "https://github.com/BEEmod/BEE2.4/releases/download/2.4.40.2/BEE2_v4.40.2_win64.zip"

; url the default packs will be downloaded from
!define URL_PACKS "https://github.com/BEEmod/BEE2-items/releases/download/v4.40.0/BEE2_v4.40.0_packages.zip"

; ####################################################################### ;
;                                                                         ;
;       Generally, you won't need to edit anything below this point       ;
;                                                                         ;
; ####################################################################### ;

;--------------------------------
; General

Name "${NAME}"
OutFile "${NAME} Installer.exe"
InstallDir "C:\${NAME}"
RequestExecutionLevel user

;--------------------------------
; UI
  
!define MUI_ICON "${ICON}"
!define MUI_HEADERIMAGE
!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TITLE "${NAME} Setup"

;--------------------------------
; Pages
  
; Installer pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${LICENSE}"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Set UI language
!insertmacro MUI_LANGUAGE "English"

;--------------------------------
; Section - Install App

Section "-hidden app"
    SectionIn RO
    SetOutPath "$INSTDIR"
    inetc::get /BANNER "Downloading ${NAME} App..." /CAPTION "${NAME} App" "${URL_APP}" "$TEMP\app.zip"
    nsisunz::Unzip "$TEMP\app.zip" "$INSTDIR"
    Delete "$TEMP\app.zip"
    CreateDirectory $INSTDIR\packages
    inetc::get /BANNER "Downloading ${NAME} Default packages... (this might take a few minutes)" /CAPTION "${NAME} Packages" "${URL_PACKS}" "$TEMP\packs.zip"
    nsisunz::Unzip "$TEMP\packs.zip" "$INSTDIR\packages"
    Delete "$TEMP\packs.zip"
    WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

;--------------------------------
; Section - Desktop Shortcut

Section "Desktop Shortcut" DeskShort
    CreateShortCut "$DESKTOP\${NAME}.lnk" "$INSTDIR\${APPFILE}"
SectionEnd

;--------------------------------
; Section - Start Menu Shortcut

Section "StartMenu Shortcut" StartMenuShort
    CreateShortCut "$SMPROGRAMS\${NAME}.lnk" "$INSTDIR\${APPFILE}"
SectionEnd

;--------------------------------
; Descriptions

;Language strings
LangString DESC_DeskShort ${LANG_ENGLISH} "Create Shortcut on Dekstop."
LangString DESC_StartMenuShort ${LANG_ENGLISH} "Create Shortcut in Start menu"

;Assign language strings to sections
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${DeskShort} $(DESC_DeskShort)
    !insertmacro MUI_DESCRIPTION_TEXT ${StartMenuShort} $(DESC_StartMenuShort)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
; Remove empty parent directories

Function un.RMDirUP
    !define RMDirUP '!insertmacro RMDirUPCall'

    !macro RMDirUPCall _PATH
        push '${_PATH}'
        Call un.RMDirUP
    !macroend

    ; $0 - current folder
    ClearErrors

    Exch $0
    ;DetailPrint "ASDF - $0\.."
    RMDir "$0\.."

    IfErrors Skip
    ${RMDirUP} "$0\.."
    Skip:

    Pop $0

FunctionEnd

;--------------------------------
; Section - Uninstaller

Section "Uninstall"

    ;Delete Desktop Shortcut
    Delete "$DESKTOP\${NAME}.lnk"

    ;Delete Start Menu Shortcut
    Delete "$SMPROGRAMS\${NAME}.lnk"

    ;Delete Uninstall
    Delete "$INSTDIR\Uninstall.exe"

    ;Delete Folder
    RMDir /r "$INSTDIR"
    ${RMDirUP} "$INSTDIR"

SectionEnd