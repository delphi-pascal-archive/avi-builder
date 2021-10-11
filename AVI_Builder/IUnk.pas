unit IUnk;

{This allows us to subclass IUnknown without having to include the now defunct
ole2.pas.

17 December 1998
Rob Anderson
Anderson Software - Geneva, Switzerland
anderson@nosredna.com
}

interface

uses Windows;

type

{ Result code }

  HResult = Longint;

{ Globally unique ID }

  PGUID = ^TGUID;
  TGUID = record
    D1: Longint;
    D2: Word;
    D3: Word;
    D4: array[0..7] of Byte;
  end;

{ Interface ID }

  PIID = PGUID;
  TIID = TGUID;

{ Class ID }

  PCLSID = PGUID;
  TCLSID = TGUID;

{ IUnknown interface }

  IUnknown = class
  public
    function QueryInterface(const iid: TIID; var obj): HResult; virtual; stdcall; abstract;
    function AddRef: Longint; virtual; stdcall; abstract;
    function Release: Longint; virtual; stdcall; abstract;
  end;

implementation

end.
