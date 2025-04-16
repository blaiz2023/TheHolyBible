program TheHolyBible;

uses
  Forms,
  main in 'main.pas',
  gossdat in 'gossdat.pas',
  gossgui in 'gossgui.pas',
  gossimg in 'gossimg.pas',
  gossio in 'gossio.pas',
  gossnet in 'gossnet.pas',
  gossroot in 'gossroot.pas',
  gosssnd in 'gosssnd.pas',
  gosswin in 'gosswin.pas',
  bibles in 'bibles.pas';

//{$R *.RES}
//include multi-format icon - Delphi 3 can't compile an icon of 256x256 @ 32 bit -> resource error/out of memory error - 19nov2024
{$R app-icon-16-256px.res}

begin
//(1)true=timer event driven and false=direct processing, (2)false=file handle caching disabled, (3)true=gui app mode
app__boot(true,false,not isconsole);
end.

