VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Begin VB.UserControl ucFilterList 
   ClientHeight    =   6315
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   7605
   ScaleHeight     =   6315
   ScaleWidth      =   7605
   Begin VB.TextBox txtFilter 
      Height          =   330
      Left            =   495
      TabIndex        =   3
      Top             =   4320
      Width           =   1995
   End
   Begin MSComctlLib.ListView lvFilter 
      Height          =   3300
      Left            =   360
      TabIndex        =   1
      Top             =   360
      Width           =   5775
      _ExtentX        =   10186
      _ExtentY        =   5821
      View            =   3
      LabelEdit       =   1
      LabelWrap       =   -1  'True
      HideSelection   =   0   'False
      FullRowSelect   =   -1  'True
      GridLines       =   -1  'True
      _Version        =   393217
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   0
   End
   Begin MSComctlLib.ListView lv 
      Height          =   4155
      Left            =   45
      TabIndex        =   0
      Top             =   90
      Width           =   7170
      _ExtentX        =   12647
      _ExtentY        =   7329
      View            =   3
      LabelEdit       =   1
      LabelWrap       =   -1  'True
      HideSelection   =   0   'False
      FullRowSelect   =   -1  'True
      GridLines       =   -1  'True
      _Version        =   393217
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   0
   End
   Begin VB.Label Label1 
      Caption         =   "Filter"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   -1  'True
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   45
      TabIndex        =   2
      Top             =   4320
      Width           =   420
   End
   Begin VB.Menu mnuTools 
      Caption         =   "mnuTools"
      Begin VB.Menu mnuCopyAll 
         Caption         =   "Copy All"
      End
      Begin VB.Menu mnuCopySel 
         Caption         =   "Copy Sel"
      End
      Begin VB.Menu mnuCopyColumn 
         Caption         =   "Copy Column"
      End
      Begin VB.Menu mnuSetFilterCol 
         Caption         =   "Set Filter Column"
      End
      Begin VB.Menu mnuToggleMulti 
         Caption         =   "MultiSelect"
      End
      Begin VB.Menu mnuHideSel 
         Caption         =   "Hide Selection"
      End
      Begin VB.Menu mnuAlertColWidths 
         Caption         =   "Alert Column Widths (IDE Only)"
      End
   End
End
Attribute VB_Name = "ucFilterList"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'author:  David Zimmer <dzzie@yahoo.com>
'site:    http://sandsprite.com
'License: free for any use

Public FilterColumn As Long

Event Click()
Event ColumnClick(ByVal ColumnHeader As MSComctlLib.ColumnHeader)
Event DblClick()
Event ItemClick(ByVal Item As MSComctlLib.ListItem)
Event MouseUp(Button As Integer, Shift As Integer, x As Single, y As Single)

#If 0 Then
    Dim x, y 'force lowercase so ide doesnt switch around on its own whim...
#End If

Property Get ListItems() As ListItems
    Set ListItems = lv.ListItems
End Property

Property Let MultiSelect(x As Boolean)
    lv.MultiSelect = x
    lvFilter.MultiSelect = x
    mnuToggleMulti.Checked = x
End Property

Property Let HideSelection(x As Boolean)
    lv.HideSelection = x
    lvFilter.HideSelection = x
    mnuHideSel.Checked = x
End Property

Property Get lstView() As ListView
    On Error Resume Next
    If lvFilter.Visible Then
        Set lstView = lvFilter
    Else
        Set lstView = lv
    End If
End Property

Property Get selItem() As ListItem
    On Error Resume Next
    If lvFilter.Visible Then
        Set selItem = lvFilter.SelectedItem
    Else
        Set selItem = lv.SelectedItem
    End If
End Property

Property Get Filter() As String
    Filter = txtFilter
End Property

Property Let Filter(txt As String)
     txtFilter = txt
End Property

Function AddItem(txt, ParamArray subItems()) As ListItem
    On Error Resume Next
    
    Dim i As Integer
    
    Set AddItem = lv.ListItems.Add(, , txt)
    
    For Each si In subItems
        AddItem.subItems(i + 1) = si
        i = i + 1
    Next
    
    txtFilter_Change
    
End Function

Sub Clear()
    lv.ListItems.Clear
    lvFilter.ListItems.Clear
End Sub

