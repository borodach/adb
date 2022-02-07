#ifndef __StringField__
#define __StringField__
#include "base.h"

class CStringField: public CBaseField
{
public:
	CStringField(int ID) {id=ID;}
virtual ~CStringField();
virtual void writeToBuffer(TDataSet *query,   char** buffer);
virtual String readFromBuffer(ReadData *data, int calcDiff);
virtual int getSize(TDataSet *query);
};
#endif