#ifndef __FieldTypes__
#define __FieldTypes__

#include <windows.h>
#include <Vcl.h>
#include <dbtables.hpp>

class CParser;

class SPole: public TObject
{
public:
	char 	*name;
	int		num;
	int		F_Type;
	int		tr_num;
	void	*voc;
};

union UScan
{
	char    *pChar;
	int     *pInt;
	double  *pDouble;
	Currency *pCurrency;
};

struct  SFields
{
	int     Num;     //номер поля, нумеруется с 1, если <0, то тренд
//        int     Count;
	double  porog;	//порог качественного тренда
	double dt;
	double minVal;
	int cnt;
	int initialized;
	int frozen;

};

/*
CParser*   _stdcall createParser( SFields* inFields,  int inSize,
								  SFields* outFields, int outSize
								);

void    _stdcall destroyObject(CParser *id);

int     _stdcall getSize(CParser *id, int io);

void    _stdcall getString   (  CParser         *id,
								UScan           **buffer,
								unsigned        index,
								TQuery          *guery,
								String          *st,     //result
								String          *df,     //differens
								String          *f0,	 //last value
								int             cd       // czlculate differenses
							 );
void    _stdcall writeBuffer (  CParser *id,
								UScan **buffer,
								TQuery *guery
							 );*/
#endif
