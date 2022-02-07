#ifndef __CALC__
#define __CALC__

#include "base.h"
#include "FieldTypes.h"

class CBufferSizeCalculator
{
protected:
        unsigned        fixedSize;
		CBaseField      **varFields;
		unsigned        varFieldsCount;
public:
	void Reset();
	void Init (	CBaseField	**fields,
				unsigned    fieldsCount
			  );
	unsigned getSize(TDataSet *query);

	CBufferSizeCalculator()
	{
		varFields=NULL;
		fixedSize=0;
		varFieldsCount=0;

	}

	~CBufferSizeCalculator()
	{
		Reset( );
	}
};

#endif
