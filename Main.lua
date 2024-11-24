do local StrToNumber=tonumber;local Byte=string.byte;local Char=string.char;local Sub=string.sub;local Subg=string.gsub;local Rep=string.rep;local Concat=table.concat;local Insert=table.insert;local LDExp=math.ldexp;local GetFEnv=getfenv or function() return _ENV;end ;local Setmetatable=setmetatable;local PCall=pcall;local Select=select;local Unpack=unpack or table.unpack ;local ToNumber=tonumber;local function VMCall(ByteString,vmenv,...) local DIP=1;local repeatNext;ByteString=Subg(Sub(ByteString,5),"..",function(byte) if (Byte(byte,2)==81) then repeatNext=StrToNumber(Sub(byte,1,1));return "";else local a=Char(StrToNumber(byte,16));if repeatNext then local b=Rep(a,repeatNext);repeatNext=nil;return b;else return a;end end end);local function gBit(Bit,Start,End) if End then local Res=(Bit/(2^(Start-1)))%(2^(((End-1) -(Start-1)) + 1)) ;return Res-(Res%1) ;else local Plc=2^(Start-1) ;return (((Bit%(Plc + Plc))>=Plc) and 1) or 0 ;end end local function gBits8() local FlatIdent_7126A=0;local a;while true do if (FlatIdent_7126A==1) then return a;end if (FlatIdent_7126A==0) then a=Byte(ByteString,DIP,DIP);DIP=DIP + 1 ;FlatIdent_7126A=1;end end end local function gBits16() local a,b=Byte(ByteString,DIP,DIP + 2 );DIP=DIP + 2 ;return (b * 256) + a ;end local function gBits32() local a,b,c,d=Byte(ByteString,DIP,DIP + 3 );DIP=DIP + 4 ;return (d * 16777216) + (c * 65536) + (b * 256) + a ;end local function gFloat() local FlatIdent_2661B=0;local Left;local Right;local IsNormal;local Mantissa;local Exponent;local Sign;while true do if (FlatIdent_2661B==1) then IsNormal=1;Mantissa=(gBit(Right,1,20) * (2^32)) + Left ;FlatIdent_2661B=2;end if (FlatIdent_2661B==2) then Exponent=gBit(Right,21,31);Sign=((gBit(Right,32)==1) and  -1) or 1 ;FlatIdent_2661B=3;end if (FlatIdent_2661B==0) then Left=gBits32();Right=gBits32();FlatIdent_2661B=1;end if (FlatIdent_2661B==3) then if (Exponent==0) then if (Mantissa==0) then return Sign * 0 ;else local FlatIdent_39B0=0;while true do if (FlatIdent_39B0==0) then Exponent=1;IsNormal=0;break;end end end elseif (Exponent==2047) then return ((Mantissa==0) and (Sign * (1/0))) or (Sign * NaN) ;end return LDExp(Sign,Exponent-1023 ) * (IsNormal + (Mantissa/(2^52))) ;end end end local function gString(Len) local FlatIdent_1076E=0;local Str;local FStr;while true do if (FlatIdent_1076E==3) then return Concat(FStr);end if (1==FlatIdent_1076E) then Str=Sub(ByteString,DIP,(DIP + Len) -1 );DIP=DIP + Len ;FlatIdent_1076E=2;end if (FlatIdent_1076E==0) then Str=nil;if  not Len then Len=gBits32();if (Len==0) then return "";end end FlatIdent_1076E=1;end if (FlatIdent_1076E==2) then FStr={};for Idx=1, #Str do FStr[Idx]=Char(Byte(Sub(Str,Idx,Idx)));end FlatIdent_1076E=3;end end end local gInt=gBits32;local function _R(...) return {...},Select("#",...);end local function Deserialize() local Instrs={};local Functions={};local Lines={};local Chunk={Instrs,Functions,nil,Lines};local ConstCount=gBits32();local Consts={};for Idx=1,ConstCount do local Type=gBits8();local Cons;if (Type==1) then Cons=gBits8()~=0 ;elseif (Type==2) then Cons=gFloat();elseif (Type==3) then Cons=gString();end Consts[Idx]=Cons;end Chunk[3]=gBits8();for Idx=1,gBits32() do local Descriptor=gBits8();if (gBit(Descriptor,1,1)==0) then local Type=gBit(Descriptor,2,3);local Mask=gBit(Descriptor,4,6);local Inst={gBits16(),gBits16(),nil,nil};if (Type==0) then Inst[3]=gBits16();Inst[4]=gBits16();elseif (Type==1) then Inst[3]=gBits32();elseif (Type==2) then Inst[3]=gBits32() -(2^16) ;elseif (Type==3) then Inst[3]=gBits32() -(2^16) ;Inst[4]=gBits16();end if (gBit(Mask,1,1)==1) then Inst[2]=Consts[Inst[2]];end if (gBit(Mask,2,2)==1) then Inst[3]=Consts[Inst[3]];end if (gBit(Mask,3,3)==1) then Inst[4]=Consts[Inst[4]];end Instrs[Idx]=Inst;end end for Idx=1,gBits32() do Functions[Idx-1 ]=Deserialize();end return Chunk;end local function Wrap(Chunk,Upvalues,Env) local Instr=Chunk[1];local Proto=Chunk[2];local Params=Chunk[3];return function(...) local Instr=Instr;local Proto=Proto;local Params=Params;local _R=_R;local VIP=1;local Top= -1;local Vararg={};local Args={...};local PCount=Select("#",...) -1 ;local Lupvals={};local Stk={};for Idx=0,PCount do if (Idx>=Params) then Vararg[Idx-Params ]=Args[Idx + 1 ];else Stk[Idx]=Args[Idx + 1 ];end end local Varargsz=(PCount-Params) + 1 ;local Inst;local Enum;while true do Inst=Instr[VIP];Enum=Inst[1];if (Enum<=66) then if (Enum<=32) then if (Enum<=15) then if (Enum<=7) then if (Enum<=3) then if (Enum<=1) then if (Enum>0) then local A=Inst[2];Top=(A + Varargsz) -1 ;for Idx=A,Top do local FlatIdent_27957=0;local VA;while true do if (0==FlatIdent_27957) then VA=Vararg[Idx-A ];Stk[Idx]=VA;break;end end end else local A;Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];if (Stk[Inst[2]]==Inst[4]) then VIP=VIP + 1 ;else VIP=Inst[3];end end elseif (Enum==2) then local FlatIdent_77C29=0;local A;local Results;local Limit;local Edx;while true do if (FlatIdent_77C29==2) then for Idx=A,Top do local FlatIdent_8CEDF=0;while true do if (FlatIdent_8CEDF==0) then Edx=Edx + 1 ;Stk[Idx]=Results[Edx];break;end end end break;end if (FlatIdent_77C29==1) then Top=(Limit + A) -1 ;Edx=0;FlatIdent_77C29=2;end if (FlatIdent_77C29==0) then A=Inst[2];Results,Limit=_R(Stk[A](Unpack(Stk,A + 1 ,Top)));FlatIdent_77C29=1;end end else local Edx;local Results,Limit;local A;Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Results,Limit=_R(Stk[A](Unpack(Stk,A + 1 ,Inst[3])));Top=(Limit + A) -1 ;Edx=0;for Idx=A,Top do Edx=Edx + 1 ;Stk[Idx]=Results[Edx];end VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Results,Limit=_R(Stk[A](Unpack(Stk,A + 1 ,Top)));Top=(Limit + A) -1 ;Edx=0;for Idx=A,Top do local FlatIdent_33EA4=0;while true do if (FlatIdent_33EA4==0) then Edx=Edx + 1 ;Stk[Idx]=Results[Edx];break;end end end VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Top));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Stk[Inst[3]]]=Stk[Inst[4]];end elseif (Enum<=5) then if (Enum==4) then local A=Inst[2];Stk[A]=Stk[A]();else local A=Inst[2];local T=Stk[A];for Idx=A + 1 ,Top do Insert(T,Stk[Idx]);end end elseif (Enum==6) then local FlatIdent_25DF3=0;local Step;local Index;local A;while true do if (FlatIdent_25DF3==7) then Inst=Instr[VIP];A=Inst[2];Index=Stk[A];FlatIdent_25DF3=8;end if (FlatIdent_25DF3==1) then A=Inst[2];Stk[A]=Stk[A]();VIP=VIP + 1 ;FlatIdent_25DF3=2;end if (FlatIdent_25DF3==5) then Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;FlatIdent_25DF3=6;end if (FlatIdent_25DF3==6) then Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;FlatIdent_25DF3=7;end if (FlatIdent_25DF3==0) then Step=nil;Index=nil;A=nil;FlatIdent_25DF3=1;end if (FlatIdent_25DF3==4) then Inst=Instr[VIP];Stk[Inst[2]]= #Stk[Inst[3]];VIP=VIP + 1 ;FlatIdent_25DF3=5;end if (FlatIdent_25DF3==8) then Step=Stk[A + 2 ];if (Step>0) then if (Index>Stk[A + 1 ]) then VIP=Inst[3];else Stk[A + 3 ]=Index;end elseif (Index<Stk[A + 1 ]) then VIP=Inst[3];else Stk[A + 3 ]=Index;end break;end if (FlatIdent_25DF3==2) then Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;FlatIdent_25DF3=3;end if (FlatIdent_25DF3==3) then Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;FlatIdent_25DF3=4;end end else local FlatIdent_2D88C=0;local Step;local Index;local VA;local A;while true do if (5==FlatIdent_2D88C) then Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;FlatIdent_2D88C=6;end if (6==FlatIdent_2D88C) then Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];FlatIdent_2D88C=7;end if (FlatIdent_2D88C==0) then Step=nil;Index=nil;VA=nil;A=nil;Stk[Inst[2]]=Inst[3];FlatIdent_2D88C=1;end if (FlatIdent_2D88C==3) then Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] -Inst[4] ;VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]={};FlatIdent_2D88C=4;end if (FlatIdent_2D88C==2) then VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Top));VIP=VIP + 1 ;FlatIdent_2D88C=3;end if (7==FlatIdent_2D88C) then Index=Stk[A];Step=Stk[A + 2 ];if (Step>0) then if (Index>Stk[A + 1 ]) then VIP=Inst[3];else Stk[A + 3 ]=Index;end elseif (Index<Stk[A + 1 ]) then VIP=Inst[3];else Stk[A + 3 ]=Index;end break;end if (FlatIdent_2D88C==1) then VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Top=(A + Varargsz) -1 ;for Idx=A,Top do VA=Vararg[Idx-A ];Stk[Idx]=VA;end FlatIdent_2D88C=2;end if (4==FlatIdent_2D88C) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]={};VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_2D88C=5;end end end elseif (Enum<=11) then if (Enum<=9) then if (Enum==8) then local A;Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];else local A=Inst[2];local Results={Stk[A](Unpack(Stk,A + 1 ,Inst[3]))};local Edx=0;for Idx=A,Inst[4] do Edx=Edx + 1 ;Stk[Idx]=Results[Edx];end end elseif (Enum==10) then if (Inst[2]<Inst[4]) then VIP=VIP + 1 ;else VIP=Inst[3];end elseif (Stk[Inst[2]]<=Inst[4]) then VIP=VIP + 1 ;else VIP=Inst[3];end elseif (Enum<=13) then if (Enum>12) then local A=Inst[2];do return Stk[A](Unpack(Stk,A + 1 ,Top));end else local A=Inst[2];local Results,Limit=_R(Stk[A](Stk[A + 1 ]));Top=(Limit + A) -1 ;local Edx=0;for Idx=A,Top do Edx=Edx + 1 ;Stk[Idx]=Results[Edx];end end elseif (Enum>14) then local FlatIdent_98388=0;local Step;local Index;local A;while true do if (1==FlatIdent_98388) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;FlatIdent_98388=2;end if (FlatIdent_98388==2) then Inst=Instr[VIP];Stk[Inst[2]]= #Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_98388=3;end if (FlatIdent_98388==4) then Index=Stk[A];Step=Stk[A + 2 ];if (Step>0) then if (Index>Stk[A + 1 ]) then VIP=Inst[3];else Stk[A + 3 ]=Index;end elseif (Index<Stk[A + 1 ]) then VIP=Inst[3];else Stk[A + 3 ]=Index;end break;end if (FlatIdent_98388==0) then Step=nil;Index=nil;A=nil;Stk[Inst[2]]=Stk[Inst[3]];FlatIdent_98388=1;end if (3==FlatIdent_98388) then Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];FlatIdent_98388=4;end end else Stk[Inst[2]]={};end elseif (Enum<=23) then if (Enum<=19) then if (Enum<=17) then if (Enum>16) then local A;Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] + Inst[4] ;VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] + Inst[4] ;VIP=VIP + 1 ;Inst=Instr[VIP];Upvalues[Inst[3]]=Stk[Inst[2]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];VIP=Inst[3];elseif Stk[Inst[2]] then VIP=VIP + 1 ;else VIP=Inst[3];end elseif (Enum==18) then Stk[Inst[2]]=Upvalues[Inst[3]];else local A;Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]= #Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]= #Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]= #Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];if (Stk[Inst[2]]==Stk[Inst[4]]) then VIP=VIP + 1 ;else VIP=Inst[3];end end elseif (Enum<=21) then if (Enum>20) then Stk[Inst[2]]= #Stk[Inst[3]];else Stk[Inst[2]]=Stk[Inst[3]]%Inst[4] ;end elseif (Enum>22) then local FlatIdent_75224=0;local A;while true do if (FlatIdent_75224==2) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_75224=3;end if (FlatIdent_75224==0) then A=nil;Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));FlatIdent_75224=1;end if (FlatIdent_75224==13) then VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_75224=14;end if (FlatIdent_75224==1) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];FlatIdent_75224=2;end if (FlatIdent_75224==14) then Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_75224=15;end if (FlatIdent_75224==19) then Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_75224=20;end if (FlatIdent_75224==4) then Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;FlatIdent_75224=5;end if (FlatIdent_75224==23) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];FlatIdent_75224=24;end if (FlatIdent_75224==20) then Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;FlatIdent_75224=21;end if (FlatIdent_75224==24) then Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_75224=25;end if (FlatIdent_75224==9) then Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;FlatIdent_75224=10;end if (FlatIdent_75224==15) then A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;FlatIdent_75224=16;end if (FlatIdent_75224==16) then Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));FlatIdent_75224=17;end if (FlatIdent_75224==6) then Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];FlatIdent_75224=7;end if (FlatIdent_75224==17) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];FlatIdent_75224=18;end if (FlatIdent_75224==10) then Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;FlatIdent_75224=11;end if (FlatIdent_75224==25) then Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;FlatIdent_75224=26;end if (FlatIdent_75224==27) then Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];FlatIdent_75224=28;end if (FlatIdent_75224==21) then Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;FlatIdent_75224=22;end if (FlatIdent_75224==18) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_75224=19;end if (FlatIdent_75224==11) then Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];FlatIdent_75224=12;end if (FlatIdent_75224==5) then Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;FlatIdent_75224=6;end if (FlatIdent_75224==26) then Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;FlatIdent_75224=27;end if (FlatIdent_75224==3) then Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_75224=4;end if (FlatIdent_75224==8) then Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_75224=9;end if (FlatIdent_75224==22) then Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];FlatIdent_75224=23;end if (FlatIdent_75224==28) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];break;end if (FlatIdent_75224==12) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];FlatIdent_75224=13;end if (FlatIdent_75224==7) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];FlatIdent_75224=8;end end else Stk[Inst[2]]=Inst[3]^Stk[Inst[4]] ;end elseif (Enum<=27) then if (Enum<=25) then if (Enum==24) then local VA;local A;Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A]();VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]={};VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Top=(A + Varargsz) -1 ;for Idx=A,Top do VA=Vararg[Idx-A ];Stk[Idx]=VA;end VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];do return Stk[A](Unpack(Stk,A + 1 ,Top));end VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];do return Unpack(Stk,A,Top);end VIP=VIP + 1 ;Inst=Instr[VIP];do return;end else local Results;local Edx;local Results,Limit;local A;Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] + Inst[4] ;VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Results,Limit=_R(Stk[A](Unpack(Stk,A + 1 ,Inst[3])));Top=(Limit + A) -1 ;Edx=0;for Idx=A,Top do Edx=Edx + 1 ;Stk[Idx]=Results[Edx];end VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Results,Limit=_R(Stk[A](Unpack(Stk,A + 1 ,Top)));Top=(Limit + A) -1 ;Edx=0;for Idx=A,Top do Edx=Edx + 1 ;Stk[Idx]=Results[Edx];end VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Results={Stk[A](Unpack(Stk,A + 1 ,Top))};Edx=0;for Idx=A,Inst[4] do Edx=Edx + 1 ;Stk[Idx]=Results[Edx];end VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] + Stk[Inst[4]] ;VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] -Inst[4] ;VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];end elseif (Enum>26) then Stk[Inst[2]]=Inst[3] + Stk[Inst[4]] ;else local FlatIdent_43337=0;local Step;local Index;local A;while true do if (6==FlatIdent_43337) then Step=Stk[A + 2 ];if (Step>0) then if (Index>Stk[A + 1 ]) then VIP=Inst[3];else Stk[A + 3 ]=Index;end elseif (Index<Stk[A + 1 ]) then VIP=Inst[3];else Stk[A + 3 ]=Index;end break;end if (FlatIdent_43337==2) then Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_43337=3;end if (FlatIdent_43337==0) then Step=nil;Index=nil;A=nil;FlatIdent_43337=1;end if (FlatIdent_43337==1) then Stk[Inst[2]]= #Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_43337=2;end if (FlatIdent_43337==4) then Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;FlatIdent_43337=5;end if (FlatIdent_43337==3) then A=Inst[2];Stk[A]=Stk[A]();VIP=VIP + 1 ;FlatIdent_43337=4;end if (FlatIdent_43337==5) then Inst=Instr[VIP];A=Inst[2];Index=Stk[A];FlatIdent_43337=6;end end end elseif (Enum<=29) then if (Enum>28) then local Edx;local Results,Limit;local A;Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Results,Limit=_R(Stk[A](Unpack(Stk,A + 1 ,Inst[3])));Top=(Limit + A) -1 ;Edx=0;for Idx=A,Top do Edx=Edx + 1 ;Stk[Idx]=Results[Edx];end VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Top));VIP=VIP + 1 ;Inst=Instr[VIP];Upvalues[Inst[3]]=Stk[Inst[2]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];do return Stk[Inst[2]];end VIP=VIP + 1 ;Inst=Instr[VIP];VIP=Inst[3];else local A=Inst[2];local Results={Stk[A]()};local Limit=Inst[4];local Edx=0;for Idx=A,Limit do Edx=Edx + 1 ;Stk[Idx]=Results[Edx];end end elseif (Enum<=30) then local FlatIdent_D14D=0;local DIP;local NStk;local Upv;local List;local Cls;local Edx;local Limit;local Results;local A;while true do if (FlatIdent_D14D==1) then Cls=nil;Edx=nil;Limit=nil;Results=nil;FlatIdent_D14D=2;end if (FlatIdent_D14D==4) then Upvalues[Inst[3]]=Stk[Inst[2]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];FlatIdent_D14D=5;end if (FlatIdent_D14D==6) then Inst=Instr[VIP];A=Inst[2];Cls={};for Idx=1, #Lupvals do List=Lupvals[Idx];for Idz=0, #List do Upv=List[Idz];NStk=Upv[1];DIP=Upv[2];if ((NStk==Stk) and (DIP>=A)) then local FlatIdent_B1F4=0;while true do if (FlatIdent_B1F4==0) then Cls[DIP]=NStk[DIP];Upv[1]=Cls;break;end end end end end break;end if (FlatIdent_D14D==3) then Edx=0;for Idx=A,Limit do local FlatIdent_527C6=0;while true do if (FlatIdent_527C6==0) then Edx=Edx + 1 ;Stk[Idx]=Results[Edx];break;end end end VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_D14D=4;end if (0==FlatIdent_D14D) then DIP=nil;NStk=nil;Upv=nil;List=nil;FlatIdent_D14D=1;end if (FlatIdent_D14D==5) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;FlatIdent_D14D=6;end if (2==FlatIdent_D14D) then A=nil;A=Inst[2];Results={Stk[A]()};Limit=Inst[4];FlatIdent_D14D=3;end end elseif (Enum>31) then local Edx;local Results,Limit;local A;Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] + Inst[4] ;VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] + Inst[4] ;VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Results,Limit=_R(Stk[A](Unpack(Stk,A + 1 ,Inst[3])));Top=(Limit + A) -1 ;Edx=0;for Idx=A,Top do local FlatIdent_656E9=0;while true do if (FlatIdent_656E9==0) then Edx=Edx + 1 ;Stk[Idx]=Results[Edx];break;end end end VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Top));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Stk[Inst[3]]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];VIP=Inst[3];elseif (Inst[2]~=Stk[Inst[4]]) then VIP=VIP + 1 ;else VIP=Inst[3];end elseif (Enum<=49) then if (Enum<=40) then if (Enum<=36) then if (Enum<=34) then if (Enum==33) then Stk[Inst[2]]=Stk[Inst[3]]/Stk[Inst[4]] ;else local A;A=Inst[2];Stk[A]=Stk[A]();VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]= #Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]= #Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];if (Stk[Inst[2]]==Inst[4]) then VIP=VIP + 1 ;else VIP=Inst[3];end end elseif (Enum==35) then Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Env[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Env[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;Inst=Instr[VIP];if  not Stk[Inst[2]] then VIP=VIP + 1 ;else VIP=Inst[3];end else local A;Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] -Inst[4] ;VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]]/Inst[4] ;VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] + Stk[Inst[4]] ;VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] * Stk[Inst[4]] ;VIP=VIP + 1 ;Inst=Instr[VIP];do return Stk[Inst[2]];end VIP=VIP + 1 ;Inst=Instr[VIP];VIP=Inst[3];end elseif (Enum<=38) then if (Enum>37) then Upvalues[Inst[3]]=Stk[Inst[2]];else Stk[Inst[2]]=Inst[3]~=0 ;end elseif (Enum==39) then Stk[Inst[2]]=Stk[Inst[3]];else Stk[Inst[2]]=Stk[Inst[3]] + Inst[4] ;end elseif (Enum<=44) then if (Enum<=42) then if (Enum>41) then do return;end else Stk[Inst[2]]=Stk[Inst[3]] -Stk[Inst[4]] ;end elseif (Enum>43) then local Edx;local Results;local A;Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] + Inst[4] ;VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Results={Stk[A](Unpack(Stk,A + 1 ,Inst[3]))};Edx=0;for Idx=A,Inst[4] do local FlatIdent_1BA2F=0;while true do if (FlatIdent_1BA2F==0) then Edx=Edx + 1 ;Stk[Idx]=Results[Edx];break;end end end VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] + Inst[4] ;VIP=VIP + 1 ;Inst=Instr[VIP];Upvalues[Inst[3]]=Stk[Inst[2]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];VIP=Inst[3];else local A;Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];for Idx=Inst[2],Inst[3] do Stk[Idx]=nil;end VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];end elseif (Enum<=46) then if (Enum>45) then local FlatIdent_1512=0;local Edx;local Results;local Limit;local VA;local A;while true do if (FlatIdent_1512==4) then for Idx=A,Top do local FlatIdent_13B77=0;while true do if (0==FlatIdent_13B77) then Edx=Edx + 1 ;Stk[Idx]=Results[Edx];break;end end end VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];FlatIdent_1512=5;end if (FlatIdent_1512==0) then Edx=nil;Results,Limit=nil;VA=nil;A=nil;FlatIdent_1512=1;end if (FlatIdent_1512==5) then do return Unpack(Stk,A,Top);end VIP=VIP + 1 ;Inst=Instr[VIP];do return;end break;end if (FlatIdent_1512==3) then A=Inst[2];Results,Limit=_R(Stk[A](Unpack(Stk,A + 1 ,Top)));Top=(Limit + A) -1 ;Edx=0;FlatIdent_1512=4;end if (FlatIdent_1512==2) then Top=(A + Varargsz) -1 ;for Idx=A,Top do VA=Vararg[Idx-A ];Stk[Idx]=VA;end VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_1512=3;end if (1==FlatIdent_1512) then Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];FlatIdent_1512=2;end end else local FlatIdent_94CF9=0;while true do if (FlatIdent_94CF9==3) then Stk[Inst[2]]=Stk[Inst[3]] + Stk[Inst[4]] ;VIP=VIP + 1 ;Inst=Instr[VIP];do return Stk[Inst[2]];end break;end if (2==FlatIdent_94CF9) then Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] + Stk[Inst[4]] ;VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_94CF9=3;end if (FlatIdent_94CF9==1) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] * Inst[4] ;VIP=VIP + 1 ;FlatIdent_94CF9=2;end if (FlatIdent_94CF9==0) then Stk[Inst[2]]=Stk[Inst[3]] * Inst[4] ;VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] + Stk[Inst[4]] ;FlatIdent_94CF9=1;end end end elseif (Enum<=47) then VIP=Inst[3];elseif (Enum==48) then local A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Top));else local A;Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Env[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Env[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];end elseif (Enum<=57) then if (Enum<=53) then if (Enum<=51) then if (Enum>50) then local A;A=Inst[2];Stk[A]=Stk[A]();VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Stk[Inst[3]]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]= #Stk[Inst[3]];else do return Stk[Inst[2]]();end end elseif (Enum>52) then local A;Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];do return Stk[A](Unpack(Stk,A + 1 ,Inst[3]));end VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];do return Unpack(Stk,A,Top);end VIP=VIP + 1 ;Inst=Instr[VIP];do return;end else local A=Inst[2];do return Unpack(Stk,A,A + Inst[3] );end end elseif (Enum<=55) then if (Enum==54) then local B;local T;local A;Stk[Inst[2]]={};VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A]();VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A]();VIP=VIP + 1 ;Inst=Instr[VIP];for Idx=Inst[2],Inst[3] do Stk[Idx]=nil;end VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];T=Stk[A];B=Inst[3];for Idx=1,B do T[Idx]=Stk[A + Idx ];end else local B=Stk[Inst[4]];if  not B then VIP=VIP + 1 ;else local FlatIdent_14716=0;while true do if (0==FlatIdent_14716) then Stk[Inst[2]]=B;VIP=Inst[3];break;end end end end elseif (Enum==56) then local FlatIdent_A446=0;local DIP;local NStk;local Upv;local List;local Cls;local VA;local A;while true do if (FlatIdent_A446==1) then Cls=nil;VA=nil;A=nil;Stk[Inst[2]]=Stk[Inst[3]];FlatIdent_A446=2;end if (FlatIdent_A446==9) then VIP=VIP + 1 ;Inst=Instr[VIP];do return;end break;end if (FlatIdent_A446==6) then Inst=Instr[VIP];A=Inst[2];do return Stk[A](Unpack(Stk,A + 1 ,Top));end VIP=VIP + 1 ;FlatIdent_A446=7;end if (8==FlatIdent_A446) then Inst=Instr[VIP];A=Inst[2];Cls={};for Idx=1, #Lupvals do List=Lupvals[Idx];for Idz=0, #List do Upv=List[Idz];NStk=Upv[1];DIP=Upv[2];if ((NStk==Stk) and (DIP>=A)) then local FlatIdent_15034=0;while true do if (FlatIdent_15034==0) then Cls[DIP]=NStk[DIP];Upv[1]=Cls;break;end end end end end FlatIdent_A446=9;end if (FlatIdent_A446==4) then A=Inst[2];Stk[A]=Stk[A]();VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_A446=5;end if (0==FlatIdent_A446) then DIP=nil;NStk=nil;Upv=nil;List=nil;FlatIdent_A446=1;end if (FlatIdent_A446==5) then A=Inst[2];Top=(A + Varargsz) -1 ;for Idx=A,Top do VA=Vararg[Idx-A ];Stk[Idx]=VA;end VIP=VIP + 1 ;FlatIdent_A446=6;end if (FlatIdent_A446==7) then Inst=Instr[VIP];A=Inst[2];do return Unpack(Stk,A,Top);end VIP=VIP + 1 ;FlatIdent_A446=8;end if (FlatIdent_A446==2) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;FlatIdent_A446=3;end if (FlatIdent_A446==3) then Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_A446=4;end end elseif (Inst[2]<=Inst[4]) then VIP=VIP + 1 ;else VIP=Inst[3];end elseif (Enum<=61) then if (Enum<=59) then if (Enum==58) then local FlatIdent_23FF9=0;local A;while true do if (FlatIdent_23FF9==0) then A=nil;Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;FlatIdent_23FF9=1;end if (1==FlatIdent_23FF9) then Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A]();FlatIdent_23FF9=2;end if (2==FlatIdent_23FF9) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] -Inst[4] ;FlatIdent_23FF9=3;end if (FlatIdent_23FF9==3) then VIP=VIP + 1 ;Inst=Instr[VIP];do return Stk[Inst[2]];end FlatIdent_23FF9=4;end if (FlatIdent_23FF9==4) then VIP=VIP + 1 ;Inst=Instr[VIP];do return;end break;end end else Stk[Inst[2]]=Inst[3];end elseif (Enum>60) then local FlatIdent_1CFC3=0;local A;while true do if (FlatIdent_1CFC3==3) then Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_1CFC3=4;end if (FlatIdent_1CFC3==8) then if (Stk[Inst[2]]==Stk[Inst[4]]) then VIP=VIP + 1 ;else VIP=Inst[3];end break;end if (7==FlatIdent_1CFC3) then Inst=Instr[VIP];Stk[Inst[2]]= #Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_1CFC3=8;end if (FlatIdent_1CFC3==5) then VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));FlatIdent_1CFC3=6;end if (FlatIdent_1CFC3==6) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;FlatIdent_1CFC3=7;end if (FlatIdent_1CFC3==4) then Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]= #Stk[Inst[3]];FlatIdent_1CFC3=5;end if (FlatIdent_1CFC3==2) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]= #Stk[Inst[3]];VIP=VIP + 1 ;FlatIdent_1CFC3=3;end if (FlatIdent_1CFC3==1) then Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];FlatIdent_1CFC3=2;end if (FlatIdent_1CFC3==0) then A=nil;Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_1CFC3=1;end end else Stk[Inst[2]]=Stk[Inst[3]]/Inst[4] ;end elseif (Enum<=63) then if (Enum>62) then local FlatIdent_6E23=0;local A;while true do if (FlatIdent_6E23==2) then Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];FlatIdent_6E23=3;end if (FlatIdent_6E23==1) then Inst=Instr[VIP];Stk[Inst[2]][Stk[Inst[3]]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_6E23=2;end if (FlatIdent_6E23==3) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]= #Stk[Inst[3]];break;end if (FlatIdent_6E23==0) then A=nil;A=Inst[2];Stk[A]=Stk[A]();VIP=VIP + 1 ;FlatIdent_6E23=1;end end elseif (Stk[Inst[2]]==Inst[4]) then VIP=VIP + 1 ;else VIP=Inst[3];end elseif (Enum<=64) then local FlatIdent_47A85=0;local A;local Step;local Index;while true do if (2==FlatIdent_47A85) then if (Step>0) then if (Index<=Stk[A + 1 ]) then VIP=Inst[3];Stk[A + 3 ]=Index;end elseif (Index>=Stk[A + 1 ]) then VIP=Inst[3];Stk[A + 3 ]=Index;end break;end if (FlatIdent_47A85==1) then Index=Stk[A] + Step ;Stk[A]=Index;FlatIdent_47A85=2;end if (FlatIdent_47A85==0) then A=Inst[2];Step=Stk[A + 2 ];FlatIdent_47A85=1;end end elseif (Enum==65) then local FlatIdent_437D4=0;local A;while true do if (3==FlatIdent_437D4) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];VIP=VIP + 1 ;FlatIdent_437D4=4;end if (FlatIdent_437D4==1) then Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];FlatIdent_437D4=2;end if (FlatIdent_437D4==2) then VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));FlatIdent_437D4=3;end if (FlatIdent_437D4==5) then Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];FlatIdent_437D4=6;end if (FlatIdent_437D4==7) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];break;end if (FlatIdent_437D4==6) then VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));FlatIdent_437D4=7;end if (FlatIdent_437D4==0) then A=nil;Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_437D4=1;end if (FlatIdent_437D4==4) then Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_437D4=5;end end elseif (Inst[2]==Stk[Inst[4]]) then VIP=VIP + 1 ;else VIP=Inst[3];end elseif (Enum<=99) then if (Enum<=82) then if (Enum<=74) then if (Enum<=70) then if (Enum<=68) then if (Enum>67) then local FlatIdent_16207=0;local A;while true do if (1==FlatIdent_16207) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_16207=2;end if (FlatIdent_16207==4) then Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;FlatIdent_16207=5;end if (FlatIdent_16207==2) then Stk[Inst[2]]=Stk[Inst[3]] + Stk[Inst[4]] ;VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] -Inst[4] ;VIP=VIP + 1 ;FlatIdent_16207=3;end if (FlatIdent_16207==6) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_16207=7;end if (FlatIdent_16207==3) then Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_16207=4;end if (5==FlatIdent_16207) then Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] + Stk[Inst[4]] ;VIP=VIP + 1 ;Inst=Instr[VIP];Upvalues[Inst[3]]=Stk[Inst[2]];FlatIdent_16207=6;end if (7==FlatIdent_16207) then VIP=Inst[3];break;end if (FlatIdent_16207==0) then A=nil;Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];FlatIdent_16207=1;end end else local A;A=Inst[2];Stk[A]=Stk[A]();VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Stk[Inst[3]]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];do return Unpack(Stk,A,A + Inst[3] );end VIP=VIP + 1 ;Inst=Instr[VIP];VIP=Inst[3];end elseif (Enum>69) then local FlatIdent_64E47=0;while true do if (FlatIdent_64E47==2) then Inst=Instr[VIP];Stk[Inst[2]][Stk[Inst[3]]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_64E47=3;end if (FlatIdent_64E47==3) then VIP=Inst[3];break;end if (1==FlatIdent_64E47) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;FlatIdent_64E47=2;end if (FlatIdent_64E47==0) then Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];FlatIdent_64E47=1;end end else Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]= #Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;Inst=Instr[VIP];do return Stk[Inst[2]];end VIP=VIP + 1 ;Inst=Instr[VIP];do return;end end elseif (Enum<=72) then if (Enum>71) then Stk[Inst[2]]=Stk[Inst[3]] -Inst[4] ;else local A;Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]= #Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];if (Stk[Inst[2]]==Stk[Inst[4]]) then VIP=VIP + 1 ;else VIP=Inst[3];end end elseif (Enum==73) then local Edx;local Results,Limit;local A;Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Results,Limit=_R(Stk[A](Unpack(Stk,A + 1 ,Inst[3])));Top=(Limit + A) -1 ;Edx=0;for Idx=A,Top do local FlatIdent_33F65=0;while true do if (FlatIdent_33F65==0) then Edx=Edx + 1 ;Stk[Idx]=Results[Edx];break;end end end VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Top));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];if Stk[Inst[2]] then VIP=VIP + 1 ;else VIP=Inst[3];end else Stk[Inst[2]]=Inst[3]/Inst[4] ;end elseif (Enum<=78) then if (Enum<=76) then if (Enum>75) then for Idx=Inst[2],Inst[3] do Stk[Idx]=nil;end elseif (Stk[Inst[2]]==Stk[Inst[4]]) then VIP=VIP + 1 ;else VIP=Inst[3];end elseif (Enum>77) then local A=Inst[2];Stk[A](Unpack(Stk,A + 1 ,Top));else Stk[Inst[2]]=Stk[Inst[3]] + Stk[Inst[4]] ;end elseif (Enum<=80) then if (Enum>79) then Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];else local A=Inst[2];do return Unpack(Stk,A,Top);end end elseif (Enum==81) then local A;Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];if (Stk[Inst[2]]==Inst[4]) then VIP=VIP + 1 ;else VIP=Inst[3];end else Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Env[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Env[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Env[Inst[3]];end elseif (Enum<=90) then if (Enum<=86) then if (Enum<=84) then if (Enum==83) then if  not Stk[Inst[2]] then VIP=VIP + 1 ;else VIP=Inst[3];end else Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];end elseif (Enum>85) then do return Stk[Inst[2]];end else local FlatIdent_2C010=0;while true do if (FlatIdent_2C010==2) then Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_2C010=3;end if (3==FlatIdent_2C010) then do return Stk[Inst[2]];end VIP=VIP + 1 ;Inst=Instr[VIP];do return;end break;end if (FlatIdent_2C010==1) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;FlatIdent_2C010=2;end if (FlatIdent_2C010==0) then Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];FlatIdent_2C010=1;end end end elseif (Enum<=88) then if (Enum>87) then local A=Inst[2];local T=Stk[A];local B=Inst[3];for Idx=1,B do T[Idx]=Stk[A + Idx ];end elseif (Inst[2]<Stk[Inst[4]]) then VIP=Inst[3];else VIP=VIP + 1 ;end elseif (Enum>89) then if (Stk[Inst[2]]<=Stk[Inst[4]]) then VIP=VIP + 1 ;else VIP=Inst[3];end else local Step;local Index;local A;Stk[Inst[2]]={};VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]= #Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Index=Stk[A];Step=Stk[A + 2 ];if (Step>0) then if (Index>Stk[A + 1 ]) then VIP=Inst[3];else Stk[A + 3 ]=Index;end elseif (Index<Stk[A + 1 ]) then VIP=Inst[3];else Stk[A + 3 ]=Index;end end elseif (Enum<=94) then if (Enum<=92) then if (Enum>91) then local FlatIdent_696E1=0;local A;while true do if (FlatIdent_696E1==2) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;FlatIdent_696E1=3;end if (3==FlatIdent_696E1) then Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_696E1=4;end if (FlatIdent_696E1==6) then do return Unpack(Stk,A,Top);end VIP=VIP + 1 ;Inst=Instr[VIP];do return;end break;end if (FlatIdent_696E1==5) then do return Stk[A](Unpack(Stk,A + 1 ,Inst[3]));end VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];FlatIdent_696E1=6;end if (FlatIdent_696E1==1) then Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];FlatIdent_696E1=2;end if (FlatIdent_696E1==0) then A=nil;Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_696E1=1;end if (FlatIdent_696E1==4) then Stk[Inst[2]]= #Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];FlatIdent_696E1=5;end end else local A;Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]= #Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];do return Stk[A](Unpack(Stk,A + 1 ,Inst[3]));end VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];do return Unpack(Stk,A,Top);end VIP=VIP + 1 ;Inst=Instr[VIP];do return;end end elseif (Enum>93) then local Edx;local Results;local A;Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] + Inst[4] ;VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Results={Stk[A](Unpack(Stk,A + 1 ,Inst[3]))};Edx=0;for Idx=A,Inst[4] do Edx=Edx + 1 ;Stk[Idx]=Results[Edx];end VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] + Inst[4] ;VIP=VIP + 1 ;Inst=Instr[VIP];Upvalues[Inst[3]]=Stk[Inst[2]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];else local A;Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] * Inst[4] ;VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] + Stk[Inst[4]] ;VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];VIP=Inst[3];end elseif (Enum<=96) then if (Enum==95) then if (Inst[2]==Inst[4]) then VIP=VIP + 1 ;else VIP=Inst[3];end else local A=Inst[2];local Index=Stk[A];local Step=Stk[A + 2 ];if (Step>0) then if (Index>Stk[A + 1 ]) then VIP=Inst[3];else Stk[A + 3 ]=Index;end elseif (Index<Stk[A + 1 ]) then VIP=Inst[3];else Stk[A + 3 ]=Index;end end elseif (Enum<=97) then local A=Inst[2];local Results={Stk[A](Unpack(Stk,A + 1 ,Top))};local Edx=0;for Idx=A,Inst[4] do local FlatIdent_95359=0;while true do if (0==FlatIdent_95359) then Edx=Edx + 1 ;Stk[Idx]=Results[Edx];break;end end end elseif (Enum==98) then local NewProto=Proto[Inst[3]];local NewUvals;local Indexes={};NewUvals=Setmetatable({},{__index=function(_,Key) local Val=Indexes[Key];return Val[1][Val[2]];end,__newindex=function(_,Key,Value) local FlatIdent_8384B=0;local Val;while true do if (FlatIdent_8384B==0) then Val=Indexes[Key];Val[1][Val[2]]=Value;break;end end end});for Idx=1,Inst[4] do VIP=VIP + 1 ;local Mvm=Instr[VIP];if (Mvm[1]==39) then Indexes[Idx-1 ]={Stk,Mvm[3]};else Indexes[Idx-1 ]={Upvalues,Mvm[3]};end Lupvals[ #Lupvals + 1 ]=Indexes;end Stk[Inst[2]]=Wrap(NewProto,NewUvals,Env);else local FlatIdent_63A3A=0;local A;local Results;local Limit;local Edx;while true do if (FlatIdent_63A3A==0) then A=Inst[2];Results,Limit=_R(Stk[A](Unpack(Stk,A + 1 ,Inst[3])));FlatIdent_63A3A=1;end if (FlatIdent_63A3A==1) then Top=(Limit + A) -1 ;Edx=0;FlatIdent_63A3A=2;end if (2==FlatIdent_63A3A) then for Idx=A,Top do Edx=Edx + 1 ;Stk[Idx]=Results[Edx];end break;end end end elseif (Enum<=116) then if (Enum<=107) then if (Enum<=103) then if (Enum<=101) then if (Enum==100) then local FlatIdent_354BC=0;while true do if (FlatIdent_354BC==1) then Stk[Inst[2]]=Stk[Inst[3]] -Inst[4] ;VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] -Inst[4] ;VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_354BC=2;end if (FlatIdent_354BC==3) then Stk[Inst[2]]=Inst[3]^Stk[Inst[4]] ;VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]]%Stk[Inst[4]] ;VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_354BC=4;end if (FlatIdent_354BC==5) then do return Stk[Inst[2]];end VIP=VIP + 1 ;Inst=Instr[VIP];VIP=Inst[3];break;end if (FlatIdent_354BC==0) then Stk[Inst[2]]=Inst[3]^Stk[Inst[4]] ;VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]]/Stk[Inst[4]] ;VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_354BC=1;end if (FlatIdent_354BC==4) then Stk[Inst[2]]=Stk[Inst[3]]%Inst[4] ;VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] -Stk[Inst[4]] ;VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_354BC=5;end if (FlatIdent_354BC==2) then Stk[Inst[2]]=Stk[Inst[3]] -Stk[Inst[4]] ;VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] + Inst[4] ;VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_354BC=3;end end else local FlatIdent_3E76B=0;while true do if (FlatIdent_3E76B==1) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Env[Inst[3]];VIP=VIP + 1 ;FlatIdent_3E76B=2;end if (FlatIdent_3E76B==2) then Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_3E76B=3;end if (FlatIdent_3E76B==0) then Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];FlatIdent_3E76B=1;end if (FlatIdent_3E76B==3) then Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Env[Inst[3]];FlatIdent_3E76B=4;end if (FlatIdent_3E76B==4) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;FlatIdent_3E76B=5;end if (FlatIdent_3E76B==6) then Stk[Inst[2]]=Env[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];break;end if (FlatIdent_3E76B==5) then Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_3E76B=6;end end end elseif (Enum>102) then local FlatIdent_15C34=0;while true do if (FlatIdent_15C34==0) then Stk[Inst[2]][Stk[Inst[3]]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_15C34=1;end if (FlatIdent_15C34==2) then Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_15C34=3;end if (FlatIdent_15C34==1) then Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_15C34=2;end if (FlatIdent_15C34==4) then VIP=Inst[3];break;end if (FlatIdent_15C34==3) then Stk[Inst[2]][Stk[Inst[3]]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_15C34=4;end end else local A=Inst[2];local T=Stk[A];for Idx=A + 1 ,Inst[3] do Insert(T,Stk[Idx]);end end elseif (Enum<=105) then if (Enum>104) then local FlatIdent_5A134=0;while true do if (FlatIdent_5A134==0) then Stk[Inst[2]]=Env[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_5A134=1;end if (FlatIdent_5A134==9) then Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];break;end if (FlatIdent_5A134==3) then Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_5A134=4;end if (FlatIdent_5A134==5) then Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_5A134=6;end if (1==FlatIdent_5A134) then Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_5A134=2;end if (FlatIdent_5A134==7) then Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_5A134=8;end if (FlatIdent_5A134==8) then Stk[Inst[2]]=Env[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_5A134=9;end if (FlatIdent_5A134==4) then Stk[Inst[2]]=Env[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_5A134=5;end if (FlatIdent_5A134==2) then Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_5A134=3;end if (FlatIdent_5A134==6) then Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_5A134=7;end end else local A;Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];for Idx=Inst[2],Inst[3] do Stk[Idx]=nil;end VIP=VIP + 1 ;Inst=Instr[VIP];Upvalues[Inst[3]]=Stk[Inst[2]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];VIP=Inst[3];end elseif (Enum==106) then local B;local T;local A;Stk[Inst[2]]={};VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];for Idx=Inst[2],Inst[3] do Stk[Idx]=nil;end VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];T=Stk[A];B=Inst[3];for Idx=1,B do T[Idx]=Stk[A + Idx ];end else Stk[Inst[2]]();end elseif (Enum<=111) then if (Enum<=109) then if (Enum==108) then Stk[Inst[2]]=Inst[3]~=0 ;VIP=VIP + 1 ;else Stk[Inst[2]][Stk[Inst[3]]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Stk[Inst[3]]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] + Inst[4] ;VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Stk[Inst[3]]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];end elseif (Enum>110) then Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Stk[Inst[3]]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] + Inst[4] ;VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];VIP=Inst[3];else Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]= #Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;Inst=Instr[VIP];do return Stk[Inst[2]];end VIP=VIP + 1 ;Inst=Instr[VIP];do return;end end elseif (Enum<=113) then if (Enum>112) then if (Stk[Inst[2]]~=Stk[Inst[4]]) then VIP=VIP + 1 ;else VIP=Inst[3];end else Stk[Inst[2]]=Stk[Inst[3]] * Inst[4] ;end elseif (Enum<=114) then Stk[Inst[2]]=Env[Inst[3]];elseif (Enum==115) then local A=Inst[2];local Cls={};for Idx=1, #Lupvals do local List=Lupvals[Idx];for Idz=0, #List do local Upv=List[Idz];local NStk=Upv[1];local DIP=Upv[2];if ((NStk==Stk) and (DIP>=A)) then Cls[DIP]=NStk[DIP];Upv[1]=Cls;end end end else local FlatIdent_5AC6=0;local A;while true do if (FlatIdent_5AC6==4) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;FlatIdent_5AC6=5;end if (FlatIdent_5AC6==5) then Inst=Instr[VIP];VIP=Inst[3];break;end if (FlatIdent_5AC6==0) then A=nil;A=Inst[2];Stk[A]=Stk[A]();VIP=VIP + 1 ;FlatIdent_5AC6=1;end if (FlatIdent_5AC6==2) then Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];FlatIdent_5AC6=3;end if (FlatIdent_5AC6==1) then Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_5AC6=2;end if (FlatIdent_5AC6==3) then Stk[A]=Stk[A]();VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];FlatIdent_5AC6=4;end end end elseif (Enum<=124) then if (Enum<=120) then if (Enum<=118) then if (Enum==117) then Stk[Inst[2]]=Stk[Inst[3]]%Stk[Inst[4]] ;else for Idx=Inst[2],Inst[3] do Stk[Idx]=nil;end VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];for Idx=Inst[2],Inst[3] do Stk[Idx]=nil;end VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]={};VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Stk[Inst[3]]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];end elseif (Enum>119) then Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];elseif (Stk[Inst[2]]~=Inst[4]) then VIP=VIP + 1 ;else VIP=Inst[3];end elseif (Enum<=122) then if (Enum>121) then local T;local VA;local A;Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]={};VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]={};VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Top=(A + Varargsz) -1 ;for Idx=A,Top do VA=Vararg[Idx-A ];Stk[Idx]=VA;end VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];T=Stk[A];for Idx=A + 1 ,Top do Insert(T,Stk[Idx]);end else local A;Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A]();VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] -Inst[4] ;VIP=VIP + 1 ;Inst=Instr[VIP];do return Stk[Inst[2]];end VIP=VIP + 1 ;Inst=Instr[VIP];do return;end end elseif (Enum>123) then local FlatIdent_33B1E=0;local Results;local Edx;local Limit;local A;while true do if (FlatIdent_33B1E==9) then A=Inst[2];Results={Stk[A](Unpack(Stk,A + 1 ,Top))};Edx=0;for Idx=A,Inst[4] do Edx=Edx + 1 ;Stk[Idx]=Results[Edx];end FlatIdent_33B1E=10;end if (2==FlatIdent_33B1E) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;FlatIdent_33B1E=3;end if (FlatIdent_33B1E==3) then Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_33B1E=4;end if (FlatIdent_33B1E==0) then Results=nil;Edx=nil;Results,Limit=nil;A=nil;FlatIdent_33B1E=1;end if (FlatIdent_33B1E==8) then Edx=0;for Idx=A,Top do Edx=Edx + 1 ;Stk[Idx]=Results[Edx];end VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_33B1E=9;end if (FlatIdent_33B1E==4) then Stk[Inst[2]]=Stk[Inst[3]] + Inst[4] ;VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];FlatIdent_33B1E=5;end if (FlatIdent_33B1E==10) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;FlatIdent_33B1E=11;end if (12==FlatIdent_33B1E) then Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;Inst=Instr[VIP];VIP=Inst[3];break;end if (5==FlatIdent_33B1E) then VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Results,Limit=_R(Stk[A](Unpack(Stk,A + 1 ,Inst[3])));FlatIdent_33B1E=6;end if (1==FlatIdent_33B1E) then Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];FlatIdent_33B1E=2;end if (FlatIdent_33B1E==7) then Inst=Instr[VIP];A=Inst[2];Results,Limit=_R(Stk[A](Unpack(Stk,A + 1 ,Top)));Top=(Limit + A) -1 ;FlatIdent_33B1E=8;end if (6==FlatIdent_33B1E) then Top=(Limit + A) -1 ;Edx=0;for Idx=A,Top do Edx=Edx + 1 ;Stk[Idx]=Results[Edx];end VIP=VIP + 1 ;FlatIdent_33B1E=7;end if (FlatIdent_33B1E==11) then Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_33B1E=12;end end else local FlatIdent_62271=0;local A;while true do if (FlatIdent_62271==0) then A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));break;end end end elseif (Enum<=128) then if (Enum<=126) then if (Enum>125) then local FlatIdent_7F9F4=0;while true do if (FlatIdent_7F9F4==6) then if  not Stk[Inst[2]] then VIP=VIP + 1 ;else VIP=Inst[3];end break;end if (FlatIdent_7F9F4==2) then Inst=Instr[VIP];Stk[Inst[2]]=Env[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_7F9F4=3;end if (FlatIdent_7F9F4==5) then Inst=Instr[VIP];Stk[Inst[2]]=Env[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_7F9F4=6;end if (FlatIdent_7F9F4==4) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;FlatIdent_7F9F4=5;end if (FlatIdent_7F9F4==3) then Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Env[Inst[3]];FlatIdent_7F9F4=4;end if (FlatIdent_7F9F4==0) then Stk[Inst[2]]={};VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Env[Inst[3]];FlatIdent_7F9F4=1;end if (FlatIdent_7F9F4==1) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;FlatIdent_7F9F4=2;end end else Stk[Inst[2]]=Stk[Inst[3]] * Stk[Inst[4]] ;end elseif (Enum>127) then local FlatIdent_3423=0;local Edx;local Results;local Limit;local A;while true do if (FlatIdent_3423==9) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] + Inst[4] ;VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Results,Limit=_R(Stk[A](Unpack(Stk,A + 1 ,Inst[3])));FlatIdent_3423=10;end if (0==FlatIdent_3423) then Edx=nil;Results,Limit=nil;A=nil;Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];FlatIdent_3423=1;end if (FlatIdent_3423==3) then Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] + Inst[4] ;VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];FlatIdent_3423=4;end if (4==FlatIdent_3423) then Results,Limit=_R(Stk[A](Unpack(Stk,A + 1 ,Inst[3])));Top=(Limit + A) -1 ;Edx=0;for Idx=A,Top do local FlatIdent_6FC5B=0;while true do if (FlatIdent_6FC5B==0) then Edx=Edx + 1 ;Stk[Idx]=Results[Edx];break;end end end VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];FlatIdent_3423=5;end if (1==FlatIdent_3423) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;FlatIdent_3423=2;end if (FlatIdent_3423==10) then Top=(Limit + A) -1 ;Edx=0;for Idx=A,Top do Edx=Edx + 1 ;Stk[Idx]=Results[Edx];end VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Results,Limit=_R(Stk[A](Unpack(Stk,A + 1 ,Top)));FlatIdent_3423=11;end if (FlatIdent_3423==2) then Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_3423=3;end if (5==FlatIdent_3423) then Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Top));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];FlatIdent_3423=6;end if (FlatIdent_3423==8) then Stk[Inst[2]]= #Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]]%Stk[Inst[4]] ;VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3] + Stk[Inst[4]] ;FlatIdent_3423=9;end if (FlatIdent_3423==12) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]]%Inst[4] ;VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Results,Limit=_R(Stk[A](Stk[A + 1 ]));FlatIdent_3423=13;end if (FlatIdent_3423==11) then Top=(Limit + A) -1 ;Edx=0;for Idx=A,Top do Edx=Edx + 1 ;Stk[Idx]=Results[Edx];end VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Top));FlatIdent_3423=12;end if (FlatIdent_3423==13) then Top=(Limit + A) -1 ;Edx=0;for Idx=A,Top do local FlatIdent_6D84C=0;while true do if (FlatIdent_6D84C==0) then Edx=Edx + 1 ;Stk[Idx]=Results[Edx];break;end end end VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A](Unpack(Stk,A + 1 ,Top));break;end if (FlatIdent_3423==6) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]= #Stk[Inst[3]];VIP=VIP + 1 ;FlatIdent_3423=7;end if (7==FlatIdent_3423) then Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]]%Stk[Inst[4]] ;VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3] + Stk[Inst[4]] ;VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_3423=8;end end else local FlatIdent_21811=0;while true do if (FlatIdent_21811==4) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] + Inst[4] ;VIP=VIP + 1 ;FlatIdent_21811=5;end if (FlatIdent_21811==1) then VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;FlatIdent_21811=2;end if (FlatIdent_21811==0) then Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];FlatIdent_21811=1;end if (FlatIdent_21811==3) then Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Stk[Inst[3]]]=Stk[Inst[4]];FlatIdent_21811=4;end if (5==FlatIdent_21811) then Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_21811=6;end if (FlatIdent_21811==6) then Stk[Inst[2]]=Inst[3];break;end if (2==FlatIdent_21811) then Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_21811=3;end end end elseif (Enum<=130) then if (Enum==129) then local Edx;local Results,Limit;local A;Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] + Inst[4] ;VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Results,Limit=_R(Stk[A](Unpack(Stk,A + 1 ,Inst[3])));Top=(Limit + A) -1 ;Edx=0;for Idx=A,Top do local FlatIdent_44005=0;while true do if (FlatIdent_44005==0) then Edx=Edx + 1 ;Stk[Idx]=Results[Edx];break;end end end VIP=VIP + 1 ;Inst=Instr[VIP];A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Top));VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]][Stk[Inst[3]]]=Stk[Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] + Inst[4] ;VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]][Stk[Inst[4]]];VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]();VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Stk[Inst[3]] + Inst[4] ;VIP=VIP + 1 ;Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];else local A=Inst[2];do return Stk[A](Unpack(Stk,A + 1 ,Inst[3]));end end elseif (Enum<=131) then Stk[Inst[2]]=Wrap(Proto[Inst[3]],nil,Env);elseif (Enum>132) then Stk[Inst[2]][Stk[Inst[3]]]=Stk[Inst[4]];else local FlatIdent_5D1D5=0;local Step;local Index;local A;while true do if (FlatIdent_5D1D5==0) then Step=nil;Index=nil;A=nil;FlatIdent_5D1D5=1;end if (FlatIdent_5D1D5==1) then Stk[Inst[2]]= #Stk[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_5D1D5=2;end if (FlatIdent_5D1D5==5) then Inst=Instr[VIP];A=Inst[2];Index=Stk[A];FlatIdent_5D1D5=6;end if (4==FlatIdent_5D1D5) then Inst=Instr[VIP];Stk[Inst[2]]=Inst[3];VIP=VIP + 1 ;FlatIdent_5D1D5=5;end if (FlatIdent_5D1D5==2) then Stk[Inst[2]]=Upvalues[Inst[3]];VIP=VIP + 1 ;Inst=Instr[VIP];FlatIdent_5D1D5=3;end if (FlatIdent_5D1D5==3) then A=Inst[2];Stk[A]=Stk[A]();VIP=VIP + 1 ;FlatIdent_5D1D5=4;end if (FlatIdent_5D1D5==6) then Step=Stk[A + 2 ];if (Step>0) then if (Index>Stk[A + 1 ]) then VIP=Inst[3];else Stk[A + 3 ]=Index;end elseif (Index<Stk[A + 1 ]) then VIP=Inst[3];else Stk[A + 3 ]=Index;end break;end end end VIP=VIP + 1 ;end end;end return Wrap(Deserialize(),{},vmenv)(...);end return VMCall("LOL!783Q0003063Q00737472696E6703043Q006368617203043Q00627974652Q033Q0073756203053Q0062697433322Q033Q0062697403043Q0062786F7203053Q007461626C6503063Q00636F6E63617403063Q00696E73657274026Q004E400362012Q00C7ECCC9811BF90D18911BB90B0F812DA93B08F62BDE5B68817BF94B38E15BC91B68017CE95B78912BB97B3E811BB95B78F10BDE7B68C11B893B78A70BB93B48113DA94B48E11BF94B68C16BF93B38D60B8F2B08917B391D18E15BC93B78A12CA91D18B67BC91B68816BC91C58F16BD9AB78D17B394B58F13BC96B78A17BE94B28F12BDE5B6FC16BF95B58F64BC97B2FC17B895C68F65B9E5B4FB17CD95B18F62BD92B38E12BF90B38B67BFE1B6FF17BA95C38F10B894B2FF16B995B58F17BC90B2FF17B395B58F10BD97B78A13CD95C48F10BD9AB6FC13CD97C48F10BD9AB6FC13CE95C38E14BD92B08911B297D18911BB96B7E811BB92B28B70BB93B08811BB93B18A70BB93B18B13DA93B08913BB93B08B12DA93B08B11B9F2B08911B993B08913BB93B08A11BB92B28B70BB93B08D11BB93B48F70BB93B08B11BB93B48F70BB93B08812DA93B08913BFF2B08911BA93B08910BB93B08817DA93B08910BCF2B08903053Q00218BA380B9026Q004C4003043Q005EFE21B703063Q00E26ECD10846B025Q00804B402Q033Q002A1FA003073Q00B74476CC815190026Q004B402Q033Q0043189503083Q00CB3B60ED6B456F71025Q00804A402Q033Q006710BB03063Q00AE5629937013026Q004A402Q033Q00D571EE03073Q00D2E448C6A1B833026Q00494003043Q008FBFFD8E03053Q0093BF87CEB8025Q008048402Q033Q002F485C03073Q004341213064973C026Q00484003043Q008D8CD87E03073Q0034B2E5BC43E7C9025Q008047402Q033Q00E6921203083Q002DCBA32B26232A5B026Q0047402Q033Q0038BB4803073Q006E59C82C78A082025Q008046402Q033Q0049457A03073Q00C270745295B6CE026Q00444003043Q00ED0D419303083Q003E857935E37F6D4F025Q0080434003043Q00D2160C0903073Q003EE22E2Q3FD0A9025Q008042402Q033Q00B966E603053Q00EDD8158295026Q0042402Q033Q00A25A6103083Q001693634970E23878026Q002Q402Q033Q0025A66103063Q00C41C97495653026Q003D402Q033Q004E972E03043Q002C63A617026Q00394003023Q00A0B903043Q00508E97C2026Q00384003083Q000EBA861817B78D1F03043Q006D7AD5E8026Q00364003053Q00CEEA75E48E03063Q00A7BA8B1788EB026Q00354003063Q00CBA9D5DC70FA03083Q006EBEC7A5BD13913D026Q00344003063Q0051EB558541FA03043Q00E0228E39026Q00334003053Q0090FF837A3C03083Q0076E09CE2165088D6026Q003240030C3Q005549D5AEF3DC4758C0A1FACD03063Q00A8262CA1C396026Q00314003073Q0080F11020A789E203053Q00C2E7946446026Q002E4003043Q00E1A917CC03053Q003C8CC863A4026Q002A4003053Q00241F82144403053Q0021507EE078026Q00264003053Q0044A0F72F4103063Q004E30C1954324026Q00224003063Q00150B40CEA27503073Q00EB667F32A7CC12026Q001C4003063Q0013671076450903073Q00EA6013621F2B6E026Q00144003063Q00B70D1EB34BAF03083Q0050C4796CDA25C8D5026Q00084003063Q009F2856EB5D0503063Q0062EC5C248233026Q00F03F03063Q0038063A5C858003073Q00A24B724835EBE7028Q0003083Q003DD0D894F24B203B03073Q004549BFB6E19F2903023Q005F4703043Q00677375622Q033Q0072657003053Q006C6465787003063Q00756E7061636B0019013Q007E7Q00122Q000100013Q00202Q00010001000200122Q000200013Q00202Q00020002000300122Q000300013Q00202Q00030003000400122Q000400053Q00062Q0004000B0001000100042F3Q000B0001001272000400063Q002050000500040007001272000600083Q002050000600060009001272000700083Q00205000070007000A00066200083Q000100062Q00273Q00074Q00273Q00014Q00273Q00054Q00273Q00024Q00273Q00034Q00273Q00064Q0008000900083Q00122Q000A000C3Q00122Q000B000D6Q0009000B000200104Q000B00094Q000900083Q00122Q000A000F3Q00122Q000B00106Q0009000B000200104Q000E00094Q000900083Q00122Q000A00123Q00122Q000B00136Q0009000B000200104Q001100094Q000900083Q00122Q000A00153Q00122Q000B00166Q0009000B000200104Q001400094Q000900083Q00122Q000A00183Q00122Q000B00196Q0009000B000200104Q001700094Q000900083Q00122Q000A001B3Q00122Q000B001C6Q0009000B000200104Q001A00094Q000900083Q00122Q000A001E3Q00122Q000B001F6Q0009000B000200104Q001D00094Q000900083Q00122Q000A00213Q00122Q000B00226Q0009000B000200104Q002000094Q000900083Q00122Q000A00243Q00122Q000B00256Q0009000B000200104Q002300094Q000900083Q00122Q000A00273Q00122Q000B00286Q0009000B000200104Q002600094Q000900083Q00122Q000A002A3Q00122Q000B002B6Q0009000B000200104Q002900094Q000900083Q00122Q000A002D3Q00122Q000B002E6Q0009000B000200104Q002C00094Q000900083Q00122Q000A00303Q00122Q000B00316Q0009000B000200104Q002F00094Q000900083Q00122Q000A00333Q00122Q000B00346Q0009000B000200104Q003200094Q000900083Q00122Q000A00363Q00122Q000B00376Q0009000B000200104Q003500094Q000900083Q00122Q000A00393Q00122Q000B003A6Q0009000B000200104Q003800092Q0008000900083Q00122Q000A003C3Q00122Q000B003D6Q0009000B000200104Q003B00094Q000900083Q00122Q000A003F3Q00122Q000B00406Q0009000B000200104Q003E00094Q000900083Q00122Q000A00423Q00122Q000B00436Q0009000B000200104Q004100094Q000900083Q00122Q000A00453Q00122Q000B00466Q0009000B000200104Q004400094Q000900083Q00122Q000A00483Q00122Q000B00496Q0009000B000200104Q004700094Q000900083Q00122Q000A004B3Q00122Q000B004C6Q0009000B000200104Q004A00094Q000900083Q00122Q000A004E3Q00122Q000B004F6Q0009000B000200104Q004D00094Q000900083Q00122Q000A00513Q00122Q000B00526Q0009000B000200104Q005000094Q000900083Q00122Q000A00543Q00122Q000B00556Q0009000B000200104Q005300094Q000900083Q00122Q000A00573Q00122Q000B00586Q0009000B000200104Q005600094Q000900083Q00122Q000A005A3Q00122Q000B005B6Q0009000B000200104Q005900094Q000900083Q00122Q000A005D3Q00122Q000B005E6Q0009000B000200104Q005C00094Q000900083Q00122Q000A00603Q00122Q000B00616Q0009000B000200104Q005F00094Q000900083Q00122Q000A00633Q00122Q000B00646Q0009000B000200104Q006200094Q000900083Q00122Q000A00663Q00122Q000B00676Q0009000B000200104Q006500094Q000900083Q00122Q000A00693Q00122Q000B006A6Q0009000B000200104Q006800092Q0041000900083Q00122Q000A006C3Q00122Q000B006D6Q0009000B000200104Q006B00094Q000900083Q00122Q000A006F3Q00122Q000B00706Q0009000B000200104Q006E00092Q0027000900083Q001231000A00723Q00122Q000B00736Q0009000B000200104Q0071000900122Q000900743Q00202Q000A3Q00714Q00090009000A00122Q000A00743Q00202Q000B3Q006E4Q000A000A000B002052000A000A000300122Q000B00743Q00202Q000C3Q006B4Q000B000B000C00202Q000B000B000200122Q000C00743Q00202Q000D3Q00684Q000C000C000D00202Q000C000C000400122Q000D00743Q002050000E3Q00652Q0054000D000D000E002052000D000D007500122Q000E00743Q00202Q000F3Q00624Q000E000E000F00202Q000E000E007600122Q000F00743Q00202Q00103Q005F4Q000F000F001000202Q000F000F000900122Q001000743Q00205000113Q005C2Q002300100010001100202Q00100010000A00122Q001100743Q00202Q00123Q00594Q00110011001200202Q00110011007700122Q001200743Q00202Q00133Q00564Q00120012001300062Q001200EF0001000100042F3Q00EF0001000283001200013Q001272001300743Q00206500143Q00534Q00130013001400122Q001400743Q00202Q00153Q00504Q00140014001500122Q001500743Q00202Q00163Q004D4Q00150015001600122Q001600743Q00202Q00173Q004A2Q00540016001600170006530016003Q01000100042F3Q003Q01001272001600743Q00205000173Q00472Q0054001600160017002050001600160078001272001700743Q00205000183Q00442Q0054001700170018000662001800020001000B2Q00273Q000D4Q00273Q000C4Q00278Q00273Q000A4Q00273Q00094Q00273Q000B4Q00273Q000E4Q00273Q00114Q00273Q000F4Q00273Q00154Q00273Q00164Q0038001900183Q00202Q001A3Q000B4Q001B00126Q001B000100024Q001C8Q00198Q00198Q00099Q0000013Q00033Q00023Q00026Q00F03F026Q00704002264Q005900025Q00122Q000300016Q00045Q00122Q000500013Q00042Q0003002100012Q001200076Q0080000800026Q000900016Q000A00026Q000B00036Q000C00046Q000D8Q000E00063Q00202Q000F000600014Q000C000F6Q000B3Q00024Q000C00036Q000D00046Q000E00016Q000F00016Q000F0006000F00102Q000F0001000F4Q001000016Q00100006001000102Q00100001001000202Q0010001000014Q000D00106Q000C8Q000A3Q000200202Q000A000A00024Q0009000A6Q00073Q00010004400003000500012Q0012000300054Q0027000400024Q0082000300044Q004F00036Q002A3Q00017Q00013Q0003043Q005F454E5600033Q0012723Q00014Q00563Q00024Q002A3Q00017Q00033Q00026Q00F03F026Q001440026Q00394002453Q00122B000300016Q000400046Q00058Q000600016Q00075Q00122Q000800026Q0006000800024Q000700023Q00202Q00070007000300066200083Q000100062Q00123Q00034Q00273Q00044Q00123Q00044Q00123Q00014Q00123Q00054Q00123Q00064Q007B0005000800022Q00273Q00053Q000283000500013Q00066200060002000100032Q00123Q00034Q00278Q00273Q00033Q00066200070003000100032Q00123Q00034Q00278Q00273Q00033Q00066200080004000100032Q00123Q00034Q00278Q00273Q00033Q00066200090005000100032Q00273Q00054Q00273Q00084Q00123Q00073Q000662000A0006000100072Q00123Q00084Q00123Q00054Q00123Q00034Q00123Q00014Q00278Q00273Q00034Q00273Q00084Q0027000B00083Q000662000C0007000100012Q00123Q00093Q000662000D0008000100082Q00273Q00084Q00123Q00024Q00273Q00064Q00273Q00094Q00273Q000A4Q00273Q00054Q00273Q00074Q00273Q000D3Q000662000E0009000100032Q00273Q000C4Q00123Q00094Q00123Q000A4Q0018000F000E6Q0010000D6Q0010000100024Q00118Q001200016Q000F001200024Q00108Q000F8Q000F9Q0000013Q000A3Q00063Q00027Q0040025Q00405440028Q00026Q00F03F034Q00026Q00304001474Q005100018Q00025Q00122Q000300016Q00010003000200262Q0001001F0001000200042F3Q001F000100123B000100034Q004C000200023Q00263E000100080001000300042F3Q0008000100123B000200033Q000E420003000B0001000200042F3Q000B000100123B000300033Q000E420003000E0001000300042F3Q000E00012Q0012000400024Q001D000500036Q00065Q00122Q000700043Q00122Q000800046Q000500086Q00043Q00024Q000400013Q00122Q000400056Q000400023Q00044Q000E000100042F3Q000B000100042F3Q0046000100042F3Q0008000100042F3Q0046000100123B000100034Q004C000200023Q00263E000100210001000300042F3Q002100012Q0012000300044Q0049000400026Q00055Q00122Q000600066Q000400066Q00033Q00024Q000200036Q000300013Q00062Q0003004300013Q00042F3Q0043000100123B000300034Q004C000400043Q00123B000500033Q00263E000500300001000300042F3Q0030000100263E000300350001000400042F3Q003500012Q0056000400023Q00263E0003002F0001000300042F3Q002F00012Q0012000600054Q0068000700026Q000800016Q0006000800024Q000400066Q000600066Q000600013Q00122Q000300043Q00044Q002F000100042F3Q0030000100042F3Q002F000100042F3Q004600012Q0056000200023Q00042F3Q0046000100042F3Q002100012Q002A3Q00017Q00033Q00028Q00026Q00F03F027Q0040032D3Q0006100002001800013Q00042F3Q0018000100123B000300014Q004C000400043Q00263E000300040001000100042F3Q0004000100123B000500013Q000E42000100070001000500042F3Q000700010020480006000100020010640006000300064Q00063Q000600202Q00070002000200202Q0008000100024Q00070007000800202Q00070007000200102Q0007000300074Q00040006000700202Q0006000400024Q0006000400064Q000600023Q00044Q0007000100042F3Q0004000100042F3Q002C000100123B000300014Q004C000400043Q00263E0003001A0001000100042F3Q001A000100123B000500013Q000E420001001D0001000500042F3Q001D00010020480006000100020010160004000300062Q004D0006000400042Q007500063Q000600065A000400280001000600042F3Q0028000100123B000600023Q000653000600290001000100042F3Q0029000100123B000600014Q0056000600023Q00042F3Q001D000100042F3Q001A00012Q002A3Q00017Q00023Q00028Q00026Q00F03F00423Q00123B3Q00014Q004C000100033Q00263E3Q00070001000100042F3Q0007000100123B000100014Q004C000200023Q00123B3Q00023Q00263E3Q00020001000200042F3Q000200012Q004C000300033Q00263E000100310001000200042F3Q0031000100123B000400013Q000E420001000D0001000400042F3Q000D000100263E000200120001000200042F3Q001200012Q0056000300023Q00263E0002000C0001000100042F3Q000C000100123B000500014Q004C000600063Q000E42000100160001000500042F3Q0016000100123B000600013Q00263E0006001D0001000200042F3Q001D000100123B000200023Q00042F3Q000C000100263E000600190001000100042F3Q001900012Q001200076Q0011000800016Q000900026Q000A00026Q0007000A00024Q000300076Q000700023Q00202Q00070007000200202Q0007000700014Q000700023Q00122Q000600023Q00044Q0019000100042F3Q000C000100042F3Q0016000100042F3Q000C000100042F3Q000D000100042F3Q000C000100042F3Q0041000100263E0001000A0001000100042F3Q000A000100123B000400013Q000E42000100390001000400042F3Q0039000100123B000200014Q004C000300033Q00123B000400023Q00263E000400340001000200042F3Q0034000100123B000100023Q00042F3Q000A000100042F3Q0034000100042F3Q000A000100042F3Q0041000100042F3Q000200012Q002A3Q00017Q00043Q00028Q00026Q00F03F027Q0040026Q00704000423Q00123B3Q00014Q004C000100033Q00263E3Q000F0001000100042F3Q000F000100123B000400013Q00263E0004000A0001000100042F3Q000A000100123B000100014Q004C000200023Q00123B000400023Q00263E000400050001000200042F3Q0005000100123B3Q00023Q00042F3Q000F000100042F3Q0005000100263E3Q00020001000200042F3Q000200012Q004C000300033Q00123B000400014Q004C000500053Q00263E000400140001000100042F3Q0014000100123B000500013Q000E42000100170001000500042F3Q0017000100263E000100350001000100042F3Q0035000100123B000600014Q004C000700073Q00263E0006001D0001000100042F3Q001D000100123B000700013Q00263E0007002E0001000100042F3Q002E00012Q001200086Q005E000900016Q000A00026Q000B00023Q00202Q000B000B00034Q0008000B00094Q000300096Q000200086Q000800023Q00202Q0008000800034Q000800023Q00122Q000700023Q00263E000700200001000200042F3Q0020000100123B000100023Q00042F3Q0035000100042F3Q0020000100042F3Q0035000100042F3Q001D000100263E000100120001000200042F3Q001200010020700006000300042Q004D0006000600022Q0056000600023Q00042F3Q0012000100042F3Q0017000100042F3Q0012000100042F3Q0014000100042F3Q0012000100042F3Q0041000100042F3Q000200012Q002A3Q00017Q00083Q00028Q00026Q00F03F027Q0040026Q007041026Q00F040026Q007040026Q000840026Q00104000463Q00123B3Q00014Q004C000100053Q00263E3Q000F0001000100042F3Q000F000100123B000600013Q00263E0006000A0001000100042F3Q000A000100123B000100014Q004C000200023Q00123B000600023Q00263E000600050001000200042F3Q0005000100123B3Q00023Q00042F3Q000F000100042F3Q0005000100263E3Q00400001000300042F3Q004000012Q004C000500053Q00123B000600013Q00263E000600130001000100042F3Q00130001000E420002001E0001000100042F3Q001E000100207000070005000400202D0008000400054Q00070007000800202Q0008000300064Q0007000700084Q0007000700024Q000700023Q00263E000100120001000100042F3Q0012000100123B000700014Q004C000800083Q00263E000700220001000100042F3Q0022000100123B000800013Q00263E000800290001000200042F3Q0029000100123B000100023Q00042F3Q0012000100263E000800250001000100042F3Q002500012Q001200096Q002C000A00016Q000B00026Q000C00023Q00202Q000C000C00074Q0009000C000C4Q0005000C6Q0004000B6Q0003000A6Q000200096Q000900023Q00202Q0009000900084Q000900023Q00122Q000800023Q00044Q0025000100042F3Q0012000100042F3Q0022000100042F3Q0012000100042F3Q0013000100042F3Q0012000100042F3Q0045000100263E3Q00020001000200042F3Q000200012Q004C000300043Q00123B3Q00033Q00042F3Q000200012Q002A3Q00017Q000E3Q00028Q00026Q000840027Q0040026Q00F03F026Q003540026Q003F40026Q002Q40026Q00F0BF026Q003440026Q00F041025Q00FC9F402Q033Q004E614E025Q00F88F40026Q00304300813Q00123B3Q00014Q004C000100073Q00263E3Q00720001000200042F3Q007200012Q004C000700073Q00123B000800013Q00263E000800370001000100042F3Q0037000100263E000100230001000300042F3Q0023000100123B000900013Q00263E0009000F0001000400042F3Q000F000100123B000100023Q00042F3Q0023000100263E0009000B0001000100042F3Q000B00012Q0012000A8Q000B00033Q00122Q000C00053Q00122Q000D00066Q000A000D00024Q0006000A6Q000A8Q000B00033Q00122Q000C00076Q000A000C000200262Q000A00200001000400042F3Q0020000100123B000A00083Q000637000700210001000A00042F3Q0021000100123B000700043Q00123B000900043Q00042F3Q000B000100263E000100360001000400042F3Q0036000100123B000900013Q00263E0009002A0001000400042F3Q002A000100123B000100033Q00042F3Q0036000100263E000900260001000100042F3Q0026000100123B000400044Q005D000A8Q000B00033Q00122Q000C00043Q00122Q000D00096Q000A000D000200202Q000A000A000A4Q0005000A000200122Q000900043Q00044Q0026000100123B000800043Q00263E000800060001000400042F3Q00060001000E420001004A0001000100042F3Q004A000100123B000900013Q00263E000900400001000400042F3Q0040000100123B000100043Q00042F3Q004A000100263E0009003C0001000100042F3Q003C00012Q0012000A00014Q0074000A000100024Q0002000A6Q000A00016Q000A000100024Q0003000A3Q00122Q000900043Q00044Q003C000100263E000100050001000200042F3Q0005000100263E0006005B0001000100042F3Q005B000100263E000500530001000100042F3Q005300010020700009000700012Q0056000900023Q00042F3Q0066000100123B000900013Q00263E000900540001000100042F3Q0054000100123B000600043Q00123B000400013Q00042F3Q0066000100042F3Q0054000100042F3Q0066000100263E000600660001000B00042F3Q0066000100263E000500630001000100042F3Q0063000100304A0009000400012Q007D000900070009000653000900650001000100042F3Q006500010012720009000C4Q007D0009000700092Q0056000900024Q0012000900024Q0024000A00073Q00202Q000B0006000D4Q0009000B000200202Q000A0005000E4Q000A0004000A4Q00090009000A4Q000900023Q00044Q0005000100042F3Q0006000100042F3Q0005000100042F3Q0080000100263E3Q00760001000300042F3Q007600012Q004C000500063Q00123B3Q00023Q00263E3Q007A0001000400042F3Q007A00012Q004C000300043Q00123B3Q00033Q00263E3Q00020001000100042F3Q0002000100123B000100014Q004C000200023Q00123B3Q00043Q00042F3Q000200012Q002A3Q00017Q00053Q00028Q00026Q00F03F026Q000840027Q0040034Q00017A3Q00123B000100014Q004C000200043Q00263E000100070001000100042F3Q0007000100123B000200014Q004C000300033Q00123B000100023Q00263E000100020001000200042F3Q000200012Q004C000400043Q00123B000500013Q000E42000200360001000500042F3Q0036000100263E000200130001000300042F3Q001300012Q001200066Q0027000700044Q0082000600074Q004F00065Q00263E0002000A0001000400042F3Q000A000100123B000600014Q004C000700073Q00263E000600170001000100042F3Q0017000100123B000700013Q00263E0007002E0001000100042F3Q002E00012Q000E00086Q000F000400083Q00122Q000800026Q000900033Q00122Q000A00023Q00042Q0008002D00012Q0012000C00014Q0003000D00026Q000E00036Q000F00036Q0010000B6Q0011000B6Q000E00116Q000D8Q000C3Q00024Q0004000B000C00044000080022000100123B000700023Q00263E0007001A0001000200042F3Q001A000100123B000200033Q00042F3Q000A000100042F3Q001A000100042F3Q000A000100042F3Q0017000100042F3Q000A000100263E0005000B0001000100042F3Q000B000100263E000200540001000200042F3Q0054000100123B000600014Q004C000700073Q00263E0006003C0001000100042F3Q003C000100123B000700013Q00263E000700430001000200042F3Q0043000100123B000200043Q00042F3Q0054000100263E0007003F0001000100042F3Q003F00012Q0012000800034Q0044000900046Q000A00056Q000B00056Q000B000B3Q00202Q000B000B00024Q0008000B00024Q000300086Q000800056Q000800086Q000800053Q00122Q000700023Q00044Q003F000100042F3Q0054000100042F3Q003C000100263E000200740001000100042F3Q0074000100123B000600013Q00263E0006006F0001000100042F3Q006F00012Q004C000300033Q0006533Q006E0001000100042F3Q006E000100123B000700014Q004C000800083Q00263E0007005E0001000100042F3Q005E000100123B000800013Q00263E000800610001000100042F3Q006100012Q0012000900064Q00040009000100022Q00273Q00093Q00263E3Q006E0001000100042F3Q006E000100123B000900054Q0056000900023Q00042F3Q006E000100042F3Q0061000100042F3Q006E000100042F3Q005E000100123B000600023Q00263E000600570001000200042F3Q0057000100123B000200023Q00042F3Q0074000100042F3Q0057000100123B000500023Q00042F3Q000B000100042F3Q000A000100042F3Q0079000100042F3Q000200012Q002A3Q00017Q00013Q0003013Q002300094Q000E00016Q000100026Q000500013Q00012Q001200025Q00122E000300016Q00048Q00028Q00019Q0000017Q001A3Q00028Q00026Q00F03F027Q0040026Q000840026Q001040026Q003D4003013Q003C03013Q0020026Q002Q4003013Q002F03013Q005B026Q004240025Q0080424003013Q007E025Q0080434003013Q003E03013Q003A025Q00804640025Q00804840026Q004940026Q004A40025Q00804A40026Q004B40025Q00804B40026Q004C4003013Q007D00F0022Q00123B3Q00014Q004C000100083Q00263E3Q00130001000100042F3Q0013000100123B000900013Q00263E000900090001000200042F3Q0009000100123B3Q00023Q00042F3Q00130001000E42000100050001000900042F3Q00050001000283000A6Q0004000A000100022Q00270001000A3Q000283000A00014Q0004000A000100022Q00270002000A3Q00123B000900023Q00042F3Q0005000100263E3Q00240001000300042F3Q0024000100123B000900013Q00263E0009001F0001000100042F3Q001F0001000283000A00024Q0004000A000100022Q00270005000A3Q000283000A00034Q0004000A000100022Q00270006000A3Q00123B000900023Q000E42000200160001000900042F3Q0016000100123B3Q00043Q00042F3Q0024000100042F3Q0016000100263E3Q00350001000400042F3Q0035000100123B000900013Q00263E000900300001000100042F3Q00300001000283000A00044Q0004000A000100022Q00270007000A3Q000283000A00054Q0004000A000100022Q00270008000A3Q00123B000900023Q00263E000900270001000200042F3Q0027000100123B3Q00053Q00042F3Q0035000100042F3Q0027000100263E3Q00E50201000500042F3Q00E50201000283000900064Q00040009000100020026770009003C0001000200042F3Q003C000100042F3Q00202Q010026770001003F0001000200042F3Q003F000100042F3Q006A000100123B000A00014Q004C000B000B3Q00263E000A00410001000100042F3Q00410001000283000C00074Q0004000C000100022Q0027000B000C3Q002677000B00490001000200042F3Q0049000100042F3Q00510001000662000C0008000100012Q00128Q0004000C000100022Q00270007000C3Q000283000C00094Q0004000C000100022Q00270001000C3Q00042F3Q006A000100263E000B00460001000100042F3Q0046000100123B000C00013Q00263E000C005A0001000200042F3Q005A0001000283000D000A4Q0004000D000100022Q0027000B000D3Q00042F3Q0046000100263E000C00540001000100042F3Q00540001000283000D000B4Q0004000D000100022Q00270005000D3Q000662000D000C000100032Q00273Q00034Q00273Q00044Q00273Q00054Q0004000D000100022Q00270006000D3Q00123B000C00023Q00042F3Q0054000100042F3Q0046000100042F3Q006A000100042F3Q00410001000E42000300370001000100042F3Q00370001000283000A000D4Q0004000A00010002000E420002007B0001000A00042F3Q007B00012Q0012000B00013Q002050000B000B00062Q0015000B000B3Q000662000C000E000100012Q00123Q00024Q0004000C000100022Q00850006000B000C000283000B000F4Q0004000B000100022Q00270001000B3Q00042F3Q00370001002677000A007E0001000100042F3Q007E000100042F3Q006E0001000283000B00104Q0006000B000100024Q0008000B3Q00122Q000B00076Q000B000B6Q000C00073Q00122Q000D00023Q00042Q000B001B2Q0100123B000F00014Q004C001000133Q000E42000200990001000F00042F3Q0099000100123B001400013Q00263E001400940001000100042F3Q00940001000283001500114Q00040015000100022Q0027001200153Q000283001500124Q00040015000100022Q0027001300153Q00123B001400023Q00263E0014008B0001000200042F3Q008B000100123B000F00033Q00042F3Q0099000100042F3Q008B0001000E42000100AA0001000F00042F3Q00AA000100123B001400013Q00263E001400A50001000100042F3Q00A50001000283001500134Q00040015000100022Q0027001000153Q000283001500144Q00040015000100022Q0027001100153Q00123B001400023Q00263E0014009C0001000200042F3Q009C000100123B000F00023Q00042F3Q00AA000100042F3Q009C000100263E000F00880001000300042F3Q0088000100263E001000D80001000100042F3Q00D8000100123B001400014Q004C001500153Q00263E001400B00001000100042F3Q00B00001000283001600154Q00040016000100022Q0027001500163Q002677001500B80001000200042F3Q00B8000100042F3Q00BC0001000283001600164Q00040016000100022Q0027001000163Q00042F3Q00D8000100263E001500B50001000100042F3Q00B5000100123B001600014Q004C001700173Q00263E001600C00001000100042F3Q00C0000100123B001700013Q00263E001700CC0001000100042F3Q00CC0001000283001800174Q00040018000100022Q0027001100183Q000283001800184Q00040018000100022Q0027001200183Q00123B001700023Q00263E001700C30001000200042F3Q00C30001000283001800194Q00040018000100022Q0027001500183Q00042F3Q00B5000100042F3Q00C3000100042F3Q00B5000100042F3Q00C0000100042F3Q00B5000100042F3Q00D8000100042F3Q00B0000100263E001000AC0001000200042F3Q00AC00010002830014001A4Q00040014000100022Q0027001300143Q002677001100E00001000200042F3Q00E0000100042F3Q00FF000100123B001400084Q0015001400143Q00064B001200E90001001400042F3Q00E900010006620014001B000100012Q00123Q00024Q00040014000100022Q0027001300143Q00042F3Q00FA000100263E001200F00001000300042F3Q00F000010006620014001C000100012Q00123Q00034Q00040014000100022Q0027001300143Q00042F3Q00FA00012Q0012001400013Q0020500014001400092Q0015001400143Q000671001200F60001001400042F3Q00F6000100042F3Q00FA00010006620014001D000100012Q00123Q00044Q00040014000100022Q0027001300143Q0006620014001E000100012Q00273Q00134Q00040014000100022Q00850008000E001400042F3Q00192Q01002677001100022Q01000100042F3Q00022Q0100042F3Q00DD000100123B001400013Q00263E0014000D2Q01000100042F3Q000D2Q010006620015001F000100012Q00123Q00024Q00040015000100022Q0027001200153Q000283001500204Q00040015000100022Q0027001300153Q00123B001400023Q000E42000200032Q01001400042F3Q00032Q01000283001500214Q00040015000100022Q0027001100153Q00042F3Q00DD000100042F3Q00032Q0100042F3Q00DD000100042F3Q00192Q0100042F3Q00AC000100042F3Q00192Q0100042F3Q008800012Q0073000F5Q000440000B00860001000283000B00224Q0004000B000100022Q0027000A000B3Q00042F3Q006E000100042F3Q0037000100263E000900390001000100042F3Q0039000100263E0001009A0201000400042F3Q009A020100123B000A000A4Q001A000A000A6Q000B8Q000B0001000200122Q000C00023Q00042Q000A00880201000662000E0023000100012Q00123Q00024Q0022000E000100024Q000F00056Q0010000E3Q00122Q0011000B6Q001100113Q00122Q001200076Q001200126Q000F0012000200262Q000F00860201000100042F3Q0086020100123B000F00014Q004C001000133Q000E42000300620201000F00042F3Q0062020100263E001000572Q01000400042F3Q00572Q012Q0012001400054Q003D001500126Q001600013Q00202Q00160016000C4Q001600166Q001700013Q00202Q00170017000D4Q001700176Q00140017000200122Q0015000E6Q001500153Q00062Q001400522Q01001500042F3Q00522Q012Q0012001400013Q00205000140014000F2Q0015001400143Q00066200150024000100032Q00273Q00084Q00273Q00134Q00123Q00014Q00040015000100022Q008500130014001500066200140025000100012Q00273Q00134Q00040014000100022Q00850003000D001400042F3Q0085020100263E0010007E2Q01000300042F3Q007E2Q012Q0012001400054Q0013001500123Q00122Q001600106Q001600163Q00122Q0017000E6Q001700176Q00140017000200122Q001500086Q001500153Q00062Q001400692Q01001500042F3Q00692Q0100066200140026000100022Q00273Q00084Q00273Q00134Q00040014000100020010780013000300142Q0012001400054Q0047001500123Q00122Q001600033Q00122Q001700036Q00140017000200122Q001500116Q001500153Q00062Q0014007B2Q01001500042F3Q007B2Q012Q0012001400013Q0020500014001400122Q0015001400143Q00066200150027000100032Q00273Q00084Q00273Q00134Q00123Q00014Q00040015000100022Q0085001300140015000283001400284Q00040014000100022Q0027001000143Q00263E001000CB2Q01000100042F3Q00CB2Q0100123B001400014Q004C001500163Q00263E0014008B2Q01000100042F3Q008B2Q01000283001700294Q00040017000100022Q0027001500173Q0002830017002A4Q00040017000100022Q0027001600173Q00123B001400023Q00263E001400822Q01000200042F3Q00822Q0100263E0015008D2Q01000100042F3Q008D2Q010002830017002B4Q00040017000100022Q0027001600173Q002677001600952Q01000100042F3Q00952Q0100042F3Q00BF2Q0100123B001700014Q004C001800183Q00263E001700972Q01000100042F3Q00972Q010002830019002C4Q00040019000100022Q0027001800193Q0026770018009F2Q01000100042F3Q009F2Q0100042F3Q00B62Q0100123B001900013Q000E42000200A62Q01001900042F3Q00A62Q01000283001A002D4Q0004001A000100022Q00270018001A3Q00042F3Q00B62Q0100263E001900A02Q01000100042F3Q00A02Q01000662001A002E000100032Q00123Q00054Q00273Q000E4Q00123Q00014Q0004001A000100022Q00270011001A3Q000662001A002F000100032Q00123Q00054Q00273Q000E4Q00123Q00014Q0004001A000100022Q00270012001A3Q00123B001900023Q00042F3Q00A02Q0100263E0018009C2Q01000200042F3Q009C2Q01000283001900304Q00040019000100022Q0027001600193Q00042F3Q00BF2Q0100042F3Q009C2Q0100042F3Q00BF2Q0100042F3Q00972Q01000E1F000200C22Q01001600042F3Q00C22Q0100042F3Q00922Q01000283001700314Q00040017000100022Q0027001000173Q00042F3Q00CB2Q0100042F3Q00922Q0100042F3Q00CB2Q0100042F3Q008D2Q0100042F3Q00CB2Q0100042F3Q00822Q0100263E0010003A2Q01000200042F3Q003A2Q01000283001400324Q000400140001000200263E001400590201000100042F3Q0059020100066200150033000100012Q00123Q00064Q00040015000100022Q0027001300153Q00263E001100120201000100042F3Q0012020100123B001500014Q004C001600183Q000E42000100DE2Q01001500042F3Q00DE2Q0100123B001600014Q004C001700173Q00123B001500023Q000E42000200D92Q01001500042F3Q00D92Q012Q004C001800183Q00263E001600FD2Q01000200042F3Q00FD2Q0100263E001700E32Q01000100042F3Q00E32Q01000283001900344Q00040019000100022Q0027001800193Q00263E001800E82Q01000100042F3Q00E82Q012Q0012001900013Q0020500019001900132Q0015001900193Q000662001A0035000100012Q00123Q00064Q0033001A000100024Q00130019001A4Q001900013Q00202Q0019001900144Q001900193Q000662001A0036000100012Q00123Q00064Q0004001A000100022Q008500130019001A00042F3Q0056020100042F3Q00E82Q0100042F3Q0056020100042F3Q00E32Q0100042F3Q0056020100263E001600E12Q01000100042F3Q00E12Q0100123B001900013Q00263E001900040201000200042F3Q0004020100123B001600023Q00042F3Q00E12Q0100263E00192Q000201000100042F4Q000201000283001A00374Q0004001A000100022Q00270017001A3Q000283001A00384Q0004001A000100022Q00270018001A3Q00123B001900023Q00042F4Q00020100042F3Q00E12Q0100042F3Q0056020100042F3Q00D92Q0100042F3Q0056020100123B0015000B4Q0015001500153Q00064B0011001E0201001500042F3Q001E02012Q0012001500013Q0020500015001500152Q0015001500153Q00066200160039000100012Q00128Q00040016000100022Q008500130015001600042F3Q0056020100263E001100280201000300042F3Q002802012Q0012001500013Q0020500015001500162Q0015001500153Q0006620016003A000100012Q00128Q00040016000100022Q008500130015001600042F3Q005602012Q0012001500013Q0020500015001500172Q0015001500153Q00064B001100560201001500042F3Q0056020100123B001500014Q004C001600173Q00263E001500380201000100042F3Q003802010002830018003B4Q00040018000100022Q0027001600183Q0002830018003C4Q00040018000100022Q0027001700183Q00123B001500023Q00263E0015002F0201000200042F3Q002F020100263E0016003A0201000100042F3Q003A02010002830018003D4Q00040018000100022Q0027001700183Q002677001700420201000100042F3Q0042020100042F3Q003F02012Q0012001800013Q0020500018001800182Q0015001800183Q0006620019003E000100012Q00128Q00330019000100024Q0013001800194Q001800013Q00202Q0018001800194Q001800183Q0006620019003F000100012Q00123Q00064Q00040019000100022Q008500130018001900042F3Q0056020100042F3Q003F020100042F3Q0056020100042F3Q003A020100042F3Q0056020100042F3Q002F0201000283001500404Q00040015000100022Q0027001400153Q00263E001400CF2Q01000200042F3Q00CF2Q01000283001500414Q00040015000100022Q0027001000153Q00042F3Q003A2Q0100042F3Q00CF2Q0100042F3Q003A2Q0100042F3Q00850201000E42000100730201000F00042F3Q0073020100123B001400013Q000E420001006E0201001400042F3Q006E0201000283001500424Q00040015000100022Q0027001000153Q000283001500434Q00040015000100022Q0027001100153Q00123B001400023Q00263E001400650201000200042F3Q0065020100123B000F00023Q00042F3Q0073020100042F3Q0065020100263E000F00382Q01000200042F3Q00382Q0100123B001400013Q00263E0014007A0201000200042F3Q007A020100123B000F00033Q00042F3Q00382Q01000E42000100760201001400042F3Q00760201000283001500444Q00040015000100022Q0027001200153Q000283001500454Q00040015000100022Q0027001300153Q00123B001400023Q00042F3Q0076020100042F3Q00382Q012Q0073000F6Q0073000E5Q000440000A002A2Q0100123B000A001A4Q001A000A000A6Q000B8Q000B0001000200122Q000C00023Q00042Q000A00990201000662000E0046000100042Q00273Q00024Q00273Q00044Q00273Q000D4Q00123Q00074Q001E000E000100104Q001000076Q000D000F6Q0004000E6Q000D5Q000440000A008E02012Q0056000600023Q00263E000100DF0201000100042F3Q00DF020100123B000A00014Q004C000B000C3Q00263E000A00CD0201000200042F3Q00CD0201002677000B00A30201000100042F3Q00A3020100042F3Q00A00201000283000D00474Q0004000D000100022Q0027000C000D3Q002677000C00A90201000200042F3Q00A9020100042F3Q00B00201000283000D00484Q0004000D000100022Q00270004000D3Q000283000D00494Q0004000D000100022Q00270001000D3Q00042F3Q00DF020100263E000C00A60201000100042F3Q00A6020100123B000D00014Q004C000E000E3Q00263E000D00B40201000100042F3Q00B4020100123B000E00013Q00263E000E00C00201000100042F3Q00C00201000283000F004A4Q0004000F000100022Q00270002000F3Q000283000F004B4Q0004000F000100022Q00270003000F3Q00123B000E00023Q00263E000E00B70201000200042F3Q00B70201000283000F004C4Q0004000F000100022Q0027000C000F3Q00042F3Q00A6020100042F3Q00B7020100042F3Q00A6020100042F3Q00B4020100042F3Q00A6020100042F3Q00DF020100042F3Q00A0020100042F3Q00DF020100263E000A009E0201000100042F3Q009E020100123B000D00013Q00263E000D00D90201000100042F3Q00D90201000283000E004D4Q0004000E000100022Q0027000B000E3Q000283000E004E4Q0004000E000100022Q0027000C000E3Q00123B000D00023Q00263E000D00D00201000200042F3Q00D0020100123B000A00023Q00042F3Q009E020100042F3Q00D0020100042F3Q009E0201000283000A004F4Q0004000A000100022Q00270009000A3Q00042F3Q0039000100042F3Q0037000100042F3Q00EF020100263E3Q00020001000200042F3Q00020001000283000900504Q00040009000100022Q0027000300093Q000283000900514Q00040009000100022Q0027000400093Q00123B3Q00033Q00042F3Q000200012Q002A3Q00013Q00523Q00013Q00029Q00033Q00123B3Q00014Q00563Q00024Q002A3Q00019Q003Q00024Q002A3Q00014Q002A3Q00019Q003Q00024Q002A3Q00014Q002A3Q00019Q003Q00024Q002A3Q00014Q002A3Q00019Q003Q00024Q002A3Q00014Q002A3Q00019Q003Q00024Q002A3Q00014Q002A3Q00017Q00013Q00029Q00033Q00123B3Q00014Q00563Q00024Q002A3Q00017Q00013Q00029Q00033Q00123B3Q00014Q00563Q00024Q002A3Q00019Q003Q00044Q00128Q00323Q00014Q004F8Q002A3Q00017Q00013Q00027Q004000033Q00123B3Q00014Q00563Q00024Q002A3Q00017Q00013Q00026Q00F03F00033Q00123B3Q00014Q00563Q00024Q002A3Q00019Q003Q00034Q000E8Q00563Q00024Q002A3Q00019Q003Q00084Q006A3Q00046Q00018Q000200016Q000300036Q000400028Q000400012Q00563Q00024Q002A3Q00017Q00013Q00029Q00033Q00123B3Q00014Q00563Q00024Q002A3Q00019Q003Q00044Q00128Q00323Q00014Q004F8Q002A3Q00017Q00013Q00026Q00084000033Q00123B3Q00014Q00563Q00024Q002A3Q00019Q003Q00034Q000E8Q00563Q00024Q002A3Q00019Q003Q00024Q002A3Q00014Q002A3Q00019Q003Q00024Q002A3Q00014Q002A3Q00017Q00013Q00029Q00033Q00123B3Q00014Q00563Q00024Q002A3Q00019Q003Q00024Q002A3Q00014Q002A3Q00017Q00013Q00029Q00033Q00123B3Q00014Q00563Q00024Q002A3Q00017Q00013Q00026Q00F03F00033Q00123B3Q00014Q00563Q00024Q002A3Q00017Q00013Q00029Q00033Q00123B3Q00014Q00563Q00024Q002A3Q00019Q003Q00024Q00563Q00024Q002A3Q00017Q00013Q00026Q00F03F00033Q00123B3Q00014Q00563Q00024Q002A3Q00019Q003Q00024Q00563Q00024Q002A3Q00017Q00013Q00029Q00084Q00128Q00043Q0001000200263E3Q00050001000100042F3Q000500012Q006C8Q00253Q00014Q00563Q00024Q002A3Q00019Q003Q00044Q00128Q00323Q00014Q004F8Q002A3Q00019Q003Q00044Q00128Q00323Q00014Q004F8Q002A3Q00019Q003Q00034Q00128Q00563Q00024Q002A3Q00019Q003Q00044Q00128Q00323Q00014Q004F8Q002A3Q00019Q003Q00024Q00563Q00024Q002A3Q00017Q00013Q00026Q00F03F00033Q00123B3Q00014Q00563Q00024Q002A3Q00017Q00013Q00026Q00F03F00033Q00123B3Q00014Q00563Q00024Q002A3Q00019Q003Q00044Q00128Q00323Q00014Q004F8Q002A3Q00017Q00013Q00026Q00444000094Q00459Q00000100016Q000200023Q00202Q0002000200014Q000200026Q0001000100028Q00016Q00028Q00019Q003Q00034Q00128Q00563Q00024Q002A3Q00017Q00013Q00027Q004000064Q00559Q00000100013Q00202Q0001000100018Q00016Q00028Q00017Q00013Q00026Q00474000094Q00459Q00000100016Q000200023Q00202Q0002000200014Q000200026Q0001000100028Q00016Q00028Q00017Q00013Q00026Q00084000033Q00123B3Q00014Q00563Q00024Q002A3Q00017Q00013Q00029Q00033Q00123B3Q00014Q00563Q00024Q002A3Q00019Q003Q00024Q002A3Q00014Q002A3Q00017Q00013Q00029Q00033Q00123B3Q00014Q00563Q00024Q002A3Q00017Q00013Q00029Q00033Q00123B3Q00014Q00563Q00024Q002A3Q00017Q00013Q00026Q00F03F00033Q00123B3Q00014Q00563Q00024Q002A3Q00017Q00023Q00027Q0040025Q0080474000094Q005C9Q00000100013Q00122Q000200016Q000300023Q00202Q0003000300024Q000300038Q00039Q008Q00017Q00023Q00026Q004840026Q00184000094Q005B9Q00000100016Q000200023Q00202Q0002000200014Q000200023Q00122Q000300028Q00039Q008Q00017Q00013Q00026Q00F03F00033Q00123B3Q00014Q00563Q00024Q002A3Q00017Q00013Q00026Q00F03F00033Q00123B3Q00014Q00563Q00024Q002A3Q00017Q00013Q00029Q00033Q00123B3Q00014Q00563Q00024Q002A3Q00019Q003Q00094Q00363Q00046Q00018Q0001000100024Q00028Q0002000100024Q000300048Q000400012Q00563Q00024Q002A3Q00017Q00013Q00029Q00033Q00123B3Q00014Q00563Q00024Q002A3Q00019Q003Q00044Q00128Q00323Q00014Q004F8Q002A3Q00019Q003Q00044Q00128Q00323Q00014Q004F8Q002A3Q00017Q00013Q00029Q00033Q00123B3Q00014Q00563Q00024Q002A3Q00019Q003Q00024Q002A3Q00014Q002A3Q00019Q003Q00044Q00128Q00323Q00014Q004F8Q002A3Q00017Q00013Q00026Q00F04000054Q00799Q003Q0001000200206Q00016Q00028Q00017Q00013Q00029Q00033Q00123B3Q00014Q00563Q00024Q002A3Q00019Q003Q00024Q002A3Q00014Q002A3Q00017Q00013Q00029Q00033Q00123B3Q00014Q00563Q00024Q002A3Q00017Q00013Q00026Q00F04000054Q00799Q003Q0001000200206Q00016Q00028Q00019Q003Q00044Q00128Q00323Q00014Q004F8Q002A3Q00017Q00013Q00026Q00F03F00033Q00123B3Q00014Q00563Q00024Q002A3Q00017Q00013Q00027Q004000033Q00123B3Q00014Q00563Q00024Q002A3Q00017Q00013Q00029Q00033Q00123B3Q00014Q00563Q00024Q002A3Q00019Q003Q00024Q002A3Q00014Q002A3Q00019Q003Q00024Q002A3Q00014Q002A3Q00019Q003Q00024Q002A3Q00014Q002A3Q00019Q003Q00074Q00359Q00000100016Q000200026Q000300038Q00039Q008Q00017Q00013Q00029Q00033Q00123B3Q00014Q00563Q00024Q002A3Q00019Q003Q00034Q000E8Q00563Q00024Q002A3Q00017Q00013Q00026Q00F03F00033Q00123B3Q00014Q00563Q00024Q002A3Q00019Q003Q00033Q0002838Q00563Q00024Q002A3Q00013Q00013Q00023Q00028Q0003013Q002C032B3Q00123B000300014Q004C000400043Q00263E000300020001000100042F3Q0002000100028300056Q00040005000100022Q0027000400053Q00263E000400070001000100042F3Q00070001000283000500014Q000400050001000200263E0005000B0001000100042F3Q000B000100123B000600014Q004C000700073Q00263E0006000F0001000100042F3Q000F000100123B000700013Q00263E000700120001000100042F3Q0012000100123B000800013Q00263E000800150001000100042F3Q0015000100123B000900024Q0015000900094Q0029000900010009000662000A0002000100012Q00273Q00024Q0043000A000100026Q0009000A4Q00098Q000A00016Q000B00026Q000900023Q00044Q0015000100042F3Q0012000100042F3Q000B000100042F3Q000F000100042F3Q000B000100042F3Q0007000100042F3Q002A000100042F3Q000200012Q002A3Q00013Q00033Q00013Q00029Q00033Q00123B3Q00014Q00563Q00024Q002A3Q00017Q00013Q00029Q00033Q00123B3Q00014Q00563Q00024Q002A3Q00019Q003Q00044Q00128Q00323Q00014Q004F8Q002A3Q00019Q003Q00034Q000E8Q00563Q00024Q002A3Q00017Q00013Q00026Q00F03F00033Q00123B3Q00014Q00563Q00024Q002A3Q00017Q00013Q00029Q00033Q00123B3Q00014Q00563Q00024Q002A3Q00019Q003Q00024Q002A3Q00014Q002A3Q00017Q00013Q00026Q00F03F00033Q00123B3Q00014Q00563Q00024Q002A3Q00019Q003Q00024Q002A3Q00014Q002A3Q00019Q003Q00024Q002A3Q00014Q002A3Q00017Q00033Q00026Q00F03F027Q0040026Q000840030D3Q00205000033Q000100205000043Q000200205000053Q000300066200063Q000100072Q00273Q00034Q00273Q00044Q00273Q00054Q00128Q00123Q00014Q00273Q00024Q00123Q00024Q0056000600024Q002A3Q00013Q00013Q00143Q00026Q00F03F026Q00F0BF03013Q0023028Q00026Q000840025Q00E89C40025Q00E49740026Q001040027Q0040025Q00A88940025Q0096A040026Q001440025Q00088940025Q003CB140026Q001C40025Q00308C40025Q002AA240026Q001840025Q009EA840025Q001094400051013Q007A00018Q000200016Q000300026Q000400033Q00122Q000500013Q00122Q000600026Q00078Q00088Q00098Q00083Q00012Q0012000900043Q001207000A00036Q000B8Q00093Q000200202Q0009000900014Q000A8Q000B5Q00122Q000C00046Q000D00093Q00122Q000E00013Q00042Q000C0020000100065A0003001C0001000F00042F3Q001C00012Q00290010000F00030020280011000F00012Q00540011000800112Q008500070010001100042F3Q001F00010020280010000F00012Q00540010000800102Q0085000B000F0010000440000C001500012Q0029000C00090003002028000C000C00012Q004C000D000E3Q00123B000F00043Q00263E000F00492Q01000100042F3Q00492Q0100260B000E00A70001000500042F3Q00A7000100260B000E005E0001000100042F3Q005E0001000E570004002E0001000E00042F3Q002E0001002E5F0006002E0001000700042F3Q005A000100123B001000044Q004C001100133Q00263E0010004B0001000100042F3Q004B00012Q004C001300133Q00263E0011003B0001000100042F3Q003B00010020280014001200012Q0067000B0014001300202Q0014000D00084Q0014001300144Q000B0012001400044Q00472Q0100263E001100330001000400042F3Q0033000100123B001400043Q00263E001400440001000400042F3Q004400010020500012000D00090020500015000D00052Q00540013000B001500123B001400013Q00263E0014003E0001000100042F3Q003E000100123B001100013Q00042F3Q0033000100042F3Q003E000100042F3Q0033000100042F3Q00472Q0100263E001000300001000400042F3Q0030000100123B001400043Q00263E001400520001000100042F3Q0052000100123B001000013Q00042F3Q00300001000E420004004E0001001400042F3Q004E000100123B001100044Q004C001200123Q00123B001400013Q00042F3Q004E000100042F3Q0030000100042F3Q00472Q010020500010000D00092Q00540010000B00102Q006B00100001000100042F3Q00472Q01002E0A000A00680001000B00042F3Q0068000100263E000E00680001000900042F3Q006800010020500010000D00092Q0046001100053Q00202Q0012000D00054Q0011001100124Q000B0010001100044Q00472Q0100123B001000044Q004C001100153Q00263E0010006E0001000100042F3Q006E00012Q004C001300143Q00123B001000093Q00263E001000A00001000900042F3Q00A000012Q004C001500153Q00263E001100810001000900042F3Q008100012Q0027001600124Q0027001700063Q00123B001800013Q00046000160080000100123B001A00043Q00263E001A00780001000400042F3Q007800010020280015001500012Q0054001B001300152Q0085000B0019001B00042F3Q007F000100042F3Q0078000100044000160077000100042F3Q00472Q0100263E001100980001000400042F3Q0098000100123B001600043Q00263E001600880001000100042F3Q0088000100123B001100013Q00042F3Q0098000100263E001600840001000400042F3Q008400010020500012000D00092Q007C001700046Q0018000B00124Q001900066Q001A000B3Q00202Q001B0012000100202Q001C000D00054Q0019001C6Q00188Q00173Q00184Q001400186Q001300173Q00122Q001600013Q00044Q0084000100263E001100710001000100042F3Q007100012Q004D00160014001200204800060016000100123B001500043Q00123B001100093Q00042F3Q0071000100042F3Q00472Q0100263E0010006A0001000400042F3Q006A000100123B001100044Q004C001200123Q00123B001000013Q00042F3Q006A000100042F3Q00472Q0100260B000E002B2Q01000C00042F3Q002B2Q01000E57000800AD0001000E00042F3Q00AD0001002E39000E00272Q01000D00042F3Q00272Q0100123B001000044Q004C001100153Q00263E001000BC0001000500042F3Q00BC00010020280016001500012Q006D000B0016001400202Q0016000D00084Q0016001400164Q000B0015001600202Q0005000500014Q000D0001000500202Q0016000D000900202Q0017000D00054Q000B0016001700122Q001000083Q00263E001000C10001000F00042F3Q00C100012Q0054000D000100052Q002A3Q00013Q00042F3Q00472Q0100263E001000D40001000800042F3Q00D400010020280005000500012Q0019000D0001000500202Q0015000D00094Q001600046Q0017000B00154Q001800066Q0019000B3Q00202Q001A0015000100202Q001B000D00054Q0018001B6Q00178Q00163Q00174Q001300176Q001200166Q00160013001500202Q00060016000100122Q0010000C3Q000E42000100E00001001000042F3Q00E000010020280005000500012Q007F000D0001000500202Q0016000D00094Q001700053Q00202Q0018000D00054Q0017001700184Q000B0016001700202Q0005000500014Q000D0001000500122Q001000093Q00263E001000FC0001000C00042F3Q00FC000100123B001100044Q0027001600154Q0027001700063Q00123B001800013Q000460001600F8000100123B001A00044Q004C001B001B3Q00263E001A00E90001000400042F3Q00E9000100123B001B00043Q002E0A001000EC0001001100042F3Q00EC000100263E001B00EC0001000400042F3Q00EC00010020280011001100012Q0054001C001200112Q0085000B0019001C00042F3Q00F7000100042F3Q00EC000100042F3Q00F7000100042F3Q00E90001000440001600E700010020280005000500012Q0054000D000100050020500015000D000900123B001000123Q000E420012000D2Q01001000042F3Q000D2Q012Q00540016000B00152Q0081001700066Q0018000B3Q00202Q0019001500014Q001A00066Q0017001A6Q00163Q00024Q000B0015001600202Q0005000500014Q000D0001000500202Q0016000D00094Q0016000B00164Q00160001000100202Q00050005000100122Q0010000F3Q000E42000400182Q01001000042F3Q00182Q012Q004C001100114Q0076001600176Q001300176Q001200166Q001400153Q00202Q0016000D00094Q00178Q000B0016001700122Q001000013Q00263E001000AF0001000900042F3Q00AF00010020500016000D00092Q006F001700053Q00202Q0018000D00054Q0017001700184Q000B0016001700202Q0005000500014Q000D0001000500202Q0015000D000900202Q0016000D00054Q0014000B001600122Q001000053Q00044Q00AF000100042F3Q00472Q010020500010000D00090020500011000D00052Q0085000B0010001100042F3Q00472Q0100260B000E003E2Q01001200042F3Q003E2Q0100123B001000044Q004C001100113Q00263E0010002F2Q01000400042F3Q002F2Q010020500011000D00092Q00200012000B00114Q001300066Q0014000B3Q00202Q00150011000100202Q0015001500044Q001600066Q001300166Q00123Q00024Q000B0011001200044Q00472Q0100042F3Q002F2Q0100042F3Q00472Q01002677000E00422Q01000F00042F3Q00422Q01002E0A001300442Q01001400042F3Q00442Q012Q002A3Q00013Q00042F3Q00472Q010020500010000D00092Q000E00116Q0085000B0010001100202800050005000100042F3Q0023000100263E000F00240001000400042F3Q002400012Q0054000D00010005002050000E000D000100123B000F00013Q00042F3Q0024000100042F3Q002300012Q002A3Q00017Q00",GetFEnv(),...); end
local v0 = tonumber;
local v1 = string.byte;
local v2 = string.char;
local v3 = string.sub;
local v4 = string.gsub;
local v5 = string.rep;
local v6 = table.concat;
local v7 = table.insert;
local v8 = math.ldexp;
local v9 = getfenv or function()
	return _ENV;
