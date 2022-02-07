
#include "Calculator.h"
#define VARIABLE_MASK 0x10000

		unsigned        fixedSize;
		CBaseField      **varFields;
		unsigned        varFieldsCount;

/////////////////////////////////////////////////////////////////////////////////
//                                                                             //
//                           Reset()                                           //
//                                                                             //
//                                                                             //
/////////////////////////////////////////////////////////////////////////////////

void CBufferSizeCalculator::Reset()
{
		if(varFields!=NULL)
		{
			delete [] varFields;
			varFields=NULL;
		};
		varFieldsCount=fixedSize=0;
}

/////////////////////////////////////////////////////////////////////////////////
//                                                                             //
//                           Init                                              //
//                                                                             //
//                                                                             //
/////////////////////////////////////////////////////////////////////////////////

void CBufferSizeCalculator::Init(	CBaseField	**fields,
									unsigned	fieldsCount
								)
{
	unsigned i;
	Reset();
	if(fieldsCount==0) return;
	for(i=0; i<fieldsCount; i++)
	{
		if(fields[i]->getID()&VARIABLE_MASK)
		{
			varFieldsCount++;
		}
		else fixedSize+=fields[i]->getSize(NULL);
	}
	
	if(varFieldsCount==0) return;

	varFields = new CBaseField* [varFieldsCount];

	int j=0;

	for(i=0; i<fieldsCount; i++, fields++)
	{

		if((*fields)->getID()&VARIABLE_MASK)
		{
			varFields[j++]=*fields;
		}
	}

}

/////////////////////////////////////////////////////////////////////////////////
//                                                                             //
//                           getSize                                           //
//                                                                             //
//                                                                             //
/////////////////////////////////////////////////////////////////////////////////

unsigned CBufferSizeCalculator::getSize(TDataSet *query)
{
	if(varFields==NULL) return fixedSize;

	unsigned size=fixedSize;

	for(unsigned i=0; i<varFieldsCount; i++) size+=varFields[i]->getSize(query);

	return size;
}


