object Form1: TForm1
  Left = 224
  Top = 114
  Width = 565
  Height = 365
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object DBGrid1: TDBGrid
    Left = 0
    Top = 0
    Width = 337
    Height = 289
    DataSource = DataSource1
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
  end
  object Button1: TButton
    Left = 360
    Top = 264
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 352
    Top = 8
    Width = 169
    Height = 233
    Lines.Strings = (
      'Memo1')
    TabOrder = 2
  end
  object Query1: TQuery
    AutoCalcFields = False
    DatabaseName = 'DBDEMOS'
    SQL.Strings = (
      'select * from animals')
    Left = 24
    Top = 8
  end
  object DataSource1: TDataSource
    DataSet = Query1
    Left = 88
    Top = 8
  end
end
