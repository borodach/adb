#ifndef __TrendTemplate__
#define __TrendTemplate__
#include "base.h"

template <class T, int ID>
class CTrendTemplate: public CBaseField
{
public:
  CTrendTemplate() {id=ID;}
virtual ~CTrendTemplate();
virtual void writeToBuffer(TDataSet *query,   char* *buffer);
virtual String readFromBuffer(ReadData *data, int calcDiff);
virtual int getSize(TDataSet *query);
};

template <class T, int ID>
CTrendTemplate<T,ID>::~CTrendTemplate()
{
}

template <class T, int ID>
CTrendTemplate<T,ID>::getSize(TDataSet *query)
{
		return sizeof(T);
}

template <class T, int ID>
void CTrendTemplate<T,ID>::writeToBuffer(TDataSet *query,   char* *buffer)
{
	T tmp,pr;

	if(query->Fields->Fields[fieldNumber]->IsNull) tmp=0 ;
	else  tmp=(T)query->Fields->Fields[fieldNumber]->Value;

	if(query->RecNo!=1)
	{
		query->Prior();
		if(query->Fields->Fields[fieldNumber]->IsNull) pr=0;
		else pr=(T)query->Fields->Fields[fieldNumber]->Value;
		query->Next();
	}
	else pr=0;

	tmp=tmp-pr;
	*((T*)(*buffer))=tmp;
	((T*)(*buffer))++;
}

template <class T, int ID>
String CTrendTemplate<T,ID>::readFromBuffer(ReadData *data, int calcDiff)
{
	   //##T t=*(T*)(data->buffer)+(T)(data->old);
	   T t=*(T*)(data->buffer);
		if(calcDiff)
		{
				T tmp;
				if(data->query->Fields->Fields[fieldNumber]->IsNull) tmp=0;
				else  tmp=(T)data->query->Fields->Fields[fieldNumber]->Value
				-(T)(data->old);//##;

		if(tmp!=0) data->diff=((t-tmp)/(1.0*tmp));
		else data->diff=t!=0;
		}

		String res=convertToString(t, data->view);
        ((T*)(data->buffer))++;
        return res;
}

#endif