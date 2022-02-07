//---------------------------------------------------------------------------

#include <vcl.h>

#include "StringField.h"

#include "BaseTemplate.hpp"
#include "TrendTemplate.hpp"
#include "TrendTemplate1.hpp"
#include "IntTemplate.hpp"

#pragma hdrstop

#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button1Click(TObject *Sender)
{
   Query1->Close();
   Query1->Open();

   CTrendTemplate1 <int,0> bb0(0.25);
   CTrendTemplate <int,2> a0;
   CBaseTemplate <int,3> c0;

   CTrendTemplate1 <double,0> a1(0.25);
   CTrendTemplate <double,2> b1;
   CBaseTemplate <double,3> c1;

   CTrendTemplate1 <Currency,0> a2(0.25);
   CTrendTemplate <Currency,2> b2;
   CBaseTemplate <Currency,3> c2;


   CStringField bbb0(1);

   int mn=1;

   CIntTemplate <int,2> b0(&mn,4);



   b0.set_fieldNum(1);
   ReadData data;
   char buf[512];
   char *b=buf;
   data.buffer=buf;
   data.query=Query1;
   int i=0;

   while(!Query1->Eof)
   {
        b0.writeToBuffer(Query1,&b);
        Query1->Next();
        i++;
   }
  Query1->First();
  Memo1->Clear();
  data.old=0;
  data.diff=0;
  b0.set_fieldNum(2);
  //data.query=NULL;
  for(;i;i--)
  {
        data.old=b0.readFromBuffer(&data,1);
        Memo1->Lines->Add(String(data.old)+" "+FloatToStr(data.diff));
        Query1->Next();
  }

}
//---------------------------------------------------------------------------
