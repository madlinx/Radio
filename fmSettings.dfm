object Form2: TForm2
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099
  ClientHeight = 352
  ClientWidth = 513
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  DesignSize = (
    513
    352)
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 430
    Top = 320
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 349
    Top = 320
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 268
    Top = 320
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1054#1050
    TabOrder = 3
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 8
    Top = 320
    Width = 92
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1055#1086' '#1091#1084#1086#1083#1095#1072#1085#1080#1102
    TabOrder = 4
    OnClick = Button4Click
  end
  object PageControl_Settings: TPageControl
    Left = 8
    Top = 8
    Width = 497
    Height = 305
    ActivePage = TabSheet_General
    TabOrder = 0
    object TabSheet_General: TTabSheet
      Caption = #1054#1073#1097#1080#1077
      DesignSize = (
        489
        277)
      object CheckBox_Autoplay: TCheckBox
        Left = 24
        Top = 39
        Width = 441
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = #1040#1074#1090#1086#1074#1086#1089#1087#1088#1086#1080#1079#1074#1077#1076#1077#1085#1080#1077' '#1087#1088#1080' '#1079#1072#1087#1091#1089#1082#1077
        TabOrder = 1
      end
      object CheckBox_Autorun: TCheckBox
        Left = 24
        Top = 16
        Width = 441
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = #1047#1072#1087#1091#1089#1082#1072#1090#1100' '#1072#1074#1090#1086#1084#1072#1090#1080#1095#1077#1089#1082#1080' '#1087#1088#1080' '#1074#1093#1086#1076#1077' '#1074' '#1089#1080#1089#1090#1077#1084#1091
        TabOrder = 0
      end
    end
    object TabSheet_Playback: TTabSheet
      Caption = #1042#1086#1089#1087#1088#1086#1080#1079#1074#1077#1076#1077#1085#1080#1077
      ImageIndex = 1
      DesignSize = (
        489
        277)
      object Label1: TLabel
        Left = 24
        Top = 19
        Width = 105
        Height = 13
        Caption = #1059#1089#1090#1088#1086#1081#1089#1090#1074#1086' '#1074#1099#1074#1086#1076#1072':'
      end
      object Label2: TLabel
        Left = 24
        Top = 73
        Width = 88
        Height = 13
        Caption = #1042#1088#1077#1084#1103' '#1086#1078#1080#1076#1072#1085#1080#1103':'
      end
      object Label4: TLabel
        Left = 210
        Top = 73
        Width = 5
        Height = 13
        Caption = #1089
      end
      object Label3: TLabel
        Left = 24
        Top = 46
        Width = 80
        Height = 13
        Caption = #1056#1072#1079#1084#1077#1088' '#1073#1091#1092#1077#1088#1072':'
      end
      object Label5: TLabel
        Left = 210
        Top = 46
        Width = 11
        Height = 13
        Caption = #1084#1089
      end
      object ComboBox_Device: TComboBox
        Left = 136
        Top = 16
        Width = 329
        Height = 21
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        Enabled = False
        TabOrder = 0
      end
      object Edit_Timeout: TEdit
        Left = 136
        Top = 70
        Width = 52
        Height = 21
        Alignment = taCenter
        AutoSelect = False
        Enabled = False
        TabOrder = 3
        Text = '5'
        OnChange = Edit_TimeoutChange
      end
      object UpDown_Timeout: TUpDown
        Left = 188
        Top = 70
        Width = 16
        Height = 21
        Associate = Edit_Timeout
        Enabled = False
        Min = 1
        Max = 60
        Position = 5
        TabOrder = 4
      end
      object Edit_BufferSize: TEdit
        Left = 136
        Top = 43
        Width = 52
        Height = 21
        Alignment = taCenter
        AutoSelect = False
        Enabled = False
        TabOrder = 1
        Text = '500'
        OnChange = Edit_BufferSizeChange
      end
      object UpDown_BufferSize: TUpDown
        Left = 188
        Top = 43
        Width = 16
        Height = 21
        Associate = Edit_BufferSize
        Enabled = False
        Min = 10
        Max = 5000
        Position = 500
        TabOrder = 2
      end
    end
    object TabSheet_View: TTabSheet
      Caption = #1042#1080#1076
      ImageIndex = 2
      DesignSize = (
        489
        277)
      object Label_Font: TLabel
        Left = 24
        Top = 46
        Width = 85
        Height = 13
        Caption = #1064#1088#1080#1092#1090' '#1076#1080#1089#1087#1083#1077#1103':'
      end
      object Label6: TLabel
        Left = 24
        Top = 19
        Width = 75
        Height = 13
        Caption = #1062#1074#1077#1090' '#1076#1080#1089#1087#1083#1077#1103':'
      end
      object Button10: TButton
        Left = 178
        Top = 15
        Width = 24
        Height = 23
        Hint = #1042#1099#1073#1088#1072#1090#1100' '#1094#1074#1077#1090
        Caption = '...'
        DoubleBuffered = True
        ParentDoubleBuffered = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnClick = Button10Click
      end
      object CheckBox_ScrollStreamTitle: TCheckBox
        Left = 24
        Top = 103
        Width = 441
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = #1055#1088#1086#1082#1088#1091#1090#1082#1072' '#1080#1085#1092#1086#1088#1084#1072#1094#1080#1080' '#1088#1072#1076#1080#1086#1087#1086#1090#1086#1082#1072
        TabOrder = 4
      end
      object CheckBox_ScrollStationName: TCheckBox
        Left = 24
        Top = 80
        Width = 441
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = #1055#1088#1086#1082#1088#1091#1090#1082#1072' '#1085#1072#1079#1074#1072#1085#1080#1103' '#1088#1072#1076#1080#1086#1089#1090#1072#1085#1094#1080#1080
        TabOrder = 3
      end
      object ComboBox_Font: TComboBox
        Left = 120
        Top = 43
        Width = 345
        Height = 21
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 2
        Items.Strings = (
          'a_LCDNova'
          'Tahoma')
      end
      object ColorPanel: TPanel
        Left = 120
        Top = 16
        Width = 52
        Height = 21
        BevelKind = bkFlat
        BevelOuter = bvNone
        Color = 33023
        ParentBackground = False
        TabOrder = 0
        StyleElements = [seFont, seBorder]
      end
    end
  end
end
