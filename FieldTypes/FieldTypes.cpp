//---------------------------------------------------------------------------

#include "FieldTypes.h"
#include "Parser.h"


CParser* _export _stdcall createParser( SPole** pole,           int count,
                                                                SFields* inFields,  int inSize,
                                                                SFields* outFields, int outSize
                                                          )
{

                CParser *res= new CParser[2];
                res[0].Init( pole, count, inFields, inSize);
                res[1].Init( pole, count, outFields, outSize);
                return res;
}

void   _stdcall destroyParser(CParser *id)
{
                if(id!=NULL) return;
                delete []id;
}

int  _stdcall getSize(CParser *id, TDataSet *query, int io)
{
           int result=0;

           if(io&1) result=id->getSize(query);
           if(io&2) result+=id[1].getSize(query);

           return result;
}


void   _stdcall getString   (   CParser         *id,
                                                                UScan           **buffer,
                                                                unsigned        index,
                                                                TDataSet          *guery,
                                                                String          *st,     //result
                                                                String          *df,     //differens
                                                                String          *f0,     //last value
                                                                int             cd       // calculate differenses
                                                         )
{
                CParser *p;
/*              String  nil="";
                if(st==NULL) st=&nil;
                if(df==NULL) df=&nil;
                if(f0==NULL) f0=&nil;*/
                if(id[1].present()) p=id+1;
                else p=id;

                p->getString(   buffer,
                                                index,
                                                guery,
                                                st,
                                                df,
                                                f0,
                                                cd
                                        );

}

void   _stdcall writeBuffer (  CParser *id,
                               UScan **buffer,
                               TDataSet *query,
                               int      io
                             )
{
				if( io&1 ) id->writeBuffer( buffer, query);
				id++;
                if( io&2 )id->writeBuffer( buffer, query);
}



#pragma hdrstop
//---------------------------------------------------------------------------
//   Important note about DLL memory management when your DLL uses the
//   static version of the RunTime Library:
//
//   If your DLL exports any functions that pass String objects (or structs/
//   classes containing nested Strings) as parameter or function results,
//   you will need to add the library MEMMGR.LIB to both the DLL project and
//   any other projects that use the DLL.  You will also need to use MEMMGR.LIB
//   if any other projects which use the DLL will be performing new or delete
//   operations on any non-TObject-derived classes which are exported from the
//   DLL. Adding MEMMGR.LIB to your project will change the DLL and its calling
//   EXE's to use the BORLNDMM.DLL as their memory manager.  In these cases,
//   the file BORLNDMM.DLL should be deployed along with your DLL.
//
//   To avoid using BORLNDMM.DLL, pass string information using "char *" or
//   ShortString parameters.
//
//   If your DLL uses the dynamic version of the RTL, you do not need to
//   explicitly add MEMMGR.LIB as this will be done implicitly for you
//---------------------------------------------------------------------------

#pragma argsused

int WINAPI DllEntryPoint(HINSTANCE hinst, unsigned long reason, void* lpReserved)
{
                return 1;
}
