VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "SqlCommand"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Option Explicit
'
' SqlCommand
' ==========

' Copywrite (C) 2014 Philip Wales
' This file (SqlCommand.cls) is distributed under the GPL-3.0 license
' Obtain a copy of the GPL-3.0 license <http://opensource.org/licenses/GPL-3.0>
'
' Wrapper for `ADODB.Command`.  It is only created by a SqlConnection. I don't
' know if it does anything more useful than `ADODB.Command` other than return
' an SqlResult, which will be more interesting.
'
Implements Applicable
Implements Showable
'
' Private Members
' ---------------
Private pCommand As ADODB.Command
'
' Constructor
' -----------
Public Function Make(ByVal adoCommand As ADODB.Command) As SqlCommand

    Dim result As New SqlCommand
    Set result.Command = adoCommand
    Set Make = result

End Function
Friend Property Set Command(ByVal adoCommand As ADODB.Command)

    Set pCommand = adoCommand
    
End Property
'
' Interfaces
' ----------
'
' ### Applicable
'
' SQLCommands can return two values: a RecordSet if the command is a query (
' which is only a SELECT command) or the number of rows affected if the command
' is an update command (which is an INSERT, UPDATE, or DELETE command.)
'
Public Function ADOExecuteQueryOnArray(ByRef args() As Variant) As ADODB.RecordSet

    ResetArgs args
    Set ADOExecuteQueryOnArray = pCommand.Execute()

End Function
Public Function ADOExecuteQuery(ParamArray args() As Variant) As ADODB.RecordSet

    Set ADOExecuteQuery = ADOExecuteQueryOnArray(CArray(args))

End Function
Public Function ExecuteQuery(ParamArray args() As Variant) As SqlResult

    Set ExecuteQuery = ExecuteQueryOnArray(CArray(args))

End Function
Public Function ExecuteQueryOnArray(ByRef args() As Variant) As SqlResult

    Set ExecuteQueryOnArray = SqlResult.Make(ADOExecuteQueryOnArray(args))

End Function
Public Function ExecuteUpdate(ParamArray args() As Variant) As Long

    ExecuteUpdate = ExecuteUpdateOnArray(CArray(args))

End Function
Public Function ExecuteUpdateOnArray(ByRef args() As Variant) As Long

    ResetArgs args
    
    Dim checkRows As Long
    pCommand.Execute checkRows
    
    ExecuteUpdateOnArray = checkRows

End Function
Private Sub ResetArgs(ByRef args() As Variant)

    pCommand.Parameters.Refresh ' clear parameters
    
    Dim arg
    For Each arg In args
        
        Dim adoType As ADODB.DataTypeEnum
        adoType = GetADOTypeOf(arg)
        
        Dim parm As ADODB.Parameter
        Set parm = pCommand.CreateParameter(Type:=adoType, Value:=arg)
        pCommand.Parameters.Append parm
        
    Next
    
End Sub
''
' I was using `adVariant` for everything becuase it was the simplest solution
' and it worked until I used a boolean as an arg and it broke. So maybe I
' should add more types cases.
Private Function GetADOTypeOf(ByVal arg As Variant) As ADODB.DataTypeEnum

    Dim result As ADODB.DataTypeEnum
    Select Case TypeName(arg)
        Case "Boolean"
            result = adBoolean
        Case Else
            result = adVariant
    End Select
    
    GetADOTypeOf = result

End Function
'
' On problem with this section is that SqlCommand is Applicable which means
' they implement the `Apply` method, but they have two candidates for what the
' `Apply` method should call: `ExecuteQuery` and `ExecuteUpdate`.  Currently,
' it defaults to `ExecuteQuery`, but I would like it to smartly decide what
' type of command the SqlCommand is.  Determining the type of a plain text
' command is simple enough with just string operations but with stored procs
' I am at a lost.
'
' Perhaps split this class into SqlQuery and SqlUpdate and let the user decide.
' Two reasons why I haven't split the class:
'
'   1. I have never seen another library split the command classes on result
'      type.
'     - Java splits the command Interfaces on custom text (PreparedStatement) and
'       stored procs (CallableStatement)
'   2. Both would implement an ISqlCommand interface and would need a default
'      implementation module. So now what was 1 file is now 4.
'
Private Function Applicable_Apply(ParamArray args() As Variant) As Variant

    Set Applicable_Apply = ExecuteQueryOnArray(CArray(args))

End Function
Private Function Applicable_ApplyOnArray(ByRef args() As Variant) As Variant

    Set Applicable_ApplyOnArray = ExecuteQueryOnArray(CArray(args))

End Function
'
' ### Embeded
'
Public Function Compose(ByVal f As Applicable) As Applicable

    Set Compose = defApply.Compose(Me, f)

End Function
Private Function Applicable_Compose(ByVal f As Applicable) As Applicable

    Set Applicable_Compose = Compose(f)

End Function
Public Function AndThen(ByVal g As Applicable) As Applicable

    Set AndThen = defApply.AndThen(Me, g)

End Function
Private Function Applicable_AndThen(ByVal g As Applicable) As Applicable

    Set Applicable_AndThen = AndThen(g)

End Function
Public Function Partial(ParamArray args() As Variant) As Applicable

    Set Partial = AsPartial(CArray(args))

End Function
Private Function Applicable_Partial(ParamArray args() As Variant) As Applicable

    Set Applicable_Partial = AsPartial(CArray(args))

End Function
Public Function AsPartial(ByRef args() As Variant) As Applicable

    Set AsPartial = defApply.AsPartial(Me, args)

End Function
Private Function Applicable_AsPartial(ByRef args() As Variant) As Applicable

    Set Applicable_AsPartial = AsPartial(args)

End Function
Public Function delay(ParamArray args() As Variant) As Delayed

    Set delay = AsDelay(CArray(args))

End Function
Private Function Applicable_Delay(ParamArray args() As Variant) As Delayed

    Set Applicable_Delay = AsDelay(CArray(args))

End Function
Public Function AsDelay(ByRef args() As Variant) As Delayed

    Set AsDelay = defApply.AsDelay(Me, args)

End Function
Private Function Applicable_AsDelay(ByRef args() As Variant) As Delayed

    Set Applicable_AsDelay = AsDelay(args)

End Function
'
' ### Showable
'
Public Function Show() As String

    Show = defShow.ParamShowableObject(Me, pCommand.CommandText)

End Function
Private Function Showable_Show() As String

    Showable_Show = Show

End Function
