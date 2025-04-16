unit main;

interface

uses
{$ifdef gui3} {$define gui2} {$endif}
{$ifdef gui2} {$define gui}  {$define jpeg} {$endif}
{$ifdef gui} {$define bmp} {$define ico} {$define gif} {$define snd} {$endif}

{$ifdef con3} {$define con2} {$endif}
{$ifdef con2} {$define bmp} {$define ico} {$define gif} {$define jpeg} {$endif}

{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d3laz} {$undef laz} {$endif}
{$ifdef d3laz} windows, messages, sysutils, classes, graphics, forms, dialogs, math, gossroot, {$ifdef gui}gossgui,{$endif} {$ifdef snd}gosssnd,{$endif} gosswin, gossio, gossimg, gossnet; {$endif}
{$B-} {generate short-circuit boolean evaluation code -> stop evaluating logic as soon as value is known}

//## ==========================================================================================================================================================================================================================
//##
//## MIT License
//##
//## Copyright 2025 Blaiz Enterprises ( http://www.blaizenterprises.com )
//##
//## Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
//## files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
//## modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
//## is furnished to do so, subject to the following conditions:
//##
//## The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//##
//## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//## OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//## LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//## CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//##
//## ==========================================================================================================================================================================================================================
//## Library.................. app code (main.pas)
//## Version.................. 1.00.2146
//## Items.................... 3
//## Last Updated ............ 17apr2025, 21mar2025
//## Lines of Code............ 2,400+
//##
//## main.pas ................ app code
//## gossroot.pas ............ console/gui app startup and control
//## gossio.pas .............. file io
//## gossimg.pas ............. image/graphics
//## gossnet.pas ............. network
//## gosswin.pas ............. 32bit windows api's
//## gosssnd.pas ............. sound/audio/midi/chimes
//## gossgui.pas ............. gui management/controls
//## gossdat.pas ............. static data/icons/splash/help settings/help document(gui only)
//##
//## ==========================================================================================================================================================================================================================
//## | Name                   | Hierarchy         | Version   | Date        | Update history / brief description of function
//## |------------------------|-------------------|-----------|-------------|--------------------------------------------------------
//## | tprogram               | tbasicapp         | 1.00.303  | 17apr2025   | The Holy Bible - 21mar2025
//## | tbiblesearch           | tbasicscroll      | 1.00.1343 | 17apr2025   | Search panel - 21mar2025
//## | tbookcore              | tobjectex         | 1.00.500  | 17apr2025   | Book content object
//## ==========================================================================================================================================================================================================================
//## Performance Note:
//##
//## The runtime compiler options "Range Checking" and "Overflow Checking", when enabled under Delphi 3
//## (Project > Options > Complier > Runtime Errors) slow down graphics calculations by about 50%,
//## causing ~2x more CPU to be consumed.  For optimal performance, these options should be disabled
//## when compiling.
//## ==========================================================================================================================================================================================================================


var
   itimerbusy:boolean=false;
   iapp:tobject=nil;

   //shared vars
   sysshared_historylist:array[0..99] of string;
   sysshared_stylemaskcount:longint=0;
   sysshared_stylemask:tstr8=nil;


const
   //line codes
   lbCode         =ssdollar;
   lbTitle        =ssat;
   lbTestament    =ssexclaim;
   lbBook         =sshash;
   //scope code
   scFull         =2;
   scTestament    =1;
   scBook         =0;

   bookcore_titlecount=200;

type
{tbookcore}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxx//5555555555555555555
   tbookcore=class(tobjectex)
   private
    ilastfindslot  :longint;
    icount         :longint;
    ititle         :array[0..(bookcore_titlecount-1)] of string;
    ifrom          :array[0..(bookcore_titlecount-1)] of longint;
    iscope         :array[0..(bookcore_titlecount-1)] of longint;//0=book, 1=testament, 2=entire text
    icode          :string;
    ifiledata      :tstr8;
    ifilesize      :longint;
    ifileindex     :longint;
    function getscope(x:longint):longint;
    function getfrom(x:longint):longint;
    function gettitle(x:longint):string;
    procedure setfileindex(x:longint);
    function getstylemask:tstr8;
    function getfpathname(x:longint):string;
    function getfpath(x:longint):string;
    function getfname(x:longint):string;
    function getfbarename(x:longint):string;
    function getfsize(x:longint):longint;
    function getfcount:longint;
    procedure xloadfile;
    function xfindbyname2(const xtitle:string;var xslot,xfrom,xscope:longint):boolean;
   public
    //create
    constructor create; override;
    destructor destroy; override;
    //information
    property count:longint read icount;
    property scope[x:longint]:longint read getscope;
    property from [x:longint]:longint read getfrom;
    property title[x:longint]:string  read gettitle;
    property code:string read icode;
    property stylemask:tstr8 read getstylemask;
    //.file support
    property fcount              :longint read getfcount;
    property fpathname[x:longint]:string  read getfpathname;
    property fpath    [x:longint]:string  read getfpath;
    property fname    [x:longint]:string  read getfname;
    property fbarename[x:longint]:string  read getfbarename;
    property fsize    [x:longint]:longint read getfsize;
    //.current file in use
    property fileindex:longint read ifileindex write setfileindex;
    property filesize :longint read ifilesize;
    property filedata :tstr8 read ifiledata;
    //find
    function findbyname(const xtitle:string;var xslot:longint):boolean;
    function findbyslot(xslot:longint;var xtitle:string;var xfrom,xto,xscope:longint):boolean;
    function findbookslot(xfrom:longint;var xslot:longint):boolean;
    procedure findbookslotRESET;
    function nextsection1(var dpos,dstart,dlen:longint):boolean;//1-based
   end;


{tbiblesearch}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//222222222222222222222222222222
   tbiblesearch=class(tbasicscroll)
   private
    icore:tbookcore;
    itimer100:comp;
    ititlebar,itoolbar:tbasictoolbar;
    itext:tbasicbwp;
    iedit:tbasicedit;
    icompact,imustfind,imustfind_retainvpos,imustfindnohistory,iloaded,iexact,iall,iauto:boolean;
    ititle,ilastfind:string;
    ihighlight,ititleslot,ialign,iid:longint;
    inamelist:array[0..399] of string;
    istartpos:array[0..399] of longint;
    icount:longint;
    function getsettings:string;
    procedure setsettings(x:string);
    procedure xfind(xaddtohistory,xretainvpos:boolean);
    procedure __onclick(sender:tobject);
    function __onmenuclick(sender:tbasiccontrol;xstyle:string;xcode:longint;xcode2:string;xtepcolor:longint):boolean;
    procedure xcmd(sender:tobject;xcode:longint;xcode2:string);
    procedure xupdatebuttons;
    procedure xshowmenuFill(sender:tobject;xstyle:string;xmenudata:tstr8;var ximagealign:longint;var xmenuname:string);
    function gettitle:string;
    function getfileindex:longint;
    procedure setfileindex(x:longint);
    procedure settitle(x:string);
    procedure settitle2(x:string;xallowfind:boolean);
    //history support
    procedure hissave;
    procedure hisload;
    function histext:string;
    procedure hissettext(x:string);
    procedure hisclear;
    procedure hisadd(xline:string);
   public
    //create
    constructor create(xparent:tobject;xid:longint); virtual;
    constructor create2(xparent:tobject;xstart:boolean;xid:longint); virtual;
    destructor destroy; override;
    procedure _ontimer(sender:tobject); override;
    function _onnotify(sender:tobject):boolean; override;
    //info
    property exact:boolean read iexact write iexact;
    property all:boolean read iall write iall;
    property title:string read gettitle write settitle;
    property titleslot:longint read ititleslot;
    property fileindex:longint read getfileindex write setfileindex;
    //settings
    property settings:string read getsettings write setsettings;//settings as a single line of text
    procedure setparams(xfileindex:longint;xtitle:string;xallowfind:boolean);
   end;


{tapp}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//111111111111111111111
   tapp=class(tbasicapp)
   private
    iloaded,ibuildingcontrol:boolean;
    ipanelcount:longint;
    itimer100,itimer350,itimer500:comp;
    isettingsref:string;
    isearch:array[0..2] of tbiblesearch;
    procedure xcmd0(xcode2:string);
    procedure xcmd(sender:tobject;xcode:longint;xcode2:string);
    procedure __onclick(sender:tobject);
    procedure __ontimer(sender:tobject); override;
    procedure xloadsettings;
    procedure xsavesettings;
    procedure xautosavesettings;
    procedure xupdatebuttons;
   public
    //create
    constructor create; virtual;
    destructor destroy; override;
   end;

{$ifdef gui}
  TForm1 = class(TForm)//placeholder to keep Delphi 3 happy
  private

  public

  end;
{$endif}



//info procs -------------------------------------------------------------------
function app__info(xname:string):string;
function info__app(xname:string):string;//information specific to this unit of code - 20jul2024: program defaults added, 23jun2024


//app procs --------------------------------------------------------------------
//.create / destroy
procedure app__create;
procedure app__destroy;

//.event handlers
function app__onmessage(m,w,l:longint):longint;
procedure app__onpaintOFF;//called when screen was live and visible but is now not live, and output is back to line by line
procedure app__onpaint(sw,sh:longint);
procedure app__ontimer;

//.support procs
function app__netmore:tnetmore;//optional - return a custom "tnetmore" object for a custom helper object for each network record -> once assigned to a network record, the object remains active and ".clear()" proc is used to reduce memory/clear state info when record is reset/reused
function app__findcustomtep(xindex:longint;var xdata:tlistptr):boolean;
function app__syncandsavesettings:boolean;

