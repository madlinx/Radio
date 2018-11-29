object Form_StationStatistics: TForm_StationStatistics
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1057#1074#1086#1081#1089#1090#1074#1072
  ClientHeight = 351
  ClientWidth = 505
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Label_StreamName: TLabel
    Left = 24
    Top = 19
    Width = 91
    Height = 13
    Caption = #1053#1072#1079#1074#1072#1085#1080#1077' '#1087#1086#1090#1086#1082#1072':'
  end
  object Label_StreamDescription: TLabel
    Left = 24
    Top = 46
    Width = 92
    Height = 13
    Caption = #1054#1087#1080#1089#1072#1085#1080#1077' '#1087#1086#1090#1086#1082#1072':'
  end
  object Label_ContentType: TLabel
    Left = 24
    Top = 73
    Width = 73
    Height = 13
    Caption = #1058#1080#1087' '#1082#1086#1085#1090#1077#1085#1090#1072':'
  end
  object Label_StreamStarted: TLabel
    Left = 24
    Top = 100
    Width = 106
    Height = 13
    Caption = #1053#1072#1095#1072#1083#1086'  '#1090#1088#1072#1085#1089#1083#1103#1094#1080#1080':'
  end
  object Label_Bitrate: TLabel
    Left = 24
    Top = 154
    Width = 46
    Height = 13
    Caption = #1041#1080#1090#1088#1077#1081#1090':'
  end
  object Label_Listeners: TLabel
    Left = 24
    Top = 181
    Width = 106
    Height = 13
    Caption = #1057#1083#1091#1096#1072#1090#1077#1083#1080' ('#1089#1077#1081#1095#1072#1089'):'
  end
  object Label_Genre: TLabel
    Left = 24
    Top = 235
    Width = 32
    Height = 13
    Caption = #1046#1072#1085#1088':'
  end
  object Label_StreamURL: TLabel
    Left = 24
    Top = 262
    Width = 62
    Height = 13
    Caption = 'URL '#1087#1086#1090#1086#1082#1072':'
  end
  object Label_CurrentlyPlaying: TLabel
    Left = 24
    Top = 289
    Width = 78
    Height = 13
    Caption = #1057#1077#1081#1095#1072#1089' '#1080#1075#1088#1072#1077#1090':'
  end
  object Label_Channels: TLabel
    Left = 24
    Top = 127
    Width = 43
    Height = 13
    Caption = #1050#1072#1085#1072#1083#1099':'
  end
  object Label_ListenersPeak: TLabel
    Left = 24
    Top = 208
    Width = 99
    Height = 13
    Caption = #1057#1083#1091#1096#1072#1090#1077#1083#1080' ('#1084#1072#1082#1089'.):'
  end
  object Button_Close: TButton
    Left = 422
    Top = 318
    Width = 75
    Height = 25
    Caption = #1047#1072#1082#1088#1099#1090#1100
    TabOrder = 0
    OnClick = Button_CloseClick
  end
  object Edit_StreamName: TEdit
    Left = 144
    Top = 16
    Width = 337
    Height = 21
    ParentColor = True
    ReadOnly = True
    TabOrder = 1
    Text = 'Edit_StreamName'
  end
  object Edit_StreamDescription: TEdit
    Left = 144
    Top = 43
    Width = 337
    Height = 21
    ParentColor = True
    ReadOnly = True
    TabOrder = 2
    Text = 'Edit_StreamDescription'
  end
  object Edit_ContentType: TEdit
    Left = 144
    Top = 70
    Width = 337
    Height = 21
    ParentColor = True
    ReadOnly = True
    TabOrder = 3
    Text = 'Edit_ContentType'
  end
  object Edit_StreamStarted: TEdit
    Left = 144
    Top = 97
    Width = 337
    Height = 21
    ParentColor = True
    ReadOnly = True
    TabOrder = 4
    Text = 'Edit_StreamStarted'
  end
  object Edit_Channels: TEdit
    Left = 144
    Top = 124
    Width = 337
    Height = 21
    ParentColor = True
    ReadOnly = True
    TabOrder = 5
    Text = 'Edit_Channels'
  end
  object Edit_Bitrate: TEdit
    Left = 144
    Top = 151
    Width = 337
    Height = 21
    ParentColor = True
    ReadOnly = True
    TabOrder = 6
    Text = 'Edit_Bitrate'
  end
  object Edit_Listeners: TEdit
    Left = 144
    Top = 178
    Width = 337
    Height = 21
    ParentColor = True
    ReadOnly = True
    TabOrder = 7
    Text = 'Edit_Listeners'
  end
  object Edit_ListenersPeak: TEdit
    Left = 144
    Top = 205
    Width = 337
    Height = 21
    ParentColor = True
    ReadOnly = True
    TabOrder = 8
    Text = 'Edit_ListenersPeak'
  end
  object Edit_Genre: TEdit
    Left = 144
    Top = 232
    Width = 337
    Height = 21
    ParentColor = True
    ReadOnly = True
    TabOrder = 9
    Text = 'Edit_Genre'
  end
  object Edit_StreamURL: TEdit
    Left = 144
    Top = 259
    Width = 337
    Height = 21
    ParentColor = True
    ReadOnly = True
    TabOrder = 10
    Text = 'Edit_StreamURL'
  end
  object Edit_CurrentlyPlaying: TEdit
    Left = 144
    Top = 286
    Width = 337
    Height = 21
    ParentColor = True
    ReadOnly = True
    TabOrder = 11
    Text = 'Edit_CurrentlyPlaying'
  end
  object Button1: TButton
    Left = 341
    Top = 318
    Width = 75
    Height = 25
    Caption = #1054#1073#1085#1086#1074#1080#1090#1100
    TabOrder = 12
    OnClick = Button1Click
  end
end
