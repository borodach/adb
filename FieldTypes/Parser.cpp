
#include "Parser.h"
#include "BaseTemplate.hpp"
#include "IntTemplate.hpp"
#include "TrendTemplate.hpp"
#include "TrendTemplate1.hpp"
#include "StringField.hpp"


void CParser::Init(SPole **pole, int count, SFields *inFields, unsigned inSize)
{
	fieldsCount=inSize;
	if(inSize) fields = new CBaseField*[fieldsCount];
	else fields=NULL;

	for(unsigned i=0; i<fieldsCount; i++)
	{
		int n=abs(inFields[i].Num);
		if(n<0) n=-n;
		n--;

		switch(pole[n]->F_Type)
		{
		case 0:
			if(inFields[i].cnt==0)				//not interval
			{
				if(inFields[i].Num>0)			//not trend
					fields[i]=new CBaseTemplate<int,0x0001>;
				else
				{
					if(inFields[i].porog==0)  	// just trend
						fields[i]=new CTrendTemplate<int,0x0201>;
					else                        //relative trend
						fields[i]=new CTrendTemplate1<int,0x0301>(inFields[i].porog);
				}
			}
			else                    //interval
				fields[i]=new CIntTemplate<int,0x0401>(inFields[i].minVal,inFields[i].dt);

			break;
		case 1:
			if(inFields[i].cnt==0)				//not interval
			{
				if(inFields[i].Num>0)			//not trend
					fields[i]=new CBaseTemplate<double,0x0002>;
				else
				{
					if(inFields[i].porog==0)  	// just trend
						fields[i]=new CTrendTemplate<double,0x0202>;
					else                        //relative trend
						fields[i]=new CTrendTemplate1<double,0x0302>(inFields[i].porog);
				}
			}
			else                    //interval
				fields[i]=new CIntTemplate<double,0x0402>(inFields[i].minVal,inFields[i].dt);

			break;
		case 2:
			if(inFields[i].cnt==0)				//not interval
			{
				if(inFields[i].Num>0)			//not trend
					fields[i]=new CBaseTemplate<Currency,0x0003>;
				else
				{
					if(inFields[i].porog==0)  	// just trend
						fields[i]=new CTrendTemplate<Currency,0x0203>;
					else                        //relative trend
						fields[i]=new CTrendTemplate1<Currency,0x0303>(inFields[i].porog);
				}
			}
			else                    //interval
				{
					Currency a1(inFields[i].minVal);
					Currency a2(inFields[i].dt);
					fields[i]=new CIntTemplate<Currency,0x0403>(a1,a2);
				}
			break;
		case 3:
			fields[i]=new CStringField(1|VARIABLE_MASK);

			break;
		};
		fields[i]->set_fieldNum(pole[n]->num);

	}
	calculator.Init(fields, fieldsCount);
}

void CParser::Reset()
{
	calculator.Reset();
	if(fields!=NULL)
	{
		for(unsigned i=0;i<fieldsCount;i++)
		{
			if(fields[i]!=NULL)
			{
				delete fields[i];
				fields[i]=NULL;
			}
		}
		delete fields;
		fields=NULL;
	}
	fieldsCount=0;
}

void CParser::getString   (  UScan       **buffer,
						unsigned	index,
						TDataSet    *query,
						String      *st,     //result
						String      *df,     //differens
						String      *f0,	 //last value
						int         cd      // calculate differenses
						 )
{
	ReadData data;
	data.query=query;
	data.old=*f0;
	data.buffer=(char*)(*buffer);
	data.view=query->Fields->Fields[fields[index]->get_fieldNum()]->DataType;
	*st=fields[index]->readFromBuffer(&data, cd);
	*buffer=(UScan*)data.buffer;
	if(cd)*df=FloatToStr(data.diff);


}
void CParser::writeBuffer (	UScan **buffer,
							TDataSet *query
						  )
{
	for(unsigned i=0; i<fieldsCount; i++)
	{
		fields[i]->writeToBuffer(query, (char**)buffer);
	}
}


