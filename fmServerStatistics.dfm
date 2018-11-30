object Form_ServerStatistics: TForm_ServerStatistics
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = #1057#1090#1072#1090#1080#1089#1090#1080#1082#1072' '#1089#1077#1088#1074#1077#1088#1072
  ClientHeight = 551
  ClientWidth = 774
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    774
    551)
  PixelsPerInch = 96
  TextHeight = 13
  object ListView_Statistics: TListView
    Left = 8
    Top = 8
    Width = 758
    Height = 504
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = #1056#1072#1076#1080#1086#1089#1090#1072#1085#1094#1080#1103
        Width = 200
      end
      item
        Caption = #1053#1072#1079#1074#1072#1085#1080#1077' '#1087#1086#1090#1086#1082#1072
        Width = 200
      end
      item
        Caption = #1054#1087#1080#1089#1072#1085#1080#1077' '#1087#1086#1090#1086#1082#1072
        Width = 200
      end
      item
        Caption = #1058#1080#1087' '#1082#1086#1085#1090#1077#1085#1090#1072
        Width = 100
      end
      item
        Caption = #1053#1072#1095#1072#1083#1086' '#1090#1088#1072#1085#1089#1083#1103#1094#1080#1080
        Width = 150
      end
      item
        Caption = #1050#1072#1085#1072#1083#1099
        Width = 60
      end
      item
        Caption = #1041#1080#1090#1088#1077#1081#1090
        Width = 60
      end
      item
        Caption = #1063#1072#1089#1090#1086#1090#1072' '#1076#1080#1089#1082#1088#1077#1090#1080#1079#1072#1094#1080#1080
      end
      item
        Alignment = taRightJustify
        Caption = #1057#1083#1091#1096#1072#1090#1077#1083#1080' ('#1089#1077#1081#1095#1072#1089')'
        Width = 60
      end
      item
        Alignment = taRightJustify
        Caption = #1057#1083#1091#1096#1072#1090#1077#1083#1080' ('#1084#1072#1082#1089'.)'
        Width = 60
      end
      item
        Caption = #1046#1072#1085#1088
        Width = 150
      end
      item
        Caption = 'URL '#1087#1086#1090#1086#1082#1072
        Width = 200
      end
      item
        Caption = #1057#1077#1081#1095#1072#1089' '#1080#1075#1088#1072#1077#1090
        Width = 200
      end>
    OwnerData = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnColumnClick = ListView_StatisticsColumnClick
    OnData = ListView_StatisticsData
    ExplicitWidth = 761
    ExplicitHeight = 482
  end
  object Button_Close: TButton
    Left = 691
    Top = 518
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1047#1072#1082#1088#1099#1090#1100
    TabOrder = 1
    OnClick = Button_CloseClick
    ExplicitLeft = 694
    ExplicitTop = 496
  end
  object Button_Refresh: TButton
    Left = 610
    Top = 518
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1054#1073#1085#1086#1074#1080#1090#1100
    TabOrder = 2
    OnClick = Button_RefreshClick
    ExplicitLeft = 613
    ExplicitTop = 496
  end
end