Sub SetColumnHeaders(csvList As String, Optional csvWidths As String)
    
    On Error Resume Next
    
    lv.ColumnHeaders.Clear
    lvFilter.ColumnHeaders.Clear
    
    tmp = Split(csvList, ",")
    For Each t In tmp
        lv.ColumnHeaders.Add , , Trim(t)
        lvFilter.ColumnHeaders.Add , , Trim(t)
    Next
    
    If Len(csvWidths) > 0 Then
        tmp = Split(csvWidths, ",")
        For i = 0 To UBound(tmp)
            If Len(tmp(i)) > 0 Then
                lv.ColumnHeaders(i + 1).Width = CLng(tmp(i))
                lvFilter.ColumnHeaders(i + 1).Width = CLng(tmp(i))
            End If
        Next
    End If
    
End Sub

Private Sub Label1_Click()
    PopupMenu mnuTools
End Sub

Private Sub mnuAlertColWidths_Click()
    Dim tmp(), c As ColumnHeader
    For Each c In lv.ColumnHeaders
        push tmp, Round(c.Width)
    Next
    InputBox "Column Widths are: ", , Join(tmp, ",")
End Sub

Private Sub mnuCopyAll_Click()
    Clipboard.Clear
    Clipboard.SetText Me.GetAllElements()
End Sub

Private Sub mnuCopyColumn_Click()
    On Error Resume Next
    Dim x As Long
    x = InputBox("Enter column index to copy", , 0)
    If Len(x) = 0 Then Exit Sub
    x = CLng(x) - 1 'we are 0 based internally..
    Clipboard.Clear
    Clipboard.SetText Me.GetAllText(x)
End Sub

Private Sub mnuCopySel_Click()
    Clipboard.Clear
    Clipboard.SetText Me.GetAllElements(True)
End Sub

Private Sub mnuHideSel_Click()
    Me.HideSelection = Not lv.HideSelection
End Sub

Private Sub mnuSetFilterCol_Click()
    On Error Resume Next
    Dim x As Long
    x = InputBox("Enter column that filter searches", , FilterColumn + 1)
    If Len(x) = 0 Then Exit Sub
    x = CLng(x) - 1 'we are 0 based internally..
    FilterColumn = x
End Sub

Private Sub mnuToggleMulti_Click()
    Me.MultiSelect = Not lv.MultiSelect
End Sub

Private Sub txtFilter_Change()

    Dim li As ListItem
    Dim t As String
    
    On Error Resume Next
    
    If Len(txtFilter) = 0 Then
        lvFilter.Visible = False
        Exit Sub
    End If
    
    lvFilter.Visible = True
    lvFilter.ListItems.Clear
    
    For Each li In lv.ListItems
        If FilterColumn = 0 Then
            t = li.Text
        Else
            If FilterColumn >= lv.ColumnHeaders.count Then FilterColumn = lv.ColumnHeaders.count - 1
            t = li.subItems(FilterColumn)
        End If
        If InStr(1, t, txtFilter, vbTextCompare) > 0 Then
            CloneListItemTo li, lvFilter
        End If
    Next
    
    
End Sub

Sub CloneListItemTo(li As ListItem, lv As ListView)
    Dim li2 As ListItem, i As Integer
    Set li2 = lv.ListItems.Add(, , li.Text)
    For i = 1 To lv.ColumnHeaders.count - 1
        li2.subItems(i) = li.subItems(i)
    Next
    If li.ForeColor <> vbBlack Then SetLiColor li2, li.ForeColor
    
    On Error Resume Next
    If IsObject(li.Tag) Then
        Set li2.Tag = li.Tag
    Else
        li2.Tag = li.Tag
    End If
    
End Sub


Private Sub lv_Click()
    RaiseEvent Click
End Sub

Private Sub lv_ColumnClick(ByVal ColumnHeader As MSComctlLib.ColumnHeader)
    RaiseEvent ColumnClick(ColumnHeader)
End Sub

Private Sub lv_DblClick()
    RaiseEvent DblClick
End Sub

Private Sub lv_ItemClick(ByVal Item As MSComctlLib.ListItem)
    RaiseEvent ItemClick(Item)
End Sub

Private Sub lv_MouseUp(Button As Integer, Shift As Integer, x As Single, y As Single)
    RaiseEvent MouseUp(Button, Shift, x, y)
End Sub

Private Sub lvFilter_Click()
    RaiseEvent Click
End Sub

Private Sub lvFilter_ColumnClick(ByVal ColumnHeader As MSComctlLib.ColumnHeader)
    RaiseEvent ColumnClick(ColumnHeader)
End Sub

Private Sub lvFilter_DblClick()
    RaiseEvent DblClick
End Sub

Private Sub lvFilter_ItemClick(ByVal Item As MSComctlLib.ListItem)
    RaiseEvent ItemClick(Item)
