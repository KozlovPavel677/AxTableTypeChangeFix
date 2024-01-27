# AxTableTypeChangeFix
This is a fix for Microsoft Dynamamics AX 2012 R3 kernel bug. Sometimes axapta changes type of table object in AOT (view becomes table, map becomes table, etc). The fix suggests a trigger for ModelElementData table in Model database of axapta application. The trigger prevents from such change type. 

## Setup
Run sequentially sql scripts in your axapta model database :
1. \\Sql\\Create Scalar-valued aMRC_posByCountBin.sql
2. \\Sql\\Create Scalar-valued aMRC_axTableType.sql
3. \\Sql\\Create_T_SQL_ModelElementData_Trigger_Update.sql

or

1. Import \\Xpo\\PKoz_JEV007444_Public_dev.xpo in axapta application.
2. Run class ModelElementDataTriggers_MRC
3. Take from infolog generated sql scripts
4. Run this scripts  in your axapta model database.

### Discussion : 
https://axforum.info/forums/showthread.php?p=440314&langid=1#post440314

## License
The AxTableTypeChangeFix source code in this repo is available under the MIT license. See [License.txt](LICENSE.txt).
