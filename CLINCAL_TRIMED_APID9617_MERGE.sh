exec 1> $CODE/edlr2_ppm_clinical/logs/`echo $0 | cut -d '/' -f8 | sed 's/\.sh//g'`_$(date +"%Y%m%d_%H%M%S").log 2>&1

######################################################################################################################################################
# RULER --- no line of code or comments should extend beyond column 150 (Unix code may be an exception).
#--------*---------*---------*---------*---------*---------*---------*---------*---------*---------*---------*---------*---------*---------*---------*
#        0         0         0         0         0         0         0         0         0         1         1         1         1         1         1
#        1         2         3         4         5         6         7         8         9         0         1         2         3         4         5
#        0         0         0         0         0         0         0         0         0         0         0         0         0         0         0
#--------*---------*---------*---------*---------*---------*---------*---------*---------*---------*---------*---------*---------*---------*--------*
####################################################################################################################################################

#====================================================================================================================================================
# Title     	    : CLINCAL_TRIMED_APID9617_MERGE
# Filename    	    : CLINCAL_TRIMED_APID9617_MERGE.sh
# Description 	    : THIS SCRIPT IS USED TO MERGE data into UM_RQST table
#                     
# Source Tables     : 
# Target Tables	    : UM_RQST table
# Key Columns	    : TRIMED_CASE_ID, CLNCL_SOR_CD
# Developer         : IBM
# Created on        : 12/23/2019
# Location     	    : KOLKATA
# Logic             : THIS SCRIPT IS USED TO TAKE MERGE data into UM_RQST table
# Parameters	    : 
# Return codes      : 0 for succeed
# Change log below this line...
# Date       Ver#  Modified By(IBM)  	 Change and Reason for Change
# ---------- ----- --------------------- -----------------------------------------------------------------------------------
# 12/23/2019  1.0   IBM 		   New script for Merging UM_RQST table PVID 35309 APID 9617
#=====================================================================================================================================================

########################################################################

# variable assignments from positional parameters and hardcoded values

#########################################################################

echo "script file="$0
PARM_FILE=$1
echo "parm file="$PARM_FILE.parm

###############################################################################
# Invoke parameter file.
###############################################################################

. $CODE/edlr2_ppm_clinical/scripts/$PARM_FILE.parm

###############################################################################
# BEGIN BTEQ EXECUTION
###############################################################################
bteq <<EOF
/*****************************************************************************/
/* SET WIDTH should be max of 150 and all lines of code and comments should  */
/* be no wider than column 150. Exceptions are where BTEQ Export is used and */
/* output is wider than 150 columns. In this case the width can be set appro-*/
/* priate to the output line length.                                         */
/*****************************************************************************/
.SET WIDTH 150;

/***put BTEQ in Transaction mode***/
.SET SESSION TRANSACTION BTET;

/*****************************************************************************/
/* The $LOGON global variable should be used exclusively in EDWard           */
/* environments                                                              */
/*****************************************************************************/

.run file $LOGON/$LOGON_ID;
/***************************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***************************** Error Handling ********************************/

/*****************************************************************************/
/* The next three items are to assist DBA team in problem resolution.        */
/*****************************************************************************/
SELECT SESSION;

/***************************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***************************** Error Handling ********************************/

SET QUERY_BAND = 'ApplicationName=$0;Frequency=One Time;' FOR SESSION;

/***************************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***************************** Error Handling ********************************/

/******************************************************************************
Set default database based on parameter in parm file if needs to be different than 
the logon ID's default database.
**********************************************************************************/

DATABASE $ETL_VIEWS_DB;


/************************************** Error Handling ******************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/************************************** Error Handling ******************************************************************/
create multiset volatile table  SML_TRIMED_WORK as 
(
SELECT
DISTINCT
 CAST(TRIMED_CASE_ID AS VARCHAR(25)) AS V_TRI_CASE_ID
,C_PGM_IND
FROM LZ_TRIMED_AIM_PROD_CD_WORK) 
with data 
on commit preserve rows;

/************************************** Error Handling ******************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/************************************** Error Handling ******************************************************************/


Collect statistics column(V_TRI_CASE_ID) on SML_TRIMED_WORK ;

/************************************** Error Handling ******************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/************************************** Error Handling ******************************************************************/

UPDATE UM_RQST 
FROM SML_TRIMED_WORK B
SET AIM_PROD_CD         = B.C_PGM_IND
   ,CRCTD_LOAD_LOG_KEY    = (SEL CRCTD_LOAD_LOG_KEY FROM CRCTD_LOAD_LOG
        WHERE LOAD_END_DTM   = '8888-12-31 12:00:00.000000'
        AND CRCTD_PBLSH_IND='N'
        AND CRCTD_PBLSH_DTM='8888-12-31 12:00:00.000000'
        AND CRCTD_DESC_TXT='$CRCTD_DESC_TXT')
WHERE  RFRNC_NBR    = B.V_TRI_CASE_ID
WHERE    CLNCL_SOR_CD       = '870' 
AND    AIM_PROD_CD       <> 'MSK' 
;


/************************************** Error Handling ******************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/************************************** Error Handling ******************************************************************/


.QUIT 0

/*****************************************************************************/
/* ERROR HANDLING ROUTINES                                                   */
/*                                                                           */
/* DO NOT OVERRIDE THE TERADATA ERRORCODE.                                   */
/* User defined error routines may be added in this section. Give definition */
/* of any code passed from the error routine in a comment in the error       */
/* routine or in the comment block at the beginning of the script.           */
/*****************************************************************************/

.LABEL ERRORS

.QUIT ERRORCODE

EOF
#===============================================================================
#END BTEQ EXECUTION
#===============================================================================
# show AIX return code and exit with it
RETURN_CODE=$?
END_TIME=`date +%s`
TT_SECS=$(( END_TIME - ST_TIME))
TT_HRS=$(( TT_SECS / 3600 ))
TT_REM_MS=$(( TT_SECS % 3600 ))
TT_MINS=$(( TT_REM_MS / 60 ))
TT_REM_SECS=$(( TT_REM_MS % 60 ))
echo "Total Time Taken ="$TT_HRS:$TT_MINS:$TT_REM_SECS HH:MM:SS
echo "script return code = " $RETURN_CODE
exit $RETURN_CODE
