#ifndef __IntTemplate__
#define __IntTemplate__
#include "Base.h"

template <class T, int ID>
class CIntTemplate: public CBaseField
{
protected:
T pmin;
T dt;
public:
	CIntTemplate(T &pm, T d)
	{
		dt=d;
		pmin=pm;
		id=ID;
	}
virtual ~CIntTemplate();
virtual void writeToBuffer(TDataSet *query, char* *buffer);
virtual String readFromBuffer(ReadData *data, int calcDiff);
virtual int getSize(TDataSet *query);

/*
T getCount() {return dt;}
T setCount(T cnt)
 {
	T t=dt;
	dt=cnt;
	return t;
 }
*/
};

template <class T, int ID>
CIntTemplate<T,ID>::~CIntTemplate()
{
}

template <class T, int ID>
CIntTemplate<T,ID>::getSize(TDataSet *query)
{
		return sizeof(int);
}

template <class T, int ID>
void CIntTemplate<T,ID>::writeToBuffer(TDataSet *query,   char* *buffer)
{
	T tmp;
	if(query->Fields->Fields[fieldNumber]->IsNull) tmp=0;
	else  tmp=(T)query->Fields->Fields[fieldNumber]->Value;

    int i=(double)((double)tmp - pmin)/(double)dt;

	*(int*)(*buffer)=i;
	((int*)(*buffer))++;
}

template <class T, int ID>
String CIntTemplate<T,ID>::readFromBuffer(ReadData *data, int calcDiff)
{
	int t=*(int*)(data->buffer);
	((int*)(data->buffer))++;

	T minV,maxV,m;
	minV=(double)(pmin+t*dt);
	maxV=minV+dt;

	if(calcDiff)
	{
				data->diff=0;
			T tmp;
			if(data->query->Fields->Fields[fieldNumber]->IsNull) tmp=0;
			else  tmp=(T)data->query->Fields->Fields[fieldNumber]->Value;
			if( (tmp>maxV) ||  (tmp<minV) )
			{
			m=(maxV+minV)/2;
			if(tmp!=0) data->diff=((m-tmp)/(1.0*tmp));
			else  data->diff=1;
			}

	}

		String res=convertToString(minV, data->view)+" - "+convertToString(maxV, data->view);

		return res;
}

#endif