#ifndef __MYPARSER__
#define __MYPARSER__

#define VARIABLE_MASK 0x10000

#include "Calculator.h"
#include "base.h"
#include "FieldTypes.h"

class CParser
{
protected:
	CBufferSizeCalculator calculator;
	CBaseField **fields;
	unsigned   fieldsCount;

public:
	CParser()
	{
			fields=NULL;
			fieldsCount=0;
			//Init(pole, count, inFields, inSize);
	}

	~CParser()
	{
			Reset();
	}

	void Init(SPole **pole, int count, SFields *inFields, unsigned inSize);
	void Reset();

	int getSize( TDataSet *query)
	{
		return calculator.getSize( query);
	}
	void getString   (  UScan       **buffer,
						unsigned	index,
						TDataSet      *guery,
						String      *st,     //result
						String      *df,     //differens
						String      *f0,	 //last value
						int         cd       // calculate differenses
					 );
   void writeBuffer (	UScan **buffer,
						TDataSet *query
					);
   int present()
   {
		return fields!=NULL;
   }

};
#endif

