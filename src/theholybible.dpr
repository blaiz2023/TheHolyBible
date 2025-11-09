program TheHolyBible;

uses
  main in 'main.pas',
  gossgui in 'gossgui.pas',
  gossdat in 'gossdat.pas',
  gossimg in 'gossimg.pas',
  gossio in 'gossio.pas',
  gossnet in 'gossnet.pas',
  gossroot in 'gossroot.pas',
  gosssnd in 'gosssnd.pas',
  gosswin in 'gosswin.pas',
  gossjpg in 'gossjpg.pas',
  gosszip in 'gosszip.pas',
  bibles in 'bibles.pas';

//include multi-format icon - Delphi 3 can't compile an of 256x256 @ 32 bit -> resource error/out of memory error - 19nov2024
{$R theholybible-256.res}//17jun2025

//include version information
{$r ver.res}

begin
//(1)false=event driven disabled, (2)false=file handle caching disabled, (3)true=gui app mode
app__boot(true,false,not isconsole);
end.