const
tep_write32:array[0..432] of byte=(
84,69,65,49,35,17,0,0,0,30,0,0,0,255,255,255,37,0,0,0,2,255,255,255,2,0,0,0,2,255,255,255,11,0,0,0,2,255,255,255,2,0,0,0,2,255,255,255,11,0,0,0,2,255,255,255,2,0,0,0,3,255,255,255,10,0,0,0,2,255,255,255,2,0,0,0,3,255,255,255,10,0,0,0,2,255,255,255,2,0,0,0,4,255,255,255,9,0,0,0,2,255,255,255,2,0,0,0,4,255,255,255,9,0,0,0,2,255,255,255,2,0,0,0,5,255,255,255,8,0,0,0,2,255,255,255,2,0,0,0,5,255,255,255,8,0,0,0,2,255,255,255,2,0,0,0,6,255,255,255,7,0,0,0,2,255,255,255,2,0,0,0,6,255,255,255,7,0,0,0,2,255,255,255,2,0,0,0,7,255,255,255,6,0,0,0,2,255,255,255,2,0,0,0,7,255,255,255,6,0,0,0,2,255,255,255,2,0,0,0,7,255,255,255,6,0,0,0,2,255,255,255,2,0,0,0,7,255,255,255,6,0,0,0,2,255,255,255,2,0,0,0,7,255,255,255,6,0,0,0,2,255,255,255,2,0,0,0,7,255,255,255,6,0,0,0,2,255,255,255,2,0,0,0,6,255,255,255,7,0,0,0,2,255,255,255,2,0,0,0,6,255,255,255,7,0,0,0,2,255,255,255,2,0,0,0,5,255,255,255,8,0,0,0,2,255,255,255,2,0,0,0,5,255,255,255,8,0,0,0,2,255,255,255,2,0,0,0,4,255,255,255,9,0,0,0,2,255,255,255,2,0,0,0,4,255,
255,255,9,0,0,0,2,255,255,255,2,0,0,0,3,255,255,255,10,0,0,0,2,255,255,255,2,0,0,0,3,255,255,255,10,0,0,0,2,255,255,255,2,0,0,0,2,255,255,255,11,0,0,0,2,255,255,255,2,0,0,0,2,255,255,255,42);

tep_search32:array[0..416] of byte=(
84,69,65,49,35,32,0,0,0,30,0,0,0,255,255,255,139,0,0,0,6,255,255,255,24,0,0,0,2,255,255,255,6,0,0,0,1,255,255,255,22,0,0,0,1,255,255,255,9,0,0,0,2,255,255,255,19,0,0,0,1,255,255,255,11,0,0,0,1,255,255,255,19,0,0,0,1,255,255,255,4,0,0,0,2,255,255,255,6,0,0,0,1,255,255,255,17,0,0,0,1,255,255,255,4,0,0,0,1,255,255,255,9,0,0,0,1,255,255,255,16,0,0,0,1,255,255,255,3,0,0,0,1,255,255,255,10,0,0,0,1,255,255,255,16,0,0,0,1,255,255,255,3,0,0,0,1,255,255,255,10,0,0,0,1,255,255,255,16,0,0,0,1,255,255,255,14,0,0,0,1,255,255,255,16,0,0,0,1,255,255,255,14,0,0,0,1,255,255,255,16,0,0,0,1,255,255,255,14,0,0,0,1,255,255,255,17,0,0,0,1,255,255,255,12,0,0,0,1,255,255,255,19,0,0,0,1,255,255,255,11,0,0,0,1,255,255,255,19,0,0,0,2,255,255,255,9,0,0,0,3,255,255,255,20,0,0,0,1,255,255,255,6,0,0,0,4,255,255,255,1,0,0,0,1,255,255,255,20,0,0,0,6,255,255,255,2,0,0,0,1,255,255,255,3,0,0,0,1,255,255,255,28,0,0,0,1,255,255,255,3,0,0,0,1,255,255,255,28,0,0,0,1,255,255,255,3,0,0,0,1,255,255,255,28,0,0,0,1,255,255,255,3,0,0,0,1,255,
255,255,28,0,0,0,1,255,255,255,3,0,0,0,1,255,255,255,28,0,0,0,1,255,255,255,3,0,0,0,1,255,255,255,28,0,0,0,1,255,255,255,1,0,0,0,2,255,255,255,29,0,0,0,2,255,255,255,100);

tep_panel20:array[0..416] of byte=(
84,69,65,49,35,16,0,0,0,20,0,0,0,252,252,252,50,102,102,51,12,252,252,252,3,128,128,64,2,252,252,252,1,128,128,64,1,252,252,252,1,128,128,64,1,252,252,252,7,128,128,64,1,252,252,252,2,153,153,76,1,252,252,252,1,153,153,76,1,252,252,252,1,153,153,76,2,252,252,252,7,153,153,76,1,252,252,252,2,178,178,89,2,252,252,252,1,178,178,89,1,252,252,252,1,178,178,89,1,252,252,252,7,178,178,89,1,252,252,252,2,204,204,102,1,252,252,252,1,204,204,102,1,252,252,252,1,204,204,102,2,252,252,252,7,204,204,102,1,252,252,252,2,230,230,115,2,252,252,252,1,230,230,115,1,252,252,252,1,230,230,115,1,252,252,252,7,230,230,115,1,252,252,252,2,255,255,128,1,252,252,252,1,255,255,128,1,252,252,252,1,255,255,128,2,252,252,252,7,255,255,128,1,252,252,252,2,255,255,128,2,252,252,252,1,255,255,128,1,252,252,252,1,255,255,128,1,252,252,252,7,255,255,128,1,252,252,252,2,230,230,115,1,252,252,252,1,230,230,115,1,252,252,252,1,230,230,115,2,252,252,252,7,230,230,115,1,252,252,252,2,204,204,102,2,252,252,252,1,204,204,102,1,252,252,
252,1,204,204,102,1,252,252,252,7,204,204,102,1,252,252,252,2,178,178,89,1,252,252,252,1,178,178,89,1,252,252,252,1,178,178,89,2,252,252,252,7,178,178,89,1,252,252,252,2,153,153,76,2,252,252,252,1,153,153,76,1,252,252,252,1,153,153,76,1,252,252,252,7,153,153,76,1,252,252,252,2,128,128,64,1,252,252,252,1,128,128,64,1,252,252,252,1,128,128,64,2,252,252,252,7,128,128,64,1,252,252,252,3,102,102,51,12,252,252,252,50);
{
:array[0..416] of byte=(
84,69,65,49,35,16,0,0,0,20,0,0,0,252,252,252,50,0,0,0,12,252,252,252,3,0,0,0,2,252,252,252,1,0,0,0,1,252,252,252,1,0,0,0,1,252,252,252,7,0,0,0,1,252,252,252,2,0,0,0,1,252,252,252,1,0,0,0,1,252,252,252,1,0,0,0,2,252,252,252,7,0,0,0,1,252,252,252,2,0,0,0,2,252,252,252,1,0,0,0,1,252,252,252,1,0,0,0,1,252,252,252,7,0,0,0,1,252,252,252,2,0,0,0,1,252,252,252,1,0,0,0,1,252,252,252,1,0,0,0,2,252,252,252,7,0,0,0,1,252,252,252,2,0,0,0,2,252,252,252,1,0,0,0,1,252,252,252,1,0,0,0,1,252,252,252,7,0,0,0,1,252,252,252,2,0,0,0,1,252,252,252,1,0,0,0,1,252,252,252,1,0,0,0,2,252,252,252,7,0,0,0,1,252,252,252,2,0,0,0,2,252,252,252,1,0,0,0,1,252,252,252,1,0,0,0,1,252,252,252,7,0,0,0,1,252,252,252,2,0,0,0,1,252,252,252,1,0,0,0,1,252,252,252,1,0,0,0,2,252,252,252,7,0,0,0,1,252,252,252,2,0,0,0,2,252,252,252,1,0,0,0,1,252,252,252,1,0,0,0,1,252,252,252,7,0,0,0,1,252,252,252,2,0,0,0,1,252,252,252,1,0,0,0,1,252,252,252,1,0,0,0,2,252,252,252,7,0,0,0,1,252,252,252,2,0,0,0,2,252,252,252,1,0,0,0,1,252,252,252,1,0,0,0,1,252,252,
252,7,0,0,0,1,252,252,252,2,0,0,0,1,252,252,252,1,0,0,0,1,252,252,252,1,0,0,0,2,252,252,252,7,0,0,0,1,252,252,252,3,0,0,0,12,252,252,252,50);
}

//.cleaning procs
function bible__cleanfile(xfilename:string;xremtabs,xstrictcheck,xlrelaxed_nocodechecking:boolean):boolean;//22mar2025
function bible__cleanfiles(xfolder,xmask:string;xremtabs,xstrictcheck:boolean):boolean;
function bible__cleanlines(const xin:string):string;//22mar2025



implementation

{$ifdef gui}
uses
    gossdat, bibles;
{$endif}


//info procs -------------------------------------------------------------------
function app__info(xname:string):string;
begin
result:=info__rootfind(xname);
end;

function info__app(xname:string):string;//information specific to this unit of code - 20jul2024: program defaults added, 23jun2024
begin
//defaults
result:='';

try
//init
xname:=strlow(xname);

