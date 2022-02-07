
#include "StringField.hpp"
#include <string.h >

CStringField::~CStringField()
{
}


CStringField::getSize(TDataSet *query)
{
        return query->Fields->Fields[fieldNumber]->AsString.Length()+1;
}


void CStringField::writeToBuffer(TDataSet *query,   char** buffer)
{
    String tmp;
    if(query->Fields->Fields[fieldNumber]->IsNull) tmp="";
    else  tmp=query->Fields->Fields[fieldNumber]->AsString;
    strcpy( (*buffer), tmp.c_str());
    (*buffer)+=tmp.Length()+1;
}

String CStringField::readFromBuffer(ReadData *data, int calcDiff)
{
        String res=data->buffer;

        if(calcDiff)
	{
        	String tmp;
        	if(data->query->Fields->Fields[fieldNumber]->IsNull)
                        tmp="";
        	else  tmp=data->query->Fields->Fields[fieldNumber]->AsString;

        if(res!=tmp) data->diff=1;
       	else data->diff=0;
	}

        data->buffer=data->buffer+strlen(data->buffer)+1;

        return res;
}