End Sub

Private Sub lvFilter_MouseUp(Button As Integer, Shift As Integer, x As Single, y As Single)
    RaiseEvent MouseUp(Button, Shift, x, y)
End Sub

Private Sub UserControl_Initialize()
    mnuAlertColWidths.Visible = isIde()
End Sub

Private Sub UserControl_Resize()
    On Error Resume Next
    With UserControl
        lv.top = 0
        lv.Left = 0
        lv.Width = .Width
        lv.Height = .Height - txtFilter.Height - 300
        txtFilter.top = .Height - txtFilter.Height - 150
        txtFilter.Width = .Width - txtFilter.Left '- lblTools.Width - 100
        'lblTools.Left = .Width - lblTools.Width
        Label1.top = txtFilter.top + 30
        'lblTools.Top = txtFilter.Top + 30
    End With
    lvFilter.Move lv.Left, lv.top, lv.Width, lv.Height
    lv.ColumnHeaders(lv.ColumnHeaders.count).Width = lv.Width - lv.ColumnHeaders(lv.ColumnHeaders.count).Left - 200
    lvFilter.ColumnHeaders(lvFilter.ColumnHeaders.count).Width = lv.ColumnHeaders(lv.ColumnHeaders.count).Width
End Sub


Public Sub SetLiColor(li As ListItem, newcolor As Long)
    Dim f As ListSubItem
'    On Error Resume Next
    li.ForeColor = newcolor
    For Each f In li.ListSubItems
        f.ForeColor = newcolor
    Next
End Sub

Public Sub ColumnSort(Column As ColumnHeader)
    Dim ListViewControl As ListView
    On Error Resume Next
    
    Set ListViewControl = lv
    If lvFilter.Visible Then Set ListViewControl = lvFilter
        
    With ListViewControl
       If .SortKey <> Column.index - 1 Then
             .SortKey = Column.index - 1
             .SortOrder = lvwAscending
       Else
             If .SortOrder = lvwAscending Then
              .SortOrder = lvwDescending
             Else
              .SortOrder = lvwAscending
             End If
       End If
       .Sorted = -1
    End With
    
End Sub

Public Function GetAllElements(Optional selectedOnly As Boolean = False) As String
    Dim ret() As String, i As Integer, tmp As String
    Dim li As ListItem
    Dim ListViewControl As ListView
    Dim include  As Boolean
    
    On Error Resume Next
    
    Set ListViewControl = lv
    If lvFilter.Visible Then Set ListViewControl = lvFilter
        
    For i = 1 To ListViewControl.ColumnHeaders.count
        tmp = tmp & ListViewControl.ColumnHeaders(i).Text & vbTab
    Next

    push ret, tmp
    push ret, String(50, "-")

    For Each li In ListViewControl.ListItems
    
        If selectedOnly Then
            If Not li.Selected Then GoTo nextone
        End If
            
        tmp = li.Text & vbTab
        For i = 1 To ListViewControl.ColumnHeaders.count - 1
            tmp = tmp & li.subItems(i) & vbTab
        Next
        push ret, tmp
        
nextone:
    Next

    GetAllElements = Join(ret, vbCrLf)

End Function

Function GetAllText(Optional subItemRow As Long = 0, Optional selectedOnly As Boolean = False) As String
    Dim i As Long
    Dim tmp() As String, x As String
    Dim ListViewControl As ListView
    
    On Error Resume Next
    
    Set ListViewControl = lv
    If lvFilter.Visible Then Set ListViewControl = lvFilter
    
    For i = 1 To ListViewControl.ListItems.count
        If subItemRow = 0 Then
            x = ListViewControl.ListItems(i).Text
            If selectedOnly And Not ListViewControl.ListItems(i).Selected Then x = Empty
            If Len(x) > 0 Then
                push tmp, x
            End If
        Else
            x = ListViewControl.ListItems(i).subItems(subItemRow)
            If selectedOnly And Not ListViewControl.ListItems(i).Selected Then x = Empty
            If Len(x) > 0 Then
                push tmp, x
            End If
        End If
    Next
    
    GetAllText = Join(tmp, vbCrLf)
End Function

Private Sub push(ary, value) 'this modifies parent ary object
    On Error GoTo init
    Dim x As Integer
    x = UBound(ary) '<-throws Error If Not initalized
    ReDim Preserve ary(UBound(ary) + 1)
    ary(UBound(ary)) = value
    Exit Sub
init:     ReDim ary(0): ary(0) = value
End Sub















