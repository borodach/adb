object SQLWizard: TSQLWizard
  Left = 271
  Top = 143
  BorderStyle = bsDialog
  Caption = '������ SQL-��������.'
  ClientHeight = 282
  ClientWidth = 475
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 4
    Top = 0
    Width = 237
    Height = 185
    Caption = '���� ������:'
    TabOrder = 0
    object FieldList: TListBox
      Left = 8
      Top = 14
      Width = 221
      Height = 165
      ItemHeight = 13
      MultiSelect = True
      TabOrder = 0
      OnClick = FieldListClick
    end
  end
  object GroupBox2: TGroupBox
    Left = 4
    Top = 178
    Width = 237
    Height = 67
    Caption = '��������� ����������:'
    TabOrder = 1
    object SortField: TComboBox
      Left = 8
      Top = 16
      Width = 221
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
      OnClick = FieldListClick
    end
    object Asc: TRadioButton
      Left = 5
      Top = 43
      Width = 116
      Height = 17
      Caption = '�� �����������.'
      Checked = True
      TabOrder = 1
      TabStop = True
      OnClick = FieldListClick
    end
    object Desc: TRadioButton
      Left = 125
      Top = 43
      Width = 100
      Height = 17
      Caption = '�� ��������.'
      TabOrder = 2
      OnClick = FieldListClick
    end
  end
  object Button1: TButton
    Left = 96
    Top = 255
    Width = 75
    Height = 22
    Caption = '������'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 304
    Top = 255
    Width = 75
    Height = 22
    Caption = '������'
    TabOrder = 3
    OnClick = Button2Click
  end
  object GroupBox3: TGroupBox
    Left = 239
    Top = 0
    Width = 232
    Height = 245
    Caption = '������:'
    TabOrder = 4
    object Query: TRichEdit
      Left = 8
      Top = 14
      Width = 217
      Height = 224
      ReadOnly = True
      TabOrder = 0
    end
  end
  object DB: TDatabase
    SessionName = 'Default'
    Left = 455
  end
end
