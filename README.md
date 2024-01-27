# AxTableTypeChangeFix
This is a fix for Microsoft Dynamamics AX 2012 R3 kernel bug. Sometimes axapta changes type of table object in AOT (view becomes table, map becomes table, etc). The fix suggests a trigger for ModelElementData table in Model database of axapta application. The trigger prevents from such change type.
