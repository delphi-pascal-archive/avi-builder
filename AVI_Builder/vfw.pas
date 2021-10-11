unit VFW;

{ don't know who wrote this - the AVI section for avifil32.dll - Thanks !!!}

interface

uses Windows, IUnk;

type

{ TAVIFileInfoW record }

  LONG = Longint;
  PVOID = Pointer;

  TAVIFileInfoW = record
    dwMaxBytesPerSec,	// max. transfer rate
    dwFlags,		// the ever-present flags
    dwCaps,
    dwStreams,
    dwSuggestedBufferSize,

    dwWidth,
    dwHeight,

    dwScale,
    dwRate,	// dwRate / dwScale == samples/second
    dwLength,

    dwEditCount: DWORD;

    szFileType: array[0..63] of WideChar;		// descriptive string for file type?
  end;
  PAVIFileInfoW = ^TAVIFileInfoW;

{ TAVIStreamInfoA record }

  TAVIStreamInfoA = record
    fccType,
    fccHandler,
    dwFlags,        // Contains AVITF_* flags
    dwCaps: DWORD;
    wPriority,
    wLanguage: WORD;
    dwScale,
    dwRate, // dwRate / dwScale == samples/second
    dwStart,
    dwLength, // In units above...
    dwInitialFrames,
    dwSuggestedBufferSize,
    dwQuality,
    dwSampleSize: DWORD;
    rcFrame: TRect;
    dwEditCount,
    dwFormatChangeCount,
    szName:  array[0..63] of AnsiChar;
  end;
  TAVIStreamInfo = TAVIStreamInfoA;
  
{ TAVIStreamInfoW record }

  TAVIStreamInfoW = record
    fccType,
    fccHandler,
    dwFlags,        // Contains AVITF_* flags
    dwCaps: DWORD;
    wPriority,
    wLanguage: WORD;
    dwScale,
    dwRate, // dwRate / dwScale == samples/second
    dwStart,
    dwLength, // In units above...
    dwInitialFrames,
    dwSuggestedBufferSize,
    dwQuality,
    dwSampleSize: DWORD;
    rcFrame: TRect;
    dwEditCount,
    dwFormatChangeCount,
    szName:  array[0..63] of WideChar;
  end;

{ IAVIStream interface }

  IAVIStream = class(IUnknown)
    function Create(lParam1, lParam2: LPARAM): HResult; virtual; stdcall; abstract;
    function Info(var psi: TAVIStreamInfoW; lSize: LONG): HResult; virtual; stdcall; abstract;
    function FindSample(lPos, lFlags: LONG): LONG; virtual; stdcall; abstract;
    function ReadFormat(lPos: LONG; lpFormat: PVOID; var lpcbFormat: LONG): HResult; virtual; stdcall; abstract;
    function SetFormat(lPos: LONG; lpFormat: PVOID; lpcbFormat: LONG): HResult; virtual; stdcall; abstract;
    function Read(lStart, lSamples: LONG; lpBuffer: PVOID; cbBuffer: LONG; var plBytes: LONG; var plSamples: LONG): HResult; virtual; stdcall; abstract;
    function Write(lStart, lSamples: LONG; lpBuffer: PVOID; cbBuffer: LONG; dwFlags: DWORD; var plSampWritten: LONG; var plBytesWritten: LONG): HResult; virtual; stdcall; abstract;
    function Delete(lStart, lSamples: LONG): HResult; virtual; stdcall; abstract;
    function ReadData(fcc: DWORD; lp: PVOID; var lpcb: LONG): HResult; virtual; stdcall; abstract;
    function WriteData(fcc: DWORD; lp: PVOID; cb:  LONG): HResult; virtual; stdcall; abstract;
    function SetInfo(var lpInfo: TAVIStreamInfoW; cbInfo: LONG): HResult; virtual; stdcall; abstract;
  end;
  PAVIStream = ^IAVIStream;

{ IAVIFile interface }

  IAVIFile = class(IUnknown)
    function Info(var pfi: TAVIFileInfoW; lSize: LONG): HResult; virtual; stdcall; abstract;
    function GetStream(var ppStream: PAVIStream; fccType: DWORD; lParam: LONG): HResult; virtual; stdcall; abstract;
    function CreateStream(var ppStream: PAVIStream; var pfi: TAVIFileInfoW): HResult; virtual; stdcall; abstract;
    function WriteData(ckid: DWORD; lpData: PVOID; cbData: LONG): HResult; virtual; stdcall; abstract;
    function ReadData(ckid: DWORD; lpData: PVOID; var lpcbData: LONG): HResult; virtual; stdcall; abstract;
    function EndRecord: HResult; virtual; stdcall; abstract;
    function DeleteStream(fccType: DWORD; lParam: LONG): HResult; virtual; stdcall; abstract;
  end;
  PAVIFile = ^IAVIFile;

procedure AVIFileInit; stdcall;
procedure AVIFileExit; stdcall;
function AVIFileOpen(var ppfile: PAVIFile; szFile: LPCSTR; uMode: UINT; lpHandler: PCLSID): HResult; stdcall;
function AVIFileCreateStream(pfile: PAVIFile; var ppavi: PAVISTREAM; var psi: TAVIStreamInfoA): HResult; stdcall;
function AVIStreamSetFormat(pavi: PAVIStream; lPos: LONG; lpFormat: PVOID; cbFormat: LONG): HResult; stdcall;
function AVIStreamWrite(pavi: PAVIStream; lStart, lSamples: LONG; lpBuffer: PVOID; cbBuffer: LONG; dwFlags: DWORD; var plSampWritten: LONG; var plBytesWritten: LONG): HResult; stdcall;
function AVIStreamRelease(pavi: PAVISTREAM): ULONG; stdcall;
function AVIFileRelease(pfile: PAVIFile): ULONG; stdcall;

const
  AVIERR_OK       = 0;

  AVIIF_LIST      = $01;
  AVIIF_TWOCC	  = $02;
  AVIIF_KEYFRAME  = $10;

  streamtypeVIDEO = $73646976; // DWORD( 'v', 'i', 'd', 's' )

{ AVI interface IDs }

  IID_IAVIFile: TGUID = (
    D1:$00020020;D2:$0;D3:$0;D4:($C0,$0,$0,$0,$0,$0,$0,$46));
  IID_IAVIStream: TGUID = (
    D1:$00020021;D2:$0;D3:$0;D4:($C0,$0,$0,$0,$0,$0,$0,$46));
  IID_IAVIStreaming: TGUID = (
    D1:$00020022;D2:$0;D3:$0;D4:($C0,$0,$0,$0,$0,$0,$0,$46));
  IID_IGetFrame: TGUID = (
    D1:$00020023;D2:$0;D3:$0;D4:($C0,$0,$0,$0,$0,$0,$0,$46));
  IID_IAVIEditStream: TGUID = (
    D1:$00020024;D2:$0;D3:$0;D4:($C0,$0,$0,$0,$0,$0,$0,$46));

{ AVI class IDs }

  CLSID_AVISimpleUnMarshal: TGUID = (
    D1:$00020009;D2:$0;D3:$0;D4:($C0,$0,$0,$0,$0,$0,$0,$46));
  CLSID_AVIFile: TGUID = (
    D1:$00020000;D2:$0;D3:$0;D4:($C0,$0,$0,$0,$0,$0,$0,$46));

implementation

procedure AVIFileInit; stdcall; external 'avifil32.dll' name 'AVIFileInit';
procedure AVIFileExit; stdcall; external 'avifil32.dll' name 'AVIFileExit';
function AVIFileOpen(var ppfile: PAVIFILE; szFile: LPCSTR; uMode: UINT; lpHandler: PCLSID): HResult; external 'avifil32.dll' name 'AVIFileOpenA';
function AVIFileCreateStream(pfile: PAVIFile; var ppavi: PAVIStream; var psi: TAVIStreamInfoA): HResult; external 'avifil32.dll' name 'AVIFileCreateStreamA';
function AVIStreamSetFormat(pavi: PAVIStream; lPos: LONG; lpFormat: PVOID; cbFormat: LONG): HResult; external 'avifil32.dll' name 'AVIStreamSetFormat';
function AVIStreamWrite(pavi: PAVIStream; lStart, lSamples: LONG; lpBuffer: PVOID; cbBuffer: LONG; dwFlags: DWORD; var plSampWritten: LONG; var plBytesWritten: LONG): HResult; external 'avifil32.dll' name 'AVIStreamWrite';
function AVIStreamRelease(pavi: PAVIStream): ULONG; external 'avifil32.dll' name 'AVIStreamRelease';
function AVIFileRelease(pfile: PAVIFile): ULONG; external 'avifil32.dll' name 'AVIFileRelease';

end.