//get
if      (xname='slogan')              then result:=''//info__app('name')+' by Blaiz Enterprises'
else if (xname='width')               then result:='1350'
else if (xname='height')              then result:='900'
else if (xname='ver')                 then result:='1.00.2146'
else if (xname='date')                then result:='17apr2025'
else if (xname='name')                then result:='The Holy Bible'
else if (xname='web.name')            then result:='theholybible'//used for website name
else if (xname='des')                 then result:='Read and search through the passages of The Holy Bible'
else if (xname='infoline')            then result:=info__app('name')+#32+info__app('des')+' v'+app__info('ver')+' (c) 1997-'+low__yearstr(2025)+' Blaiz Enterprises'
else if (xname='size')                then result:=low__b(io__filesize64(io__exename),true)
else if (xname='diskname')            then result:=io__extractfilename(io__exename)
else if (xname='service.name')        then result:=info__app('name')
else if (xname='service.displayname') then result:=info__app('service.name')
else if (xname='service.description') then result:=info__app('des')
else if (xname='new.instance')        then result:='1'//1=allow new instance, else=only one instance of app permitted
else if (xname='screensizelimit%')    then result:='95'//95% of screen area
else if (xname='realtimehelp')        then result:='0'//1=show realtime help, 0=don't
else if (xname='hint')                then result:='1'//1=show hints, 0=don't
//.links and values
else if (xname='linkname')            then result:=info__app('name')+' by Blaiz Enterprises.lnk'
else if (xname='linkname.vintage')    then result:=info__app('name')+' (Vintage) by Blaiz Enterprises.lnk'
//.author
else if (xname='author.shortname')    then result:='Blaiz'
else if (xname='author.name')         then result:='Blaiz Enterprises'
else if (xname='portal.name')         then result:='Blaiz Enterprises - Portal'
else if (xname='portal.tep')          then result:=inttostr(tepBE20)
//.software
else if (xname='software.tep')        then result:=inttostr(low__aorb(tepNext20,tepIcon20,sizeof(program_icon20h)>=2))
else if (xname='url.software')        then result:='https://www.blaizenterprises.com/'+info__app('web.name')+'.html'
else if (xname='url.software.zip')    then result:='https://www.blaizenterprises.com/'+info__app('web.name')+'.zip'
//.urls
else if (xname='url.portal')          then result:='https://www.blaizenterprises.com'
else if (xname='url.contact')         then result:='https://www.blaizenterprises.com/contact.html'
else if (xname='url.facebook')        then result:='https://web.facebook.com/blaizenterprises'
else if (xname='url.mastodon')        then result:='https://mastodon.social/@BlaizEnterprises'
else if (xname='url.twitter')         then result:='https://twitter.com/blaizenterprise'
else if (xname='url.x')               then result:=info__app('url.twitter')
else if (xname='url.instagram')       then result:='https://www.instagram.com/blaizenterprises'
else if (xname='url.sourceforge')     then result:='https://sourceforge.net/u/blaiz2023/profile/'
else if (xname='url.github')          then result:='https://github.com/blaiz2023'
//.program/splash
else if (xname='license')             then result:='MIT License'
else if (xname='copyright')           then result:='© 1997-'+low__yearstr(2025)+' Blaiz Enterprises'
//else if (xname='nocopyright')         then result:='1997-'+low__yearstr(2025)+' Blaiz Enterprises'
else if (xname='splash.web')          then result:='Web Portal: '+app__info('url.portal')

//.program values -> defaults and fallback values
else if (xname='focused.opacity')     then result:='255'//range: 50..255
else if (xname='unfocused.opacity')   then result:='255'//range: 30..255
else if (xname='opacity.speed')       then result:='9'//range: 1..10 (1=slowest, 10=fastest)

else if (xname='head.large')          then result:='1'//1=large window header, 0=small header
else if (xname='head.center')         then result:='0'//1=center window title, 0=left align window title
else if (xname='head.sleek')          then result:='1'//0=normal window head, 1=in head toolbar (sleek)
else if (xname='head.align')          then result:='1'//0=left, 1=center, 2=right -> head based toolbar alignment

else if (xname='scroll.size')         then result:='20'//scrollbar size: 5..72
else if (xname='scroll.minimal')      then result:='1'//0=normal scrollbars, 1=sleek scrollbars
else if (xname='slider.minimal')      then result:='1'//0=normal sliders, 1=sleek sliders

else if (xname='bordersize')          then result:='15'//0..72 - frame size
else if (xname='sparkle')             then result:='7'//0..20 - default sparkle level -> set 1st time app is run, range: 0-20 where 0=off, 10=medium and 20=heavy)
else if (xname='brightness')          then result:='100'//60..130 - default brightness

else if (xname='back.name')           then result:='plaster'//'texture'//balls'//default background name
else if (xname='ecomode')             then result:='0'//1=economy mode on, 0=economy mode off
else if (xname='glow')                then result:='0'//0=off, 1=on
else if (xname='emboss')              then result:='1'//0=off, 1=on
else if (xname='sleek')               then result:='1'//0=off, 1=on
else if (xname='shade.focus')         then result:='1'//1=focus shading for lists/menus etc, 0=flat focus
else if (xname='shade.round')         then result:='1'//curved shading: 0=off, 1=on
else if (xname='color.name')          then result:='white and pale'//default color scheme name
else if (xname='frame.name')          then result:='narrow'//default frame name
else if (xname='frame.max')           then result:='1'//0=no frame when maximised, 1=frame when maximised
//.font
else if (xname='font.name')           then result:='Arial'//default GUI font name
else if (xname='font.size')           then result:='10'//default GUI font size
//.font2
else if (xname='font2.use')           then result:='1'//0=don't use, 1=use this font for text boxes (special cases)
else if (xname='font2.name')          then result:='Courier New'
else if (xname='font2.size')          then result:='12'
//.help
else if (xname='help.maxwidth')       then result:='500'//pixels - right column when help shown

//.paid/store support
else if (xname='paid')                then result:='0'//desktop paid status ->  programpaid -> 0=free, 1..N=paid - also works inconjunction with "system_storeapp" and it's cost value to determine PAID status is used within help etc
else if (xname='paid.store')          then result:='1'//store paid status
//.anti-tamper programcode checker - updated dual version (program EXE must be secured using "Blaiz Tools") - 11oct2022
else if (xname='check.mode')          then result:='-91234356'//disable check
//else if (xname='check.mode')          then result:='234897'//enable check
else
   begin
   //nil
   end;

except;end;
end;


//app procs --------------------------------------------------------------------
procedure app__create;
begin
{$ifdef gui}
iapp:=tapp.create;
{$else}

//.starting...
app__writeln('');
//app__writeln('Starting server...');

//.visible - true=live stats, false=standard console output
scn__setvisible(false);


{$endif}
end;

procedure app__destroy;
begin
try
//save
//.save app settings
app__syncandsavesettings;

//free the app
freeobj(@iapp);
except;end;
end;


function app__findcustomtep(xindex:longint;var xdata:tlistptr):boolean;

  procedure m(const x:array of byte);//map array to pointer record
  begin
  {$ifdef gui}
  xdata:=low__maplist(x);
  {$else}
  xdata.count:=0;
  xdata.bytes:=nil;
  {$endif}
  end;
begin//Provide the program with a set of optional custom "tep" images, supports images in the TEA format (binary text image)
//defaults
//result:=false;

//sample custom image support

case xindex of
5000:m(tep_write32);
5001:m(tep_search32);
5002:m(tep_panel20);
end;

//successful
result:=(xdata.count>=1);
end;

