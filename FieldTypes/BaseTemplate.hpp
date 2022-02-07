#ifndef __BaseTemplate__
#define __BaseTemplate__
#include "base.h"

template <class T, int ID>
class CBaseTemplate: public CBaseField
{
public:
  CBaseTemplate() {id=ID;}
virtual ~CBaseTemplate();
virtual void writeToBuffer(TDataSet *query,   char* *buffer);
virtual String readFromBuffer(ReadData *data, int calcDiff);
virtual int getSize(TDataSet *query);
};

template <class T, int ID>
CBaseTemplate<T,ID>::~CBaseTemplate()
{
}

template <class T, int ID>
CBaseTemplate<T,ID>::getSize(TDataSet *query)
{
        return sizeof(T);
}

template <class T, int ID>
void CBaseTemplate<T,ID>::writeToBuffer(TDataSet *query,   char* *buffer)
{
    T tmp;
    if(query->Fields->Fields[fieldNumber]->IsNull) tmp=0;
    else  tmp=(T)query->Fields->Fields[fieldNumber]->Value;
    *((T*)(*buffer))=tmp;
    ((T*)(*buffer))++;
}

template <class T, int ID>
String CBaseTemplate<T,ID>::readFromBuffer(ReadData *data, int calcDiff)
{
        T t=*(T*)(data->buffer);

        if(calcDiff)
	{
        	T tmp;
        	if(data->query->Fields->Fields[fieldNumber]->IsNull) tmp=0;
        	else  tmp=(T)data->query->Fields->Fields[fieldNumber]->Value;

        if(tmp!=0) data->diff=((t-tmp)/(1.0*tmp));
       	else data->diff=t!=0;
	}
        String res=convertToString(t, data->view);
        ((T*)(data->buffer))++;
        return res;
}


/*
  procedure TIntField.toBuffer(query:TQuery; var buffer: PByte);
  begin
    PInteger(buffer)^:=query.Fields[number_of_field].AsInteger;
    Inc(buffer,sizeof(Integer));
  end;

  function TIntField.fromBufferS(old: String; var buffer: PByte):String;
  begin
    Result:=IntToStr(PInteger(buffer)^);
    Inc(buffer,sizeof(Integer));
  end;
*/
#endif