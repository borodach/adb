object ProjectCreationForm: TProjectCreationForm
  Left = 129
  Top = 73
  Width = 560
  Height = 420
  Caption = 'Создание проекта.'
  Color = clBtnFace
  Constraints.MinHeight = 420
  Constraints.MinWidth = 560
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object Top: TGroupBox
    Left = 0
    Top = 0
    Width = 552
    Height = 81
    Align = alTop
    Caption = 'Описание проекта:'
    TabOrder = 1
    object ProjectDescription: TRichEdit
      Left = 2
      Top = 15
      Width = 548
      Height = 64
      Align = alClient
      BorderStyle = bsNone
      HideScrollBars = False
      ScrollBars = ssBoth
      TabOrder = 0
    end
  end
  object BottomPanel: TPanel
    Left = 0
    Top = 360
    Width = 552
    Height = 33
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    OnResize = BottomPanelResize
    object DosWinButton: TButton
      Left = 65
      Top = 5
      Width = 61
      Height = 20
      Caption = 'Dos<->Win'
      TabOrder = 0
      OnClick = DosWinButtonClick
    end
    object OKButton: TButton
      Left = 166
      Top = 5
      Width = 61
      Height = 20
      Caption = 'OK'
      Enabled = False
      TabOrder = 1
      OnClick = OKButtonClick
    end
    object CancelButton: TButton
      Left = 299
      Top = 5
      Width = 61
      Height = 20
      Caption = 'Отмена'
      TabOrder = 2
      OnClick = CancelButtonClick
    end
  end
  object CenterPanel: TPanel
    Left = 0
    Top = 81
    Width = 552
    Height = 279
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object CenterRight: TGroupBox
      Left = 263
      Top = 0
      Width = 289
      Height = 279
      Align = alClient
      Caption = 'Результат запроса:'
      TabOrder = 0
      object SQLResultGrid: TDBGrid
        Left = 2
        Top = 15
        Width = 285
        Height = 262
        TabStop = False
        Align = alClient
        BorderStyle = bsNone
        DataSource = DataSource1
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
        ReadOnly = True
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'MS Sans Serif'
        TitleFont.Style = []
      end
    end
    object CenterLeftPanel: TPanel
      Left = 0
      Top = 0
      Width = 263
      Height = 279
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 1
      object GroupBox2: TGroupBox
        Left = 0
        Top = 0
        Width = 263
        Height = 81
        Align = alTop
        Caption = 'База данных.'
        TabOrder = 0
        object AliasName: TComboBox
          Left = 85
          Top = 22
          Width = 163
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 0
          OnChange = AliasNameChange
        end
        object RadioButton1: TRadioButton
          Left = 12
          Top = 25
          Width = 54
          Height = 14
          Caption = 'Алиас:'
          Checked = True
          TabOrder = 1
          TabStop = True
          OnClick = RadioButton1Click
        end
        object RadioButton2: TRadioButton
          Left = 12
          Top = 53
          Width = 67
          Height = 14
          Caption = 'Папка:'
          TabOrder = 2
          OnClick = RadioButton2Click
        end
        object DirName: TDirectoryEdit
          Left = 85
          Top = 50
          Width = 163
          Height = 18
          DialogKind = dkWin32
          Enabled = False
          NumGlyphs = 1
          ButtonWidth = 17
          TabOrder = 3
          Text = 'DirName'
          OnChange = DirNameChange
        end
      end
      object Panel3: TPanel
        Left = 0
        Top = 238
        Width = 263
        Height = 41
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 1
        object CheckQuery: TButton
          Left = 136
          Top = 15
          Width = 118
          Height = 22
          Caption = 'Проверить запрос'
          TabOrder = 0
          OnClick = CheckQueryClick
        end
        object SQLWizard: TButton
          Left = 9
          Top = 15
          Width = 118
          Height = 22
          Caption = 'Мастер SQL-запрсов'
          TabOrder = 1
          OnClick = SQLWizardClick
        end
      end
      object GroupBox3: TGroupBox
        Left = 0
        Top = 81
        Width = 263
        Height = 157
        Align = alClient
        Caption = 'SQL запрос'
        TabOrder = 2
        object SQLQueryText: TRichEdit
          Left = 2
          Top = 15
          Width = 259
          Height = 140
          Align = alClient
          BorderStyle = bsNone
          HideScrollBars = False
          ScrollBars = ssBoth
          TabOrder = 0
        end
      end
    end
  end
  object DataSource1: TDataSource
    Left = 416
    Top = 8
  end
end