end;
local v10 = setmetatable;
local v11 = pcall;
local v12 = select;
local v13 = unpack or table.unpack;
local v14 = tonumber;
local function v15(v16, v17, ...)
	local v18 = 1;
	local v19;
	v16 = v4(v3(v16, 5), "..", function(v30)
		if (v1(v30, 2) == 81) then
			v19 = v0(v3(v30, 1, 1));
			return "";
		else
			local v85 = 0;
			local v86;
			while true do
				if (v85 == 0) then
					v86 = v2(v0(v30, 16));
					if v19 then
						local v124 = 0;
						local v125;
						while true do
							if (v124 == 0) then
								v125 = v5(v86, v19);
								v19 = nil;
								v124 = 1;
							end
							if (v124 == 1) then
								return v125;
							end
						end
					else
						return v86;
					end
					break;
				end
			end
		end
	end);
	local function v20(v31, v32, v33)
		if v33 then
			local v87 = 0 - 0;
			local v88;
			while true do
				if (v87 == (0 - 0)) then
					v88 = (v31 / ((3 - 1) ^ (v32 - (2 - 1)))) % ((621 - ((790 - 235) + 64)) ^ (((v33 - ((1997 - (68 + 997)) - (857 + 74))) - (v32 - ((1839 - (226 + 1044)) - (367 + 201)))) + (928 - (214 + 713))));
					return v88 - (v88 % (1 + 0));
				end
			end
		else
			local v89 = 0;
			local v90;
			while true do
				if (v89 == ((0 - 0) + 0)) then
					v90 = (879 - (282 + 595)) ^ (v32 - 1);
					return (((v31 % (v90 + v90)) >= v90) and (1638 - (1523 + 114))) or (0 + 0);
				end
			end
		end
	end
	local function v21()
		local v34 = 117 - (32 + 85);
		local v35;
		while true do
			if (v34 == (1 + 0)) then
				return v35;
			end
			if (v34 == 0) then
				v35 = v1(v16, v18, v18);
				v18 = v18 + 1;
				v34 = (958 - (892 + 65)) + 0;
			end
		end
	end
	local function v22()
		local v36, v37 = v1(v16, v18, v18 + (4 - 2));
		v18 = v18 + (3 - 1);
		return (v37 * 256) + v36;
	end
	local function v23()
		local v38, v39, v40, v41 = v1(v16, v18, v18 + (4 - 1));
		v18 = v18 + (354 - (87 + 263));
		return (v41 * (16777396 - (50 + 17 + 113))) + (v40 * (48056 + 17480)) + (v39 * (628 - 372)) + v38;
	end
	local function v24()
		local v42 = v23();
		local v43 = v23();
		local v44 = 3 - 2;
		local v45 = (v20(v43, 953 - (802 + 150), 53 - 33) * ((3 - 1) ^ (24 + 8))) + v42;
		local v46 = v20(v43, 39 - (10 + 8), 1028 - (915 + 82));
		local v47 = ((v20(v43, 90 - 58) == (3 - 2)) and -(1 + 0)) or (1 - 0);
		if (v46 == 0) then
			if (v45 == 0) then
				return v47 * ((1629 - (416 + 26)) - (1069 + 118));
			else
				v46 = (6 - 4) - 1;
				v44 = 0 - 0;
			end
		elseif (v46 == 2047) then
			return ((v45 == (0 + 0)) and (v47 * ((1 - 0) / 0))) or (v47 * NaN);
		end
		return v8(v47, v46 - (1015 + 8)) * (v44 + (v45 / ((793 - (368 + 423)) ^ (163 - 111))));
	end
	local function v25(v48)
		local v49 = 772 - ((1060 - (814 + 45)) + 571);
		local v50;
		local v51;
		while true do
			if (v49 == ((2 - 1) + 0)) then
				v50 = v3(v16, v18, (v18 + v48) - ((1 + 0) - 0));
				v18 = v18 + v48;
				v49 = 440 - (145 + 293);
			end
			if ((430 - (44 + 137 + 249)) == v49) then
				v50 = nil;
				if not v48 then
					v48 = v23();
					if (v48 == ((2371 - (261 + 624)) - ((1773 - 775) + 488))) then
						return "";
					end
				end
				v49 = 3 - 2;
			end
			if (v49 == 2) then
				v51 = {};
				for v112 = 1, #v50 do
					v51[v112] = v2(v1(v3(v50, v112, v112)));
				end
				v49 = 1 + 2;
			end
			if (v49 == (3 + 0)) then
				return v6(v51);
			end
		end
	end
	local v26 = v23;
	local function v27(...)
		return {...}, v12("#", ...);
	end
	local function v28()
		local v52 = (function()
			return function(v91, v92, v93, v94, v95, v96, v97, v98)
				local v91 = (function()
					return 0 - 0;
				end)();
				local v92 = (function()
					return;
				end)();
				local v94 = (function()
					return;
				end)();
				while true do
					if (v91 ~= (0 - 0)) then
					else
						local v118 = (function()
							return 0 - 0;
						end)();
						local v119 = (function()
							return;
						end)();
						while true do
							if (v118 ~= 0) then
							else
								v119 = (function()
									return 1824 - (1195 + 629);
								end)();
								while true do
									if (v119 == (1 - 0)) then
										v91 = (function()
											return #"!";
										end)();
										break;
									end
									if (v119 ~= (241 - (187 + 54))) then
									else
										v92 = (function()
											return v93();
										end)();
										v94 = (function()
											return nil;
										end)();
										v119 = (function()
											return 781 - (162 + 618);
										end)();
									end
								end
								break;
							end
						end
					end
					if (v91 == #">") then
						if (v92 == #"|") then
							v94 = (function()
								return v93() ~= (0 + 0);
							end)();
						elseif (v92 == (2 + 0)) then
							v94 = (function()
								return v95();
							end)();
						elseif (v92 == #"asd") then
							v94 = (function()
								return v96();
							end)();
						end
						v97[v98] = (function()
							return v94;
						end)();
						break;
					end
				end
				return v91, v92, v93, v94, v95, v96, v97, v98;
			end;
		end)();
		local v53 = (function()
			return function(v99, v100, v101)
				local v102 = (function()
					return 0;
				end)();
				local v103 = (function()
					return;
				end)();
				while true do
					if ((0 - 0) ~= v102) then
					else
						v103 = (function()
							return 0;
						end)();
						while true do
							if (v103 ~= 0) then
							else
								local v126 = (function()
									return 0;
								end)();
								while true do
									if ((0 - 0) == v126) then
										v99[v100 - #"["] = (function()
											return v101();
										end)();
										return v99, v100, v101;
									end
								end
							end
						end
						break;
					end
				end
			end;
		end)();
		local v54 = (function()
			return {};
		end)();
		local v55 = (function()
			return {};
		end)();
		local v56 = (function()
			return {};
		end)();
		local v57 = (function()
			return {v54,v55,nil,v56};
		end)();
		local v58 = (function()
			return v23();
		end)();
		local v59 = (function()
			return {};
		end)();
		for v67 = #"<", v58 do
			FlatIdent_2FD19, Type, v21, Cons, v24, v25, v59, v67 = (function()
				return v52(FlatIdent_2FD19, Type, v21, Cons, v24, v25, v59, v67);
			end)();
		end
		v57[#"xnx"] = (function()
			return v21();
		end)();
		for v68 = #"}", v23() do
			local v69 = (function()
				return v21();
			end)();
			if (v20(v69, #"}", #"{") == 0) then
				local v107 = (function()
					return 0;
				end)();
				local v108 = (function()
					return;
				end)();
				local v109 = (function()
					return;
				end)();
				local v110 = (function()
					return;
				end)();
				local v111 = (function()
					return;
				end)();
				while true do
					if ((1636 - (1373 + 263)) == v107) then
						local v121 = (function()
							return 0;
						end)();
						local v122 = (function()
							return;
						end)();
						while true do
							if (v121 ~= 0) then
							else
								v122 = (function()
									return 1000 - (451 + 549);
								end)();
								while true do
									if (v122 ~= (0 + 0)) then
									else
										v108 = (function()
											return 0 - 0;
										end)();
										v109 = (function()
											return nil;
										end)();
										v122 = (function()
											return 1 - 0;
										end)();
									end
									if (v122 ~= (1385 - (746 + 638))) then
									else
										v107 = (function()
											return 1;
										end)();
										break;
									end
								end
								break;
							end
						end
					end
					if (v107 ~= 2) then
					else
						while true do
							if (v108 ~= #"}") then
							else
								local v127 = (function()
									return 0;
								end)();
								local v128 = (function()
									return;
								end)();
								while true do
									if (v127 ~= (0 + 0)) then
									else
										v128 = (function()
											return 0 - 0;
										end)();
										while true do
											if (v128 == (342 - (218 + 123))) then
												v108 = (function()
													return 1583 - (1535 + 46);
												end)();
												break;
											end
											if (v128 ~= 0) then
											else
												v111 = (function()
													return {v22(),v22(),nil,nil};
												end)();
												if (v109 == (0 + 0)) then
													local v792 = (function()
														return 0 + 0;
													end)();
													local v793 = (function()
														return;
													end)();
													while true do
														if (v792 == 0) then
															v793 = (function()
																return 560 - (306 + 254);
															end)();
															while true do
																if (v793 == (0 + 0)) then
																	v111[#"19("] = (function()
																		return v22();
																	end)();
																	v111[#"?id="] = (function()
																		return v22();
																	end)();
																	break;
																end
															end
															break;
														end
													end
												elseif (v109 == #">") then
													v111[#"nil"] = (function()
														return v23();
													end)();
												elseif (v109 == 2) then
													v111[#"19("] = (function()
														return v23() - (2 ^ 16);
													end)();
												elseif (v109 == #"xxx") then
													local v1205 = (function()
														return 0;
													end)();
													local v1206 = (function()
														return;
													end)();
													while true do
														if (0 ~= v1205) then
														else
															v1206 = (function()
																return 0 - 0;
															end)();
															while true do
																if (v1206 == 0) then
																	v111[#"gha"] = (function()
																		return v23() - ((1469 - (899 + 568)) ^ 16);
																	end)();
																	v111[#"0313"] = (function()
																		return v22();
																	end)();
																	break;
																end
															end
															break;
														end
													end
												end
												v128 = (function()
													return 1 + 0;
												end)();
											end
										end
										break;
									end
								end
							end
							if (v108 ~= 2) then
							else
								local v129 = (function()
									return 0 - 0;
								end)();
								local v130 = (function()
									return;
								end)();
								while true do
									if (v129 ~= 0) then
									else
										v130 = (function()
											return 0;
										end)();
										while true do
											if (v130 == 1) then
												v108 = (function()
													return #"-19";
												end)();
												break;
											end
											if (v130 == 0) then
												if (v20(v110, #"|", #":") ~= #" ") then
												else
													v111[605 - (268 + 335)] = (function()
														return v59[v111[292 - (60 + 230)]];
													end)();
												end
												if (v20(v110, 2, 574 - (426 + 146)) == #"|") then
													v111[#"xxx"] = (function()
														return v59[v111[#"91("]];
													end)();
												end
												v130 = (function()
													return 1;
												end)();
											end
										end
										break;
									end
								end
							end
							if (v108 == #"91(") then
								if (v20(v110, #"xnx", #"xxx") == #"]") then
									v111[#"0313"] = (function()
										return v59[v111[#"http"]];
									end)();
								end
								v54[v68] = (function()
									return v111;
								end)();
								break;
							end
							if (v108 ~= 0) then
							else
								local v132 = (function()
									return 0;
								end)();
								local v133 = (function()
									return;
								end)();
								while true do
									if (v132 ~= (0 + 0)) then
									else
										v133 = (function()
											return 1456 - (282 + 1174);
										end)();
										while true do
											if (v133 == (811 - (569 + 242))) then
												v109 = (function()
													return v20(v69, 2, #"91(");
												end)();
												v110 = (function()
													return v20(v69, #"xnxx", 6);
												end)();
												v133 = (function()
													return 1;
												end)();
											end
											if (v133 ~= (2 - 1)) then
											else
												v108 = (function()
													return #"|";
												end)();
												break;
											end
										end
										break;
									end
								end
							end
						end
						break;
					end
					if (v107 == 1) then
						local v123 = (function()
							return 0 + 0;
						end)();
						while true do
							if ((1025 - (706 + 318)) == v123) then
								v107 = (function()
									return 2;
								end)();
								break;
							end
							if (v123 == (1251 - (721 + 530))) then
								v110 = (function()
									return nil;
								end)();
								v111 = (function()
									return nil;
								end)();
								v123 = (function()
									return 1272 - (945 + 326);
								end)();
							end
						end
					end
				end
			end
		end
		for v70 = #" ", v23() do
			v55, v70, v28 = (function()
				return v53(v55, v70, v28);
			end)();
		end
		return v57;
	end
	local function v29(v61, v62, v63)
		local v64 = v61[2 - 1];
		local v65 = v61[(493 - (142 + 349)) + 0];
		local v66 = v61[703 - (117 + 154 + 429)];
		return function(...)
			local v71 = v64;
			local v72 = v65;
			local v73 = v66;
			local v74 = v27;
			local v75 = 1;
			local v76 = -1;
			local v77 = {};
			local v78 = {...};
			local v79 = v12("#", ...) - (1 - 0);
			local v80 = {};
			local v81 = {};
			for v104 = 0 + 0, v79 do
				if ((v104 >= v73) or (2272 >= 3660) or (3490 >= 3857)) then
					v77[v104 - v73] = v78[v104 + (1501 - (1408 + 92))];
				else
					v81[v104] = v78[v104 + (1087 - (230 + 231 + 625))];
				end
			end
			local v82 = (v79 - v73) + ((909 + 380) - (993 + 295));
			local v83;
			local v84;
			while true do
				v83 = v71[v75];
				v84 = v83[(2 - 1) + 0];
				if (v84 <= (1228 - (418 + 753))) then
					if (v84 <= (11 + 17)) then
						if ((v84 <= (2 + 11)) or (1930 == 3490)) then
							if ((284 == 284) and (v84 <= (2 + 4))) then
								if (v84 <= (1 + 1)) then
									if ((2448 > 1585) and (v84 <= (529 - ((2270 - (1710 + 154)) + 123)))) then
										local v136 = 1769 - (1749 + 20);
										local v137;
										while true do
											if ((1 + (321 - (200 + 118))) == v136) then
												v83 = v71[v75];
												v81[v83[2]] = v81[v83[1325 - (1249 + 73)]] * v81[v83[1 + 1 + 2]];
												v75 = v75 + (1146 - (466 + 679));
												v83 = v71[v75];
												v136 = 11 - 6;
											end
											if ((v136 == (14 - 9)) or (3054 <= 1922)) then
												do
													return v81[v83[1902 - (106 + 1794)]];
												end
												v75 = v75 + 1 + 0;
												v83 = v71[v75];
												v75 = v83[1 + 2];
												break;
											end
											if ((3970 > 289) and ((v136 == 0) or (4189 < 2526))) then
												v137 = nil;
												v81[v83[(8 - 3) - 3]] = v81[v83[7 - 4]];
												v75 = v75 + (1 - 0);
												v83 = v71[v75];
												v136 = 115 - (4 + 0 + 110);
											end
											if ((4729 == 4729) and (v136 == (587 - (57 + 0 + 527)))) then
												v75 = v75 + (1428 - (41 + 1386));
												v83 = v71[v75];
												v81[v83[(57 + 48) - (17 + 86)]] = v81[v83[3 + 0]] + v81[v83[8 - 4]];
												v75 = v75 + (2 - 1);
												v136 = 170 - (122 + 44);
											end
											if (2 == v136) then
												v81[v137] = v81[v137](v13(v81, v137 + (1 - 0), v83[9 - 6]));
												v75 = v75 + 1 + 0;
												v83 = v71[v75];
												v81[v83[2]] = v81[v83[1 + 0 + 2]] / v83[7 - 3];
												v136 = 3;
											end
											if ((v136 == ((142 - 76) - (30 + 35))) or (1251 > 1489)) then
												v81[v83[2 + 0]] = v81[v83[1260 - (1043 + (1464 - (363 + 887)))]] - v83[4];
												v75 = v75 + (3 - 2);
												v83 = v71[v75];
												v137 = v83[1214 - (323 + (1551 - 662))];
												v136 = 5 - 3;
											end
										end
									elseif (v84 > 1) then
										local v189 = 580 - (361 + 219);
										while true do
											if (v189 == 4) then
												v75 = v83[3];
												break;
											end
											if ((1189 == 1189) and (v189 == (322 - (53 + 267)))) then
												v81[v83[1 + 1]] = v81[v83[416 - (15 + 398)]][v81[v83[986 - (18 + 964)]]];
												v75 = v75 + (3 - 2);
												v83 = v71[v75];
												v189 = 2 + 1;
											end
											if ((v189 == (2 + 1)) or (670 == 1771)) then
												v81[v83[852 - (20 + (3950 - 3120))]][v81[v83[3 + 0]]] = v81[v83[(21 + 109) - (116 + 10)]];
												v75 = v75 + 1 + (0 - 0);
												v83 = v71[v75];
												v189 = 742 - (542 + 196);
											end
											if (v189 == (0 + 0)) then
												v81[v83[3 - 1]][v81[v83[1 + 2]]] = v81[v83[(1667 - (674 + 990)) + 1 + 0]];
												v75 = v75 + 1 + 0;
												v83 = v71[v75];
												v189 = 1;
											end
											if ((v189 == (2 - 1)) or (4168 <= 1718)) then
												v81[v83[4 - 2]] = v81[v83[1554 - (1126 + 425)]][v83[409 - (118 + 287)]];
												v75 = v75 + (3 - 2);
												v83 = v71[v75];
												v189 = 1123 - (118 + 1003);
											end
										end
									else
										v81[v83[2]] = v62[v83[8 - 5]];
										v75 = v75 + (378 - (142 + 235));
										v83 = v71[v75];
										v81[v83[9 - 7]] = v81[v83[3]][v83[1 + 3]];
										v75 = v75 + 1;
										v83 = v71[v75];
										v81[v83[979 - (553 + 424)]] = v81[v83[5 - 2]][v81[v83[4]]];
										v75 = v75 + 1 + 0;
										v83 = v71[v75];
										v81[v83[2 + 0]][v81[v83[2 + 1 + 0]]] = v81[v83[4]];
										v75 = v75 + 1;
										v83 = v71[v75];
										v81[v83[2]] = v81[v83[(2 - 0) + 1]] + v83[3 + 1];
										v75 = v75 + (2 - 1);
										v83 = v71[v75];
										v81[v83[5 - 3]] = v81[v83[6 - 3]] + v83[4];
										v75 = v75 + 1 + 0;
										v83 = v71[v75];
										v81[v83[9 - 7]] = v83[3];
									end
								elseif (v84 <= (757 - ((1294 - (507 + 548)) + 514))) then
									if ((1459 >= 329) and (v84 == (2 + 1))) then
										v81[v83[1331 - (797 + 532)]] = v83[3 + 0] ~= 0;
										v75 = v75 + 1 + 0;
									else
										v81[v83[4 - 2]] = v63[v83[1205 - (373 + 829)]];
									end
								elseif (v84 > (736 - (476 + 255))) then
									if (v83[1132 - (369 + 761)] ~= v81[v83[3 + 1]]) then
										v75 = v75 + (1 - 0);
									else
										v75 = v83[5 - 2];
									end
								else
									local v204 = v83[2];
									local v205 = {v81[v204](v13(v81, v204 + 1 + 0, v76))};
									local v206 = 0 - 0;
									for v811 = v204, v83[340 - (144 + (1029 - (289 + 548)))] do
										v206 = v206 + ((2035 - (821 + 997)) - (42 + (429 - (195 + 60))));
										v81[v811] = v205[v206];
									end
								end
							elseif (v84 <= (2 + 5 + 2)) then
								if ((2910 > 1112) and (v84 <= (6 + 1))) then
									do
										return;
									end
								elseif ((579 < 4604) and (v84 > ((1505 - (251 + 1250)) + 4))) then
									local v207 = 1504 - (363 + 1141);
									while true do
										if (v207 == 0) then
											v81[v83[2]] = v62[v83[1583 - (1183 + 397)]];
											v75 = v75 + (2 - 1);
											v83 = v71[v75];
											v81[v83[2 + 0]] = v81[v83[3 + 0]][v83[1979 - (1913 + 62)]];
											v207 = 1;
										end
										if ((2046 <= 4218) and (v207 == (1 + 0))) then
											v75 = v75 + 1;
											v83 = v71[v75];
											v81[v83[(14 - 9) - 3]] = v81[v83[3]][v81[v83[1937 - (565 + 1368)]]];
											v75 = v75 + (3 - 2);
											v207 = (1143 + 520) - (1477 + 184);
										end
										if (((1034 - (809 + 223)) - (0 - 0)) == v207) then
											v83 = v71[v75];
											v81[v83[2]][v81[v83[3 + 0]]] = v81[v83[11 - 7]];
											v75 = v75 + (857 - (564 + 292));
											v83 = v71[v75];
											v207 = 4 - 1;
										end
										if (v207 == 3) then
											v81[v83[(16 - 11) - 3]] = v81[v83[307 - (244 + 60)]] + v83[4 + 0];
											v75 = v75 + (477 - (41 + 435));
											v83 = v71[v75];
											v81[v83[1003 - (938 + 47 + 16)]] = v83[3];
											break;
										end
									end
								else
									local v208 = 0 + 0;
									local v209;
									local v210;
									local v211;
									while true do
										if (v208 == (1126 - (936 + 189))) then
											v211 = v83[3];
											for v1137 = 1, v211 do
												v210[v1137] = v81[v209 + v1137];
											end
											break;
										end
										if (((2488 > 810) and ((0 + 0) == v208)) or (2379 > 3094)) then
											v209 = v83[1615 - (1565 + 48)];
											v210 = v81[v209];
											v208 = 1 + 0 + (617 - (14 + 603));
										end
									end
								end
							elseif (v84 <= (1149 - (782 + 356))) then
								if ((4075 <= 4717) and (v84 == 10)) then
									for v814 = v83[2], v83[3] do
										v81[v814] = nil;
									end
									v75 = v75 + (268 - (176 + 91));
									v83 = v71[v75];
									v81[v83[(133 - (118 + 11)) - 2]] = v81[v83[4 - 1]];
									v75 = v75 + 1;
									v83 = v71[v75];
									v81[v83[1094 - (158 + 817 + 117)]] = v81[v83[1878 - (157 + 1718)]];
									v75 = v75 + 1 + 0;
									v83 = v71[v75];
									v81[v83[6 - 4]] = v83[10 - 7];
									v75 = v75 + (1019 - (697 + 268 + 53));
									v83 = v71[v75];
									v75 = v83[3];
								else
									local v220;
									v81[v83[2]] = v62[v83[7 - 4]];
									v75 = v75 + (1 - 0);
									v83 = v71[v75];
									v81[v83[4 - 2]] = v81[v83[2 + 1]];
									v75 = v75 + (1 - 0);
									v83 = v71[v75];
									v81[v83[5 - 3]] = v83[1230 - (322 + 905)];
									v75 = v75 + (612 - (602 + 9));
									v83 = v71[v75];
									v81[v83[2]] = v83[1192 - (449 + 740)];
									v75 = v75 + (873 - (826 + 46));
									v83 = v71[v75];
									v220 = v83[949 - (245 + 702)];
									v81[v220] = v81[v220](v13(v81, v220 + (3 - 2), v83[3]));
									v75 = v75 + 1 + 0;
									v83 = v71[v75];
									v81[v83[1900 - (260 + 1638)]] = v81[v83[3]] * v83[4];
									v75 = v75 + (441 - (382 + 58));
									v83 = v71[v75];
									v81[v83[6 - 4]] = v81[v83[3 + 0]] + v81[v83[8 - 4]];
									v75 = v75 + (2 - 1);
									v83 = v71[v75];
									v81[v83[1207 - (902 + 303)]] = v83[3];
									v75 = v75 + ((2 - 1) - 0);
									v83 = v71[v75];
									v75 = v83[(955 - (551 + 398)) - (2 + 1)];
								end
							elseif (v84 > (2 + 10)) then
								local v236;
								local v237, v238;
								local v239;
								local v240;
								v81[v83[2]] = v83[1693 - (1121 + 569)];
								v75 = v75 + ((77 + 138) - (18 + 4 + 192));
								v83 = v71[v75];
								v240 = v83[685 - (483 + 200)];
								v76 = (v240 + v82) - (1464 - (1404 + 59));
								for v816 = v240, v76 do
									v239 = v77[v816 - v240];
									v81[v816] = v239;
								end
								v75 = v75 + (2 - 1);
								v83 = v71[v75];
								v240 = v83[2];
								v237, v238 = v74(v81[v240](v13(v81, v240 + (1 - 0), v76)));
								v76 = (v238 + v240) - 1;
								v236 = (2845 - 2080) - (468 + 297);
								for v819 = v240, v76 do
									v236 = v236 + (563 - (334 + (525 - 297)));
									v81[v819] = v237[v236];
								end
								v75 = v75 + 1;
								v83 = v71[v75];
								v240 = v83[6 - 4];
								do
									return v13(v81, v240, v76);
								end
								v75 = v75 + (2 - 1);
								v83 = v71[v75];
								do
									return;
								end
							else
								local v247;
								local v248;
								local v247, v249;
								local v250;
								v81[v83[2]] = v81[v83[5 - 2]];
								v75 = v75 + 1 + 0;
								v83 = v71[v75];
								v81[v83[2]] = v81[v83[239 - (141 + 95)]][v81[v83[4 + 0]]];
								v75 = v75 + (2 - 1);
								v83 = v71[v75];
								v81[v83[4 - (1 + 1)]] = v62[v83[1 + 2]];
								v75 = v75 + (2 - 1);
								v83 = v71[v75];
								v81[v83[2 + 0]] = v81[v83[(7 - 5) + 1]];
								v75 = v75 + ((1 + 0) - 0);
								v83 = v71[v75];
								v81[v83[2 + 0]] = v81[v83[3]] + v83[4];
								v75 = v75 + (164 - (92 + 71));
								v83 = v71[v75];
								v81[v83[1 + 1]] = v81[v83[4 - 1]] + v83[4];
								v75 = v75 + (766 - (574 + 191));
								v83 = v71[v75];
								v81[v83[2 + 0]] = v81[v83[3]] + v83[93 - (40 + 49)];
								v75 = v75 + ((7 - 5) - 1);
								v83 = v71[v75];
								v81[v83[2 + 0]] = v81[v83[852 - (254 + 595)]][v83[130 - (55 + (561 - (99 + 391)))]];
								v75 = v75 + ((1 + 0) - 0);
								v83 = v71[v75];
								v250 = v83[(7877 - 6085) - (573 + 1217)];
								v247, v249 = v74(v81[v250](v13(v81, v250 + 1, v83[8 - 5])));
								v76 = (v249 + v250) - 1;
								v248 = (0 - 0) + 0 + 0;
								for v822 = v250, v76 do
									local v823 = (0 - 0) - 0;
									while true do
										if (v823 == 0) then
											v248 = v248 + (940 - (714 + (1829 - (1032 + 572))));
											v81[v822] = v247[v248];
											break;
										end
									end
								end
								v75 = v75 + 1;
								v83 = v71[v75];
								v250 = v83[5 - (420 - (203 + 214))];
								v247, v249 = v74(v81[v250](v13(v81, v250 + ((1818 - (568 + 1249)) - 0), v76)));
								v76 = (v249 + v250) - (1 + 0 + 0);
								v248 = 0 - 0;
								for v824 = v250, v76 do
									v248 = v248 + (807 - (118 + (1652 - 964)));
									v81[v824] = v247[v248];
								end
								v75 = v75 + (3 - 2);
								v83 = v71[v75];
								v250 = v83[50 - (25 + 23)];
								v247 = {v81[v250](v13(v81, v250 + (1887 - (927 + 959)), v76))};
								v248 = 0;
								for v827 = v250, v83[13 - 9] do
									v248 = v248 + (733 - (16 + 716));
									v81[v827] = v247[v248];
								end
								v75 = v75 + (1 - (1306 - (913 + 393)));
								v83 = v71[v75];
								v81[v83[99 - (11 + 86)]] = v81[v83[6 - 3]];
								v75 = v75 + (286 - (175 + (310 - 200)));
								v83 = v71[v75];
								v81[v83[2]] = v81[v83[6 - 3]];
								v75 = v75 + 1;
								v83 = v71[v75];
								v81[v83[9 - 7]] = v83[1799 - (503 + 1293)];
								v75 = v75 + (2 - 1);
								v83 = v71[v75];
								v75 = v83[3 + 0];
							end
						elseif ((1472 == 1472) and (v84 <= (1081 - (810 + 251)))) then
							if ((4520 > 4486) and (4794 >= 3564) and (v84 <= (12 + 4))) then
								if ((v84 <= (5 + 9)) or (622 > 1409)) then
									v81[v83[2 + 0]] = v81[v83[536 - (43 + 490)]] / v81[v83[737 - (711 + 22)]];
								elseif (v84 == (58 - 43)) then
									v81[v83[861 - (240 + 619)]] = v62[v83[3]];
								else
									local v271;
									v81[v83[2]] = v81[v83[1 + (2 - 0)]];
									v75 = v75 + (1 - 0);
									v83 = v71[v75];
									v81[v83[1 + 1]] = v83[1747 - (1344 + 400)];
									v75 = v75 + (406 - (255 + 150));
									v83 = v71[v75];
									v81[v83[2]] = v83[3 + 0];
									v75 = v75 + 1 + 0;
									v83 = v71[v75];
									v271 = v83[8 - 6];
									v81[v271] = v81[v271](v13(v81, v271 + ((413 - (269 + 141)) - 2), v83[1742 - (404 + 1335)]));
									v75 = v75 + 1;
									v83 = v71[v75];
									v81[v83[(907 - 499) - (183 + 223)]] = v83[3 - 0];
									v75 = v75 + 1 + 0;
									v83 = v71[v75];
									v81[v83[2]] = #v81[v83[2 + 1]];
									v75 = v75 + 1;
									v83 = v71[v75];
									if (v81[v83[339 - (10 + 327)]] ~= v81[v83[4]]) then
										v75 = v75 + 1;
									else
										v75 = v83[3 + 0];
									end
								end
							elseif (v84 <= (356 - (118 + (2201 - (362 + 1619))))) then
								if ((v84 == ((1631 - (950 + 675)) + 11)) or (261 <= 137)) then
									local v282;
									v81[v83[451 - (108 + 341)]] = v81[v83[2 + 1]];
									v75 = v75 + 1 + 0;
									v83 = v71[v75];
									v81[v83[(1187 - (216 + 963)) - 6]] = v83[3];
									v75 = v75 + ((2781 - (485 + 802)) - (711 + 782));
									v83 = v71[v75];
									v81[v83[3 - 1]] = #v81[v83[472 - (270 + 199)]];
									v75 = v75 + 1 + 0;
									v83 = v71[v75];
									v81[v83[2]] = v83[1822 - (580 + 1239)];
									v75 = v75 + ((561 - (432 + 127)) - 1);
									v83 = v71[v75];
									v81[v83[2]] = #v81[v83[3 + (1073 - (1065 + 8))]];
									v75 = v75 + 1 + 0;
									v83 = v71[v75];
									v282 = v83[2 + 0];
									v81[v282] = v81[v282](v13(v81, v282 + 1 + 0, v83[3]));
									v75 = v75 + 1;
									v83 = v71[v75];
									v81[v83[4 - 2]] = v83[2 + 1];
									v75 = v75 + (1168 - (645 + 522));
									v83 = v71[v75];
									v81[v83[1792 - (1010 + 780)]] = #v81[v83[3 + 0]];
									v75 = v75 + (4 - (1604 - (635 + 966)));
									v83 = v71[v75];
									if ((v81[v83[(4 + 1) - 3]] == v81[v83[4]]) or (653 >= 1699)) then
										v75 = v75 + (1837 - (1045 + (833 - (5 + 37))));
									else
										v75 = v83[3];
									end
								else
									local v296;
									local v297;
									local v298;
									v81[v83[4 - 2]] = {};
									v75 = v75 + 1;
									v83 = v71[v75];
									v81[v83[2 - 0]] = v62[v83[508 - (351 + 154)]];
									v75 = v75 + (1575 - (1281 + 293));
									v83 = v71[v75];
									v298 = v83[(666 - 398) - (28 + 238)];
									v81[v298] = v81[v298]();
									v75 = v75 + (2 - 1);
									v83 = v71[v75];
									v81[v83[1561 - (575 + 806 + 178)]] = v62[v83[3]];
									v75 = v75 + 1 + 0;
									v83 = v71[v75];
									v298 = v83[2 + (0 - 0)];
									v81[v298] = v81[v298]();
									v75 = v75 + 1;
									v83 = v71[v75];
									for v830 = v83[2], v83[1 + 1 + 1] do
										v81[v830] = nil;
									end
									v75 = v75 + (3 - 2);
									v83 = v71[v75];
									v298 = v83[2 + (0 - 0)];
									v297 = v81[v298];
									v296 = v83[473 - (381 + 89)];
									for v832 = 1, v296 do
										v297[v832] = v81[v298 + v832];
									end
								end
							elseif ((v84 == ((64 - 47) + (3 - 1))) or (2065 == 4654)) then
								v81[v83[2]] = v81[v83[3 + 0]] % v83[4];
							else
								local v310 = 0 - 0;
								local v311;
								local v312;
								while true do
									if (v310 == (1160 - (1074 + (195 - 113)))) then
										v75 = v75 + (1 - 0);
										v83 = v71[v75];
										v312 = v83[1786 - (154 + 60 + 1570)];
										v76 = (v312 + v82) - (1456 - (990 + 465));
										for v1142 = v312, v76 do
											v311 = v77[v1142 - v312];
											v81[v1142] = v311;
										end
										v310 = 3 + 2;
									end
									if (v310 == 2) then
										v75 = v75 + (530 - (318 + 211));
										v83 = v71[v75];
										v81[v83[2]] = {};
										v75 = v75 + 1;
										v83 = v71[v75];
										v310 = (9 - 7) + 1;
									end
									if (3 == v310) then
										v81[v83[2 + 0]] = v81[v83[11 - 8]];
										v75 = v75 + 1;
										v83 = v71[v75];
										v312 = v83[2];
										v81[v312] = v81[v312](v13(v81, v312 + (1727 - (1668 + 58)), v83[629 - (512 + 114)]));
										v310 = 10 - 6;
									end
									if ((2518 <= 3050) and (v310 == (0 - 0))) then
										v311 = nil;
										v312 = nil;
										v81[v83[2]] = v81[v83[10 - 7]];
										v75 = v75 + 1;
										v83 = v71[v75];
										v310 = 1588 - (963 + 624);
									end
									if (v310 == (2 + 1 + 2)) then
										v75 = v75 + 1 + (846 - (518 + 328));
										v83 = v71[v75];
										v312 = v83[2 + 0];
										do
											return v81[v312](v13(v81, v312 + ((6 - 3) - (2 - 0)), v76));
										end
										v75 = v75 + (1995 - (109 + 1885));
										v310 = 1475 - (1269 + 200);
									end
									if (v310 == 6) then
										v83 = v71[v75];
										v312 = v83[3 - 1];
										do
											return v13(v81, v312, v76);
										end
										v75 = v75 + (816 - (98 + 717));
										v83 = v71[v75];
										v310 = 833 - (802 + 24);
									end
									if ((4807 > 177) and (v310 == (11 - 4))) then
										do
											return;
										end
										break;
									end
									if (v310 == 1) then
										v81[v83[2 - 0]] = v81[v83[1 + 2]];
										v75 = v75 + 1 + 0;
										v83 = v71[v75];
										v312 = v83[2];
										v81[v312] = v81[v312]();
										v310 = 1 + 1;
									end
								end
							end
						elseif ((3663 >= 863) and (v84 <= (6 + 18))) then
							if ((4018 <= 4690) and (v84 <= (61 - 39))) then
								if (v84 > (69 - 48)) then
									local v313;
									local v314;
									local v315;
									v81[v83[1 + 1]] = #v81[v83[2 + 1]];
									v75 = v75 + 1 + 0;
									v83 = v71[v75];
									v81[v83[2 + 0]] = v62[v83[2 + 1]];
									v75 = v75 + (1434 - (797 + 636));
									v83 = v71[v75];
									v315 = v83[(326 - (301 + 16)) - 7];
									v81[v315] = v81[v315]();
									v75 = v75 + ((4748 - 3128) - (1427 + 192));
									v83 = v71[v75];
									v81[v83[(2 - 1) + 1]] = v83[3];
									v75 = v75 + (2 - 1);
									v83 = v71[v75];
									v315 = v83[2 + 0];
									v314 = v81[v315];
									v313 = v81[v315 + 2];
									if ((v313 > 0) or (4584 < 2479)) then
										if ((1753 >= 1055) and ((v314 > v81[v315 + 1]) or (392 > 2140))) then
											v75 = v83[7 - 4];
										else
											v81[v315 + 2 + 1] = v314;
										end
									elseif ((2136 >= 510) and (v314 < v81[v315 + 1])) then
										v75 = v83[329 - (192 + 134)];
									else
										v81[v315 + (1279 - (316 + 960))] = v314;
									end
								else
									v81[v83[2]] = v81[v83[3]] + v81[v83[3 + 0 + 1 + 0]];
								end
							elseif (v84 > 23) then
								local v327;
								local v328, v329;
								local v330;
								v81[v83[2]] = v62[v83[3 + 0]];
								v75 = v75 + 1 + 0;
								v83 = v71[v75];
								v81[v83[7 - 5]] = v81[v83[554 - (83 + 468)]];
								v75 = v75 + 1;
								v83 = v71[v75];
								v81[v83[2]] = v83[3];
								v75 = v75 + (1807 - (1202 + 604));
								v83 = v71[v75];
								v81[v83[(18 - 9) - 7]] = v83[4 - 1];
								v75 = v75 + ((2 + 0) - 1);
								v83 = v71[v75];
								v330 = v83[327 - (45 + 280)];
								v328, v329 = v74(v81[v330](v13(v81, v330 + 1 + 0, v83[3 + 0])));
								v76 = (v329 + v330) - (1 + 0);
								v327 = 0 + 0;
								for v835 = v330, v76 do
									local v836 = 0;
									while true do
										if (v836 == 0) then
											v327 = v327 + 1 + 0 + 0;
											v81[v835] = v328[v327];
											break;
										end
									end
								end
								v75 = v75 + (1 - 0);
								v83 = v71[v75];
								v330 = v83[1913 - (340 + 1571)];
								v81[v330] = v81[v330](v13(v81, v330 + 1 + 0, v76));
								v75 = v75 + (1773 - (1733 + 39));
								v83 = v71[v75];
								v62[v83[3]] = v81[v83[5 - (9 - 6)]];
								v75 = v75 + (1035 - (125 + 294 + 615));
								v83 = v71[v75];
								v81[v83[1950 - (1096 + (1871 - (829 + 190)))]] = v83[3];
								v75 = v75 + 1 + 0;
								v83 = v71[v75];
								do
									return v81[v83[2 - 0]];
								end
								v75 = v75 + 1 + (0 - 0);
								v83 = v71[v75];
								v75 = v83[515 - (409 + 103)];
							else
								v81[v83[238 - ((58 - 12) + 190)]] = v81[v83[(135 - 37) - ((126 - 75) + 44)]] + v83[2 + 2];
							end
						elseif (v84 <= (1343 - (1114 + 203))) then
							if ((2377 < 2472) and (v84 > (751 - (228 + 498)))) then
								v81[v83[1 + 1]] = v81[v83[2 + 1]] - v83[667 - (174 + 489)];
							elseif ((v83[5 - 3] <= v83[4]) or (4531 <= 3105)) then
								v75 = v75 + (1906 - (830 + 1075));
							else
								v75 = v83[527 - (303 + 221)];
							end
						elseif (v84 == (1296 - (231 + 1038))) then
							local v348 = v83[2 + 0];
							v81[v348] = v81[v348]();
						else
							v81[v83[1164 - (171 + 991)]] = v81[v83[12 - 9]];
						end
					elseif ((3863 == 3863) and (v84 <= (112 - 70))) then
						if (((3203 > 2189) and (v84 <= (87 - 52))) or (2764 > 2956)) then
							if ((989 < 4245) and (v84 <= (6 + 19 + 2 + 4))) then
								if ((3192 <= 3445) and (v84 <= (101 - 72))) then
									local v139 = v83[2];
									v81[v139] = v81[v139](v13(v81, v139 + (2 - 1), v76));
								elseif (v84 == ((145 - 97) - 18)) then
									if ((4775 > 3465) and (v83[6 - 4] == v81[v83[(1182 + 70) - (111 + 1137)]])) then
										v75 = v75 + (159 - (91 + 67));
									else
										v75 = v83[8 - 5];
									end
								else
									local v352;
									local v353;
									local v354;
									v81[v83[1 + 1]] = v62[v83[526 - (423 + 100)]];
									v75 = v75 + 1 + 0;
									v83 = v71[v75];
									v81[v83[2]] = v62[v83[3]];
									v75 = v75 + (2 - (614 - (520 + 93)));
									v83 = v71[v75];
									v81[v83[2]] = v62[v83[3]];
									v75 = v75 + 1 + 0;
									v83 = v71[v75];
									v81[v83[773 - (326 + 445)]] = v81[v83[13 - 10]] + v83[8 - 4];
									v75 = v75 + (2 - 1);
									v83 = v71[v75];
									v354 = v83[713 - (530 + 181)];
									v353 = {v81[v354](v13(v81, v354 + (33 - (19 + 13)), v83[4 - 1]))};
									v352 = 0 - 0;
									for v837 = v354, v83[11 - 7] do
										v352 = v352 + (277 - (259 + 17)) + 0;
										v81[v837] = v353[v352];
									end
									v75 = v75 + (1 - 0);
									v83 = v71[v75];
									v81[v83[3 - 1]] = v81[v83[1815 - (1293 + 519)]];
									v75 = v75 + (1 - 0);
									v83 = v71[v75];
									v81[v83[2]] = v81[v83[7 - 4]];
									v75 = v75 + (1 - 0);
									v83 = v71[v75];
									v81[v83[8 - 6]] = v81[v83[6 - 3]];
									v75 = v75 + 1;
									v83 = v71[v75];
									v81[v83[2]] = v81[v83[2 + 1]];
									v75 = v75 + 1 + 0;
									v83 = v71[v75];
									v81[v83[4 - 2]] = v62[v83[1 + 2]];
									v75 = v75 + 1 + 0;
									v83 = v71[v75];
									v81[v83[2]] = v81[v83[2 + 1]] + v83[1100 - (709 + 387)];
									v75 = v75 + (1859 - (673 + 1185));
									v83 = v71[v75];
									v81[v83[2]] = v81[v83[8 - 5]] + v83[12 - 8];
									v75 = v75 + (1 - 0);
									v83 = v71[v75];
									v81[v83[2 + 0]] = v81[v83[1 + 2 + 0 + 0]] + v83[5 - 1];
									v75 = v75 + 1 + 0;
									v83 = v71[v75];
									v62[v83[5 - 2]] = v81[v83[2]];
									v75 = v75 + (1 - 0);
									v83 = v71[v75];
									v81[v83[1882 - (446 + 1434)]] = v83[3];
									v75 = v75 + (1284 - (1040 + 243));
									v83 = v71[v75];
									v75 = v83[8 - 5];
								end
							elseif (v84 <= (1880 - ((1892 - 1333) + 1288))) then
								if (v84 == 32) then
									local v375 = v83[1933 - (609 + 1322)];
									do
										return v81[v375](v13(v81, v375 + (455 - (13 + (1032 - (396 + 195)))), v76));
									end
								else
									local v376 = 0;
									local v377;
									local v378;
									while true do
										if ((15 <= 390) and (v376 == (3 - 2))) then
											for v1151 = v377 + 1, v83[7 - 4] do
												v7(v378, v81[v1151]);
											end
											break;
										end
										if (((2545 >= 1717) and (v376 == ((0 - 0) - 0))) or (3711 < 507)) then
											v377 = v83[1 + 1];
											v378 = v81[v377];
											v376 = 3 - 2;
										end
									end
								end
							elseif (v84 == (13 + 21)) then
								local v379 = 0 + 0;
								local v380;
								local v381;
								while true do
									if ((((1761 - (440 + 1321)) - 0) == v379) or (4635 == 118)) then
										v380 = v83[2 + 0];
										v381 = v81[v380];
										v379 = 1 - 0;
									end
									if (v379 == (1 + 0)) then
										for v1152 = v380 + (1830 - (1059 + 770)) + 0, v76 do
											v7(v381, v81[v1152]);
										end
										break;
									end
								end
							else
								local v382 = 0 + 0;
								local v383;
								while true do
									if (v382 == 1) then
										v81[v83[2 + 0]] = v81[v83[3 + 0]];
										v75 = v75 + (434 - (153 + 280));
										v83 = v71[v75];
										v81[v83[5 - 3]] = v83[13 - 10];
										v382 = 2 + 0;
									end
									if (((545 - (424 + 121)) + 0) == v382) then
										v383 = nil;
										v81[v83[1 + 1 + 0]] = v62[v83[3 + 0]];
										v75 = v75 + 1 + (1347 - (641 + 706));
										v83 = v71[v75];
										v382 = 1 - 0;
									end
									if ((3276 <= 4677) and ((2 + 0) == v382)) then
										v75 = v75 + (668 - (89 + 578));
										v83 = v71[v75];
										v383 = v83[2 + 0];
										v81[v383] = v81[v383](v13(v81, v383 + (1 - 0), v83[3]));
										v382 = 1052 - (572 + 189 + 288);
									end
									if (v382 == 3) then
										v75 = v75 + 1 + 0;
										v83 = v71[v75];
										if ((2272 >= 1107) and (1226 < 3232) and (v81[v83[2 + 0]] == v83[1 + 3])) then
											v75 = v75 + 1;
										else
											v75 = v83[(529 - (249 + 191)) - (84 + 2)];
										end
										break;
									end
								end
							end
						elseif (v84 <= (62 - 24)) then
							if ((3767 > 706) and (v84 <= 36)) then
								local v141;
								local v142;
								local v143;
								v81[v83[2 + 0]] = {};
								v75 = v75 + (843 - (497 + 345));
								v83 = v71[v75];
								v81[v83[2]] = v62[v83[1 + 2]];
								v75 = v75 + 1 + 0;
								v83 = v71[v75];
								v81[v83[2]] = v62[v83[1336 - (605 + 728)]];
								v75 = v75 + 1 + 0;
								v83 = v71[v75];
								for v184 = v83[3 - (4 - 3)], v83[3] do
									v81[v184] = nil;
								end
								v75 = v75 + 1 + 0;
								v83 = v71[v75];
								v81[v83[7 - 5]] = v62[v83[3]];
								v75 = v75 + 1 + 0 + 0;
								v83 = v71[v75];
								v143 = v83[5 - 3];
								v142 = v81[v143];
								v141 = v83[3 + 0];
								for v186 = 490 - (457 + 32), v141 do
									v142[v186] = v81[v143 + v186];
								end
							elseif ((911 >= 521) and (v84 > (16 + 21))) then
								if ((3292 >= 1475) and (v81[v83[1404 - (832 + 570)]] ~= v83[4 + 0])) then
									v75 = v75 + 1 + 0;
								else
									v75 = v83[10 - 7];
								end
							elseif ((3804 > 3392) and ((v83[1 + 1] < v81[v83[800 - ((2266 - 1678) + 208)]]) or (4773 < 1343))) then
								v75 = v75 + 1;
							else
								v75 = v83[(435 - (183 + 244)) - 5];
							end
						elseif (v84 <= (1840 - (884 + 916))) then
							if ((v84 == (81 - 42)) or (1751 < 1528)) then
								if (v81[v83[2]] == v83[1 + 2 + 1]) then
									v75 = v75 + (654 - ((962 - (434 + 296)) + 421));
								else
									v75 = v83[3];
								end
							else
								v81[v83[1891 - (1569 + 320)]]();
							end
						elseif ((941 < 4267) and (v84 == (11 + 30))) then
							local v384 = (0 - 0) + 0;
							local v385;
							local v386;
							local v387;
							local v388;
							while true do
								if (v384 == (6 - (516 - (169 + 343)))) then
									for v1153 = v385, v76 do
										v388 = v388 + (606 - (278 + 38 + (508 - 219)));
										v81[v1153] = v386[v388];
									end
									break;
								end
								if (((1526 >= 1264) and (v384 == 1)) or (935 <= 162)) then
									v76 = (v387 + v385) - 1;
									v388 = 0 - 0;
									v384 = 1 + 1;
								end
								if (v384 == (1453 - (666 + 787))) then
									v385 = v83[427 - (360 + (190 - 125))];
									v386, v387 = v74(v81[v385](v13(v81, v385 + 1 + 0 + 0, v76)));
									v384 = 255 - (79 + (496 - 321));
								end
							end
						else
							v81[v83[2]] = v81[v83[3]] * v81[v83[4]];
						end
					elseif (v84 <= (76 - 27)) then
						if (v84 <= (36 + 9)) then
							if ((v84 <= (131 - 88)) or (3492 <= 964)) then
								v75 = v83[5 - 2];
							elseif (v84 > (943 - (503 + 396))) then
								local v390;
								local v391, v392;
								local v393;
								v81[v83[(1306 - (651 + 472)) - (92 + 68 + 21)]] = v62[v83[5 - 2]];
								v75 = v75 + 1 + 0;
								v83 = v71[v75];
								v81[v83[2]] = v81[v83[2 + 1]];
								v75 = v75 + 1 + (0 - 0);
								v83 = v71[v75];
								v81[v83[7 - 5]] = v81[v83[3]] + v83[1 + 3];
								v75 = v75 + (2 - 1);
								v83 = v71[v75];
								v81[v83[(485 - (397 + 86)) + 0]] = v81[v83[2 + 1]];
								v75 = v75 + (2 - 1);
								v83 = v71[v75];
								v393 = v83[1 + 1];
								v391, v392 = v74(v81[v393](v13(v81, v393 + (1 - 0), v83[1247 - (485 + 759)])));
								v76 = (v392 + v393) - (2 - 1);
								v390 = 1189 - (442 + (1623 - (423 + 453)));
								for v840 = v393, v76 do
									local v841 = 1135 - (832 + 303);
									while true do
										if ((414 < 1183) and (v841 == (946 - (9 + 79 + 114 + 744)))) then
											v390 = v390 + 1 + 0;
											v81[v840] = v391[v390];
											break;
										end
									end
								end
								v75 = v75 + 1;
								v83 = v71[v75];
								v393 = v83[2 + 0];
								v81[v393] = v81[v393](v13(v81, v393 + 1 + 0 + 0, v76));
								v75 = v75 + (790 - (766 + 19 + 4));
								v83 = v71[v75];
								v81[v83[9 - 7]][v81[v83[3 - 0]]] = v81[v83[10 - (6 + 0)]];
								v75 = v75 + (3 - 2);
								v83 = v71[v75];
								v81[v83[1075 - (1036 + 37)]] = v81[v83[3]] + v83[4];
								v75 = v75 + 1 + 0;
								v83 = v71[v75];
								v81[v83[3 - 1]] = v83[3 + 0];
							else
								v81[v83[1482 - (641 + 839)]] = v63[v83[916 - (910 + 3)]];
								v75 = v75 + (2 - 1);
								v83 = v71[v75];
								v81[v83[2]] = v81[v83[1687 - (1466 + 218)]][v83[2 + 2]];
								v75 = v75 + (1149 - (556 + 592));
								v83 = v71[v75];
								v81[v83[2]] = v63[v83[(1192 - (50 + 1140)) + 1]];
								v75 = v75 + 1;
								v83 = v71[v75];
								v81[v83[810 - (285 + 44 + 479)]] = v81[v83[3]][v83[858 - (174 + 680)]];
								v75 = v75 + (3 - 2);
								v83 = v71[v75];
								v81[v83[3 - 1]] = v63[v83[3 + 0 + 0]];
								v75 = v75 + 1;
								v83 = v71[v75];
								v81[v83[741 - (25 + 371 + (492 - 149))]] = v81[v83[1 + 2]][v83[1481 - (29 + 1448)]];
								v75 = v75 + (1390 - (135 + 1254));
								v83 = v71[v75];
								v81[v83[7 - 5]] = v63[v83[3]];
								v75 = v75 + (4 - 3);
								v83 = v71[v75];
								if ((4098 > 766) and not v81[v83[2]]) then
									v75 = v75 + 1;
								else
									v75 = v83[3];
								end
							end
						elseif (v84 <= (32 + 15)) then
							if ((v84 > 46) or (3904 <= 98)) then
								local v423;
								v81[v83[1529 - (389 + 1138)]] = v81[v83[3]];
								v75 = v75 + (575 - (102 + 342 + 130));
								v83 = v71[v75];
								v81[v83[2 + 0]] = v83[2 + 1];
								v75 = v75 + 1;
								v83 = v71[v75];
								v81[v83[2 + (596 - (157 + 439))]] = v83[3];
								v75 = v75 + ((2687 - 1141) - ((1063 - 743) + 1225));
								v83 = v71[v75];
								v423 = v83[2 - 0];
								v81[v423] = v81[v423](v13(v81, v423 + 1 + 0, v83[1467 - (157 + 1307)]));
								v75 = v75 + (1860 - (821 + 1038));
								v83 = v71[v75];
								v81[v83[4 - 2]] = v81[v83[1 + 2]];
								v75 = v75 + ((2 - 1) - 0);
								v83 = v71[v75];
								v81[v83[1 + 1]] = v62[v83[7 - 4]];
								v75 = v75 + (1027 - (834 + 192));
								v83 = v71[v75];
								v81[v83[1 + 1]] = v81[v83[(919 - (782 + 136)) + 2]];
								v75 = v75 + 1 + 0;
								v83 = v71[v75];
								v81[v83[2 - 0]] = v83[307 - (300 + 4)];
								v75 = v75 + 1 + 0;
								v83 = v71[v75];
								v423 = v83[5 - 3];
								v81[v423] = v81[v423](v13(v81, v423 + 1, v83[365 - (112 + 250)]));
								v75 = v75 + (856 - (112 + 743));
								v83 = v71[v75];
								if (v81[v83[1 + 1]] == v83[9 - 5]) then
									v75 = v75 + 1 + 0;
								else
									v75 = v83[3];
								end
							else
								local v441 = 0 + 0;
								while true do
									if (v441 == 4) then
										v81[v83[2]] = v81[v83[3 + (1171 - (1026 + 145))]][v81[v83[2 + 2]]];
										v75 = v75 + 1 + 0;
										v83 = v71[v75];
										v441 = 1419 - (1001 + 413);
									end
									if ((v441 == 7) or (4255 <= 549)) then
										do
											return;
										end
										break;
									end
									if ((v441 == (11 - 6)) or (2726 == 4578)) then
										v81[v83[884 - (42 + 202 + 638)]] = v81[v83[3]][v81[v83[697 - (627 + 66)]]];
										v75 = v75 + (2 - 1);
										v83 = v71[v75];
										v441 = 608 - (512 + (808 - (493 + 225)));
									end
									if ((1909 - (1665 + 241)) == v441) then
										v81[v83[719 - ((1371 - 998) + 344)]] = #v81[v83[2 + 1]];
										v75 = v75 + 1 + 0;
										v83 = v71[v75];
										v441 = 10 - 6;
									end
									if (v441 == (1 - 0)) then
										v81[v83[1101 - (35 + 1064)]] = v62[v83[3 + 0]];
										v75 = v75 + (2 - 1);
										v83 = v71[v75];
										v441 = 1 + 1;
									end
									if ((v441 == (1238 - (298 + 938))) or (472 > 516)) then
										v81[v83[1261 - (233 + 1026)]] = v83[1669 - (636 + 1030)];
										v75 = v75 + 1 + 0;
										v83 = v71[v75];
										v441 = 3;
									end
									if (v441 == (4 + 2 + (0 - 0))) then
										do
											return v81[v83[2]];
										end
										v75 = v75 + 1 + 0;
										v83 = v71[v75];
										v441 = 1 + 6;
									end
									if (v441 == (221 - (55 + 166))) then
										v81[v83[1 + 1]] = v62[v83[1 + 2]];
										v75 = v75 + (3 - 2);
										v83 = v71[v75];
										v441 = 298 - (36 + 261);
									end
								end
							end
						elseif (v84 > (83 - 35)) then
							local v442;
							v81[v83[1370 - (34 + 1334)]] = v62[v83[3]];
							v75 = v75 + 1 + 0;
							v83 = v71[v75];
							v81[v83[2 + 0]] = v62[v83[3]];
							v75 = v75 + (1284 - (1035 + 248));
							v83 = v71[v75];
							v81[v83[23 - (20 + 1)]] = v62[v83[1 + 2]];
							v75 = v75 + 1;
							v83 = v71[v75];
							v81[v83[2 + 0]] = v81[v83[322 - (134 + 185)]] + v81[v83[1137 - ((1568 - 1019) + 171 + 413)]];
							v75 = v75 + (686 - (314 + 371));
							v83 = v71[v75];
							v81[v83[(9 - 3) - 4]] = v81[v83[3]] - v83[972 - (478 + 490)];
							v75 = v75 + 1;
							v83 = v71[v75];
							v442 = v83[2 + 0];
							v81[v442] = v81[v442](v13(v81, v442 + 1, v83[1175 - (786 + 386)]));
							v75 = v75 + 1;
							v83 = v71[v75];
							v81[v83[2]] = v81[v83[9 - (1601 - (210 + 1385))]];
							v75 = v75 + (1380 - (1055 + 324));
							v83 = v71[v75];
							v81[v83[1342 - (1093 + 247)]] = v62[v83[3]];
							v75 = v75 + 1;
							v83 = v71[v75];
							v81[v83[2 + (1689 - (1201 + 488))]] = v81[v83[1 + 2]] + v81[v83[(10 + 5) - (19 - 8)]];
							v75 = v75 + (3 - 2);
							v83 = v71[v75];
							v62[v83[8 - 5]] = v81[v83[2 - 0]];
							v75 = v75 + (2 - 1);
							v83 = v71[v75];
							v81[v83[2]] = v83[588 - (352 + 233)];
							v75 = v75 + 1;
							v83 = v71[v75];
							v75 = v83[2 + 1];
						else
							local v460;
							local v461;
							local v460, v462;
							local v463;
							v81[v83[7 - 5]] = v81[v83[3]];
							v75 = v75 + 1;
							v83 = v71[v75];
							v81[v83[6 - 4]] = v81[v83[3 + 0]][v81[v83[4]]];
							v75 = v75 + (2 - (2 - 1));
							v83 = v71[v75];
							v81[v83[690 - (364 + 324)]] = v62[v83[7 - 4]];
							v75 = v75 + (2 - 1);
							v83 = v71[v75];
							v81[v83[1 + 1]] = v81[v83[12 - 9]];
							v75 = v75 + ((1 + 0) - 0);
							v83 = v71[v75];
							v81[v83[2]] = v81[v83[3]] + v83[4];
							v75 = v75 + (2 - 1);
							v83 = v71[v75];
							v81[v83[1270 - (1249 + 19)]] = v81[v83[3 + 0]][v83[15 - 11]];
							v75 = v75 + (1087 - ((1950 - 1264) + 400));
							v83 = v71[v75];
							v463 = v83[2 + 0];
							v460, v462 = v74(v81[v463](v13(v81, v463 + ((804 - (489 + 85)) - (73 + 156)), v83[1504 - (277 + 1224)])));
							v76 = (v462 + v463) - 1;
							v461 = 0 + 0;
							for v842 = v463, v76 do
								local v843 = 0;
								while true do
									if ((4264 > 983) and (v843 == (1493 - (663 + 830)))) then
										v461 = v461 + (812 - (634 + 87 + 90));
										v81[v842] = v460[v461];
										break;
									end
								end
							end
							v75 = v75 + (2 - 1);
							v83 = v71[v75];
							v463 = v83[1 + 1];
							v460, v462 = v74(v81[v463](v13(v81, v463 + (3 - 2), v76)));
							v76 = (v462 + v463) - (471 - (224 + 246));
							v461 = 875 - (461 + 414);
							for v844 = v463, v76 do
								v461 = v461 + ((1 + 0) - 0);
								v81[v844] = v460[v461];
							end
							v75 = v75 + (1 - 0);
							v83 = v71[v75];
							v463 = v83[1 + 1];
							v460 = {v81[v463](v13(v81, v463 + 1 + 0, v76))};
							v461 = 0;
							for v847 = v463, v83[4] do
								v461 = v461 + 1;
								v81[v847] = v460[v461];
							end
							v75 = v75 + 1;
							v83 = v71[v75];
							v81[v83[2]] = v81[v83[5 - (1 + 1)]];
							v75 = v75 + (3 - 2);
							v83 = v71[v75];
							v81[v83[515 - (203 + 310)]] = v81[v83[1996 - (1238 + 755)]];
							v75 = v75 + 1;
							v83 = v71[v75];
							v81[v83[2]] = v83[1 + 2];
							v75 = v75 + (1535 - (709 + 79 + 746));
							v83 = v71[v75];
							v75 = v83[4 - 1];
						end
					elseif ((386 < 4511) and ((v84 <= (76 - 23)) or (4623 == 1784))) then
						if ((4795 > 3065) and (v84 <= (915 - (196 + 659 + 9)))) then
							if (v84 > 50) then
								v81[v83[7 - 5]] = v83[5 - 2] ~= (833 - (171 + 662));
							else
								v81[v83[95 - (4 + 89)]] = v81[v83[3]][v83[(263 - (172 + 78)) - 9]];
							end
						elseif ((v84 == (19 + 33)) or (4884 == 1777)) then
							v81[v83[8 - 6]] = v29(v72[v83[2 + (1 - 0)]], nil, v63);
						else
							local v487;
							v81[v83[2]] = v62[v83[3]];
							v75 = v75 + (1487 - (35 + 1451));
							v83 = v71[v75];
							v487 = v83[2];
							v81[v487] = v81[v487]();
							v75 = v75 + (1454 - (28 + 1425));
							v83 = v71[v75];
							v81[v83[2]] = v81[v83[1996 - (941 + 1052)]] - v83[4 + 0];
							v75 = v75 + (1515 - (822 + 692));
							v83 = v71[v75];
							do
								return v81[v83[2 - 0]];
							end
							v75 = v75 + 1;
							v83 = v71[v75];
							do
								return;
							end
						end
					elseif ((546 <= 1071) and (v84 <= (26 + 29))) then
						if ((v84 == (351 - (45 + 252))) or (2997 == 3076)) then
							local v493;
							local v494;
							local v495;
							v81[v83[1 + 1]] = v81[v83[3 + 0]];
							v75 = v75 + 1 + (0 - 0);
							v83 = v71[v75];
							v81[v83[(2 + 2) - (1 + 1)]] = v83[3];
							v75 = v75 + (434 - (114 + 319));
							v83 = v71[v75];
							v81[v83[2 - 0]] = #v81[v83[3]];
							v75 = v75 + (1 - 0);
							v83 = v71[v75];
							v81[v83[2 + 0]] = v83[4 - 1];
							v75 = v75 + (1 - 0);
							v83 = v71[v75];
							v495 = v83[1965 - (556 + (2356 - 949))];
							v494 = v81[v495];
							v493 = v81[v495 + 2];
							if ((v493 > (1206 - (741 + 465))) or (1158 >= 4765)) then
								if ((v494 > v81[v495 + (466 - (170 + 295))]) or (844 == 250)) then
									v75 = v83[2 + 1];
								else
									v81[v495 + 3 + 0] = v494;
								end
							elseif ((v494 < v81[v495 + (2 - 1)]) or (4862 <= 3641)) then
								v75 = v83[3];
							else
								v81[v495 + 3 + 0] = v494;
							end
						elseif (v81[v83[2 + 0]] == v81[v83[3 + 1]]) then
							v75 = v75 + (1231 - (957 + 273));
						else
							v75 = v83[1 + 2];
						end
					elseif ((v84 == (23 + (40 - 7))) or (4757 < 3588)) then
						if (v81[v83[7 - 5]] <= v83[2 + 2]) then
							v75 = v75 + (2 - 1);
						else
							v75 = v83[(5 + 4) - 6];
						end
					else
						local v507;
						local v508;
						v81[v83[9 - 7]] = v62[v83[1783 - (389 + 1391)]];
						v75 = v75 + 1 + 0 + 0;
						v83 = v71[v75];
						v81[v83[1 + 1]] = v83[6 - 3];
						v75 = v75 + 1;
						v83 = v71[v75];
						v508 = v83[953 - (783 + 168)];
						v76 = (v508 + v82) - ((11 - 8) - (4 - 2));
						for v850 = v508, v76 do
							local v851 = 0 + 0;
							while true do
								if (v851 == 0) then
									v507 = v77[v850 - v508];
									v81[v850] = v507;
									break;
								end
							end
						end
						v75 = v75 + (312 - (309 + 2));
						v83 = v71[v75];
						v508 = v83[5 - 3];
						v81[v508] = v81[v508](v13(v81, v508 + (1213 - (1090 + 122)), v76));
						v75 = v75 + 1 + 0 + 0;
						v83 = v71[v75];
						v81[v83[6 - 4]] = v81[v83[3 + 0]] - v83[4];
						v75 = v75 + 1;
						v83 = v71[v75];
						v81[v83[1120 - (628 + 490)]] = v83[1 + 2];
					end
				elseif ((2850 > 997) and (v84 <= 86)) then
					if (v84 <= ((100 + 75) - (551 - (133 + 314)))) then
						if (v84 <= 64) then
							if ((4180 <= 4502) and (v84 <= (274 - 214))) then
								if (v84 <= (832 - (431 + 343))) then
									local v155 = 0 - 0;
									local v156;
									local v157;
									local v158;
									while true do
										if (v155 == (2 - 1)) then
											v158 = v81[v156 + 2 + 0];
											if ((v158 > 0) or (197 > 4460)) then
												if (v157 > v81[v156 + 1 + 0]) then
													v75 = v83[3];
												else
													v81[v156 + (1698 - (556 + 1139))] = v157;
												end
											elseif (v157 < v81[v156 + (16 - (6 + 9))]) then
												v75 = v83[3];
											else
												v81[v156 + 1 + 2] = v157;
											end
											break;
										end
										if (v155 == 0) then
											v156 = v83[2 + 0];
											v157 = v81[v156];
											v155 = 1;
										end
									end
								elseif (v84 > (228 - (28 + 141))) then
									v81[v83[1 + 1]][v81[v83[(1 + 2) - 0]]] = v81[v83[3 + 1]];
									v75 = v75 + 1;
									v83 = v71[v75];
									v81[v83[2]] = v81[v83[(1533 - (199 + 14)) - (486 + 831)]][v83[(35 - 25) - 6]];
									v75 = v75 + (3 - 2);
									v83 = v71[v75];
									v81[v83[(1550 - (647 + 902)) + 1]] = v81[v83[9 - 6]][v81[v83[1267 - (668 + 595)]]];
									v75 = v75 + (2 - 1) + 0;
									v83 = v71[v75];
									v81[v83[(234 - (85 + 148)) + 1]][v81[v83[8 - 5]]] = v81[v83[294 - (23 + 267)]];
									v75 = v75 + ((3234 - (426 + 863)) - (1129 + 815));
									v83 = v71[v75];
									v81[v83[389 - ((1736 - 1365) + 16)]] = v83[1753 - ((2980 - (873 + 781)) + (566 - 142))];
								elseif ((v81[v83[2]] <= v81[v83[7 - 3]]) or (149 == 893)) then
									v75 = v75 + (3 - (4 - 2));
								else
									v75 = v83[3];
								end
							elseif (v84 <= (180 - (88 + 30))) then
								if ((v84 > (832 - (720 + 51))) or (475 < 230)) then
									local v531 = v83[4 - 2];
									do
										return v81[v531](v13(v81, v531 + (1777 - (175 + 246 + 1355)), v83[4 - 1]));
									end
								else
									local v532;
									local v533;
									local v534;
									local v535;
									local v536;
									local v537;
									local v538;
									v81[v83[1 + 1]] = v81[v83[3]];
									v75 = v75 + (1084 - (286 + 797));
									v83 = v71[v75];
									v81[v83[7 - 5]] = v83[4 - 1];
									v75 = v75 + (440 - (397 + 42));
									v83 = v71[v75];
									v81[v83[1 + 1]] = v81[v83[803 - (24 + 776)]];
									v75 = v75 + 1;
									v83 = v71[v75];
									v538 = v83[2 - 0];
									v81[v538] = v81[v538]();
									v75 = v75 + (786 - (222 + 563));
									v83 = v71[v75];
									v538 = v83[3 - 1];
									v76 = (v538 + v82) - (1 + 0);
									for v855 = v538, v76 do
										v537 = v77[v855 - v538];
										v81[v855] = v537;
									end
									v75 = v75 + 1;
									v83 = v71[v75];
									v538 = v83[192 - (23 + 167)];
									do
										return v81[v538](v13(v81, v538 + (1799 - (690 + 1108)), v76));
									end
									v75 = v75 + (3 - 2) + 0;
									v83 = v71[v75];
									v538 = v83[2 + 0];
									do
										return v13(v81, v538, v76);
									end
									v75 = v75 + (849 - (40 + 808));
									v83 = v71[v75];
									v538 = v83[1 + 1];
									v536 = {};
									for v858 = 3 - 2, #v80 do
										v535 = v80[v858];
										for v910 = 0 + 0, #v535 do
											local v911 = 0;
											while true do
												if ((69 <= 137) and ((0 + (0 - 0)) == v911)) then
													v534 = v535[v910];
													v533 = v534[(2 - 1) + (1947 - (414 + 1533))];
													v911 = 572 - (47 + 524);
												end
												if (v911 == 1) then
													v532 = v534[2 + 0 + 0];
													if ((2296 == 2296) and (v533 == v81) and (v532 >= v538)) then
														local v1207 = 0 - 0;
														while true do
															if (((1037 < 1746) and ((0 - 0) == v1207)) or (532 >= 1376)) then
																v536[v532] = v533[v532];
																v534[2 - 1] = v536;
																break;
															end
														end
													end
													break;
												end
											end
										end
									end
									v75 = v75 + (1727 - (1165 + 561));
									v83 = v71[v75];
									do
										return;
									end
								end
							elseif ((1698 < 2725) and (v84 == (2 + 61))) then
								if ((3738 >= 3692) and (v81[v83[6 - 4]] ~= v81[v83[2 + 2]])) then
									v75 = v75 + (480 - (341 + 138));
								else
									v75 = v83[1 + (557 - (443 + 112))];
								end
							else
								local v551 = v83[2];
								local v552, v553 = v74(v81[v551](v13(v81, v551 + (1 - 0), v83[3])));
								v76 = (v553 + v551) - (327 - (89 + 237));
								local v554 = 0 - 0;
								for v860 = v551, v76 do
									v554 = v554 + 1;
									v81[v860] = v552[v554];
								end
							end
						elseif ((v84 <= (140 - 73)) or (3822 < 823)) then
							if (v84 <= 65) then
								v81[v83[883 - (581 + 300)]] = v81[v83[1223 - (855 + 365)]] - v81[v83[4]];
							elseif ((v84 == (156 - 90)) or (4962 == 3146)) then
								v81[v83[2]] = {};
							else
								v81[v83[2]] = v83[1 + (1481 - (888 + 591))];
							end
						elseif ((v84 <= 69) or (475 > 4146)) then
							if (v84 > (1303 - (1030 + 205))) then
								if ((4064 == 4064) and (not v81[v83[(5 - 3) + 0]] or (121 >= 129))) then
									v75 = v75 + 1 + 0 + 0;
								else
									v75 = v83[3];
								end
							else
								v62[v83[(1088 - 799) - (156 + 130)]] = v81[v83[2]];
							end
						elseif ((v84 == (159 - 89)) or (2058 > 4958)) then
							v81[v83[2 - 0]] = v81[v83[5 - 2]] * v83[4];
							v75 = v75 + 1 + 0;
							v83 = v71[v75];
							v81[v83[2]] = v81[v83[3]] + v81[v83[4]];
							v75 = v75 + 1;
							v83 = v71[v75];
							v81[v83[2 + 0]] = v81[v83[72 - (4 + 6 + 59)]] * v83[4];
							v75 = v75 + 1 + 0;
							v83 = v71[v75];
							v81[v83[9 - 7]] = v81[v83[1166 - (671 + 492)]] + v81[v83[4 + 0]];
							v75 = v75 + (1216 - (369 + 846));
							v83 = v71[v75];
							v81[v83[2]] = v81[v83[1 + 2]] + v81[v83[4 + 0]];
							v75 = v75 + (1946 - (1036 + 909));
							v83 = v71[v75];
							do
								return v81[v83[2 + 0]];
							end
						else
							local v565 = 0 + 0;
							local v566;
							local v567;
							while true do
								if (v565 == (0 - (0 + 0))) then
									v566 = v83[205 - ((20 - 9) + 192)];
									v567 = {};
									v565 = 1 + 0;
								end
								if ((1759 == 1759) and (v565 == (176 - ((250 - 115) + 40)))) then
									for v1166 = 1679 - (136 + 1542), #v80 do
										local v1167 = v80[v1166];
										for v1192 = 0, #v1167 do
											local v1193 = 0 - 0;
											local v1194;
											local v1195;
											local v1196;
											while true do
												if (v1193 == (1 + 0)) then
													v1196 = v1194[4 - 2];
													if (((v1195 == v81) and (v1196 >= v566)) or (4543 == 358)) then
														v567[v1196] = v1195[v1196];
														v1194[1 - 0] = v567;
													end
													break;
												end
												if ((2003 == 2003) and ((176 - (50 + 126)) == v1193)) then
													v1194 = v1167[v1192];
													v1195 = v1194[1];
													v1193 = 2 - 1;
												end
											end
										end
									end
									break;
								end
							end
						end
					elseif (v84 <= (18 + (196 - 136))) then
						if (v84 <= (1487 - (1233 + 180))) then
							if (v84 <= (1041 - (522 + 447))) then
								v81[v83[2]] = v83[3] / v83[1425 - (107 + 1314)];
							elseif ((v84 == (34 + 39)) or (3 == 2368)) then
								do
									return v81[v83[2]]();
								end
							else
								local v568;
								v568 = v83[5 - 3];
								v81[v568] = v81[v568]();
								v75 = v75 + 1;
								v83 = v71[v75];
								v81[v83[2 + 0]] = v62[v83[2 + 1]];
								v75 = v75 + (1 - 0);
								v83 = v71[v75];
								v81[v83[(10 - 3) - 5]] = v81[v83[(1385 + 528) - (716 + 1194)]];
								v75 = v75 + 1 + 0;
								v83 = v71[v75];
								v81[v83[488 - (68 + 418)]] = v83[1 + 2];
								v75 = v75 + (504 - (74 + 429));
								v83 = v71[v75];
								v81[v83[3 - (2 - 1)]] = #v81[v83[2 + 1]];
								v75 = v75 + 1;
								v83 = v71[v75];
								v81[v83[2]] = v83[(10 - 4) - 3];
								v75 = v75 + 1;
								v83 = v71[v75];
								v81[v83[2 + 0 + 0]] = #v81[v83[8 - 5]];
								v75 = v75 + 1;
								v83 = v71[v75];
								v568 = v83[4 - (1094 - (770 + 322))];
								v81[v568] = v81[v568](v13(v81, v568 + ((26 + 408) - (279 + 154)), v83[1 + 2]));
								v75 = v75 + (779 - (454 + 324));
								v83 = v71[v75];
								if ((v81[v83[2]] == v83[4 + 0]) or (2270 == 3114)) then
									v75 = v75 + 1;
								else
									v75 = v83[20 - (12 + 5)];
								end
							end
						elseif (v84 <= (41 + 35)) then
							if ((v84 > ((26 + 164) - 115)) or (2757 > 3968)) then
								local v583;
								v81[v83[2]] = v62[v83[3]];
								v75 = v75 + (1 - 0) + 0;
								v83 = v71[v75];
								v81[v83[1095 - (277 + 816)]] = v62[v83[12 - 9]];
								v75 = v75 + (1184 - (1058 + 125));
								v83 = v71[v75];
								v81[v83[(1 - 0) + 1]] = v83[978 - (815 + 160)];
								v75 = v75 + (4 - 3);
								v83 = v71[v75];
								v81[v83[4 - 2]] = v83[1 + 2];
								v75 = v75 + 1;
								v83 = v71[v75];
								v81[v83[5 - 3]] = #v81[v83[1901 - (41 + (5057 - 3200))]];
								v75 = v75 + (1894 - (1222 + 671));
								v83 = v71[v75];
								v583 = v83[5 - 3];
								do
									return v81[v583](v13(v81, v583 + (3 - 2), v83[3 - 0]));
								end
								v75 = v75 + (1183 - (128 + 101 + 953));
								v83 = v71[v75];
								v583 = v83[1776 - ((1664 - 553) + 319 + 344)];
								do
									return v13(v81, v583, v76);
								end
								v75 = v75 + (1580 - (874 + 705));
								v83 = v71[v75];
								do
									return;
								end
							else
								v81[v83[1 + 1 + 0]] = v63[v83[3 + 0]];
								v75 = v75 + ((1 + 0) - 0);
								v83 = v71[v75];
								v81[v83[1 + 1]] = v63[v83[682 - (642 + 37)]];
								v75 = v75 + 1 + 0;
								v83 = v71[v75];
								v81[v83[1 + 1]] = v81[v83[7 - 4]][v83[458 - (233 + 221)]];
								v75 = v75 + (2 - 1);
								v83 = v71[v75];
								v81[v83[2]] = v63[v83[3 + 0]];
								v75 = v75 + (1542 - (718 + 823));
								v83 = v71[v75];
								v81[v83[2 + 0]] = v81[v83[808 - (266 + 539)]][v83[11 - 7]];
								v75 = v75 + (1226 - (636 + 589));
								v83 = v71[v75];
								v81[v83[4 - 2]] = v63[v83[3]];
								v75 = v75 + (1 - 0);
								v83 = v71[v75];
								v81[v83[2]] = v81[v83[3]][v83[4]];
								v75 = v75 + 1 + 0;
								v83 = v71[v75];
								v81[v83[2]] = v63[v83[2 + 1]];
								v75 = v75 + (1016 - ((2473 - 1816) + 358));
								v83 = v71[v75];
								v81[v83[4 - 2]] = v81[v83[6 - 3]][v83[4]];
								v75 = v75 + (1188 - (1151 + (49 - 13)));
								v83 = v71[v75];
								v81[v83[2]] = v63[v83[3 + 0]];
							end
						elseif (v84 == (21 + 56)) then
							local v610 = 0 + 0;
							local v611;
							local v612;
							local v613;
							while true do
								if ((v610 == (0 - 0)) or (1564 > 3303)) then
									v611 = v83[1834 - (1552 + 280)];
									v612 = {v81[v611](v13(v81, v611 + (835 - (64 + 770)), v83[3 + 0]))};
									v610 = 2 - 1;
								end
								if (((1 + 0) == v610) or (2164 > 3146)) then
									v613 = 0;
									for v1168 = v611, v83[(5744 - 4497) - (157 + 1086)] do
										local v1169 = 0 - 0;
										while true do
											if ((686 < 2227) and (v1169 == (0 - (0 - 0)))) then
												v613 = v613 + (1 - 0);
												v81[v1168] = v612[v613];
												break;
											end
										end
									end
									break;
								end
							end
						else
							local v614 = 0;
							local v615;
							while true do
								if ((605 == 605) and (v614 == ((0 + 0) - 0))) then
									v615 = v83[821 - (599 + (1088 - 868))];
									do
										return v13(v81, v615, v615 + v83[5 - 2]);
									end
									break;
								end
							end
						end
					elseif (v84 <= (2013 - (1813 + 118))) then
						if ((812 <= 1870) and (v84 <= ((890 - (762 + 69)) + 21))) then
							if (v84 > (1296 - (841 + (1217 - 841)))) then
								local v616 = 0;
								local v617;
								while true do
									if ((v616 == (9 - (2 + 0))) or (2878 < 141)) then
										v75 = v75 + 1 + 0;
										v83 = v71[v75];
										v81[v83[5 - (2 + 1)]] = v83[862 - ((1122 - 658) + 395)];
										break;
									end
									if ((3889 == 3889) and (v616 == (12 - 7))) then
										v83 = v71[v75];
										v81[v83[1 + 1]] = v83[840 - (467 + 370)];
										v75 = v75 + (1 - 0);
										v616 = 5 + 1;
									end
									if ((474 < 1065) and (v616 == (13 - 9))) then
										v83 = v71[v75];
										v81[v83[1 + 1]] = v81[v83[6 - 3]];
										v75 = v75 + (521 - (150 + 370));
										v616 = 1287 - (74 + 1208);
									end
									if ((4139 > 3173) and (v616 == (4 - 2))) then
										v83 = v71[v75];
										v81[v83[9 - 7]] = v62[v83[3 + 0]];
										v75 = v75 + (391 - (14 + 376));
										v616 = 4 - 1;
									end
									if (0 == v616) then
										v617 = nil;
										v81[v83[2 + 0]] = v83[1 + 2 + 0];
										v75 = v75 + 1 + 0;
										v616 = 2 - (1 + 0);
									end
									if ((1411 < 2388) and (v616 == (5 + 1))) then
										v83 = v71[v75];
										v617 = v83[2];
										v81[v617] = v81[v617](v13(v81, v617 + (79 - ((89 - 66) + 55)), v83[6 - 3]));
										v616 = 5 + 2;
									end
									if ((4392 == 4392) and (v616 == 1)) then
										v83 = v71[v75];
										for v1170 = v83[2 + 0], v83[4 - 1] do
											v81[v1170] = nil;
										end
										v75 = v75 + 1;
										v616 = 159 - (8 + 149);
									end
									if (v616 == 3) then
										v83 = v71[v75];
										v81[v83[1 + 1]] = v62[v83[904 - (652 + (1569 - (1199 + 121)))]];
										v75 = v75 + (2 - 1);
										v616 = 1872 - (708 + 1160);
									end
								end
							else
								local v618 = 0;
								local v619;
								while true do
									if (v618 == (2 - 1)) then
										v81[v83[3 - 1]] = v62[v83[(50 - 20) - (10 + 17)]];
										v75 = v75 + 1 + (0 - 0);
										v83 = v71[v75];
										v619 = v83[1734 - (1400 + 137 + 195)];
										v618 = 3 - 1;
									end
									if (v618 == (1913 - (242 + 1666))) then
										v81[v83[1 + 1]] = v83[2 + 1];
										break;
									end
									if (4 == v618) then
										v83 = v71[v75];
										v62[v83[3 + 0]] = v81[v83[942 - (850 + (321 - 231))]];
										v75 = v75 + (1 - 0);
										v83 = v71[v75];
										v618 = 1395 - ((835 - 475) + 912 + 118);
									end
									if ((4771 == 4771) and (v618 == (2 + 0))) then
										v81[v619] = v81[v619](v13(v81, v619 + (2 - 1), v83[3]));
										v75 = v75 + (1 - 0);
										v83 = v71[v75];
										v81[v83[2]] = v81[v83[1664 - (909 + 752)]];
										v618 = 1226 - (109 + 1114);
									end
									if ((1013 == 1013) and (v618 == (0 - 0))) then
										v619 = nil;
										v81[v83[2]] = v81[v83[2 + 1]];
										v75 = v75 + (243 - (6 + (2043 - (518 + 1289))));
										v83 = v71[v75];
										v618 = (1 - 0) + 0;
									end
									if (3 == v618) then
										v75 = v75 + 1 + 0;
										v83 = v71[v75];
										for v1172 = v83[4 - 2], v83[4 - 1] do
											v81[v1172] = nil;
										end
										v75 = v75 + 1 + 0;
										v618 = 1137 - ((1570 - 494) + 57);
									end
								end
							end
						elseif ((520 == 520) and (v84 > 81)) then
							local v620;
							v81[v83[1 + 1]] = v81[v83[(510 + 182) - (579 + 110)]];
							v75 = v75 + 1 + 0;
							v83 = v71[v75];
							v81[v83[(471 - (304 + 165)) + 0]] = v83[3];
							v75 = v75 + 1 + 0;
							v83 = v71[v75];
							v81[v83[409 - (174 + 233)]] = #v81[v83[3]];
							v75 = v75 + (2 - 1);
							v83 = v71[v75];
							v81[v83[3 - 1]] = v83[3];
							v75 = v75 + 1 + 0;
							v83 = v71[v75];
							v81[v83[2]] = #v81[v83[1177 - (663 + 511)]];
							v75 = v75 + 1 + 0;
							v83 = v71[v75];
							v620 = v83[1 + 0 + (161 - (54 + 106))];
							v81[v620] = v81[v620](v13(v81, v620 + (1970 - (1618 + 351)), v83[3]));
							v75 = v75 + (2 - 1);
							v83 = v71[v75];
							v81[v83[2 + 0 + 0]] = v83[6 - 3];
							v75 = v75 + 1;
							v83 = v71[v75];
							v81[v83[4 - 2]] = #v81[v83[3]];
							v75 = v75 + 1 + 0;
							v83 = v71[v75];
							if (v81[v83[2]] == v81[v83[7 - 3]]) then
								v75 = v75 + 1 + 0;
							else
								v75 = v83[1 + (1018 - (10 + 1006))];
							end
						else
							v81[v83[1 + 1]] = v81[v83[725 - (478 + 244)]] % v81[v83[521 - (440 + 11 + 66)]];
						end
					elseif (v84 <= (39 + 45)) then
						if (v84 > 83) then
							local v635 = v72[v83[9 - 6]];
							local v636;
							local v637 = {};
							v636 = v10({}, {__index=function(v863, v864)
								local v865 = 0 - 0;
								local v866;
								while true do
									if ((v865 == (1556 - (655 + 901))) or (3546 <= 2759)) then
										v866 = v637[v864];
										return v866[1 + 0][v866[2 + 0]];
									end
								end
							end,__newindex=function(v867, v868, v869)
								local v870 = v637[v868];
								v870[1][v870[2 + 0]] = v869;
							end});
							for v872 = 1, v83[15 - 11] do
								v75 = v75 + (1446 - (695 + 750));
								local v873 = v71[v75];
								if ((v873[1] == (95 - 67)) or (98 >= 2345)) then
									v637[v872 - (1 - 0)] = {v81,v873[354 - (285 + 66)]};
								else
									v637[v872 - 1] = {v62,v873[1 + 2]};
								end
								v80[#v80 + (300 - (176 + 123))] = v637;
							end
							v81[v83[1 + 1]] = v29(v635, v636, v63);
						else
							v81[v83[2 + 0]][v81[v83[(129 + 143) - (239 + 30)]]] = v81[v83[2 + (1291 - (1140 + 149))]];
						end
					elseif (v84 == (82 + 3)) then
						v81[v83[2]] = v81[v83[4 - 1]] / v83[4];
					else
						local v642;
						local v643, v644;
						local v645;
						v81[v83[5 - (2 + 1)]] = v81[v83[318 - (306 + 9)]][v81[v83[(16 - 3) - 9]]];
						v75 = v75 + 1;
						v83 = v71[v75];
						v81[v83[2]] = v62[v83[1 + 2]];
						v75 = v75 + 1 + 0 + 0;
						v83 = v71[v75];
						v81[v83[1 + 1]] = v81[v83[8 - 5]];
						v75 = v75 + (1376 - ((3901 - 2761) + 235));
						v83 = v71[v75];
						v81[v83[2]] = v81[v83[(3 - 1) + 1]] + v83[4];
						v75 = v75 + 1 + 0;
						v83 = v71[v75];
						v81[v83[1 + 1 + 0]] = v81[v83[3]];
						v75 = v75 + ((183 - 130) - (33 + 19));
						v83 = v71[v75];
						v645 = v83[1 + 1];
						v643, v644 = v74(v81[v645](v13(v81, v645 + (2 - 1), v83[2 + 1])));
						v76 = (v644 + v645) - (1 - 0);
						v642 = 0 + 0;
						for v875 = v645, v76 do
							v642 = v642 + (690 - (586 + 103));
							v81[v875] = v643[v642];
						end
						v75 = v75 + 1;
						v83 = v71[v75];
						v645 = v83[1 + 1];
						v81[v645] = v81[v645](v13(v81, v645 + (2 - (187 - (165 + 21))), v76));
						v75 = v75 + 1;
						v83 = v71[v75];
						v81[v83[1490 - ((1420 - (61 + 50)) + 179)]][v81[v83[2 + 1]]] = v81[v83[4]];
						v75 = v75 + 1;
						v83 = v71[v75];
						v75 = v83[3];
					end
				elseif ((4016 > 3561) and (v84 <= (180 - 80))) then
					if (v84 <= (41 + 52)) then
						if (v84 <= (424 - 335)) then
							if ((1857 < 3234) and (v84 <= 87)) then
								v81[v83[5 - 3]] = v83[3 + 0] ^ v81[v83[7 - 3]];
								v75 = v75 + ((1 - 0) - 0);
								v83 = v71[v75];
								v81[v83[2]] = v81[v83[612 - (295 + 314)]] / v81[v83[9 - 5]];
								v75 = v75 + (1963 - (1300 + 662));
								v83 = v71[v75];
								v81[v83[6 - 4]] = v81[v83[1758 - (463 + 715 + 577)]] - v83[3 + 1];
								v75 = v75 + (2 - 1);
								v83 = v71[v75];
								v81[v83[2]] = v81[v83[1408 - (851 + 554)]] - v83[4 + 0];
								v75 = v75 + (2 - 1);
								v83 = v71[v75];
								v81[v83[2]] = v81[v83[3]] - v81[v83[8 - 4]];
								v75 = v75 + 1;
								v83 = v71[v75];
								v81[v83[304 - (115 + 187)]] = v81[v83[3]] + v83[4 + 0];
								v75 = v75 + 1;
								v83 = v71[v75];
								v81[v83[2 + 0]] = v83[11 - 8] ^ v81[v83[1165 - ((1620 - (1295 + 165)) + 229 + 772)]];
								v75 = v75 + 1 + 0;
								v83 = v71[v75];
								v81[v83[1 + 1 + 0]] = v81[v83[5 - 2]] % v81[v83[362 - (237 + 121)]];
								v75 = v75 + (898 - (525 + (1769 - (819 + 578))));
								v83 = v71[v75];
								v81[v83[2]] = v81[v83[4 - 1]] % v83[12 - (1410 - (331 + 1071))];
								v75 = v75 + (143 - (96 + 46));
								v83 = v71[v75];
								v81[v83[2]] = v81[v83[780 - (643 + 134)]] - v81[v83[(745 - (588 + 155)) + (1284 - (546 + 736))]];
								v75 = v75 + (2 - (1938 - (1834 + 103)));
								v83 = v71[v75];
								do
									return v81[v83[7 - 5]];
								end
								v75 = v75 + 1 + 0;
								v83 = v71[v75];
								v75 = v83[5 - (2 + 0)];
							elseif ((4297 > 1243) and (v84 > (179 - 91))) then
								local v660 = 0;
								local v661;
								while true do
									if (v660 == (719 - (316 + 403))) then
										v661 = v81[v83[4]];
										if not v661 then
											v75 = v75 + 1;
										else
											v81[v83[2]] = v661;
											v75 = v83[2 + 1];
										end
										break;
									end
								end
							else
								local v662;
								local v663;
								local v664;
								v81[v83[2]] = #v81[v83[8 - 5]];
								v75 = v75 + (2 - 1) + 0;
								v83 = v71[v75];
								v81[v83[4 - 2]] = v62[v83[(1769 - (1536 + 230)) + 0]];
								v75 = v75 + 1;
								v83 = v71[v75];
								v664 = v83[1 + 1];
								v81[v664] = v81[v664]();
								v75 = v75 + 1;
								v83 = v71[v75];
								v81[v83[6 - 4]] = v83[3];
								v75 = v75 + (4 - 3);
								v83 = v71[v75];
								v664 = v83[3 - 1];
								v663 = v81[v664];
								v662 = v81[v664 + 1 + (492 - (128 + 363))];
								if ((4068 > 1180) and (v662 > (0 - 0))) then
									if (v663 > v81[v664 + 1]) then
										v75 = v83[3];
									else
										v81[v664 + 1 + 2] = v663;
									end
								elseif (v663 < v81[v664 + (2 - 1)]) then
									v75 = v83[20 - (12 + 5)];
								else
									v81[v664 + (11 - 8)] = v663;
								end
							end
						elseif ((167 <= 4460) and (v84 <= (193 - 102))) then
							if (v84 > 90) then
								if (v83[2] < v83[8 - 4]) then
									v75 = v75 + (2 - (1 + 0));
								else
									v75 = v83[1 + 2];
								end
							else
								local v675 = 0;
								local v676;
								while true do
									if ((v675 == (1973 - (1656 + (788 - 471)))) or (3812 < 3081)) then
										v676 = v83[2 + 0];
										do
											return v13(v81, v676, v76);
										end
										break;
									end
								end
							end
						elseif ((v84 > (74 + 18)) or (3611 > 4881)) then
							v81[v83[(2 + 2) - 2]] = v81[v83[14 - 11]] + v83[358 - (5 + 349)];
							v75 = v75 + (4 - 3);
							v83 = v71[v75];
							v81[v83[2 - 0]] = v81[v83[(3750 - 2476) - (266 + 1005)]] + v83[3 + (2 - 1)];
							v75 = v75 + 1 + 0;
							v83 = v71[v75];
							v81[v83[6 - 4]] = v81[v83[3 - 0]][v81[v83[4]]];
							v75 = v75 + 1;
							v83 = v71[v75];
							v81[v83[1011 - (615 + 394)]][v81[v83[1699 - (507 + 54 + 1135)]]] = v81[v83[5 - 1]];
							v75 = v75 + (3 - 2);
							v83 = v71[v75];
							v75 = v83[1069 - (507 + 559)];
						elseif v81[v83[4 - 2]] then
							v75 = v75 + 1;
						else
							v75 = v83[3];
						end
					elseif (v84 <= ((283 + 13) - 200)) then
						if (v84 <= 94) then
							v81[v83[390 - (212 + 176)]] = v62[v83[3]];
							v75 = v75 + 1;
							v83 = v71[v75];
							v81[v83[907 - (250 + 655)]] = v62[v83[8 - 5]];
							v75 = v75 + ((2 - 1) - (0 - 0));
							v83 = v71[v75];
							v81[v83[2 - 0]] = v83[1959 - (1869 + 87)];
							v75 = v75 + (3 - 2);
							v83 = v71[v75];
							v81[v83[2]] = #v81[v83[1904 - (484 + 1417)]];
							v75 = v75 + (2 - 1);
							v83 = v71[v75];
							v81[v83[2 - 0]] = v81[v83[776 - (48 + 725)]][v81[v83[4]]];
							v75 = v75 + (1 - 0);
							v83 = v71[v75];
							v81[v83[5 - (654 - (59 + 592))]] = v81[v83[3]][v81[v83[3 + 1]]];
							v75 = v75 + ((4 - 2) - 1);
							v83 = v71[v75];
							do
								return v81[v83[1 + 1]];
							end
							v75 = v75 + (1 - 0) + 0 + 0;
							v83 = v71[v75];
							do
								return;
							end
						elseif ((2513 == 2513) and (v84 > (948 - (152 + 701)))) then
							local v685 = v83[1313 - ((601 - (70 + 101)) + 881)];
							v81[v685] = v81[v685](v13(v81, v685 + 1 + 0, v83[898 - (557 + 338)]));
						else
							local v687;
							local v688, v689;
							local v690;
							v81[v83[2]] = v62[v83[1 + 2]];
							v75 = v75 + (2 - 1);
							v83 = v71[v75];
							v81[v83[6 - 4]] = v81[v83[3]];
							v75 = v75 + (2 - (2 - 1));
							v83 = v71[v75];
							v81[v83[2]] = v83[6 - 3];
							v75 = v75 + (802 - (499 + 215 + 87));
							v83 = v71[v75];
							v690 = v83[2];
							v688, v689 = v74(v81[v690](v13(v81, v690 + (867 - (39 + 827)), v83[3])));
							v76 = (v689 + v690) - 1;
							v687 = 0 - 0;
							for v878 = v690, v76 do
								v687 = v687 + (2 - (2 - 1));
								v81[v878] = v688[v687];
							end
							v75 = v75 + (3 - 2);
							v83 = v71[v75];
							v690 = v83[(243 - (123 + 118)) - 0];
							v81[v690] = v81[v690](v13(v81, v690 + 1 + 0, v76));
							v75 = v75 + 1;
							v83 = v71[v75];
							v81[v83[5 - 3]] = v81[v83[1 + 2]];
							v75 = v75 + (1 - 0);
							v83 = v71[v75];
							v81[v83[2]] = v62[v83[107 - (103 + 1)]];
							v75 = v75 + (555 - (475 + 79));
							v83 = v71[v75];
							if v81[v83[4 - 2]] then
								v75 = v75 + (3 - 2);
							else
								v75 = v83[1 + 2];
							end
						end
					elseif ((3331 > 1280) and (v84 <= (22 + 65 + 11))) then
						if ((2347 >= 579) and (2187 < 3817) and (v84 > (1600 - (1395 + 108)))) then
							v81[v83[5 - 3]][v83[1207 - (7 + 15 + 1182)]] = v81[v83[1403 - (653 + 746)]];
						else
							v81[v83[1 + (1 - 0)]] = v81[v83[3]][v81[v83[2 + 2]]];
						end
					elseif ((428 <= 985) and (v84 > (418 - (27 + 292)))) then
						local v707;
						v81[v83[(7 - 2) - 3]] = v62[v83[3 - 0]];
						v75 = v75 + (4 - 3);
						v83 = v71[v75];
						v707 = v83[3 - 1];
						v81[v707] = v81[v707]();
						v75 = v75 + (1 - 0);
						v83 = v71[v75];
						v81[v83[2]] = v81[v83[142 - (43 + 96)]] - v83[(42 - 26) - 12];
						v75 = v75 + ((1 + 0) - 0);
						v83 = v71[v75];
						do
							return v81[v83[2 + 0]];
						end
						v75 = v75 + 1 + 0;
						v83 = v71[v75];
						do
							return;
						end
					else
						local v714;
						local v715, v716;
						local v717;
						v81[v83[3 - 1]] = v62[v83[2 + 1]];
						v75 = v75 + ((1 + 0) - (0 + 0));
						v83 = v71[v75];
						v81[v83[1 + 1]] = v62[v83[1 + 2]];
						v75 = v75 + (1752 - (1414 + 337));
						v83 = v71[v75];
						v81[v83[1942 - (1642 + 298)]] = v81[v83[3]];
						v75 = v75 + (2 - 1);
						v83 = v71[v75];
						v81[v83[5 - 3]] = v81[v83[8 - 5]];
						v75 = v75 + 1 + 0;
						v83 = v71[v75];
						v81[v83[2 + 0]] = v81[v83[975 - (357 + 615)]];
						v75 = v75 + 1;
						v83 = v71[v75];
						v717 = v83[2 + 0];
						v715, v716 = v74(v81[v717](v13(v81, v717 + (2 - 1), v83[3])));
						v76 = (v716 + v717) - (1 + 0);
						v714 = 0 - 0;
						for v881 = v717, v76 do
							v714 = v714 + 1 + 0;
							v81[v881] = v715[v714];
						end
						v75 = v75 + 1 + 0;
						v83 = v71[v75];
						v717 = v83[1 + 1];
						v715, v716 = v74(v81[v717](v13(v81, v717 + 1, v76)));
						v76 = (v716 + v717) - (1 + 0 + 0);
						v714 = 1301 - (384 + (2247 - 1330));
						for v884 = v717, v76 do
							local v885 = 697 - (122 + 6 + 569);
							while true do
								if ((2409 == 2409) and (2952 >= 1023) and (v885 == (1543 - (1407 + (250 - 114))))) then
									v714 = v714 + 1;
									v81[v884] = v715[v714];
									break;
								end
							end
						end
						v75 = v75 + (1888 - (687 + 1200));
						v83 = v71[v75];
						v717 = v83[1712 - (556 + 1154)];
						v81[v717] = v81[v717](v13(v81, v717 + ((1237 - (885 + 349)) - 2), v76));
						v75 = v75 + ((77 + 19) - ((24 - 15) + 86));
						v83 = v71[v75];
						v81[v83[423 - ((799 - 524) + 146)]][v81[v83[1 + (970 - (915 + 53))]]] = v81[v83[805 - (768 + 33)]];
					end
				elseif (((554 <= 3482) and (v84 <= (171 - (29 + 35)))) or (962 >= 3722)) then
					if (v84 <= (456 - 353)) then
						if (v84 <= 101) then
							local v180 = (0 - 0) - 0;
							local v181;
							local v182;
							local v183;
							while true do
								if (v180 == (2 - 0)) then
									if (v182 > (0 - 0)) then
										if (v183 <= v81[v181 + 1 + 0]) then
											v75 = v83[1015 - (53 + (1287 - (287 + 41)))];
											v81[v181 + (411 - (312 + 96))] = v183;
										end
									elseif ((74 <= 3533) and (v183 >= v81[v181 + (848 - (638 + 209))])) then
										v75 = v83[4 - 1];
										v81[v181 + 3] = v183;
									end
									break;
								end
								if ((2395 < 2649) and (1657 < 3319) and (v180 == 1)) then
									v183 = v81[v181] + v182;
									v81[v181] = v183;
									v180 = (150 + 137) - (147 + 138);
								end
								if (v180 == (899 - (813 + 86))) then
									v181 = v83[2 + 0];
									v182 = v81[v181 + (3 - (1687 - (96 + 1590)))];
									v180 = 493 - (18 + 474);
								end
							end
						elseif ((v84 > ((1707 - (741 + 931)) + 67)) or (1616 == 1003) or (1373 > 4744)) then
							for v889 = v83[2], v83[9 - 6] do
								v81[v889] = nil;
							end
						else
							local v735 = 1086 - (860 + 226);
							local v736;
							local v737;
							local v738;
							while true do
								if ((2479 < 3052) and (v735 == (307 - (121 + 182)))) then
									v81[v83[1 + 1]] = v83[1243 - (988 + 252)];
									v75 = v75 + 1 + 0;
									v83 = v71[v75];
									v735 = 2 + 3;
								end
								if (v735 == (1978 - (49 + 1921))) then
									if (v736 > (890 - (223 + 667))) then
										if (v737 > v81[v738 + (53 - (26 + 25 + 1))]) then
											v75 = v83[5 - 2];
										else
											v81[v738 + (6 - 3)] = v737;
										end
									elseif ((v737 < v81[v738 + (1126 - ((415 - 269) + 979))]) or (3777 < 1129)) then
										v75 = v83[1 + 2];
									else
										v81[v738 + 3] = v737;
									end
									break;
								end
								if (v735 == (607 - (311 + 294))) then
									v81[v83[2]] = {};
									v75 = v75 + (2 - 1);
									v83 = v71[v75];
									v735 = (9 - 7) + 1;
								end
								if (v735 == (1450 - (496 + 947))) then
									v738 = v83[1360 - (1233 + 125)];
									v737 = v81[v738];
									v736 = v81[v738 + 1 + 1];
									v735 = 8 + 0;
								end
								if (v735 == (0 + 0)) then
									v736 = nil;
									v737 = nil;
									v738 = nil;
									v735 = 1;
								end
								if ((v735 == 1) or (3672 <= 863)) then
									v81[v83[1647 - (963 + 682)]] = v81[v83[3 + 0]];
									v75 = v75 + (1505 - (504 + 1000));
									v83 = v71[v75];
									v735 = 2 + 0;
								end
								if ((612 < 1082) and (v735 == (3 + 0 + 0))) then
									v81[v83[1 + 1]] = v81[v83[4 - 1]];
									v75 = v75 + 1 + 0;
									v83 = v71[v75];
									v735 = 3 + 1;
								end
								if ((1185 < 2612) and (2142 == 2142) and (v735 == (187 - (156 + 26)))) then
									v81[v83[2]] = v81[v83[3]];
									v75 = v75 + 1 + 0;
									v83 = v71[v75];
									v735 = 6;
								end
								if (v735 == (8 - 2)) then
									v81[v83[(72 + 94) - (149 + 15)]] = v83[963 - (284 + 606 + 70)];
									v75 = v75 + 1;
									v83 = v71[v75];
									v735 = 7;
								end
							end
						end
					elseif (v84 <= ((842 - 620) - (39 + 78))) then
						if ((4480 >= 683) and (v84 == ((191 + 395) - (14 + 229 + 239)))) then
							local v739 = 0 - 0;
							while true do
								if ((2 - 1) == v739) then
									v81[v83[2 + 0]] = v81[v83[2 + 1]][v81[v83[(4 - 3) + 3]]];
									v75 = v75 + 1;
									v83 = v71[v75];
									v739 = 1 + 1;
								end
								if ((2796 >= 2496) and (v739 == 2)) then
									v81[v83[1 + 1]]();
									v75 = v75 + (1 - 0);
									v83 = v71[v75];
									v739 = 3 + 0;
								end
								if ((v739 == (10 - 7)) or (1680 < 749)) then
									v81[v83[1 + 1]] = v83[54 - (12 + 39)];
									v75 = v75 + 1 + 0;
									v83 = v71[v75];
									v739 = (11 + 1) - 8;
								end
								if (v739 == (0 - 0)) then
									v81[v83[1 + 1]] = v81[v83[2 + 1]][v83[9 - 5]];
									v75 = v75 + (495 - (64 + 430)) + 0;
									v83 = v71[v75];
									v739 = 4 - 3;
								end
								if (v739 == (1714 - (1596 + 114))) then
									v75 = v83[(7 + 0) - (367 - (106 + 257))];
									break;
								end
							end
						else
							local v740;
							v81[v83[(507 + 208) - (164 + 549)]] = v62[v83[1441 - (1059 + 379)]];
							v75 = v75 + (1 - 0);
							v83 = v71[v75];
							v81[v83[2 + 0]] = v62[v83[1 + (723 - (496 + 225))]];
							v75 = v75 + (393 - (145 + 247));
							v83 = v71[v75];
							v81[v83[2]] = v83[3];
							v75 = v75 + 1 + 0;
							v83 = v71[v75];
							v81[v83[2]] = #v81[v83[2 + 1]];
							v75 = v75 + (2 - (1 - 0));
							v83 = v71[v75];
							v81[v83[1 + (4 - 3)]] = v83[(1661 - (256 + 1402)) + 0];
							v75 = v75 + (1 - 0);
							v83 = v71[v75];
							v740 = v83[722 - ((2153 - (30 + 1869)) + 466)];
							do
								return v81[v740](v13(v81, v740 + 1, v83[3]));
							end
							v75 = v75 + (561 - (544 + 16));
							v83 = v71[v75];
							v740 = v83[(1374 - (213 + 1156)) - 3];
							do
								return v13(v81, v740, v76);
							end
							v75 = v75 + (629 - (294 + 334));
							v83 = v71[v75];
							do
								return;
							end
						end
					elseif (v84 == (359 - (236 + 17))) then
						local v752 = 0 + 0;
						local v753;
						while true do
							if ((2 + 0) == v752) then
								v75 = v75 + (3 - 2);
								v83 = v71[v75];
								v753 = v83[9 - 7];
								v81[v753] = v81[v753](v13(v81, v753 + 1 + 0, v83[3 + 0]));
								v752 = 797 - (413 + 381);
							end
							if ((v752 == (1 + 3)) or (2012 < 213)) then
								v83 = v71[v75];
								v81[v83[2]] = v62[v83[5 - 2]];
								v75 = v75 + 1;
								v83 = v71[v75];
								v752 = 5;
							end
							if ((4516 >= 2342) and (v752 == ((190 - (96 + 92)) - 1))) then
								v81[v83[1972 - (582 + 1388)]] = v62[v83[3]];
								v75 = v75 + (1 - 0);
								v83 = v71[v75];
								v81[v83[2 + 0]] = v62[v83[367 - (326 + 38)]];
								v752 = 5 - 3;
							end
							if ((4636 > 3610) and (v752 == 3)) then
								v75 = v75 + ((1 + 0) - 0);
								v83 = v71[v75];
								v81[v83[622 - (47 + 573)]] = v81[v83[3]];
								v75 = v75 + 1 + 0;
								v752 = 4;
							end
							if ((v752 == (25 - 19)) or (24 == 1960)) then
								v75 = v75 + (1 - 0);
								v83 = v71[v75];
								v81[v83[2]] = v83[1667 - (1269 + 395)];
								break;
							end
							if ((v752 == (492 - (76 + 416))) or (2402 == 3445)) then
								v753 = nil;
								v81[v83[2]] = v62[v83[446 - (319 + (1023 - (142 + 757)))]];
								v75 = v75 + ((2 + 0) - 1);
								v83 = v71[v75];
								v752 = 1008 - (564 + 443);
							end
							if (v752 == (13 - 8)) then
								v81[v83[460 - (337 + 121)]] = v81[v83[8 - 5]] + v83[13 - 9];
								v75 = v75 + (1912 - (1261 + 650));
								v83 = v71[v75];
								v62[v83[1 + 1 + 1]] = v81[v83[(81 - (32 + 47)) - 0]];
								v752 = 6;
							end
						end
					else
						local v754;
						local v755;
						local v756;
						v81[v83[1819 - (772 + 1045)]] = v62[v83[1 + 2]];
						v75 = v75 + ((2122 - (1053 + 924)) - (102 + 42));
						v83 = v71[v75];
						v81[v83[1846 - (1524 + 320)]] = v62[v83[1273 - (1049 + 221)]];
						v75 = v75 + ((154 + 3) - ((30 - 12) + 138));
						v83 = v71[v75];
						v81[v83[1650 - (685 + 963)]] = v62[v83[3]];
						v75 = v75 + (2 - 1);
						v83 = v71[v75];
						v81[v83[1104 - (67 + 1035)]] = v81[v83[351 - (136 + 212)]] + v83[4];
						v75 = v75 + (4 - 3);
						v83 = v71[v75];
						v756 = v83[2 + 0];
						v755 = {v81[v756](v13(v81, v756 + 1 + 0, v83[1607 - (240 + 1364)]))};
						v754 = 1082 - (1050 + 32);
						for v891 = v756, v83[14 - 10] do
							v754 = v754 + 1 + 0;
							v81[v891] = v755[v754];
						end
						v75 = v75 + 1;
						v83 = v71[v75];
						v81[v83[1057 - (331 + 724)]] = v81[v83[1 + 2]];
						v75 = v75 + (645 - (269 + 375));
						v83 = v71[v75];
						v81[v83[727 - ((416 - 149) + 458)]] = v81[v83[1 + 2]];
						v75 = v75 + (1 - 0);
						v83 = v71[v75];
						v81[v83[820 - (667 + (1860 - (541 + 1168)))]] = v62[v83[(3097 - (645 + 952)) - (1410 + 87)]];
						v75 = v75 + (1898 - (1504 + 393));
						v83 = v71[v75];
						v81[v83[5 - 3]] = v81[v83[3]] + v83[10 - 6];
						v75 = v75 + ((1635 - (669 + 169)) - (461 + 335));
						v83 = v71[v75];
						v81[v83[1 + 1]] = v81[v83[1764 - ((5992 - 4262) + 31)]] + v83[1671 - (728 + 939)];
						v75 = v75 + (3 - 2);
						v83 = v71[v75];
						v62[v83[3]] = v81[v83[3 - 1]];
						v75 = v75 + (1 - 0);
						v83 = v71[v75];
						v81[v83[2]] = v83[3];
					end
				elseif ((639 < 3347) and (v84 <= (254 - 143))) then
					if (v84 <= (1177 - (138 + 930))) then
						if ((160 <= 3550) and (v84 == (37 + 71))) then
							do
								return v81[v83[2 + 0]];
							end
						else
							v81[v83[1 + 1 + 0]] = v62[v83[(768 - (181 + 584)) + 0]];
							v75 = v75 + (4 - 3);
							v83 = v71[v75];
							v81[v83[2]] = v62[v83[3]];
							v75 = v75 + 1;
							v83 = v71[v75];
							v81[v83[1768 - (459 + 1307)]] = v81[v83[1873 - (474 + 1396)]][v83[6 - 2]];
							v75 = v75 + 1 + 0;
							v83 = v71[v75];
							v81[v83[1 + 1]] = v81[v83[8 - 5]][v81[v83[(1396 - (665 + 730)) + 3]]];
							v75 = v75 + (3 - 2);
							v83 = v71[v75];
							do
								return v81[v83[8 - 6]];
							end
							v75 = v75 + (592 - (562 + (83 - 54)));
							v83 = v71[v75];
							do
								return;
							end
						end
					elseif ((4167 <= 4286) and (v84 > (94 + (32 - 16)))) then
						v81[v83[1421 - (374 + 1045)]] = v83[3 + 0] ^ v81[v83[12 - (1358 - (540 + 810))]];
					else
						local v786 = 638 - (448 + 190);
						while true do
							if ((3441 < 3525) and (v786 == 0)) then
								v81[v83[1 + 1]] = v62[v83[3]];
								v75 = v75 + 1 + 0;
								v83 = v71[v75];
								v786 = 1 + 0;
							end
							if ((4114 < 4964) and (v786 == (11 - 8))) then
								v81[v83[(19 - 14) - 3]][v81[v83[(4115 - 2618) - (1307 + 149 + 38)]]] = v81[v83[4]];
								v75 = v75 + 1;
								v83 = v71[v75];
								v786 = 4;
							end
							if (v786 == ((210 - (166 + 37)) - 5)) then
								v81[v83[4 - 2]] = v81[v83[8 - (1886 - (22 + 1859))]][v81[v83[4]]];
								v75 = v75 + (684 - (232 + 451));
								v83 = v71[v75];
								v786 = 3 + 0;
							end
							if (((149 < 3450) and (v786 == (1 + 0))) or (1161 == 2575)) then
								v81[v83[566 - (510 + 54)]] = v81[v83[5 - 2]][v83[4]];
								v75 = v75 + (37 - ((1785 - (843 + 929)) + (285 - (30 + 232))));
								v83 = v71[v75];
								v786 = 3 - 1;
							end
							if ((v786 == (5 - 1)) or (3406 < 2659) or (3531 > 3543)) then
								v75 = v83[3];
								break;
							end
						end
					end
				elseif (v84 <= 113) then
					if (v84 > ((579 - 376) - 91)) then
						v81[v83[1090 - ((1607 - (55 + 722)) + (553 - 295))]] = #v81[v83[3]];
					else
						local v788 = v83[6 - 4];
						v76 = (v788 + v82) - (1 + 0);
						for v894 = v788, v76 do
							local v895 = 0 + 0;
							local v896;
							while true do
								if ((543 == 543) and (3445 == 3445) and (v895 == (1441 - (860 + 581)))) then
									v896 = v77[v894 - v788];
									v81[v894] = v896;
									break;
								end
							end
						end
					end
				elseif (v84 > (420 - 306)) then
					local v789 = 0;
					local v790;
					while true do
						if (((4871 == 4871) and (v789 == ((1676 - (78 + 1597)) + 0))) or (3788 < 44)) then
							v75 = v75 + (242 - (237 + 4));
							v83 = v71[v75];
							v81[v83[2]] = v81[v83[(2 + 4) - 3]];
							v789 = (4 + 0) - 2;
						end
						if ((v789 == (11 - 5)) or (4790 < 2768)) then
							v81[v83[2 + 0]] = v83[2 + 1];
							break;
						end
						if (((7 - (5 + 0)) == v789) or (2384 < 828)) then
							v75 = v75 + (550 - (305 + 244)) + 0;
							v83 = v71[v75];
							v81[v83[2 + 0 + 0]] = v62[v83[(1534 - (95 + 10)) - (85 + 1341)]];
							v789 = 4 - 1;
						end
						if (v789 == (0 - 0)) then
							v790 = nil;
							v790 = v83[374 - (45 + 327)];
							v81[v790] = v81[v790]();
							v789 = 1 - 0;
						end
						if (((506 - (315 + 129 + 58)) == v789) or (4805 < 3074)) then
							v81[v790] = v81[v790]();
							v75 = v75 + 1 + (0 - 0);
							v83 = v71[v75];
							v789 = 1 + 4;
						end
						if (v789 == 3) then
							v75 = v75 + 1;
							v83 = v71[v75];
							v790 = v83[2];
							v789 = 4;
						end
						if ((v789 == (3 + 2)) or (2084 >= 3519)) then
							v81[v83[5 - (3 - 0)]] = v81[v83[1735 - (64 + (2430 - (592 + 170)))]];
							v75 = v75 + (1974 - (1227 + 746));
							v83 = v71[v75];
							v789 = 6;
						end
					end
				else
					v81[v83[5 - 3]] = v81[v83[5 - 2]] * v83[498 - (415 + 79)];
				end
				v75 = v75 + 1 + 0;
			end
		end;
	end
	return v29(v28(), {}, v17)(...);
end
return v15("LOL!123Q0003083Q00746F6E756D62657203063Q00737472696E6703043Q006279746503043Q00636861722Q033Q0073756203043Q00677375622Q033Q0072657003053Q007461626C6503063Q00636F6E63617403063Q00696E7365727403043Q006D61746803053Q006C6465787003073Q0067657466656E76030C3Q007365746D6574617461626C6503053Q007063612Q6C03063Q0073656C65637403063Q00756E7061636B0360012Q004C4F4C21303433513Q3033304133512Q3036433646363136343733373437323639364536373033303433512Q3036373631364436353033303733512Q3034383251373437303437363537343033344133512Q303638325137343730372Q334132513246373236312Q373245363736393734363837353632373537333635373236333646364537343635364537343245363336463644324634423646363136433631333733342Q3332463442364636313643363133373246373236352Q363733324636383635363136343733324636443631363936453246344436313639364532453643373536313Q302Q39512Q3033512Q30312Q32513Q30313Q303133512Q30312Q32513Q30323Q303233512Q30323032513Q30323Q30323Q30332Q30312Q32513Q30343Q303436513Q30323Q303436513Q303133513Q303234513Q30313Q30313Q303136513Q303137512Q3000323Q00124B3Q00013Q00122Q000100023Q00202Q00010001000300122Q000200023Q00202Q00020002000400122Q000300023Q00202Q00030003000500122Q000400023Q00202Q00040004000600122Q000500023Q00203200050005000700122C000600083Q00202Q00060006000900122Q000700083Q00202Q00070007000A00122Q0008000B3Q00202Q00080008000C00122Q0009000D3Q00062Q000900150001000100042B3Q0015000100023400095Q001204000A000E3Q001204000B000F3Q001204000C00103Q001204000D00113Q000645000D001D0001000100042B3Q001D0001001204000D00083Q002032000D000D0011001204000E00013Q000654000F00010001000A2Q001C3Q00044Q001C3Q00034Q001C3Q00014Q001C8Q001C3Q00024Q001C3Q00054Q001C3Q00084Q001C3Q00064Q001C3Q000C4Q001C3Q000D4Q003D0010000F3Q00122Q001100126Q001200096Q0012000100024Q00138Q00108Q00109Q009Q0000013Q00023Q00013Q0003043Q005F454E5600033Q0012043Q00014Q006C3Q00024Q00073Q00017Q00033Q00026Q00F03F026Q00144003023Q002Q2E02433Q001250000300016Q000400046Q00058Q000600016Q00075Q00122Q000800026Q00060008000200122Q000700033Q00065400083Q000100062Q000F3Q00024Q001C3Q00044Q000F3Q00034Q000F3Q00014Q000F3Q00044Q000F3Q00054Q00600005000800022Q001C3Q00053Q000234000500013Q00065400060002000100032Q000F3Q00024Q001C8Q001C3Q00033Q00065400070003000100032Q000F3Q00024Q001C8Q001C3Q00033Q00065400080004000100032Q000F3Q00024Q001C8Q001C3Q00033Q00065400090005000100032Q001C3Q00054Q001C3Q00084Q000F3Q00063Q000654000A0006000100072Q001C3Q00084Q000F3Q00074Q000F3Q00044Q000F3Q00024Q000F3Q00014Q001C8Q001C3Q00034Q001C000B00083Q000654000C0007000100012Q000F3Q00083Q000654000D0008000100072Q001C3Q00084Q001C3Q00064Q001C3Q00054Q001C3Q00074Q001C3Q000D4Q001C3Q00094Q001C3Q000A3Q000654000E0009000100032Q001C3Q000C4Q000F3Q00084Q000F3Q00094Q0014000F000E6Q0010000D6Q0010000100024Q00118Q001200016Q000F001200024Q00108Q000F8Q000F9Q0000013Q000A3Q00063Q00027Q0040025Q00405440028Q00026Q00F03F034Q00026Q00304001384Q002300018Q00025Q00122Q000300016Q00010003000200262Q000100150001000200042B3Q00150001001243000100033Q002627000100070001000300042B3Q000700012Q000F000200024Q0018000300036Q00045Q00122Q000500043Q00122Q000600046Q000300066Q00023Q00024Q000200013Q00122Q000200056Q000200023Q00044Q0007000100042B3Q00370001001243000100034Q0067000200023Q002627000100170001000300042B3Q001700012Q000F000300044Q005F000400026Q00055Q00122Q000600066Q000400066Q00033Q00024Q000200036Q000300013Q00062Q0003003400013Q00042B3Q00340001001243000300034Q0067000400043Q0026270003002F0001000300042B3Q002F00012Q000F000500054Q004F000600026Q000700016Q0005000700024Q000400056Q000500056Q000500013Q00122Q000300043Q000E1E000400250001000300042B3Q002500012Q006C000400023Q00042B3Q0025000100042B3Q003700012Q006C000200023Q00042B3Q0037000100042B3Q001700012Q00073Q00017Q00033Q00028Q00026Q00F03F027Q004003253Q00065C0002001400013Q00042B3Q00140001001243000300014Q0067000400043Q002627000300040001000100042B3Q0004000100201A0005000100020010570005000300054Q00053Q000500202Q00060002000200202Q0007000100024Q00060006000700202Q00060006000200102Q0006000300064Q00040005000600202Q0005000400024Q0005000400054Q000500023Q00044Q0004000100042B3Q00240001001243000300014Q0067000400043Q002627000300160001000100042B3Q0016000100201A00050001000200106F0004000300052Q00150005000400042Q005100053Q000500063B000400210001000500042B3Q00210001001243000500023Q000645000500220001000100042B3Q00220001001243000500014Q006C000500023Q00042B3Q001600012Q00073Q00017Q00023Q00028Q00026Q00F03F003D3Q0012433Q00014Q0067000100023Q0026273Q002E0001000200042B3Q002E0001001243000300014Q0067000400043Q002627000300060001000100042B3Q00060001001243000400013Q002627000400090001000100042B3Q000900010026270001000E0001000200042B3Q000E00012Q006C000200023Q002627000100040001000100042B3Q00040001001243000500014Q0067000600063Q000E1E000100120001000500042B3Q00120001001243000600013Q002627000600210001000100042B3Q002100012Q000F00076Q006A000800016Q000900026Q000A00026Q0007000A00024Q000200076Q000700023Q00202Q0007000700024Q000700023Q00122Q000600023Q002627000600150001000200042B3Q00150001001243000100023Q00042B3Q0004000100042B3Q0015000100042B3Q0004000100042B3Q0012000100042B3Q0004000100042B3Q0009000100042B3Q0004000100042B3Q0006000100042B3Q0004000100042B3Q003C00010026273Q00020001000100042B3Q00020001001243000300013Q000E1E000100360001000300042B3Q00360001001243000100014Q0067000200023Q001243000300023Q002627000300310001000200042B3Q003100010012433Q00023Q00042B3Q0002000100042B3Q0031000100042B3Q000200012Q00073Q00017Q00043Q00028Q00026Q00F03F027Q0040026Q00704000353Q0012433Q00014Q0067000100033Q0026273Q002E0001000200042B3Q002E00012Q0067000300033Q001243000400013Q002627000400060001000100042B3Q00060001002627000100250001000100042B3Q00250001001243000500014Q0067000600063Q0026270005000C0001000100042B3Q000C0001001243000600013Q000E1E0001001E0001000600042B3Q001E00012Q000F00076Q006B000800016Q000900026Q000A00023Q00202Q000A000A00034Q0007000A00084Q000300086Q000200076Q000700023Q00202Q00070007000300202Q0007000700014Q000700023Q00122Q000600023Q0026270006000F0001000200042B3Q000F0001001243000100023Q00042B3Q0025000100042B3Q000F000100042B3Q0025000100042B3Q000C0001002627000100050001000200042B3Q000500010020720005000300042Q00150005000500022Q006C000500023Q00042B3Q0005000100042B3Q0006000100042B3Q0005000100042B3Q00340001000E1E0001000200013Q00042B3Q00020001001243000100014Q0067000200023Q0012433Q00023Q00042B3Q000200012Q00073Q00017Q00073Q00028Q00027Q0040026Q00F03F026Q007041026Q00F040026Q007040026Q00084000323Q0012433Q00014Q0067000100053Q0026273Q00270001000200042B3Q002700012Q0067000500053Q001243000600013Q002627000600060001000100042B3Q00060001000E1E000300110001000100042B3Q001100010020720007000500040020460008000400054Q00070007000800202Q0008000300064Q0007000700084Q0007000700024Q000700023Q002627000100050001000100042B3Q000500012Q000F00076Q001F000800016Q000900026Q000A00023Q00202Q000A000A00074Q0007000A000A4Q0005000A6Q000400096Q000300086Q000200076Q000700023Q00202Q00070007000200202Q00070007000300202Q0007000700034Q000700023Q00122Q000100033Q00044Q0005000100042B3Q0006000100042B3Q0005000100042B3Q003100010026273Q002B0001000300042B3Q002B00012Q0067000300043Q0012433Q00023Q0026273Q00020001000100042B3Q00020001001243000100014Q0067000200023Q0012433Q00033Q00042B3Q000200012Q00073Q00017Q000E3Q00028Q00026Q00F03F027Q0040026Q003440026Q00F041026Q003540026Q003F40026Q002Q40026Q00F0BF026Q000840025Q00FC9F402Q033Q004E614E025Q00F88F40026Q00304300693Q0012433Q00014Q0067000100063Q0026273Q00150001000200042B3Q00150001001243000700013Q002627000700090001000200042B3Q000900010012433Q00033Q00042B3Q00150001002627000700050001000100042B3Q00050001001243000300024Q000B00088Q000900023Q00122Q000A00023Q00122Q000B00046Q0008000B000200202Q0008000800054Q00040008000100122Q000700023Q00044Q000500010026273Q00280001000300042B3Q002800012Q000F00076Q002F000800023Q00122Q000900063Q00122Q000A00076Q0007000A00024Q000500076Q00078Q000800023Q00122Q000900086Q00070009000200262Q000700260001000200042B3Q00260001001243000700093Q000659000600270001000700042B3Q00270001001243000600023Q0012433Q000A3Q000E1E0001003900013Q00042B3Q00390001001243000700013Q000E1E000100340001000700042B3Q003400012Q000F000800014Q00730008000100024Q000100086Q000800016Q0008000100024Q000200083Q00122Q000700023Q0026270007002B0001000200042B3Q002B00010012433Q00023Q00042B3Q0039000100042B3Q002B00010026273Q00020001000A00042B3Q00020001001243000700013Q0026270007003C0001000100042B3Q003C0001002627000500530001000100042B3Q00530001002627000400450001000100042B3Q004500010020720008000600012Q006C000800023Q00042B3Q005E0001001243000800014Q0067000900093Q002627000800470001000100042B3Q00470001001243000900013Q0026270009004A0001000100042B3Q004A0001001243000500023Q001243000300013Q00042B3Q005E000100042B3Q004A000100042B3Q005E000100042B3Q0047000100042B3Q005E00010026270005005E0001000B00042B3Q005E00010026270004005B0001000100042B3Q005B00010030480008000200012Q002A0008000600080006450008005D0001000100042B3Q005D00010012040008000C4Q002A0008000600082Q006C000800024Q000F000800026Q000900063Q00202Q000A0005000D4Q0008000A000200202Q00090004000E4Q0009000300094Q0008000800094Q000800023Q00044Q003C000100042B3Q000200012Q00073Q00017Q00053Q00028Q00034Q00026Q00F03F026Q000840027Q0040014C3Q001243000100014Q0067000200033Q001243000400013Q002627000400240001000100042B3Q002400010026270001001D0001000100042B3Q001D00012Q0067000200023Q0006453Q001C0001000100042B3Q001C0001001243000500014Q0067000600063Q0026270005000C0001000100042B3Q000C0001001243000600013Q0026270006000F0001000100042B3Q000F00012Q000F00076Q001B0007000100022Q001C3Q00073Q0026273Q001C0001000100042B3Q001C0001001243000700024Q006C000700023Q00042B3Q001C000100042B3Q000F000100042B3Q001C000100042B3Q000C0001001243000100033Q002627000100230001000400042B3Q002300012Q000F000500014Q001C000600034Q003E000500064Q005A00055Q001243000400033Q002627000400030001000300042B3Q000300010026270001003A0001000500042B3Q003A00012Q004200056Q0036000300053Q00122Q000500036Q000600023Q00122Q000700033Q00042Q0005003900012Q000F000900024Q0063000A00036Q000B00046Q000C00026Q000D00086Q000E00086Q000B000E6Q000A8Q00093Q00024Q0003000800090004650005002E0001001243000100043Q002627000100020001000300042B3Q000200012Q000F000500044Q0031000600056Q000700066Q000800066Q000800083Q00202Q0008000800034Q0005000800024Q000200056Q000500066Q000500056Q000500063Q00122Q000100053Q00044Q0002000100042B3Q0003000100042B3Q000200012Q00073Q00017Q00013Q0003013Q002300094Q004200016Q007000026Q002200013Q00012Q000F00025Q00120D000300016Q00048Q00028Q00019Q0000017Q00143Q00026Q00F03F027Q004003013Q007B03013Q007D03013Q002C028Q002Q033Q006E696C03043Q00303833362Q033Q006768612Q033Q002D313903043Q003F69643D026Q0008402Q033Q003Q782Q033Q0039312803043Q00682Q747003013Q007C03013Q005C03013Q003C03013Q003E2Q033Q0031392800CD022Q0002348Q001B3Q00010002000234000100014Q001B000100010002000234000200024Q001B000200010002000234000300034Q001B000300010002000234000400044Q001B000400010002000234000500054Q001B000500010002000234000600064Q001B000600010002000234000700074Q001B000700010002002627000700952Q01000100042B3Q00952Q010026273Q000E0001000200042B3Q000E0001001243000800034Q0058000800086Q00098Q00090001000200122Q000A00013Q00042Q000800852Q01000654000C0008000100012Q000F3Q00014Q004A000C000100024Q000D00026Q000E000C3Q00122Q000F00046Q000F000F3Q00122Q001000056Q001000106Q000D0010000200262Q000D00832Q01000600042B3Q00832Q01001243000D00064Q0067000E00113Q002627000D00390001000600042B3Q00390001001243001200063Q000E1E000600340001001200042B3Q00340001000234001300094Q001B0013000100022Q001C000E00133Q0002340013000A4Q001B0013000100022Q001C000F00133Q001243001200013Q0026270012002B0001000100042B3Q002B0001001243000D00013Q00042B3Q0039000100042B3Q002B0001002627000D00702Q01000200042B3Q00702Q01002627000E00D10001000100042B3Q00D100010002340012000B4Q001B001200010002000E1E000100450001001200042B3Q004500010002340013000C4Q001B0013000100022Q001C000E00133Q00042B3Q00D10001002Q26001200480001000600042B3Q0048000100042B3Q003F00010006540013000D000100012Q000F3Q00034Q001B0013000100022Q001C001100133Q002627000F007D0001000600042B3Q007D0001001243001300064Q0067001400153Q0026270013006A0001000100042B3Q006A0001002627001400520001000600042B3Q005200010002340016000E4Q001B0016000100022Q001C001500163Q002627001500570001000600042B3Q00570001001243001600074Q0071001600163Q0006540017000F000100012Q000F3Q00034Q001B0017000100022Q0053001100160017001243001600084Q0071001600163Q00065400170010000100012Q000F3Q00034Q001B0017000100022Q005300110016001700042B3Q00CD000100042B3Q0057000100042B3Q00CD000100042B3Q0052000100042B3Q00CD0001002627001300500001000600042B3Q00500001001243001600063Q002627001600710001000100042B3Q00710001001243001300013Q00042B3Q005000010026270016006D0001000600042B3Q006D0001000234001700114Q001B0017000100022Q001C001400173Q000234001700124Q001B0017000100022Q001C001500173Q001243001600013Q00042B3Q006D000100042B3Q0050000100042B3Q00CD0001001243001300054Q0071001300133Q000637000F00880001001300042B3Q00880001001243001300094Q0071001300133Q00065400140013000100012Q000F8Q001B0014000100022Q005300110013001400042B3Q00CD0001002627000F00910001000200042B3Q009100010012430013000A4Q0071001300133Q00065400140014000100012Q000F8Q001B0014000100022Q005300110013001400042B3Q00CD00010012430013000A4Q0071001300133Q000637000F00CD0001001300042B3Q00CD0001001243001300064Q0067001400163Q0026270013009C0001000600042B3Q009C0001001243001400064Q0067001500153Q001243001300013Q002627001300970001000100042B3Q009700012Q0067001600163Q000E1E000600B00001001400042B3Q00B00001001243001700063Q002627001700A60001000100042B3Q00A60001001243001400013Q00042B3Q00B00001002627001700A20001000600042B3Q00A20001000234001800154Q001B0018000100022Q001C001500183Q000234001800164Q001B0018000100022Q001C001600183Q001243001700013Q00042B3Q00A20001000E1E0001009F0001001400042B3Q009F0001002627001500B20001000600042B3Q00B20001000234001700174Q001B0017000100022Q001C001600173Q000E1E000600B70001001600042B3Q00B70001001243001700094Q0071001700173Q00065400180018000100012Q000F8Q001B0018000100022Q00530011001700180012430017000B4Q0071001700173Q00065400180019000100012Q000F3Q00034Q001B0018000100022Q005300110017001800042B3Q00CD000100042B3Q00B7000100042B3Q00CD000100042B3Q00B2000100042B3Q00CD000100042B3Q009F000100042B3Q00CD000100042B3Q009700010002340013001A4Q001B0013000100022Q001C001200133Q00042B3Q003F0001002627000E00EA0001000C00042B3Q00EA00012Q000F001200024Q0011001300103Q00122Q0014000D6Q001400143Q00122Q0015000E6Q001500156Q00120015000200122Q001300046Q001300133Q00062Q001200E50001001300042B3Q00E500010012430012000F4Q0071001200123Q0006540013001B000100022Q001C3Q00064Q001C3Q00114Q001B0013000100022Q00530011001200130006540012001C000100012Q001C3Q00114Q001B0012000100022Q00530001000B001200042B3Q00822Q01000E1E0006003F2Q01000E00042B3Q003F2Q01001243001200064Q0067001300153Q000E1E000600F30001001200042B3Q00F30001001243001300064Q0067001400143Q001243001200013Q002627001200EE0001000100042B3Q00EE00012Q0067001500153Q000E1E000600072Q01001300042B3Q00072Q01001243001600063Q000E1E000100FD0001001600042B3Q00FD0001001243001300013Q00042B3Q00072Q01002627001600F90001000600042B3Q00F900010002340017001D4Q001B0017000100022Q001C001400173Q0002340017001E4Q001B0017000100022Q001C001500173Q001243001600013Q00042B3Q00F90001000E1E000100F60001001300042B3Q00F60001002627001400092Q01000600042B3Q00092Q010002340016001F4Q001B0016000100022Q001C001500163Q002Q26001500112Q01000600042B3Q00112Q0100042B3Q00312Q01000234001600204Q001B001600010002002627001600192Q01000100042B3Q00192Q01000234001700214Q001B0017000100022Q001C001500173Q00042B3Q00312Q01002627001600132Q01000600042B3Q00132Q01001243001700063Q000E1E000100222Q01001700042B3Q00222Q01000234001800224Q001B0018000100022Q001C001600183Q00042B3Q00132Q010026270017001C2Q01000600042B3Q001C2Q0100065400180023000100022Q000F3Q00024Q001C3Q000C4Q001B0018000100022Q001C000F00183Q00065400180024000100022Q000F3Q00024Q001C3Q000C4Q001B0018000100022Q001C001000183Q001243001700013Q00042B3Q001C2Q0100042B3Q00132Q01002Q26001500342Q01000100042B3Q00342Q0100042B3Q000E2Q01000234001600254Q001B0016000100022Q001C000E00163Q00042B3Q003F2Q0100042B3Q000E2Q0100042B3Q003F2Q0100042B3Q00092Q0100042B3Q003F2Q0100042B3Q00F6000100042B3Q003F2Q0100042B3Q00EE0001002Q26000E00422Q01000200042B3Q00422Q0100042B3Q003B0001001243001200063Q002627001200672Q01000600042B3Q00672Q012Q000F001300024Q0011001400103Q00122Q001500106Q001500153Q00122Q001600056Q001600166Q00130016000200122Q001400116Q001400143Q00062Q001300552Q01001400042B3Q00552Q0100065400130026000100022Q001C3Q00064Q001C3Q00114Q001B0013000100020010620011000200132Q000F001300024Q0010001400103Q00122Q001500023Q00122Q001600026Q00130016000200122Q001400106Q001400143Q00062Q0013005F2Q01001400042B3Q005F2Q0100042B3Q00662Q010012430013000E4Q0071001300133Q00065400140027000100022Q001C3Q00064Q001C3Q00114Q001B0014000100022Q0053001100130014001243001200013Q002627001200432Q01000100042B3Q00432Q01000234001300284Q001B0013000100022Q001C000E00133Q00042B3Q003B000100042B3Q00432Q0100042B3Q003B000100042B3Q00822Q01000E1E000100280001000D00042B3Q00280001001243001200063Q002627001200772Q01000100042B3Q00772Q01001243000D00023Q00042B3Q00280001002627001200732Q01000600042B3Q00732Q01000234001300294Q001B0013000100022Q001C001000133Q0002340013002A4Q001B0013000100022Q001C001100133Q001243001200013Q00042B3Q00732Q0100042B3Q002800012Q0047000D6Q0047000C5Q0004650008001A0001001243000800124Q0058000800086Q00098Q00090001000200122Q000A00013Q00042Q000800932Q01001243000C00104Q0071000C000C4Q0041000C000B000C000654000D002B000100012Q000F3Q00044Q001B000D000100022Q00530002000C000D0004650008008B2Q012Q006C000400023Q00042B3Q000E0001002Q26000700982Q01000600042B3Q00982Q0100042B3Q001000010026273Q00ED2Q01000600042B3Q00ED2Q01001243000800064Q00670009000A3Q002627000800A52Q01000600042B3Q00A52Q01000234000B002C4Q001B000B000100022Q001C0009000B3Q000234000B002D4Q001B000B000100022Q001C000A000B3Q001243000800013Q0026270008009C2Q01000100042B3Q009C2Q01002Q26000900AA2Q01000600042B3Q00AA2Q0100042B3Q00A72Q01000234000B002E4Q001B000B000100022Q001C000A000B3Q000E1E000200B32Q01000A00042B3Q00B32Q01000234000B002F4Q001B000B000100022Q001C3Q000B3Q00042B3Q00ED2Q01002627000A00CF2Q01000100042B3Q00CF2Q01001243000B00064Q0067000C000C3Q002627000B00B72Q01000600042B3Q00B72Q01001243000C00063Q002627000C00C02Q01000100042B3Q00C02Q01000234000D00304Q001B000D000100022Q001C000A000D3Q00042B3Q00CF2Q01002627000C00BA2Q01000600042B3Q00BA2Q01000234000D00314Q001B000D000100022Q001C0003000D3Q000654000D0032000100032Q001C3Q00014Q001C3Q00024Q001C3Q00034Q001B000D000100022Q001C0004000D3Q001243000C00013Q00042B3Q00BA2Q0100042B3Q00CF2Q0100042B3Q00B72Q01002627000A00AD2Q01000600042B3Q00AD2Q01001243000B00064Q0067000C000C3Q002627000B00D32Q01000600042B3Q00D32Q01001243000C00063Q000E1E000100DC2Q01000C00042B3Q00DC2Q01000234000D00334Q001B000D000100022Q001C000A000D3Q00042B3Q00AD2Q01002627000C00D62Q01000600042B3Q00D62Q01000234000D00344Q001B000D000100022Q001C0001000D3Q000234000D00354Q001B000D000100022Q001C0002000D3Q001243000C00013Q00042B3Q00D62Q0100042B3Q00AD2Q0100042B3Q00D32Q0100042B3Q00AD2Q0100042B3Q00ED2Q0100042B3Q00A72Q0100042B3Q00ED2Q0100042B3Q009C2Q01001243000800034Q0071000800083Q0006373Q00C70201000800042B3Q00C70201001243000800064Q00670009000A3Q002627000800BD0201000100042B3Q00BD0201002627000900F52Q01000600042B3Q00F52Q01000234000B00364Q001B000B000100022Q001C000A000B3Q002627000A00140201000600042B3Q00140201001243000B00064Q0067000C000C3Q002627000B00FE2Q01000600042B3Q00FE2Q01001243000C00063Q000E1E0006000B0201000C00042B3Q000B0201000654000D0037000100012Q000F8Q001B000D000100022Q001C0005000D3Q000234000D00384Q001B000D000100022Q001C0006000D3Q001243000C00013Q000E1E000100010201000C00042B3Q00010201000234000D00394Q001B000D000100022Q001C000A000D3Q00042B3Q0014020100042B3Q0001020100042B3Q0014020100042B3Q00FE2Q01002627000A00B20201000100042B3Q00B20201001243000B00124Q0071000B000B4Q001C000C00053Q001243000D00013Q00043A000B00A90201001243000F00064Q0067001000133Q000E1E0006002E0201000F00042B3Q002E0201001243001400063Q002627001400240201000100042B3Q00240201001243000F00013Q00042B3Q002E0201002627001400200201000600042B3Q002002010002340015003A4Q001B0015000100022Q001C001000153Q0002340015003B4Q001B0015000100022Q001C001100153Q001243001400013Q00042B3Q00200201002627000F00950201000200042B3Q00950201002Q26001000330201000100042B3Q0033020100042B3Q008002010002340014003C4Q001B0014000100022Q001C001300143Q002Q26001100390201000100042B3Q0039020100042B3Q00560201001243001400134Q0071001400143Q000637001200420201001400042B3Q004202010006540014003D000100012Q000F3Q00014Q001B0014000100022Q001C001300143Q00042B3Q00510201002627001200490201000200042B3Q004902010006540014003E000100012Q000F3Q00054Q001B0014000100022Q001C001300143Q00042B3Q005102010012430014000A4Q0071001400143Q000637001200510201001400042B3Q005102010006540014003F000100012Q000F3Q00064Q001B0014000100022Q001C001300143Q00065400140040000100012Q001C3Q00134Q001B0014000100022Q00530006000E001400042B3Q00A70201002627001100360201000600042B3Q00360201001243001400064Q0067001500153Q0026270014005A0201000600042B3Q005A0201000234001600414Q001B0016000100022Q001C001500163Q002Q26001500620201000100042B3Q0062020100042B3Q00660201000234001600424Q001B0016000100022Q001C001100163Q00042B3Q00360201002Q26001500690201000600042B3Q0069020100042B3Q005F0201001243001600063Q002627001600700201000100042B3Q00700201000234001700434Q001B0017000100022Q001C001500173Q00042B3Q005F02010026270016006A0201000600042B3Q006A020100065400170044000100012Q000F3Q00014Q001B0017000100022Q001C001200173Q000234001700454Q001B0017000100022Q001C001300173Q001243001600013Q00042B3Q006A020100042B3Q005F020100042B3Q0036020100042B3Q005A020100042B3Q0036020100042B3Q00A70201002627001000300201000600042B3Q00300201001243001400063Q002627001400890201000100042B3Q00890201000234001500464Q001B0015000100022Q001C001000153Q00042B3Q00300201002627001400830201000600042B3Q00830201000234001500474Q001B0015000100022Q001C001100153Q000234001500484Q001B0015000100022Q001C001200153Q001243001400013Q00042B3Q0083020100042B3Q0030020100042B3Q00A70201002627000F001D0201000100042B3Q001D0201001243001400063Q002627001400A10201000600042B3Q00A10201000234001500494Q001B0015000100022Q001C001200153Q0002340015004A4Q001B0015000100022Q001C001300153Q001243001400013Q002627001400980201000100042B3Q00980201001243000F00023Q00042B3Q001D020100042B3Q0098020100042B3Q001D02012Q0047000F5Q000465000B001B0201001243000B00144Q0071000B000B3Q000654000C004B000100012Q000F3Q00014Q001B000C000100022Q00530004000B000C000234000B004C4Q001B000B000100022Q001C000A000B3Q000E06000200B50201000A00042B3Q00B5020100042B3Q00FA2Q01000234000B004D4Q001B000B000100022Q001C3Q000B3Q00042B3Q00C7020100042B3Q00FA2Q0100042B3Q00C7020100042B3Q00F52Q0100042B3Q00C70201002627000800F32Q01000600042B3Q00F32Q01000234000B004E4Q001B000B000100022Q001C0009000B3Q000234000B004F4Q001B000B000100022Q001C000A000B3Q001243000800013Q00042B3Q00F32Q01000234000800504Q001B0008000100022Q001C000700083Q00042B3Q0010000100042B3Q000E00012Q00073Q00013Q00513Q00013Q00029Q00033Q0012433Q00014Q006C3Q00024Q00073Q00019Q003Q00024Q00073Q00014Q00073Q00019Q003Q00024Q00073Q00014Q00073Q00019Q003Q00024Q00073Q00014Q00073Q00019Q003Q00024Q00073Q00014Q00073Q00019Q003Q00024Q00073Q00014Q00073Q00019Q003Q00024Q00073Q00014Q00073Q00017Q00013Q00029Q00033Q0012433Q00014Q006C3Q00024Q00073Q00019Q003Q00044Q000F8Q00493Q00014Q005A8Q00073Q00017Q00013Q00029Q00033Q0012433Q00014Q006C3Q00024Q00073Q00019Q003Q00024Q00073Q00014Q00073Q00017Q00013Q00029Q00033Q0012433Q00014Q006C3Q00024Q00073Q00017Q00013Q00027Q004000033Q0012433Q00014Q006C3Q00024Q00073Q00019Q003Q00094Q00123Q00046Q00018Q0001000100024Q00028Q0002000100024Q000300048Q000400012Q006C3Q00024Q00073Q00017Q00013Q00029Q00033Q0012433Q00014Q006C3Q00024Q00073Q00019Q003Q00044Q000F8Q00493Q00014Q005A8Q00073Q00019Q003Q00044Q000F8Q00493Q00014Q005A8Q00073Q00017Q00013Q00029Q00033Q0012433Q00014Q006C3Q00024Q00073Q00019Q003Q00024Q00073Q00014Q00073Q00019Q003Q00044Q000F8Q00493Q00014Q005A8Q00073Q00017Q00013Q00026Q00F04000054Q00359Q003Q0001000200206Q00016Q00028Q00017Q00013Q00029Q00033Q0012433Q00014Q006C3Q00024Q00073Q00019Q003Q00024Q00073Q00014Q00073Q00017Q00013Q00029Q00033Q0012433Q00014Q006C3Q00024Q00073Q00017Q00013Q00026Q00F04000054Q00359Q003Q0001000200206Q00016Q00028Q00019Q003Q00044Q000F8Q00493Q00014Q005A8Q00073Q00017Q00013Q00026Q00F03F00033Q0012433Q00014Q006C3Q00024Q00073Q00017Q00013Q0003043Q006173643100084Q002E9Q00000100013Q00122Q000200016Q000200026Q0001000100028Q00016Q00028Q00019Q003Q00034Q000F8Q006C3Q00024Q00073Q00017Q00013Q00029Q00033Q0012433Q00014Q006C3Q00024Q00073Q00019Q003Q00024Q00073Q00014Q00073Q00017Q00013Q00029Q00033Q0012433Q00014Q006C3Q00024Q00073Q00017Q00013Q00029Q00033Q0012433Q00014Q006C3Q00024Q00073Q00017Q00013Q00026Q00F03F00033Q0012433Q00014Q006C3Q00024Q00073Q00017Q00013Q00026Q00F03F00033Q0012433Q00014Q006C3Q00024Q00073Q00017Q00023Q00027Q00402Q033Q00786E7800084Q004C9Q00000100013Q00122Q000200013Q00122Q000300026Q000300038Q00039Q008Q00017Q00023Q0003043Q0030383336026Q00184000084Q00699Q00000100013Q00122Q000200016Q000200023Q00122Q000300028Q00039Q008Q00017Q00013Q00026Q00F03F00033Q0012433Q00014Q006C3Q00024Q00073Q00017Q00013Q00027Q004000064Q006D9Q00000100013Q00202Q0001000100018Q00016Q00028Q00017Q00013Q002Q033Q00786E7800084Q002E9Q00000100013Q00122Q000200016Q000200026Q0001000100028Q00016Q00028Q00017Q00013Q00026Q00084000033Q0012433Q00014Q006C3Q00024Q00073Q00019Q003Q00024Q00073Q00014Q00073Q00019Q003Q00024Q00073Q00014Q00073Q00019Q003Q00044Q000F8Q00493Q00014Q005A8Q00073Q00017Q00013Q00029Q00033Q0012433Q00014Q006C3Q00024Q00073Q00019Q003Q00024Q00073Q00014Q00073Q00017Q00013Q00029Q00033Q0012433Q00014Q006C3Q00024Q00073Q00017Q00013Q0003013Q005B00043Q0012433Q00014Q00718Q006C3Q00024Q00073Q00017Q00013Q00027Q004000033Q0012433Q00014Q006C3Q00024Q00073Q00019Q003Q00034Q00428Q006C3Q00024Q00073Q00019Q003Q00084Q00243Q00046Q00018Q000200016Q000300036Q000400028Q000400012Q006C3Q00024Q00073Q00017Q00013Q00026Q00F03F00033Q0012433Q00014Q006C3Q00024Q00073Q00019Q003Q00034Q00428Q006C3Q00024Q00073Q00019Q003Q00034Q00428Q006C3Q00024Q00073Q00017Q00013Q00029Q00033Q0012433Q00014Q006C3Q00024Q00073Q00019Q003Q00044Q000F8Q00493Q00014Q005A8Q00073Q00019Q003Q00034Q00428Q006C3Q00024Q00073Q00017Q00013Q00026Q00F03F00033Q0012433Q00014Q006C3Q00024Q00073Q00017Q00013Q00029Q00033Q0012433Q00014Q006C3Q00024Q00073Q00019Q003Q00024Q00073Q00014Q00073Q00019Q003Q00024Q006C3Q00024Q00073Q00017Q00013Q00029Q00084Q000F8Q001B3Q000100020026273Q00050001000100042B3Q000500012Q00038Q00333Q00014Q006C3Q00024Q00073Q00019Q003Q00044Q000F8Q00493Q00014Q005A8Q00073Q00019Q003Q00044Q000F8Q00493Q00014Q005A8Q00073Q00019Q003Q00034Q000F8Q006C3Q00024Q00073Q00017Q00013Q00029Q00033Q0012433Q00014Q006C3Q00024Q00073Q00017Q00013Q00026Q00F03F00033Q0012433Q00014Q006C3Q00024Q00073Q00017Q00013Q00026Q00F03F00033Q0012433Q00014Q006C3Q00024Q00073Q00019Q003Q00044Q000F8Q00493Q00014Q005A8Q00073Q00019Q003Q00024Q006C3Q00024Q00073Q00017Q00013Q00026Q00F03F00033Q0012433Q00014Q006C3Q00024Q00073Q00017Q00013Q00029Q00033Q0012433Q00014Q006C3Q00024Q00073Q00019Q003Q00024Q006C3Q00024Q00073Q00019Q003Q00024Q00073Q00014Q00073Q00019Q003Q00024Q00073Q00014Q00073Q00019Q003Q00044Q000F8Q00493Q00014Q005A8Q00073Q00017Q00013Q00027Q004000033Q0012433Q00014Q006C3Q00024Q00073Q00017Q00013Q00027Q004000033Q0012433Q00014Q006C3Q00024Q00073Q00017Q00013Q00029Q00033Q0012433Q00014Q006C3Q00024Q00073Q00019Q003Q00024Q00073Q00014Q00073Q00017Q00013Q00026Q00F03F00033Q0012433Q00014Q006C3Q00024Q00073Q00017Q00033Q00026Q00F03F027Q0040026Q000840030D3Q00203200033Q000100203200043Q000200203200053Q000300065400063Q000100072Q001C3Q00034Q001C3Q00044Q001C3Q00054Q000F8Q000F3Q00014Q000F3Q00024Q001C3Q00024Q006C000600024Q00073Q00013Q00013Q00163Q00028Q00026Q000840026Q00F03F026Q001040026Q00F0BF027Q004003013Q0023026Q001440025Q0064A740025Q00D08A40025Q0056AD40025Q00988C40025Q00D4AE40025Q003EAD40026Q001C40026Q001840025Q00DC9440025Q00D4A940025Q00607F40025Q00E49740025Q00308040025Q00308C4000F9012Q001243000100014Q00670002000F3Q000E1E000200190001000100042B3Q001900012Q004200106Q0066000B00106Q00108Q000C00103Q00122Q001000016Q0011000A3Q00122Q001200033Q00042Q00100018000100063B000400140001001300042B3Q001400012Q004100140013000400205D00150013000300202Q0015001500014Q0015000900154Q00080014001500044Q001700010020170014001300032Q00610014000900142Q0053000C001300140004650010000C0001001243000100043Q0026270001001F0001000100042B3Q001F00012Q000F00026Q000F000300014Q000F000400023Q001243000100033Q002627000100250001000300042B3Q002500012Q000F000500033Q001243000600033Q001243000700053Q001243000100063Q000E1E000600330001000100042B3Q003300012Q004200106Q001C000800104Q004200106Q007000116Q002200103Q00012Q001C000900104Q0039001000043Q00122Q001100076Q00128Q00103Q000200202Q000A0010000300122Q000100023Q0026270001003A0001000400042B3Q003A00012Q00410010000A0004002017001000100003002017000D001000012Q0067000E000F3Q001243000100083Q002627000100020001000800042B3Q00020001001243001000013Q002627001000EF2Q01000300042B3Q00EF2Q01002638000F009C2Q01000200042B3Q009C2Q01002638000F00902Q01000300042B3Q00902Q01002E5B000A008E0001000900042B3Q008E0001000E250001008E0001000F00042B3Q008E0001001243001100014Q0067001200163Q0026270011004D0001000300042B3Q004D00012Q0067001400153Q001243001100063Q002627001100870001000600042B3Q008700012Q0067001600163Q0026270012005E0001000300042B3Q005E0001001243001700013Q002627001700570001000300042B3Q00570001001243001200063Q00042B3Q005E0001002627001700530001000100042B3Q005300012Q001500180015001300201A000700180003001243001600013Q001243001700033Q00042B3Q00530001000E06000600620001001200042B3Q00620001002E19000B00760001000C00042B3Q007600012Q001C001700134Q001C001800073Q001243001900033Q00043A001700750001001243001B00014Q0067001C001C3Q000E1E000100680001001B00042B3Q00680001001243001C00013Q002627001C006B0001000100042B3Q006B00010020170016001600032Q0061001D001400162Q0053000C001A001D00042B3Q0074000100042B3Q006B000100042B3Q0074000100042B3Q0068000100046500170066000100042B3Q00ED2Q01002627001200500001000100042B3Q005000010020320013000E00062Q0030001700056Q0018000C00134Q001900056Q001A000C3Q00202Q001B0013000300202Q001C000E00024Q0019001C6Q00188Q00173Q00184Q001500186Q001400173Q00122Q001200033Q00044Q0050000100042B3Q00ED2Q01002627001100490001000100042B3Q00490001001243001200014Q0067001300133Q001243001100033Q00042B3Q0049000100042B3Q00ED2Q01001243001100014Q0067001200173Q0026270011009D0001000100042B3Q009D0001001243001800013Q000E1E000300970001001800042B3Q00970001001243001100033Q00042B3Q009D0001002627001800930001000100042B3Q00930001001243001200014Q0067001300133Q001243001800033Q00042B3Q00930001002627001100A90001000300042B3Q00A90001001243001800013Q002627001800A40001000300042B3Q00A40001001243001100063Q00042B3Q00A90001002627001800A00001000100042B3Q00A000012Q0067001400153Q001243001800033Q00042B3Q00A00001000E1E000200822Q01001100042B3Q00822Q01002627001200C30001000200042B3Q00C30001001243001800013Q002627001800B30001000300042B3Q00B300010020170006000600032Q0061000E00020006001243001800063Q002627001800BB0001000100042B3Q00BB00010020170019001700032Q003C000C0019001600202Q0019000E00044Q0019001600194Q000C0017001900122Q001800033Q002627001800AE0001000600042B3Q00AE00010020320019000E0006002032001A000E00022Q0053000C0019001A001243001200043Q00042B3Q00C3000100042B3Q00AE0001002E5B000E00CA0001000D00042B3Q00CA0001002627001200CA0001000F00042B3Q00CA00012Q0061000E000200062Q00073Q00013Q00042B3Q00ED2Q01002627001200E90001000800042B3Q00E90001001243001800013Q002627001800DE0001000100042B3Q00DE0001001243001300014Q001C001900174Q001C001A00073Q001243001B00033Q00043A001900DD0001001243001D00013Q002627001D00D50001000100042B3Q00D500010020170013001300032Q0061001E001400132Q0053000C001C001E00042B3Q00DC000100042B3Q00D50001000465001900D40001001243001800033Q002627001800E30001000600042B3Q00E300010020320017000E0006001243001200103Q00042B3Q00E90001000E1E000300CD0001001800042B3Q00CD00010020170006000600032Q0061000E00020006001243001800063Q00042B3Q00CD0001002Q26001200ED0001000400042B3Q00ED0001002E190012000B2Q01001100042B3Q000B2Q01001243001800013Q002627001800F40001000600042B3Q00F400012Q001500190015001700201A000700190003001243001200083Q00042B3Q000B2Q01002627001800F90001000100042B3Q00F900010020170006000600032Q0061000E00020006001243001800033Q002627001800EE0001000300042B3Q00EE00010020320017000E00062Q000C001900056Q001A000C00174Q001B00056Q001C000C3Q00202Q001D0017000300202Q001D001D000100202Q001D001D000100202Q001E000E00024Q001B001E6Q001A8Q00193Q001A4Q0015001A6Q001400193Q00122Q001800063Q00044Q00EE0001002627001200272Q01000100042B3Q00272Q01001243001800014Q0067001900193Q0026270018000F2Q01000100042B3Q000F2Q01001243001900013Q002627001900162Q01000300042B3Q00162Q012Q0067001600173Q001243001900063Q000E1E0006001D2Q01001900042B3Q001D2Q01002032001A000E00062Q0042001B6Q0053000C001A001B001243001200033Q00042B3Q00272Q01000E1E000100122Q01001900042B3Q00122Q012Q0067001300134Q000A001A001B6Q0015001B6Q0014001A3Q00122Q001900033Q00044Q00122Q0100042B3Q00272Q0100042B3Q000F2Q010026270012004A2Q01001000042B3Q004A2Q01001243001800014Q0067001900193Q0026270018002B2Q01000100042B3Q002B2Q01001243001900013Q002627001900342Q01000600042B3Q00342Q01002017001A000600030020170006001A00010012430012000F3Q00042B3Q004A2Q01002627001900402Q01000100042B3Q00402Q012Q0061001A000C00172Q002D001B00056Q001C000C3Q00202Q001D001700034Q001E00076Q001B001E6Q001A3Q00024Q000C0017001A00202Q00060006000300122Q001900033Q0026270019002E2Q01000300042B3Q002E2Q012Q0061000E00020006002068001A000E00064Q001A000C001A4Q001A0001000100122Q001900063Q00044Q002E2Q0100042B3Q004A2Q0100042B3Q002B2Q01002627001200622Q01000300042B3Q00622Q01001243001800013Q002627001800572Q01000300042B3Q00572Q010020320019000E00062Q0001001A00063Q00202Q001B000E00024Q001A001A001B4Q000C0019001A00202Q00190006000300202Q00060019000100122Q001800063Q0026270018005C2Q01000600042B3Q005C2Q012Q0061000E00020006001243001200063Q00042B3Q00622Q010026270018004D2Q01000100042B3Q004D2Q010020170006000600032Q0061000E00020006001243001800033Q00042B3Q004D2Q01002627001200AB0001000600042B3Q00AB0001001243001800014Q0067001900193Q002627001800662Q01000100042B3Q00662Q01001243001900013Q0026270019006E2Q01000300042B3Q006E2Q012Q0061000E000200060020320017000E0006001243001900063Q002627001900772Q01000100042B3Q00772Q01002032001A000E00062Q0009001B00063Q00202Q001C000E00024Q001B001B001C4Q000C001A001B00202Q00060006000300122Q001900033Q002627001900692Q01000600042B3Q00692Q01002032001A000E00022Q00610016000C001A001243001200023Q00042B3Q00AB000100042B3Q00692Q0100042B3Q00AB000100042B3Q00662Q0100042B3Q00AB000100042B3Q00ED2Q01002627001100900001000600042B3Q00900001001243001800013Q002627001800892Q01000100042B3Q00892Q012Q0067001600173Q001243001800033Q000E1E000300852Q01001800042B3Q00852Q01001243001100023Q00042B3Q0090000100042B3Q00852Q0100042B3Q0090000100042B3Q00ED2Q01000E25000600962Q01000F00042B3Q00962Q010020320011000E00062Q004200126Q0053000C0011001200042B3Q00ED2Q010020320011000E00062Q006E001200063Q00202Q0013000E00024Q0012001200134Q000C0011001200044Q00ED2Q01002638000F00E02Q01000800042B3Q00E02Q01002627000F00B02Q01000400042B3Q00B02Q01001243001100014Q0067001200123Q002627001100A22Q01000100042B3Q00A22Q010020320012000E00062Q00560013000C00124Q001400056Q0015000C3Q00202Q0016001200034Q001700076Q001400176Q00133Q00024Q000C0012001300044Q00ED2Q0100042B3Q00A22Q0100042B3Q00ED2Q01001243001100014Q0067001200143Q002627001100D12Q01000300042B3Q00D12Q012Q0067001400143Q002Q26001200B92Q01000300042B3Q00B92Q01002E5B001400BF2Q01001300042B3Q00BF2Q010020170015001300032Q0002000C0015001400202Q0015000E00044Q0015001400154Q000C0013001500044Q00ED2Q01002E5B001500B52Q01001600042B3Q00B52Q01002627001200B52Q01000100042B3Q00B52Q01001243001500013Q000E1E000300C82Q01001500042B3Q00C82Q01001243001200033Q00042B3Q00B52Q01002627001500C42Q01000100042B3Q00C42Q010020320013000E00060020320016000E00022Q00610014000C0016001243001500033Q00042B3Q00C42Q0100042B3Q00B52Q0100042B3Q00ED2Q01000E1E000100B22Q01001100042B3Q00B22Q01001243001500013Q002627001500D82Q01000300042B3Q00D82Q01001243001100033Q00042B3Q00B22Q01000E1E000100D42Q01001500042B3Q00D42Q01001243001200014Q0067001300133Q001243001500033Q00042B3Q00D42Q0100042B3Q00B22Q0100042B3Q00ED2Q01002638000F00E62Q01001000042B3Q00E62Q010020320011000E00060020320012000E00022Q0053000C0011001200042B3Q00ED2Q01000E25000F00EA2Q01000F00042B3Q00EA2Q012Q00073Q00013Q00042B3Q00ED2Q010020320011000E00062Q00610011000C00112Q002800110001000100201700060006000300042B3Q003C00010026270010003D0001000100042B3Q003D00012Q0061000E00020006002032000F000E0003001243001000033Q00042B3Q003D000100042B3Q003C000100042B3Q00F82Q0100042B3Q000200012Q00073Q00017Q00", v9(), ...);
