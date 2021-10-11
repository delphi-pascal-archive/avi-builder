unit AniTool;

{This tool allows the user to easily create avi files for use, for example, with
the Delphi/C++Builder TAnimate component.  It is an improvement on an old
freeware thing I found lying around somewhere.  Unfortunately I don't know who
wrote the original, but all of the work in VFW and DIBitmap is his (or hers).

You can use this software however you want so long as it remains free.  Please
leave in some mention of Anderson Software.  Also, if anyone knows who did the
work on VFW and DIBitmap, please add their names too.

I think its use is pretty obvious.  Add some bitmaps, sort them and then create
the avi.  It has to be saved before the preview starts.  The frame counter lets
you speed up or slow down the animation, but it has to be saved again before the
change registers (as do any changes of frame order).

17 December 1998
Rob Anderson
Anderson Software - Geneva, Switzerland
anderson@nosredna.com
}

interface

uses
  SysUtils, ComCtrls, StdCtrls, Spin, Buttons, ToolWin, Menus, Dialogs,
  ExtCtrls, Controls, Classes, Forms;

type
  TAniToolForm = class(TForm)
    BitmapListBox: TListBox;
    AddBitmapDialog: TOpenDialog;
    SaveAVIDialog: TSaveDialog;
    Panel2: TPanel;
    Panel3: TPanel;
    Splitter1: TSplitter;
    Animate1: TAnimate;
    Label1: TLabel;
    ToolBar1: TToolBar;
    SpeedButton4: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    spinRate: TSpinEdit;
    SpeedButton1: TSpeedButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    Panel1: TPanel;
    BitmapImage: TImage;
    Label2: TLabel;
    StatusBar1: TStatusBar;
    procedure SpeedButton4Click(Sender: TObject);
    procedure BitmapListBoxClick(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
  private
    { Private Declarations }
  public
    { Public Declarations }
  end;

var
  AniToolForm: TAniToolForm;

implementation

uses Windows, Graphics, VFW, DIBitmap;

{$R *.DFM}

procedure TAniToolForm.SpeedButton4Click(Sender: TObject);
var
  MyBitmap: TBitmap;
  i:        Integer;
begin
  with AddBitmapDialog do
    if Execute then
      for i:=0 to Files.Count-1 do
      begin
        MyBitmap := TBitmap.Create;
        MyBitmap.LoadFromFile(Files[i]);
        BitmapListBox.Items.AddObject(ExtractFileName(Files[i]),MyBitmap);
      end;
end;

procedure TAniToolForm.BitmapListBoxClick(Sender: TObject);
begin
  with BitmapListBox do
    if SelCount>1 then
      BitmapImage.Picture := nil
    else
      BitmapImage.Picture.Bitmap := Items.Objects[ItemIndex] as TBitmap;
end;

procedure TAniToolForm.SpeedButton3Click(Sender: TObject);
var
  i: Integer;
begin
  with BitmapListBox do
    for i:=Items.Count-1 downto 0 do
      if Selected[i] then
      begin
        (Items.Objects[i] as TBitmap).Free;
        Items.Delete(i);
      end;
end;

procedure TAniToolForm.SpeedButton1Click(Sender: TObject);
var
  i: Integer;
  pfile: PAVIFile;
  asi: TAVIStreamInfo;
  ps: PAVIStream;
  nul: Longint;

  BitmapInfo: PBitmapInfoHeader;
  BitmapInfoSize: Integer;
  BitmapBits: Pointer;
  BitmapSize: Integer;
begin
  Animate1.Filename := '';
  Animate1.Active := False;

  with BitmapListBox, SaveAVIDialog do
    if Execute then
    begin
      AVIFileInit;

      if AVIFileOpen(pfile, PChar(FileName), OF_WRITE or OF_CREATE, nil)=AVIERR_OK then
      begin
        FillChar(asi,sizeof(asi),0);

        asi.fccType := streamtypeVIDEO;                 //  Now prepare the stream
        asi.fccHandler := 0;
        asi.dwScale := 1;
        asi.dwRate := spinRate.Value;

        with Items.Objects[0] as TBitmap do
        begin
          InternalGetDIBSizes(Handle,BitmapInfoSize,DWORD(BitmapSize),Integer(256));
          BitmapInfo := AllocMem(BitmapInfoSize);
          BitmapBits := AllocMem(BitmapSize);
          InternalGetDIB(Handle,0,BitmapInfo^,BitmapBits^,256);
        end;

        asi.dwSuggestedBufferSize := BitmapInfo^.biSizeImage;
        asi.rcFrame.Right := BitmapInfo^.biWidth;
        asi.rcFrame.Bottom := BitmapInfo^.biHeight;

        if AVIFileCreateStream(pfile,ps,asi)=AVIERR_OK then
          with (Items.Objects[0] as TBitmap) do
          begin
            InternalGetDIB(Handle,0,BitmapInfo^,BitmapBits^,256);
            if AVIStreamSetFormat(ps,0,BitmapInfo,BitmapInfoSize)=AVIERR_OK then
            begin
              for i:=0 to Items.Count-1 do
                with (Items.Objects[i] as TBitmap) do
                begin
                  InternalGetDIB(Handle,0,BitmapInfo^,BitmapBits^,256);
                  if AVIStreamWrite(ps,i,1,BitmapBits,BitmapSize,AVIIF_KEYFRAME,nul,nul)<>AVIERR_OK then
                  begin
                    raise Exception.Create('Could not add frame');
                    break;
                  end;
                end;
            end;
          end;
          FreeMem(BitmapInfo);
          FreeMem(BitmapBits);
        end;

      AVIStreamRelease(ps);
      AVIFileRelease(pfile);

      AVIFileExit;
    end;
    if FileExists(SaveAVIDialog.Filename) then begin
      Animate1.Filename := SaveAVIDialog.Filename;
      Animate1.Active := True;
    end;
end;

procedure TAniToolForm.SpeedButton2Click(Sender: TObject);
var jnSelectedItem : word;
begin
  jnSelectedItem := BitmapListBox.ItemIndex;
  if jnSelectedItem > 0 then begin
    BitmapListBox.Items.Move(jnSelectedItem, jnSelectedItem - 1);
    BitmapListBox.Selected[jnSelectedItem - 1] := True;
  end;
end;

procedure TAniToolForm.SpeedButton5Click(Sender: TObject);
var jnSelectedItem : word;
begin
  jnSelectedItem := BitmapListBox.ItemIndex;
  if jnSelectedItem < BitmapListBox.Items.Count - 1 then begin
    BitmapListBox.Items.Move(jnSelectedItem, jnSelectedItem + 1);
    BitmapListBox.Selected[jnSelectedItem + 1] := True;
  end;
end;

procedure TAniToolForm.SpeedButton6Click(Sender: TObject);
begin
  BitmapListBox.Sorted := not BitmapListBox.Sorted;
end;

end.
