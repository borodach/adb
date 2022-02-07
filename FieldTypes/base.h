#ifndef __base_h__
#define __base_h__

#include <Vcl.h>
#include <dbtables.hpp>
#include <db.hpp>
//#iclude <syscurr.h>

String convertToString(int a,int view);
String convertToString(double a,int view);
String convertToString(Currency &a,int view);

struct ReadData
{
		TDataSet *query;
        Variant old;
        char* buffer;
        //void* pmax;
        //void* pmin;
        int view;
        double diff;
};

class CBaseField
{
protected:
        unsigned      id;               //ID класса
		int           fieldNumber;      //номер поля в курсоре

public:

virtual void writeToBuffer(TDataSet *query,   char* *buffer)=0;
virtual String readFromBuffer(ReadData *data, int calcDiff)=0;
virtual int getSize(TDataSet *query)=0;
virtual void  readFromBuffer (ReadData *data, TField *field, int calcDiff);
virtual ~CBaseField();

		int get_fieldNum() {return fieldNumber;}
		int set_fieldNum(int newNumber)
		{
			  int tmp=fieldNumber;
			  fieldNumber=newNumber;
			  return tmp;
		}
		int getID() {return id;}

};

/*

TIntField = class(TBaseField)
public
  constructor Init(i:Integer);
  procedure toBuffer(query:TQuery; var buffer: PByte); override;
  function fromBufferS(old: String; var buffer: PByte):String;override;
  function getSize(query:TQuery):Integer;override;
end;
*/


//////////////////////////////////////////////////////////////////
//				Base class
//////////////////////////////////////////////////////////////////

/*  function TBaseField.getNum:Integer;
  begin
	Result:=number_of_field;
  end;
  function TBaseField.setNum(newNum:Integer):Integer;
  begin
	Result:=number_of_field;
	number_of_field:=newNum;
  end;

  procedure TBaseField.save(stream:TMystream);
  begin
	stream.Write(ID,sizeof(ID));
	stream.Write(number_of_field,sizeof(number_of_field));
  end;

  procedure TBaseField.fromBufferF(old: String; var buffer: PByte; o: TField);
  begin
	o.AsString:=fromBufferS(query,buffer);
  end;


//////////////////////////////////////////////////////////////////
//				TIntField implementation
//////////////////////////////////////////////////////////////////

  constructor TIntField.Init;
  begin
	inherited Create;
	ID:=$0001;
  end;
  function TIntField.getSize(query:TQuery):Integer;
  begin
	Result:=sizeof(Integer);
  end;

  procedure TIntField.toBuffer(query:TQuery; var buffer: PByte);
  begin
	PInteger(buffer)^:=query.Fields[number_of_field].AsInteger;
	Inc(buffer,sizeof(Integer));
  end;

  function TIntField.fromBufferS(old: String; var buffer: PByte):String;
  begin
	Result:=IntToStr(PInteger(buffer)^);
	Inc(buffer,sizeof(Integer));
  end;*/
#endif