function app__syncandsavesettings:boolean;
begin
//defaults
result:=false;
try
//.settings
{
app__ivalset('powerlevel',ipowerlevel);
app__ivalset('ramlimit',iramlimit);
{}


//.save
app__savesettings;

//successful
result:=true;
except;end;
end;

function app__netmore:tnetmore;//optional - return a custom "tnetmore" object for a custom helper object for each network record -> once assigned to a network record, the object remains active and ".clear()" proc is used to reduce memory/clear state info when record is reset/reused
begin
result:=tnetbasic.create;
end;

function app__onmessage(m,w,l:longint):longint;
begin
//defaults
result:=0;
end;

procedure app__onpaintOFF;//called when screen was live and visible but is now not live, and output is back to line by line
begin
//nil
end;

procedure app__onpaint(sw,sh:longint);
begin
//console app only
end;

procedure app__ontimer;
begin
try
//check
if itimerbusy then exit else itimerbusy:=true;//prevent sync errors

//last timer - once only
if app__lasttimer then
   begin

   end;

//check
if not app__running then exit;


//first timer - once only
if app__firsttimer then
   begin

   end;



except;end;
try
itimerbusy:=false;
except;end;
end;


//support procs ----------------------------------------------------------------
function bible__cleanfile(xfilename:string;xremtabs,xstrictcheck,xlrelaxed_nocodechecking:boolean):boolean;//22mar2025
label
   skipdone,skipend;
var
   ctitle,ctestament,cbook,v1,dcount,xpos,p:longint;
   s,d,sline:tstr8;
   ln,dn,dv,df,e,v:string;

   function xsplit(var sv,dn,dv:string):boolean;
   var
      slen,p,p2:longint;
   begin
   //defaults
   result:=false;

   //init
   slen:=low__len(sv);

   //get
   for p:=1 to slen do if (sv[p-1+stroffset]=':') then
      begin
      for p2:=p downto 1 do if (sv[p2-1+stroffset]=#32) then
         begin
         dn:=stripwhitespace_lt(strcopy1(sv,1,p2-1));
         dv:=stripwhitespace_lt(strcopy1(sv,p2+1,slen));

         //.filter
         if xremtabs then swapstrs(dv,#9,#32);

         result:=true;
         break;
         end;
      break;
      end;
   end;

   procedure dadd(x:string);
   begin
   d.sadd(x+#10);
   end;
begin
//defaults
result     :=false;
s          :=nil;
sline      :=nil;
d          :=nil;
ctitle     :=0;
ctestament :=0;
cbook      :=0;

try
//init
s     :=str__new8;
sline :=str__new8;
d     :=str__new8;

//xlrelaxed_nocodechecking
if xlrelaxed_nocodechecking then
   begin
   xstrictcheck:=false;
   end;

//load
if not io__fromfile(xfilename,@d,e) then
   begin
   showerror('Error: '+e+' for file:'+rcode+xfilename);
   goto skipend;
   end;
df:=io__remlastext(xfilename)+'-clean.txt';

//clean into lines
if xlrelaxed_nocodechecking then
   begin
   //basic text per line cleaning, no encoding, book titles or other checks are made
   d.text:=bible__cleanlines(d.text);
   goto skipdone;
   end
else s.text:=bible__cleanlines(d.text);

//clear (d)
str__clear(@d);

//clean
dcount:=0;
xpos:=0;
ln:='';

while low__nextline0(s,sline,xpos) do
begin
v:=stripwhitespace_lt(sline.text);

if (v<>'') then
   begin
   inc(dcount);
   v1:=byte(v[0+stroffset]);

   if      (v1=lbcode) then dadd(v)//bible CODE
   else if (v1=lbtitle) then
      begin
      dadd(v);//bible title
      inc(ctitle);
      end
   else if (v1=lbtestament) then
      begin
      dadd(v);//bible testament
      inc(ctestament);
      end
   else
      begin
      if xsplit(v,dn,dv) then
         begin
         //add book title
         if not strmatch(dn,ln) then
            begin
            dadd(char(lbBook)+dn);//book marker
            inc(cbook);
            ln:=dn;
            end;
         //add passage
         dadd(dv);
         end
      else
         begin
         showbasic('error at line '+k64(dcount));
         break;
         end;
      end;

   end;
end;

//save
skipdone:
if not io__tofile(df,@d,e) then
   begin
   showerror('Error: '+e+' for file:'+rcode+df);
   goto skipend;
   end;

//check
if xstrictcheck then
   begin
   if (ctitle<=0) then
      begin
      showerror('No title found, e.g. "'+char(lbTitle)+'King James Bible"');
      goto skipend;
      end;
   if (ctestament<=0) then
      begin
      showerror('1 or fewer testament markers found, e.g. "'+char(lbTestament)+'Old Testament"');
      goto skipend;
      end;
   if (cbook<=0) then
      begin
      showerror('No book content found');
      goto skipend;
      end;
   end;

//successful
result:=true;
skipend:
except;end;
//free
str__free(@s);
str__free(@sline);
str__free(@d);
end;

function bible__cleanfiles(xfolder,xmask:string;xremtabs,xstrictcheck:boolean):boolean;
var
   a:tdynamicstring;
   p:longint;
begin
//defaults
result:=true;
a:=nil;

try
//init
a:=tdynamicstring.create;

//file list
io__filelist(a,true,xfolder,xmask,'*-clean.txt');

//get
for p:=0 to (a.count-1) do if not bible__cleanfile(a.value[p],xremtabs,xstrictcheck,false) then
   begin
   result:=false;
   showerror('Failed to clean the Bible file:'+rcode+a.value[p]);
   break;
   end;//p

except;end;
//free
freeobj(@a);
end;

function bible__cleanlines(const xin:string):string;//22mar2025
label
   redo,skipone,skipend;
var
   xlastnotnil,xonce:boolean;
   vlen,spos,p,lp:longint;
   s,sline,d:tstr8;
   v:string;
   vtitleORcode,vstarthasnumber:boolean;

   procedure dadd2(x:string;xspace:boolean);
   begin
   x          :=stripwhitespace_lt(x);
   xlastnotnil:=(x<>'');

   if xlastnotnil then
      begin
      d.sadd( insstr( low__aorbstr(rcode,#32,xspace) ,not xonce) + x );
      xonce:=false;
      end;
   end;

   procedure dadd(const x:string);
   begin
   dadd2(x,false);
   end;

   function vc(p:longint):char;
   begin
   if (p<1) or (p>vlen) then result:=#0
   else                      result:=v[p-1+stroffset];
   end;

   function vnum(p:longint):boolean;
   begin
   case byte(vc(p)) of
   nn0..nn9:result:=true;
   else     result:=false;
   end;//case
   end;
begin
//defaults
result:='';
s     :=nil;
sline :=nil;
d     :=nil;

try
//init
xonce :=true;
s     :=str__new8;
sline :=str__new8;
d     :=str__new8;
spos  :=0;

//utf8 -> ascii (d -> s)
d.sadd(xin);
if not utf8__toascii(@d,@s,false) then goto skipend;
str__clear(@d);

//get
while low__nextline0(s,sline,spos) do
begin
v   :=sline.text+#0;//append a EOL marker
vlen:=low__len(v);

if (vlen>=1) then
   begin
   p :=1;
   lp:=1;
   vstarthasnumber:=vnum(1);
   vtitleORcode   :=(not vstarthasnumber) and ((vc(1)='$') or (vc(1)='@') or (vc(1)='!') or (vc(1)='#'));

   //line is a book title or code -> skip line processing and just add
   if vtitleORcode then
      begin
      dadd(strcopy1(v,1,vlen-1));
      goto skipone;
      end;

   redo:
   if (vc(p)=':') and vnum(p-1) and vnum(p+1) then
      begin

      //123:1
      if vnum(p-3) and vnum(p-2) then
         begin
         dadd2(strcopy1(v,lp,p-lp-3),not vstarthasnumber);
         lp:=p-3;
         end
      //23:1
      else if vnum(p-2) then
         begin
         dadd2(strcopy1(v,lp,p-lp-2),not vstarthasnumber);
         lp:=p-2;
         end
      //3:1
      else
         begin
         dadd2(strcopy1(v,lp,p-lp-1),not vstarthasnumber);
         lp:=p-1;
         end;

      //reset
      vstarthasnumber:=true;
      end
   else if (vc(p)=#0) then dadd2(strcopy1(v,lp,p-lp),not vstarthasnumber);

   //loop
   inc(p);
   if (p<=vlen) then goto redo;
   skipone:
   end;
end;//loop

//finalise
d.sadd(rcode);

//set
result:=d.text;
skipend:
except;end;
//free
str__free(@s);
str__free(@sline);
str__free(@d);
end;


//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//1111111111111111111111111111
constructor tapp.create;
var
   p:longint;
begin

//if not bible__cleanfile('c:\temp15\1.txt',true,true,true) then showbasic('err1');
//if not bible__cleanfile('c:\123Bibles__2025\public-domain\kjv_old.txt',true,false,true) then showbasic('err1');
//app__halt;


if system_debug then dbstatus(38,'Debug 010 - 21may2021_528am');//yyyy


//d2laz__makeproject(false);//make a lazarus project from this Delphi 3 app

//bible__cleanfiles('c:\123bibles__2025\','*.txt',true,true);


//check source code for know problems ------------------------------------------
//io__sourecode_checkall(['']);


//self
inherited create(strint32(app__info('width')),strint32(app__info('height')),true);
ibuildingcontrol:=true;
iloaded:=false;

//init
for p:=0 to high(sysshared_historylist) do sysshared_historylist[p]:='';

ipanelcount:=high(isearch)+1;

//controls
with rootwin do
begin
scroll:=false;
xhead;
xgrad;

xhead.add('1 Panel',5002,0,'panel.1','Toggle two panel view');
xhead.add('2 Panels',5002,0,'panel.2','Toggle two panel view');
xhead.add('3 Panels',5002,0,'panel.3','Toggle two panel view');

xhead.xaddoptions;
xhead.xaddhelp;
end;

rootwin.xcols.style:=bcLefttoright;
for p:=0 to high(isearch) do
begin

rootwin.xcols.remcount[p]:=100;
with rootwin.xcols.cols2[p,1,false] do
begin
isearch[p]:=tbiblesearch.create(client,p+1);
end;

end;//p



//events
rootwin.xhead.onclick:=__onclick;


//defaults


//start timer event
ibuildingcontrol:=false;
xloadsettings;

//finish
createfinish;
end;

destructor tapp.destroy;
begin
try
//settings
xsavesettings;
//controls

//self
inherited destroy;
except;end;
end;

procedure tapp.xupdatebuttons;
begin
try
rootwin.xhead.bmarked2['panel.1']:=(ipanelcount=1);
rootwin.xhead.bmarked2['panel.2']:=(ipanelcount=2);
rootwin.xhead.bmarked2['panel.3']:=(ipanelcount=3);

//.show columns
rootwin.xcols.vis[1]:=(ipanelcount>=2);
rootwin.xcols.vis[2]:=(ipanelcount>=3);

except;end;
end;

procedure tapp.xloadsettings;
var
   a:tvars8;
   e:string;
   p:longint;
begin
try
//defaults
a:=nil;
//check
if zznil(prgsettings,5001) then exit;
//init
a:=vnew2(950);
//filter
a.i['panelcount']:=prgsettings.idef2('panelcount',2,1,high(isearch)+1);
for p:=0 to high(isearch) do isearch[p].settings:=prgsettings.s['search.'+intstr32(p)];

//get
ipanelcount:=a.i['panelcount'];
for p:=0 to high(isearch) do a.s['search.'+intstr32(p)]:=isearch[p].settings;

//sync
prgsettings.data:=a.data;
xupdatebuttons;
except;end;
try
freeobj(@a);
iloaded:=true;
except;end;
end;

procedure tapp.xsavesettings;
var
   a:tvars8;
   e:string;
   p:longint;
begin
try
//check
if not iloaded then exit;
//defaults
a:=nil;
a:=vnew2(951);

//get
a.i['panelcount']:=ipanelcount;
for p:=0 to high(isearch) do a.s['search.'+intstr32(p)]:=isearch[p].settings;

//set
prgsettings.data:=a.data;
siSaveprgsettings;
except;end;
try;freeobj(@a);except;end;
end;

procedure tapp.xautosavesettings;
var
   p:longint;
   str1:string;
begin
try
//check
if not iloaded then exit;
//get
str1:='';
for p:=0 to high(isearch) do str1:=str1+isearch[p].settings+#7;

//set
if low__setstr(isettingsref,intstr32(ipanelcount)+'|'+str1) then xsavesettings;
except;end;
end;

procedure tapp.__onclick(sender:tobject);
begin
xcmd(sender,0,'');
end;

procedure tapp.xcmd0(xcode2:string);
begin
xcmd(nil,0,xcode2);
end;

procedure tapp.xcmd(sender:tobject;xcode:longint;xcode2:string);
label
   skipend;
var
   xresult:boolean;
   e:string;
begin//use for testing purposes only - 15mar2020
//defaults
xresult:=true;
e:=gecTaskfailed;

try
//init
if zzok(sender,7455) and (sender is tbasictoolbar) then
   begin
   //ours next
   xcode:=(sender as tbasictoolbar).ocode;
   xcode2:=strlow((sender as tbasictoolbar).ocode2);
   end;

//get
if      (xcode2='panel.1') then ipanelcount:=1
else if (xcode2='panel.2') then ipanelcount:=2
else if (xcode2='panel.3') then ipanelcount:=3
//else if (xcode2='test') then gui.poptxt(e,1,'','')
else
   begin
   if system_debug then showbasic('Unknown Command>'+xcode2+'<<');
   end;

skipend:
except;end;
try
xupdatebuttons;
if not xresult then gui.poperror('',e);
except;end;
end;

procedure tapp.__ontimer(sender:tobject);//._ontimer
label
   skipend;
var
   bol1:boolean;
begin
try
//timer100
if (ms64>=itimer100) and iloaded then
   begin

   //reset
   itimer100:=ms64+100;
   end;

//timer350
if (ms64>=itimer350) then
   begin
   //page
   xupdatebuttons;
   //reset
   itimer350:=ms64+350;
   end;

//timer500
if (ms64>=itimer500) then
   begin
   //savesettings
   xautosavesettings;
   //reset
   itimer500:=ms64+500;
   end;

//debug support
if system_debug then
   begin
   if system_debugFAST then rootwin.paintallnow;
   end;
if system_debug and system_debugRESIZE then
   begin
   if (system_debugwidth<=0) then system_debugwidth:=gui.width;
   if (system_debugheight<=0) then system_debugheight:=gui.height;
   //change the width and height to stress
   //was: if (random(10)=0) then gui.setbounds(gui.left,gui.top,system_debugwidth+random(32)-16,system_debugheight+random(128)-64);
   gui.setbounds(gui.left,gui.top,system_debugwidth+random(32)-16,system_debugheight+random(128)-64);
   end;

skipend:
except;end;
end;


//## tbookcore #################################################################
//xxxxxxxxxxxxxxxxxxxxxx//5555555555555555555555
constructor tbookcore.create;
begin
if classnameis('tbookcore') then track__inc(satOther,1);
inherited create;

//vars
ifileindex     :=-1;//not set
ifilesize      :=0;
ifiledata      :=nil;//pointer to filedata
ilastfindslot  :=0;
icount         :=0;

//shared style stream
if (sysshared_stylemask=nil) then sysshared_stylemask:=str__new8;
inc(sysshared_stylemaskcount);

//shared storage
if (sysshared_storage=nil) then
   begin
   sysshared_storage:=tstorage.create;
   sysshared_storage.odatafilter_txt_matchwordcore:=true;
   sysshared_storage.fill(storage__findfile);
   sysshared_storagecount:=1;
   end
else inc(sysshared_storagecount);
end;

destructor tbookcore.destroy;
var
   p:longint;
begin
try
//shared storage
sysshared_storagecount:=frcmin32(sysshared_storagecount-1,0);
if (sysshared_storagecount<=0) and (sysshared_storage<>nil) then freeobj(@sysshared_storage);

//shared style mask
sysshared_stylemaskcount:=frcmin32(sysshared_stylemaskcount-1,0);
if (sysshared_stylemaskcount<=0) and (sysshared_stylemask<>nil) then str__free(@sysshared_stylemask);

//self
inherited destroy;
if classnameis('tbookcore') then track__inc(satOther,-1);
except;end;
end;

function tbookcore.getfcount:longint;
begin
result:=sysshared_storage.count;
end;

function tbookcore.getfpathname(x:longint):string;
begin
result:=sysshared_storage.pathname[x];
end;

function tbookcore.getfpath(x:longint):string;
begin
result:=sysshared_storage.path[x];
end;

function tbookcore.getfname(x:longint):string;
begin
result:=sysshared_storage.name[x];
end;

function tbookcore.getfbarename(x:longint):string;
begin
result:=sysshared_storage.barename[x];
end;

function tbookcore.getfsize(x:longint):longint;
begin
result:=sysshared_storage.size[x];
end;

function tbookcore.getstylemask:tstr8;
begin
result:=sysshared_stylemask;
end;

procedure tbookcore.xloadfile;//load book from file
var
   vc,dpos,dstart,dlen:longint;
   procedure vadd(xcap:string;xfrom,xscope:longint);
   begin
   //filter
   xcap:=stripwhitespace_lt(xcap);

   //get
   if (xcap<>'') and (icount<=high(ititle)) then
      begin
      ititle[icount]       :=xcap;
      ifrom [icount]       :=xfrom;
      iscope[icount]       :=frcrange32(xscope,0,2);//0=book, 1=testament, 2=entire text
      inc(icount);
      end;
   end;

   function v:string;
   begin
   result:=ifiledata.str1[dstart,dlen];
   end;
begin
try
//init
icount :=0;
dpos   :=1;
icode  :='';

//get file data from shared storage
sysshared_storage.findbyslot(ifileindex,ifiledata);
ifilesize:=str__len(@ifiledata);
sysshared_stylemask.minlen(ifilesize);


//read file and extract book names and start positions
while nextsection1(dpos,dstart,dlen) do
begin
if (dlen>=1) then
   begin
   vc:=ifiledata.bytes1[dstart];

   case vc of
   lbCode      :icode:=strup(strcopy1(v,2,dlen));//21mar2025
   lbTitle     :vadd(strcopy1(v,2,dlen),dstart,2);//scope=2=entire bible
   lbTestament :vadd(strcopy1(v,2,dlen),dstart,1);//scope=1=entire testament
   lbBook      :vadd(strcopy1(v,2,dlen),dstart,0);//scope=0=current book
   end;//case

   end;
end;//while

except;end;
end;

function tbookcore.getscope(x:longint):longint;
begin
if (x>=0) and (x<icount) then result:=iscope[x] else result:=0;
end;

function tbookcore.getfrom(x:longint):longint;
begin
if (x>=0) and (x<icount) then result:=ifrom[x] else result:=0;
end;

function tbookcore.gettitle(x:longint):string;
begin
if (x>=0) and (x<icount) then result:=ititle[x] else result:='';
end;

procedure tbookcore.setfileindex(x:longint);
begin
x:=frcrange32(x,-1,sysshared_storage.count-1);//-1=no file selected
if low__setint(ifileindex,x) then xloadfile;
end;

function tbookcore.findbyname(const xtitle:string;var xslot:longint):boolean;
var
   xfrom,xscope:longint;
begin
result:=xfindbyname2(xtitle,xslot,xfrom,xscope);
end;

function tbookcore.xfindbyname2(const xtitle:string;var xslot,xfrom,xscope:longint):boolean;
var
   p:longint;
begin
//defaults
result:=false;
xslot   :=0;
xfrom   :=0;
xscope  :=0;

//find
if (icount>=1) and (xtitle<>'') then
   begin
   for p:=0 to (icount-1) do if strmatch(xtitle,ititle[p]) then
      begin
      xslot   :=p;
      xfrom   :=ifrom[p];
      xscope  :=iscope[p];
      result  :=true;
      break;
      end;
   end;
end;

procedure tbookcore.findbookslotRESET;
begin
ilastfindslot:=0;
end;

function tbookcore.findbookslot(xfrom:longint;var xslot:longint):boolean;
var
   p:longint;
begin
//defaults
result:=false;
xslot:=0;

//find
if (icount>=1) then
   begin

   for p:=ilastfindslot to (icount-1) do
   begin
   if (xfrom>=ifrom[p]) then
      begin
      if  (iscope[p]=0) then//slot is a book
          begin
          xslot:=p;
          result:=true;
          end;
      end
   else break;
   end;//p

   //sync
   if result then ilastfindslot:=xslot;
   end;

end;

function tbookcore.findbyslot(xslot:longint;var xtitle:string;var xfrom,xto,xscope:longint):boolean;
   function xfindto:longint;
   var
      p:longint;
   begin
   if      (xscope=scFull)                then result:=max32//entire text
   else if (xscope=scTestament)           then//testament
      begin
      result:=max32;

      for p:=(xslot+1) to (icount-1) do if (iscope[p]=scTestament) or (iscope[p]=scFull) then
         begin
         result:=ifrom[p]-1;
         break;
         end;

      end
   else if (xslot<(icount-1)) then result:=ifrom[xslot+1]-1//to end of current book
   else                            result:=max32;

   end;
begin
if (icount>=1) and (xslot>=0) and (xslot<icount) then
   begin
   result:=true;
   xtitle  :=ititle[xslot];
   xscope  :=iscope[xslot];
   xfrom   :=ifrom[xslot];
   xto     :=xfindto;
   end
else
   begin
   result:=false;
   xtitle  :='';
   xscope  :=0;
   xfrom   :=1;
   xto     :=1;
   end;
end;

function tbookcore.nextsection1(var dpos,dstart,dlen:longint):boolean;
label
   redo;
begin
//defaults
result:=false;

//check
if (ifilesize<=0) then exit;

//range
if (dpos<1) then dpos:=1;

//find eol
dstart:=dpos;
redo:
if (ifiledata.bytes1[dpos]=ss10) then
   begin
   result:=true;
   dlen:=dpos-dstart;
   inc(dpos);//step past eol (end of line)
   end
else if (dpos<ifilesize) then
   begin
   inc(dpos);
   goto redo;
   end;
end;

//## tbiblesearch ###############################################################
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//222222222222222222222222222222
constructor tbiblesearch.create(xparent:tobject;xid:longint);
begin
create2(xparent,true,xid);
end;

constructor tbiblesearch.create2(xparent:tobject;xstart:boolean;xid:longint);
var
   p:longint;
   str1:string;

   function xsearch:string;
   begin
   result:='Search | Type one or more words to search. If "Search as you type" is off, press Enter or click the Search button to search. To clear the current query, press the Delete key or click the Clear button.';
   end;
begin
//self
if classnameis('ttextsearch') then track__inc(satOther,1);
inherited create2(xparent,false,false);

//init
icore:=tbookcore.create;
icore.fileindex:=-1;

//vars
iid:=xid;
itimer100:=0;
ialign:=0;//left
oautoheight:=true;
bordersize:=0;
icompact:=false;
iexact:=true;
iall:=true;
ititle:='';
ititleslot:=0;
iloaded:=false;
imustfind:=false;
imustfind_retainvpos:=false;
imustfindnohistory:=false;

with client do
begin
ititlebar:=ntoolbar('');
with ititlebar do
begin
normal:=false;
caption:=str1;
otitle:=true;
add('',tepDown,0,'index','Text | Select a different text from the list to read and search');
end;

itext:=nbwp('',nil);
with itext do
begin
oautoheight:=true;
bordersize:=1;
makereadonly;//disable editing AND disables undo system
wrap:=1;//to window
wrapreadonly:=true;
makexxx(1,2,false);
iosettxt(str__new8b('Loading...'));
end;

end;


with xhigh2 do
begin
itoolbar:=ntoolbar('Type one or more words to search text');
with itoolbar do
begin
maketitle3('',false,false);
normal:=false;

add('History',tepDown,0,'history','Shared Search History | Search again using a previously used search query. Retains upto 100 search queries from all three search panels.');
add('Search',tepNone,0,'find',xsearch);
add('Clear',tepNone,0,'clear','Option | Clear search query box');

addsep;
add('All Words',tepNone,0,'all','Search Style | Match all words against the text');
add('Whole Words',tepNone,0,'exact','Search Style | Match whole words against the text');
add('Settings',tepDown,0,'settings','Settings | Show the settings menu');
end;

iedit:=nedit('Type one or more words to search',xsearch);
with iedit do
begin
odel_clearstext:=true;
scale:=1.4;
tep:=5000;
tep2:=5001;//tep_search32
orightbut_narrowfocus:=true;
end;

with nbreak(20) do
begin
normal:=false;
opaint:=true;
end;

end;


//defaults
ocanshowmenu:=true;

//.load history
if (iid<=1) then
   begin
   hisclear;
   hisload;
   end;

//events
showmenuFill1:=xshowmenuFill;
showmenuClick1:=__onmenuclick;
ititlebar.onclick:=__onclick;
itoolbar.onclick:=__onclick;
iedit.onreturn:=__onclick;
iedit.onclick2:=__onclick;

//start
if xstart then start;
end;

destructor tbiblesearch.destroy;
begin
try
//vars
freeobj(@icore);

//self
inherited destroy;
if classnameis('ttextsearch') then track__inc(satOther,-1);
except;end;
end;

function tbiblesearch.getfileindex:longint;
begin
result:=icore.fileindex;
end;

procedure tbiblesearch.setfileindex(x:longint);
begin
setparams(x,ititle,true);
end;

procedure tbiblesearch.settitle(x:string);
begin
settitle2(x,true);
end;

procedure tbiblesearch.settitle2(x:string;xallowfind:boolean);
begin
setparams(fileindex,x,xallowfind);
end;

procedure tbiblesearch.setparams(xfileindex:longint;xtitle:string;xallowfind:boolean);
begin
//range
xfileindex:=frcrange32(xfileindex,0,frcmin32(icore.fcount-1,0));
xtitle    :=strlow(xtitle);

//get
if (icore.fileindex<>xfileindex) or (not strmatch(ititle,xtitle)) then
   begin
   //load file -> load book
   icore.fileindex:=xfileindex;
   //load section (title) within book
   ititle         :=xtitle;
   icore.findbyname(xtitle,ititleslot);
   //search
   if xallowfind then imustfind:=true;
   end;
end;


function tbiblesearch.gettitle:string;
var
   xbarename,xbooksection:string;
   xatroot:boolean;
begin
if (ititleslot>=0) and (ititleslot<icore.count) then xbooksection:=icore.title[ititleslot] else xbooksection:='';
xbarename :=icore.fbarename[icore.fileindex];
xatroot   :=(ititleslot=0);
result    :=xbarename+insstr(' > '+xbooksection ,not xatroot);
end;

function tbiblesearch.histext:string;
var
   a:tstr8;
   p:longint;
begin
try
//init
a:=nil;
a:=str__new8;

//get
for p:=0 to high(sysshared_historylist) do if (sysshared_historylist[p]<>'') then a.sadd(sysshared_historylist[p]+#10);

//set
result:=a.text;
except;end;
//free
str__free(@a);
end;

procedure tbiblesearch.hissettext(x:string);
label
   redo;
var
   a,aline:tstr8;
   b:tdynamicstring;
   p,xpos:longint;
   e:string;
begin
try
//init
a      :=nil;
aline  :=nil;
b      :=nil;
a      :=str__new8;
aline  :=str__new8;
b      :=tdynamicstring.create;

//clear
hisclear;

//get
str__settext(@a,x);

//set
xpos:=0;
redo:
if low__nextline0(a,aline,xpos) then
   begin
   b.value[b.count]:=aline.text;
   goto redo;
   end;

//add to history
for p:=(b.count-1) downto 0 do hisadd(b.value[p]);
except;end;
//free
str__free(@a);
str__free(@aline);
freeobj(@b);
end;

procedure tbiblesearch.hissave;
var
   a:tstr8;
   p:longint;
   e:string;
begin
try
//init
a:=nil;
a:=str__new8;

//get
a.text:=histext;

//set
io__tofile(app__settingsfile('history.txt'),@a,e);
except;end;
//free
str__free(@a);
end;

procedure tbiblesearch.hisload;
label
   redo;
var
   a:tstr8;
   e:string;
begin
try
//init
a      :=nil;
a      :=str__new8;

//clear
hisclear;

//get
io__fromfile(app__settingsfile('history.txt'),@a,e);
hissettext(a.text);
except;end;
//free
str__free(@a);
end;

procedure tbiblesearch.hisclear;
var
   p:longint;
begin
for p:=0 to high(sysshared_historylist) do sysshared_historylist[p]:='';
end;

procedure tbiblesearch.hisadd(xline:string);
var
   p2,p:longint;
   bol1:boolean;
begin
//check
if (xline='') or strmatch(xline,sysshared_historylist[0]) then exit;

//init
bol1:=false;

//find and delete
for p:=0 to high(sysshared_historylist) do if strmatch(xline,sysshared_historylist[p]) then
   begin
   //move all down one slot
   for p2:=p downto 1 do sysshared_historylist[p2]:=sysshared_historylist[p2-1];
   bol1:=true;
   break;
   end;

//move all down one slot
if not bol1 then for p:=high(sysshared_historylist) downto 1 do sysshared_historylist[p]:=sysshared_historylist[p-1];

//add
sysshared_historylist[0]:=xline;
end;

procedure tbiblesearch.xfind(xaddtohistory,xretainvpos:boolean);
label//Search Optimisation:
     // typical 2 keyword search on an Intel Core i5-6500T CPU @ 2.50GHz is 64ms
     // reduced down to 24ms = 260% faster (2.6x faster)
     // reduced further down to 14ms = 457% faster (4.5x faster)
     // with an effective search speed of ~7.1 million words/second
   skipsearch,redo,wskip;
var
   b1,b2:tstr8;
   xhighlightstyle:byte;
   xsepcount,xmaxwidth,v1,xlastbookslot,xbookslot,xresultlimit,xfrom,xto,xscope,xsectionsmatched,xwordsmatched,xsectioncount,int1,wcountlevel,strlen1,dpos,dstart,dlen,w,v,lp,wcount,p2,p:longint;
   wlist:array[0..19] of string;
   wu   :array[0..19] of byte;
   wl   :array[0..19] of byte;
   wlen:array[0..19] of longint;
   wmatched:array[0..19] of boolean;
   xheadcode,xlasthead1,xlasthead2,xtitle,vsep1,vsep2,stext,str1:string;
   xcompact,vheadonce,xall,xhavequery,bol1,bol2,xhead,xmatchallwords,xexactmatch:boolean;
   xbookinresults:array[0..(bookcore_titlecount-1)] of longint;

   procedure vhead(xmatched:boolean);
   var
      xslot,p:longint;
   begin
   //find
   if not icore.findbookslot(dstart,xslot) then xslot:=-1;

   //mark each book that appears in the search results
   if xmatched and xhavequery and (xslot>=0) and (icore.scope[xslot]=scBook) then inc(xbookinresults[xslot]);

   //get
   if low__setint(xbookslot,xslot) and xhead then
      begin
      if (xslot>=0) then
         begin
         if xhavequery then  xlasthead1:=icore.title[xbookslot]+xheadcode
         else                xlasthead1:=insstr(#10,not vheadonce)+icore.title[xbookslot]+#10;
         end
      else xlasthead1:='';


      xlasthead2:=xlasthead1;
      for p:=1 to low__len(xlasthead2) do xlasthead2[p-1+stroffset]:='b';

      vheadonce:=false;
      end;
   end;

   function vsep(xmask:boolean):string;
   var
      p:longint;
   begin
   result:=#10+#10;
   if xmask then for p:=1 to low__len(result) do result[p-1+stroffset]:=#0;
   end;

   function vinfo(xmask:boolean):string;
   var
      xstart,xlen,bcount,p:longint;
      xonce:boolean;

      function vlen(xresult,x:string):string;
      begin
      result:=x;
      xstart:=low__len(xresult)+1;
      xlen  :=low__len(x);
      end;

      function xpad(x:longint):string;
      const
         xpadding=#32#32#32#32#32#32#32#32;//8c
      var
         xlen:longint;
      begin
      result:=k64(x);
      xlen:=low__len(result);
      if (xlen<xmaxwidth) then result:=strcopy1(xpadding,1,frcmin32(xmaxwidth-xlen,0))+result;
      end;
   begin
   result:='';

   if not xhavequery then exit;

   //find widest result count
   xmaxwidth:=0;
   for p:=0 to high(xbookinresults) do if (xbookinresults[p]>=1) then
      begin
      int1:=low__len(k64(xbookinresults[p]));
      if (int1>xmaxwidth) then xmaxwidth:=int1;
      end;

   //create result summary
   xonce:=true;
   bcount:=0;
   for p:=0 to high(xbookinresults) do if (xbookinresults[p]>=1) then inc(bcount);

   for p:=0 to high(xbookinresults) do if (xbookinresults[p]>=1) then
      begin
      if xonce then result:=result+vlen(result,k64(xsectionsmatched)+' passage'+insstr('s',xsectionsmatched<>1)+' match'+insstr('es',xsectionsmatched=1)+' your query in '+low__aorbstr('this text','these texts',bcount>=2))+':'+#10;
      xonce:=false;
      result:=result+xpad(xbookinresults[p])+' in '+icore.title[p]+#10;
      end;
   if not xonce then result:=result+#10;

   if (xsectionsmatched<=0) then result:=result+vlen(result,'No passages match your query');

   if xmask then for p:=1 to low__len(result) do if (p>=xstart) and (p<(xstart+xlen)) then result[p-1+stroffset]:='b' else result[p-1+stroffset]:=#0;
   end;

   function whave(x:string):boolean;
   var
      p:longint;
   begin
   result:=false;

   for p:=0 to (wcount-1) do if strmatch(x,wlist[p]) then
      begin
      result:=true;
      break;
      end;//p
   end;

   procedure wadd(x:string);
   var
      v:string;
   begin
   if (x<>'') and (not whave(x)) and (wcount<=high(wlist)) then
      begin
      wlist[wcount]:=strlow(x);
      wlen [wcount]:=low__len(wlist[wcount]);
      wl   [wcount]:=byte(strlow(x[1])[1]);
      wu   [wcount]:=byte(strup(x[1])[1]);
      inc(wcount);
      end;
   end;

   function xsep(x:byte):boolean;
   begin//or (x=ssColon)
   result:=(x=ssSemicolon) or (x=ssDash) or (x=ssDot) or (x=ssComma) or (x=ssExclaim) or (x=ssQuestion) or (x=ssSpace) or (x=ss10) or ((x=ssColon) and (xsepcount>=7));
   if (x=ss10) then xsepcount:=0 else inc(xsepcount);
   end;

   function xprematch:boolean;
   var
      w:longint;
   begin
   result:=false;

   for w:=0 to (wcount-1) do if (v1=wl[w]) or (v1=wu[w]) then
      begin
      result:=true;
      break;
      end;
   end;
begin
try
//init
b1:=nil;
b2:=nil;
b1:=str__new8;
b2:=str__new8;
ilastfind       :=stripwhitespace_lt(iedit.value);
stext           :=ilastfind+',';
xhavequery      :=low__len(stext)>=2;
xall            :=(not xhavequery);
wcount          :=0;
lp              :=1;
xwordsmatched   :=0;
xsectionsmatched:=0;
xsectioncount   :=0;

case ihighlight of
1:xhighlightstyle:=llh;
2:xhighlightstyle:=llu;
3:xhighlightstyle:=llb;
else xhighlightstyle:=0;
end;

xmatchallwords  :=iall;
xexactmatch     :=iexact;
vsep1           :=vsep(false);
vsep2           :=vsep(true);
xlasthead1      :='';
xlasthead2      :='';
xbookslot       :=-1;
xlastbookslot   :=-1;
vheadonce       :=true;
xhead           :=true;
xcompact        :=icompact and (icore.scope[titleslot]<>scBook);
xheadcode       :=low__aorbstr(#10,#32,xcompact);

xresultlimit:=0;//insint(5000,not xall);

for p:=0 to high(xbookinresults) do xbookinresults[p]:=0;

//title scope
if not icore.findbyslot(ititleslot,xtitle,xfrom,xto,xscope) then goto skipsearch;

//words
xsepcount:=0;

for p:=1 to low__len(stext) do
begin
v:=strbyte1(stext,p);
if xsep(v) then
   begin
   str1:=strcopy1(stext,lp,p-lp);
   lp:=p+1;
   wadd(str1);
   end;
end;//p

//check
if (wcount<=0) and (not xall) then goto skipsearch;

//clear
icore.stylemask.fill(0,icore.filesize-1,0);

//search text -> as one large block and mark "match selection" on idata2 as a series of 1's
icore.findbookslotRESET;
dpos:=xfrom;

xsepcount:=0;
redo:
if icore.nextsection1(dpos,dstart,dlen) then
   begin
   //stop
   if (dstart>xto) then goto skipsearch;

   //exclude special marker entries
   v1:=icore.filedata.bytes1[dstart];
   if (v1=lbCode) or (v1=lbTitle) or (v1=lbTestament) or (v1=lbBook) then goto redo;

   //init
   for w:=0 to (wcount-1) do wmatched[w]:=false;
   lp   :=dstart;
   int1 :=0;
   inc(xsectioncount);

   //get ............overallow by 1 char for "vsep" to trigger at end of section on a dash/return code
   for p:=dstart to (dstart+dlen) do if (p>=1) and (p<=icore.filesize) then
      begin
      v:=icore.filedata.bytes1[p];

      if xsep(v) then
         begin
         v1:=icore.filedata.bytes1[lp];

         //fast precheck -> check if at least ONE keyword "might" match current text keyword
         if xprematch then
            begin
            str1    :=icore.filedata.str1[lp,p-lp];
            strlen1 :=low__len(str1);

                                         //fast check                   //slow but thorough check
            for w:=0 to (wcount-1) do if ((not xexactmatch) or (wlen[w]=strlen1)) and ((v1=wl[w]) or (v1=wu[w])) and strmatch(wlist[w],strcopy1(str1,1, low__aorb(wlen[w],strlen1,xexactmatch) )) then
               begin
               inc(xwordsmatched);
               if not wmatched[w] then
                  begin
                  wmatched[w]:=true;
                  inc(int1);
                  end;

               //.mark highlight for matched word/words
               if (xhighlightstyle<>0) then for p2:=lp to (lp+low__aorb(wlen[w],strlen1,xexactmatch)-1) do icore.stylemask.bytes1[p2]:=xhighlightstyle;
               end;

            end;


         //.lp
         lp:=p+1;
         end;//xsep

      end;//p

   //add result
   bol1:=(int1>=low__aorb(1,wcount,xmatchallwords));
   if bol1 or xall then
      begin
      if bol1 then inc(xsectionsmatched);
      vhead(bol1);

      bol1:=((xscope>=1) and xhavequery) or low__setint(xlastbookslot,xbookslot);

      //.text
                                  b1.sadd( insstr(xlasthead1,bol1) +icore.filedata.str1[dstart,dlen] +vsep1 );

      //.style - e.g. keyword highlight
      if (xhighlightstyle<>0) or xhead then b2.sadd( insstr(xlasthead2,bol1) +icore.stylemask.str1[dstart,dlen] +vsep2 );

      //enforce result limit
      if (xresultlimit>=1) and (xsectionsmatched>=xresultlimit) then goto skipsearch;
      end;

   //loop
   goto redo;
   end;

skipsearch:
b1.sins(vinfo(false),0);

if xretainvpos then itext.ioset2(b1,low__wordcore_str2(itext.core^,'vpos.px',''),itext.vpos) else itext.iosettxt(b1);

if (xhighlightstyle<>0) or xhead then
   begin
   b2.sins(vinfo(true),0);
   itext.applystylebymask(b2);
   end;

//.history
if xaddtohistory then
   begin
   hisadd(ilastfind);
   hissave;
   end;
except;end;
//free
str__free(@b1);
str__free(@b2);
end;

procedure tbiblesearch.__onclick(sender:tobject);
begin
xcmd(sender,0,'');
end;

function tbiblesearch.__onmenuclick(sender:tbasiccontrol;xstyle:string;xcode:longint;xcode2:string;xtepcolor:longint):boolean;
begin
result:=true;
xcmd(sender,xcode,xcode2);
end;

procedure tbiblesearch.xcmd(sender:tobject;xcode:longint;xcode2:string);
label
   skipend;
var
   xresult:boolean;
   str1,e:string;
begin//use for testing purposes only - 15mar2020
//defaults
xresult:=true;
e:=gecTaskfailed;

try
//init
if zzok(sender,7455) then
   begin
   if (sender is tbasictoolbar) then
      begin
      //ours next
      xcode:=(sender as tbasictoolbar).ocode;
      xcode2:=strlow((sender as tbasictoolbar).ocode2);
      end
   else if (sender is tbasicedit) then xcode2:='find';
   end;

//get
if      (xcode2='find') then imustfind:=true
else if (xcode2='clear') then
   begin
   iedit.value:='';
   imustfind:=true;
   end
else if (xcode2='align.0') then ialign:=0
else if (xcode2='align.1') then ialign:=1
else if (xcode2='align.2') then ialign:=2
else if (strcopy1(xcode2,1,6)='index.') then title:=icore.title[strint32(strcopy1(xcode2,7,low__len(xcode2)))]
else if (strcopy1(xcode2,1,5)='file.') then fileindex:=strint32(strcopy1(xcode2,6,low__len(xcode2)))
else if (xcode2='compact') then
   begin
   icompact:=not icompact;
   imustfind_retainvpos:=true;
   end
else if (xcode2='exact') then
   begin
   iexact:=not iexact;
   imustfind:=true;
   end
else if (xcode2='all') then
   begin
   iall:=not iall;
   imustfind:=true;
   end
else if (xcode2='auto') then
   begin
   iauto:=not iauto;
   end
else if (strcopy1(xcode2,1,10)='highlight.') then
   begin
   ihighlight:=frcrange32(strint32(strcopy1(xcode2,11,low__len(xcode2))),0,3);
   imustfind_retainvpos:=true;
   end
else if (xcode2='hisclear') then
   begin
   if gui.popquery('Are you sure you wish to clear search history?') and gui.popquery('Confirm: Clear search history?') then
      begin
      hisclear;
      hissave;
      end;
   end
else if (xcode2='hisedit') then
   begin
   str1:=histext;
   if gui.poptxt2(str1,0,false,'','') then
      begin
      hissettext(str1);
      hissave;
      end;
   end
else if (xcode2='history') or (xcode2='settings') or (xcode2='index') then showmenu2(xcode2)
else if strmatch(strcopy1(xcode2,1,14),'searchhistory:') then
   begin
   iedit.value:=strcopy1(xcode2,15,low__len(xcode2));
   imustfind:=true;
   end
else
   begin
   if system_debug then showbasic('Unknown Command>'+xcode2+'<<');
   end;
skipend:
except;end;
try
xupdatebuttons;
if not xresult then gui.poperror('',e);
except;end;
end;

procedure tbiblesearch.xshowmenuFill(sender:tobject;xstyle:string;xmenudata:tstr8;var ximagealign:longint;var xmenuname:string);
var
   xtep,xindent,p:longint;
   bol1:boolean;
begin
try
//check
if zznil(xmenudata,2326) then exit;
xmenuname:='nostradamus.'+xstyle+'.'+intstr32(iid);

//init
if (xstyle='history') then
   begin
   low__menutitle(xmenudata,tepNone,'Shared Search History','');
   low__menuitem2(xmenudata,tepEdit20,'Edit history','Edit search history','hisedit',100,aknone,true);
   low__menuitem2(xmenudata,tepClose20,'Clear history...','Clear search history...','hisclear',100,aknone,true);
   low__menusep(xmenudata);

   for p:=0 to high(sysshared_historylist) do if (sysshared_historylist[p]<>'') then low__menuitem2(xmenudata,tepFNew20,sysshared_historylist[p],'Search using this query','searchhistory:'+sysshared_historylist[p],100,aknone,true);
   end
else if (xstyle='settings') then
   begin
   low__menutitle(xmenudata,tepNone,'Search','');
   low__menuitem2(xmenudata,tep__yes(iall),'Match all words','Search Method | Match all words against the text','all',100,aknone,true);
   low__menuitem2(xmenudata,tep__yes(iexact),'Match whole words','Search Method | Match whole words against the text','exact',100,aknone,true);
   low__menuitem2(xmenudata,tep__yes(iauto),'Search as you type','Search Mode | Automatically search as you type | A search is performed after a short 0.5s idle time','auto',100,aknone,true);

   low__menutitle(xmenudata,tepNone,'Matches','');
   low__menuitem2(xmenudata,tep__tick(ihighlight=1),'Highlight','Search Results | Highlight matching words','highlight.1',100,aknone,true);
   low__menuitem2(xmenudata,tep__tick(ihighlight=2),'Underline','Search Results | Underline matching words','highlight.2',100,aknone,true);
   low__menuitem2(xmenudata,tep__tick(ihighlight=3),'Bold','Search Results | Show matching words in bold','highlight.3',100,aknone,true);
   low__menuitem2(xmenudata,tep__tick(ihighlight=0),'Off','Search Results | Do not highlight matching words','highlight.0',100,aknone,true);
   if (icore.scope[titleslot]<>scBook) then low__menuitem2(xmenudata,tep__yes(icompact),'Compact','Search Results | Show title and passage on the same line','compact',100,aknone,true);

   low__menutitle(xmenudata,tepNone,'Toolbar Alignment','');
   low__menuitem2(xmenudata,tep__tick(ialign=0),'Left','Toolbar Alignment | Left align toolbar links','align.0',100,aknone,true);
   low__menuitem2(xmenudata,tep__tick(ialign=1),'Center','Toolbar Alignment | Center toolbar links','align.1',100,aknone,true);
   low__menuitem2(xmenudata,tep__tick(ialign=2),'Right','Toolbar Alignment | Right align toolbar links','align.2',100,aknone,true);

   end
else if (xstyle='index') then
   begin
   bol1:=(icore.fcount>=2);
   //.available books (files)
   if bol1 then low__menutitle(xmenudata,tepnone,'Available Texts','');
   for p:=0 to (icore.fcount-1) do
   begin
   low__menuitem4(xmenudata,tep__tick(p=icore.fileindex),icore.fbarename[p],'Select to view text','file.'+intstr32(p),100,aknone,0,false,true);
   end;

   //.loaded book's sections:
   if bol1 then low__menutitle(xmenudata,tepnone,'Contents','');
   for p:=0 to (icore.count-1) do
   begin

   case icore.scope[p] of
   scBook:begin
      xindent:=35*vizoom;
      xtep:=tepBulletSquare20;//tepFnew20;
      end;
   scTestament:begin
      xindent:=10*vizoom;
      xtep:=tepNone;
      end;
   else//title
      begin
      xindent:=0;
      xtep:=tepFnew20;
      end;
   end;

   //.tep override
   if (p=titleslot) then xtep:=tepTick20;

   if (icore.scope[p]=scTestament) then low__menusep(xmenudata);
   low__menuitem4(xmenudata,xtep,icore.title[p],'Select to view text','index.'+intstr32(p),100,aknone,xindent, (p=titleslot) ,true);
   if (icore.scope[p]=scTestament) then low__menusep(xmenudata);
   end;//p
   end;
except;end;
end;

procedure tbiblesearch.xupdatebuttons;
begin
ititlebar.bcap2['index']:=title;
itoolbar.bmarked2['exact']:=iexact;
itoolbar.bmarked2['all']:=iall;
itoolbar.bmarked2['auto']:=iauto;
itoolbar.halign:=ialign;//14mar2025
end;

procedure tbiblesearch._ontimer(sender:tobject);
var
   xretainvpos,xhis:boolean;
begin

if (ms64>=itimer100) then
   begin
   //check
   if vistartupdone and iloaded and gui.paintfirst then
      begin

      //find
      if imustfind or imustfind_retainvpos or imustfindnohistory then
         begin
         xretainvpos          :=imustfind_retainvpos;
         xhis                 :=not imustfindnohistory;
         imustfind            :=false;
         imustfindnohistory   :=false;
         imustfind_retainvpos :=false;
         xfind(xhis,xretainvpos);
         end;

      //search as you type
      if iauto and (low__keyidle>=500) and (ilastfind<>stripwhitespace_lt(iedit.value)) then imustfind:=true;
      end;

   //reset
   itimer100:=ms64+100;
   end;

end;

function tbiblesearch.getsettings:string;
begin
result:=
'compact:'+bolstr(icompact)+';'+
'exact:'+bolstr(iexact)+';'+
'all:'+bolstr(iall)+';'+
'auto:'+bolstr(iauto)+';'+
'highlight:'+intstr32(ihighlight)+';'+
'align:'+intstr32(ialign)+';'+
'slot:'+intstr32(ititleslot)+';'+
'fslot:'+intstr32(fileindex)+';'+
'query:'+iedit.value;
end;

procedure tbiblesearch.setsettings(x:string);
var
   fslot,xslot,lp,p:longint;
   n,v:string;

   function vstr:string;
   begin
   result:=strcopy1(x,lp+low__len(n)+1,low__len(x)-1);
   if (strcopy1(result,low__len(result),1)=';') then strdel1(result,low__len(result),1);
   end;
begin
//init
icompact       :=false;
iexact         :=true;
iall           :=true;
iauto          :=true;
ihighlight     :=1;//highlight
ialign         :=0;//0=left, 1=center, 2=right
fslot          :=3;//3=(CPDV) Catholic Public Domain Version
xslot          :=0;

case iid of
1:iedit.value    :='';
2:iedit.value    :='';
3:iedit.value    :='';
else iedit.value :='';
end;
x           :=x+';';

//get
lp:=1;
for p:=1 to low__len(x) do
begin
if (x[p-1+stroffset]=';') then
   begin
   low__splitstr(strcopy1(x,lp,p-lp),ssColon,n,v);
   n:=strlow(n);

   if      (n='compact')   then icompact:=(strint32(v)<>0)
   else if (n='exact')     then iexact:=(strint32(v)<>0)
   else if (n='all')       then iall:=(strint32(v)<>0)
   else if (n='auto')      then iauto:=(strint32(v)<>0)
   else if (n='highlight') then ihighlight:=frcrange32(strint32(v),0,3)
   else if (n='align')     then ialign:=frcrange32(strint32(v),0,2)
   else if (n='slot')      then xslot:=strint32(v)
   else if (n='fslot')     then fslot:=strint32(v)
   else if (n='query') then
      begin
      iedit.value:=vstr;
      break;
      end;

   lp:=p+1;
   end;
end;//p

//sync

setparams(fslot,title,false);//load file (book) first
setparams(fslot,icore.title[xslot],false);//set title using book's contents
xupdatebuttons;

if not iloaded then
   begin
   iloaded:=true;
   imustfindnohistory:=true;
   end;
end;

function tbiblesearch._onnotify(sender:tobject):boolean;
begin
//defaults
result:=false;
end;

end.
