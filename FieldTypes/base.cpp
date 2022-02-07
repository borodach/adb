#include "base.h"
#include "TrendTemplate.hpp"
#include "BaseTemplate.hpp"

void  CBaseField::readFromBuffer (ReadData *data, TField *field, int calcDiff)
{
        field->AsString=readFromBuffer(data, calcDiff);
}
CBaseField::~CBaseField()
{
}


String convertToString(int a,int view)
{
        return IntToStr(a);
}

String convertToString(double a,int view)
{
        switch(view)
        {
                case ftFloat: return FloatToStr(a);
                case ftDate: return DateToStr(a);
                case ftTime: return TimeToStr(a);
                case ftDateTime: return DateTimeToStr(a);
        }
        return "";

}
String convertToString(Currency &a,int view)
{
        return CurrToStr(a);
}