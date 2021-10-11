unit DIBitmap;

{ don't know who wrote this - Thanks !!!}

interface

uses Windows, SysUtils, Classes;

procedure InitializeBitmapInfoHeader(Bitmap: HBITMAP; var BI: TBitmapInfoHeader;
  Colors: Integer);

procedure InternalGetDIBSizes(Bitmap: HBITMAP; var InfoHeaderSize: Integer;
  var ImageSize: DWORD; Colors: Integer);

function InternalGetDIB(Bitmap: HBITMAP; Palette: HPALETTE;
  var BitmapInfo; var Bits; Colors: Integer): Boolean;

implementation

procedure InitializeBitmapInfoHeader(Bitmap: HBITMAP; var BI: TBitmapInfoHeader;
  Colors: Integer);
var
  BM: Windows.TBitmap;
begin
  GetObject(Bitmap, SizeOf(BM), @BM);
  with BI do
  begin
    biSize := SizeOf(BI);
    biWidth := BM.bmWidth;
    biHeight := BM.bmHeight;
    if Colors <> 0 then
      case Colors of
        2: biBitCount := 1;
        16: biBitCount := 4;
        256: biBitCount := 8;
      end
    else biBitCount := BM.bmBitsPixel * BM.bmPlanes;
    biPlanes := 1;
    biXPelsPerMeter := 0;
    biYPelsPerMeter := 0;
    if biBitCount>8 then biClrUsed := 0 else biClrUsed := Colors;
    biClrImportant := 0;
    biCompression := BI_RGB;
    if biBitCount in [16, 32] then biBitCount := 24;
    biSizeImage := (((biWidth * biBitCount) + 31) div 32) * 4 * biHeight;
  end;
end;

procedure InternalGetDIBSizes(Bitmap: HBITMAP; var InfoHeaderSize: Integer;
  var ImageSize: DWORD; Colors: Integer);
var
  BI: TBitmapInfoHeader;
begin
  InitializeBitmapInfoHeader(Bitmap, BI, Colors);
  with BI do
  begin
    case biBitCount of
      24: InfoHeaderSize := SizeOf(TBitmapInfoHeader);
    else
      InfoHeaderSize := SizeOf(TBitmapInfoHeader) + SizeOf(TRGBQuad) *
       (1 shl biBitCount);
    end;
  end;
  ImageSize := BI.biSizeImage;
end;

function InternalGetDIB(Bitmap: HBITMAP; Palette: HPALETTE;
  var BitmapInfo; var Bits; Colors: Integer): Boolean;
var
  OldPal: HPALETTE;
  Focus: HWND;
  DC: HDC;
begin
  InitializeBitmapInfoHeader(Bitmap, TBitmapInfoHeader(BitmapInfo), Colors);
  OldPal := 0;
  Focus := GetFocus;
  DC := GetDC(Focus);
  try
    if Palette <> 0 then
    begin
      OldPal := SelectPalette(DC, Palette, False);
      RealizePalette(DC);
    end;
    Result := GetDIBits(DC, Bitmap, 0, TBitmapInfoHeader(BitmapInfo).biHeight, @Bits,
      TBitmapInfo(BitmapInfo), DIB_RGB_COLORS) <> 0;
  finally
    if OldPal <> 0 then SelectPalette(DC, OldPal, False);
    ReleaseDC(Focus, DC);
  end;
end;

end.
