#ifndef __TrendTemplate1__
#define __TrendTemplate1__
#include "base.h"

template <class T, int ID>
class CTrendTemplate1: public CBaseField
{
protected:
        double sens;
public:
  CTrendTemplate1(double perc)
  {
        sens=perc;
        id=ID;
  }
virtual ~CTrendTemplate1();
virtual void writeToBuffer(TDataSet *query,   char* *buffer);
virtual String readFromBuffer(ReadData *data, int calcDiff);
virtual int getSize(TDataSet *query);

        double getSens()
        {
                return sens;
        }

        double setSens(double s)
        {
                double t=sens;
                sens=s;
                return t;
        }

};

template <class T, int ID>
CTrendTemplate1<T,ID>::~CTrendTemplate1()
{
}

template <class T, int ID>
CTrendTemplate1<T,ID>::getSize(TDataSet *query)
{
        return sizeof(char);
}

template <class T, int ID>
void CTrendTemplate1<T,ID>::writeToBuffer(TDataSet *query,   char* *buffer)
{
    T tmp,pr;
    double d;

    char val=0;

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

    //tpm-=pr;

    if(pr==0)
    {
        if(tmp<0) val=-1;
        else
                if(tmp>0) val=1;
    }
    else
    {
         d=(tmp-pr)/(1.0*pr);
         if(d>=sens) val=1;
         if(d<=-sens) val=-1;
    }

    **buffer=val;
    (*buffer)++;
}

template <class T, int ID>
String CTrendTemplate1<T,ID>::readFromBuffer(ReadData *data,int calcDiff)
{
        char t=*data->buffer;
        data->buffer++;
        String res=convertToString(sens*t, ftFloat);

        if(calcDiff)
        {
          char val;
          double d;
          T tmp,pr;
          if(data->query->Fields->Fields[fieldNumber]->IsNull) tmp=0 ;
          else  tmp=(T)data->query->Fields->Fields[fieldNumber]->Value;


          if(data->query->RecNo!=1)
          {
              data->query->Prior();
              if(data->query->Fields->Fields[fieldNumber]->IsNull) pr=0;
              else pr=(T)data->query->Fields->Fields[fieldNumber]->Value;
              data->query->Next();
          }
          else pr=0;

          val=0;
          if(pr==0)
          {
              if(tmp<0) val=-1;
              else
                      if(tmp>0) val=1;
          }
          else
          {
               d=(tmp-pr)/(1.0*pr);
               if(d>=sens) val=1;
               if(d<=-sens) val=-1;
          }

          data->diff=t-val;

        }

        return res;
}
#endif