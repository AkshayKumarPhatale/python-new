exec 1> $CODE/sr_riskadj/logs/SR_RISK_bteq_MAO004_INCR_DTL_TRNSFRM_load_$(date +"%Y%m%d_%H%M%S").log 2>&1
#===============================================================================
# Title             : SR_RISK_bteq_MAO004_INCR_DTL_TRNSFRM_load
# Filename          : SR_RISK_bteq_MAO004_INCR_DTL_TRNSFRM_load.sh
# Description       : This script invokes tranformations to CMS MAO004 tables.
# Source Tables     : SRC_MAO_DTL
# Target Tables     : CMS_MAO_004_DTL_TRNSFRM
# Key Columns       : NA
# Developer         : UST OnSHORE
# Created on        : 18 AUG 2016
# Location          : RICHMOND
# Logic             : The BTEQ script invokes tranformations to CMS MAO004 tables.
# Parameters        : -NA-
# Date                 	Ver#         Modified By(Name)                           Change and Reason for Change
# ----------            -----        -------------------------------          --------------------------------------------
# 18 AUG 2016		1.0			      UST GLOBAL									Initial version										
#===========================================================================================================================================================

PARM_FILE=$1
CMS_SUBJ_AREA_NM=$2
CMS_WORK_FLOW_NM=$3
TRFRM_SUBJ_AREA_NM=$4
TRFRM_WORK_FLOW_NM=$5

echo "script file="$0
echo "parm file="$PARM_FILE

. $CODE/sr_riskadj/ctlfiles/$PARM_FILE;

#===============================================================================
#BTEQ Script
#===============================================================================

bteq<<EOF

.SET WIDTH 100;
/* put BTEQ in Transaction mode */
.SET SESSION TRANSACTION BTET;

/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***************** Error Handling ********************************/

/* PARM_FILE gives the file path containing the logon details */
.run file $logon; 

/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/**************** Error Handling ********************************/
SELECT SESSION;
/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***************** Error Handling ********************************/
SET QUERY_BAND = 'ApplicationName=$0;Frequency=Monthly;' FOR SESSION;

/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***************** Error Handling ********************************/
/**************************************************************************************************
Set default database based on parameter in parm file if needs to be different than the logon ID's
default database.
**************************************************************************************************/

DATABASE $ETL_DATA_SR_RISKADJ;

/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***************** Error Handling ********************************/

DELETE FROM $ETL_DATA_SR_RISKADJ.WORK_CMS_MAO_004_DTL;

/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***************** Error Handling ********************************/

INSERT INTO $ETL_DATA_SR_RISKADJ.WORK_CMS_MAO_004_DTL
(
RCRD_TYPE_CD
,RPT_ID
,CMS_CNTRCT_NBR
,CMS_RUN_DT_TXT
,CMS_MBR_HIC_NBR_ID
,LNK_TO_ALW_DSALW_CD 
,ENCNTR_ICN_ID
,ENCNTR_TYPE_SWCH_CD
,ICN_LNK_TO_ID
,PLAN_SBMSN_DT_TXT
,FROM_SRVC_DT_TXT
,THRU_SRVC_DT_TXT
,CLM_TYPE_CD
,ALW_DISALW_IND_CD
,ALW_DISALW_CHNG_RSN_CD
,FILE_NM_CD
,FILE_NM
,SOR_CD
,SCRTY_LVL_CD
,LOAD_LOG_KEY
)
SELECT 
 DTL.RCRD_TYPE_CD
,DTL.RPT_ID
,DTL.CMS_CNTRCT_NBR
,DTL.CMS_RUN_DT_TXT
,DTL.CMS_MBR_HIC_NBR_ID
,DTL.ENCNTR_LNK_TO_STTS_IND_CD 
,DTL.ENCNTR_ICN_ID
,DTL.ENCNTR_TYPE_SWCH_CD
,DTL.ICN_LNK_TO_ID
,DTL.PLAN_SBMSN_DT_TXT
,DTL.FROM_SRVC_DT_TXT
,DTL.THRU_SRVC_DT_TXT
,DTL.CLM_TYPE_CD
,DTL.ALW_DISALW_IND_CD
,DTL.ALW_DISALW_CHNG_RSN_CD
,DTL.FILE_NM_CD
,DTL.FILE_NM
,DTL.SOR_CD
,DTL.SCRTY_LVL_CD
,DTL.LOAD_LOG_KEY
FROM $CMS_MAO_DTL_TBL DTL

INNER JOIN $SR_RADJ_QA.LOAD_LOG LL
ON DTL.LOAD_LOG_KEY=LL.LOAD_LOG_KEY
AND   LL.SUBJ_AREA_NM = '$CMS_SUBJ_AREA_NM'
AND    LL.WORK_FLOW_NM = '$CMS_WORK_FLOW_NM'
AND LL.PBLSH_IND ='Y'
AND    LL.LOAD_STRT_DTM = ( SELECT MAX(LOAD_STRT_DTM) LOAD_STRT_DTM
                                            FROM $SR_RADJ_QA.$CMS_LD_LOG_TBL
                                      WHERE SUBJ_AREA_NM = '$CMS_SUBJ_AREA_NM'
                                      AND PBLSH_IND='Y' )

GROUP BY  DTL.RCRD_TYPE_CD ,DTL.RPT_ID ,DTL.CMS_CNTRCT_NBR ,DTL.CMS_RUN_DT_TXT ,DTL.CMS_MBR_HIC_NBR_ID 
,DTL.ENCNTR_LNK_TO_STTS_IND_CD,DTL.ENCNTR_ICN_ID
,DTL.ENCNTR_TYPE_SWCH_CD ,DTL.ICN_LNK_TO_ID ,DTL.PLAN_SBMSN_DT_TXT ,DTL.FROM_SRVC_DT_TXT ,DTL.THRU_SRVC_DT_TXT
,DTL.CLM_TYPE_CD ,DTL.ALW_DISALW_IND_CD ,DTL.ALW_DISALW_CHNG_RSN_CD ,DTL.FILE_NM_CD ,DTL.FILE_NM ,DTL.SOR_CD
,DTL.SCRTY_LVL_CD ,DTL.LOAD_LOG_KEY;
                                      
/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***************** Error Handling ********************************/
CREATE VOLATILE TABLE WORK_CAL_TMP
(
YEAR_MNTH_DAY_NBR VARCHAR(8) 
)
PRIMARY INDEX(YEAR_MNTH_DAY_NBR)
ON COMMIT PRESERVE ROWS;

                                      
/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***************** Error Handling ********************************/
INSERT INTO WORK_CAL_TMP
(
YEAR_MNTH_DAY_NBR
)
SELECT 
 YEAR_MNTH_DAY_NBR FROM $ETL_DATA_SR_RISKADJ.CLNDR
 GROUP BY 1;
 
 /***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***************** Error Handling ********************************/
INSERT INTO $MAO_004_DTL_TRNSFRM
(
RCRD_TYPE_CD
,RPT_ID
,CMS_CNTRCT_NBR
,CMS_RUN_DT_TXT
,CMS_RUN_DT
,CMS_MBR_HIC_NBR_ID
,ENCNTR_ICN_ID
,ENCNTR_TYPE_SWCH_CD
,ICN_LNK_TO_ID 
,LNK_TO_ALW_DISALW_CD 
,ENCNTR_LNK_TO_NOT_FND_IND
,REPLCD_IND
,REPLCD_BY_ENCNTR_ICN_ID
,REPLCD_RPT_DT_TXT
,REPLCD_RPT_DT
,PLAN_SBMSN_DT_TXT
,PLAN_SBMSN_DT
,FROM_SRVC_DT_TXT
,FROM_SRVC_DT
,THRU_SRVC_DT_TXT
,THRU_SRVC_DT
,EGR_GRP_NBR
,CLM_TYPE_CD
,ALW_DISALW_IND_CD
,ALW_DISALW_CHNG_RSN_CD
,FILE_NM_CD
,FILE_NM
,SOR_CD
,SCRTY_LVL_CD
,SOR_DTM
,LOAD_LOG_KEY
,TRNSFRM_LOAD_LOG_KEY
,UPDTD_LOAD_LOG_KEY
,CRCTD_LOAD_LOG_KEY
,DS_NM
,DS_CTGRY_1_TXT
,DS_CTGRY_2_TXT
,DS_CD
,PCN_KEY
,VNDR_NM
)
SELECT
 DTL.RCRD_TYPE_CD
,DTL.RPT_ID
,DTL.CMS_CNTRCT_NBR
,CASE WHEN TRIM(DTL.CMS_RUN_DT_TXT) IS NULL THEN 'NA' ELSE DTL.CMS_RUN_DT_TXT END AS CMS_RUN_DT_TXT
,CASE WHEN TRIM(DTL.CMS_RUN_DT_TXT) IS NULL THEN CAST ('1111-01-01' AS DATE FORMAT 'YYYY-MM-DD') 
	WHEN TRIM(DTL.CMS_RUN_DT_TXT) = '' THEN CAST('11110101' AS DATE FORMAT 'YYYYMMDD')
	  WHEN  ( TRIM(DTL.CMS_RUN_DT_TXT) IS NOT NULL AND WORK_CAL_TMP_RUN_DT.YEAR_MNTH_DAY_NBR IS NULL) 
	          THEN CAST('11110101' AS DATE FORMAT 'YYYYMMDD')  ELSE
	CAST (DTL.CMS_RUN_DT_TXT AS DATE FORMAT 'YYYYMMDD') 
    END AS CMS_RUN_DT
,DTL.CMS_MBR_HIC_NBR_ID
,DTL.ENCNTR_ICN_ID
,CASE WHEN ( TRIM(DTL.ENCNTR_TYPE_SWCH_CD) = '' AND TRIM (ICN_LNK_TO_ID) = '') THEN '1'
      ELSE DTL.ENCNTR_TYPE_SWCH_CD END AS ENCNTR_TYPE_SWCH_CD
,DTL.ICN_LNK_TO_ID
,DTL.LNK_TO_ALW_DSALW_CD 
,CASE WHEN (DTL.ENCNTR_TYPE_SWCH_CD NOT IN ('1','4') OR TRIM (ICN_LNK_TO_ID) <> '') THEN 'N' 
      ELSE '' END AS ENCNTR_LNK_TO_NOT_FND_IND
,CASE WHEN DTL.ENCNTR_TYPE_SWCH_CD IN ('2','5','8') THEN 'Y'
			ELSE '' END AS REPLCD_IND
,'' AS REPLCD_BY_ENCNTR_ICN_ID
,'NA' AS REPLCD_RPT_DT_TXT
,CAST ('8888-12-31' AS DATE FORMAT 'YYYY-MM-DD') AS REPLCD_RPT_DT
,DTL.PLAN_SBMSN_DT_TXT
,CASE WHEN TRIM(DTL.PLAN_SBMSN_DT_TXT) IS NULL THEN CAST ('1111-01-01' AS DATE FORMAT 'YYYY-MM-DD') 
	          WHEN TRIM(DTL.PLAN_SBMSN_DT_TXT) = '' THEN CAST('11110101' AS DATE FORMAT 'YYYYMMDD') 
	          WHEN  ( TRIM(DTL.PLAN_SBMSN_DT_TXT) IS NOT NULL AND WORK_CAL_TMP_SBMSN.YEAR_MNTH_DAY_NBR IS NULL) 
	          THEN CAST('11110101' AS DATE FORMAT 'YYYYMMDD')
	           ELSE 	CAST (DTL.PLAN_SBMSN_DT_TXT AS DATE FORMAT 'YYYYMMDD') 
   END AS PLAN_SBMSN_DT
,DTL.FROM_SRVC_DT_TXT
,CASE WHEN TRIM(DTL.FROM_SRVC_DT_TXT) IS NULL THEN CAST ('1111-01-01' AS DATE FORMAT 'YYYY-MM-DD') 
			   WHEN TRIM(DTL.FROM_SRVC_DT_TXT) = '' THEN CAST('11110101' AS DATE FORMAT 'YYYYMMDD')  
	          WHEN  ( TRIM(DTL.FROM_SRVC_DT_TXT) IS NOT NULL AND WORK_CAL_TMP_FRM_DT.YEAR_MNTH_DAY_NBR IS NULL) 
	          THEN CAST('11110101' AS DATE FORMAT 'YYYYMMDD')			   
			   ELSE 	CAST (DTL.FROM_SRVC_DT_TXT AS DATE FORMAT 'YYYYMMDD') 
    END AS FROM_SRVC_DT
,DTL.THRU_SRVC_DT_TXT
,CASE WHEN TRIM(DTL.THRU_SRVC_DT_TXT) IS NULL THEN CAST ('8888-12-31' AS DATE FORMAT 'YYYY-MM-DD') 
			  WHEN TRIM(DTL.THRU_SRVC_DT_TXT) = '' THEN CAST('88881231' AS DATE FORMAT 'YYYYMMDD') 
	          WHEN  ( TRIM(DTL.THRU_SRVC_DT_TXT) IS NOT NULL AND WORK_CAL_TMP_THRU_DT.YEAR_MNTH_DAY_NBR IS NULL) 
	          THEN CAST('88881231' AS DATE FORMAT 'YYYYMMDD')		
	 ELSE CAST (DTL.THRU_SRVC_DT_TXT AS DATE FORMAT 'YYYYMMDD') 
    END AS THRU_SRVC_DT
,'UNK' AS EGR_GRP_NBR
,DTL.CLM_TYPE_CD
,DTL.ALW_DISALW_IND_CD
,DTL.ALW_DISALW_CHNG_RSN_CD
,DTL.FILE_NM_CD
,DTL.FILE_NM
,DTL.SOR_CD
,DTL.SCRTY_LVL_CD
,CURRENT_TIMESTAMP AS SOR_DTM
,DTL.LOAD_LOG_KEY
,TLL.LOAD_LOG_KEY AS TRNSFRM_LOAD_LOG_KEY
,DTL.LOAD_LOG_KEY AS UPDTD_LOAD_LOG_KEY
,'0' AS CRCTD_LOAD_LOG_KEY

/* MRDM 27814 - ADD PCN COLUMNS */
,'UNK' AS DS_NM
,'UNK' AS DS_CTGRY_1_TXT
,'UNK' AS DS_CTGRY_2_TXT
,'UNK' AS DS_CD
,'UNK' AS PCN_KEY
,'UNK' AS VNDR_NM
    
FROM $ETL_DATA_SR_RISKADJ.WORK_CMS_MAO_004_DTL DTL

INNER JOIN $SR_RADJ_QA.LOAD_LOG LL
ON DTL.LOAD_LOG_KEY=LL.LOAD_LOG_KEY
AND   LL.SUBJ_AREA_NM = '$CMS_SUBJ_AREA_NM'
AND    LL.WORK_FLOW_NM = '$CMS_WORK_FLOW_NM'
AND LL.PBLSH_IND ='Y'
AND    LL.LOAD_STRT_DTM = ( SELECT MAX(LOAD_STRT_DTM) LOAD_STRT_DTM
                                            FROM $SR_RADJ_QA.$CMS_LD_LOG_TBL
                                      WHERE SUBJ_AREA_NM = '$CMS_SUBJ_AREA_NM'
                                      AND PBLSH_IND='Y' )

LEFT JOIN WORK_CAL_TMP  WORK_CAL_TMP_RUN_DT
ON  CMS_RUN_DT_TXT = WORK_CAL_TMP_RUN_DT.YEAR_MNTH_DAY_NBR

LEFT JOIN WORK_CAL_TMP  WORK_CAL_TMP_SBMSN
ON  PLAN_SBMSN_DT_TXT = WORK_CAL_TMP_SBMSN.YEAR_MNTH_DAY_NBR

LEFT JOIN WORK_CAL_TMP  WORK_CAL_TMP_FRM_DT
ON  FROM_SRVC_DT_TXT = WORK_CAL_TMP_FRM_DT.YEAR_MNTH_DAY_NBR

LEFT JOIN WORK_CAL_TMP  WORK_CAL_TMP_THRU_DT
ON  THRU_SRVC_DT_TXT = WORK_CAL_TMP_THRU_DT.YEAR_MNTH_DAY_NBR

CROSS JOIN $SR_RADJ_QA.LOAD_LOG TLL
WHERE  TLL.SUBJ_AREA_NM = '$TRFRM_SUBJ_AREA_NM'
AND    TLL.PBLSH_IND= 'N'
AND    TLL.WORK_FLOW_NM = '$TRFRM_WORK_FLOW_NM';

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CMS_DB','$MAO_004_DTL_TRNSFRM','N',RTRN_CD,RTRN_CNT,MSG);
/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/
/*
CREATE VOLATILE TABLE VT_TRNSFRM_LOAD_LOG
     (
	LOAD_LOG_KEY BIGINT NOT NULL
      )
PRIMARY INDEX(LOAD_LOG_KEY)
ON COMMIT PRESERVE ROWS; 
*/
/****************************************************************************************************************/
/* .IF ERRORCODE <> 0 THEN .GOTO ERRORS*/
/****************************************************************************************************************/

INSERT INTO WORK_TRNSFRM_LOAD_LOG
(
LOAD_LOG_KEY
)
SELECT LOAD_LOG_KEY 
FROM $SR_RADJ_QA.LOAD_LOG 
WHERE  SUBJ_AREA_NM = '$TRFRM_SUBJ_AREA_NM'
AND    PBLSH_IND= 'N'
AND    WORK_FLOW_NM = '$TRFRM_WORK_FLOW_NM'
; 

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$ETL_TEMP_SR_RISKADJ','WORK_TRNSFRM_LOAD_LOG','N',RTRN_CD,RTRN_CNT,MSG);
/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/


UPDATE TRNSFRM
FROM $MAO_004_DTL_TRNSFRM TRNSFRM
	,WORK_TRNSFRM_LOAD_LOG TLL_LOAD
SET UPDTD_LOAD_LOG_KEY =TLL_LOAD.LOAD_LOG_KEY
WHERE ENCNTR_LNK_TO_NOT_FND_IND ='N'
AND TRNSFRM.TRNSFRM_LOAD_LOG_KEY = TLL_LOAD.LOAD_LOG_KEY;
/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/
/*
CREATE VOLATILE TABLE VT_FACT_MBRSHP
     (
	MEDCR_MRKT_SGMNT_CD CHAR(5) CHARACTER SET LATIN NOT CASESPECIFIC NOT NULL,
	CMS_CNTRCT_NBR CHAR(5) CHARACTER SET LATIN NOT CASESPECIFIC NOT NULL
      )
PRIMARY INDEX(CMS_CNTRCT_NBR)
ON COMMIT PRESERVE ROWS; 
*/
/****************************************************************************************************************/
/*.IF ERRORCODE <> 0 THEN .GOTO ERRORS*/
/****************************************************************************************************************/

INSERT INTO WORK_FACT_MBRSHP
(
CMS_CNTRCT_NBR,
MEDCR_MRKT_SGMNT_CD,
CRCTD_LOAD_LOG_KEY
)
SELECT DISTINCT 
CMS_CNTRCT_NBR,
MEDCR_MRKT_SGMNT_CD,
0 AS CRCTD_LOAD_LOG_KEY

FROM 
$ETL_DATA_SR_RISKADJ.FACT_MBRSHP
WHERE CMS_CNTRCT_NBR NOT IN ('UNK')
AND TRIM(MEDCR_MRKT_SGMNT_CD) <>'UNK'
; 

 /***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$ETL_TEMP_SR_RISKADJ','WORK_FACT_MBRSHP','N',RTRN_CD,RTRN_CNT,MSG);
/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/
UPDATE TRNSFRM
FROM $MAO_004_DTL_TRNSFRM TRNSFRM
	,WORK_FACT_MBRSHP FACT ,WORK_TRNSFRM_LOAD_LOG TLL_LOAD
SET EGR_GRP_NBR= FACT.MEDCR_MRKT_SGMNT_CD
,UPDTD_LOAD_LOG_KEY =TLL_LOAD.LOAD_LOG_KEY
WHERE 
TRNSFRM.CMS_CNTRCT_NBR = FACT.CMS_CNTRCT_NBR
AND TRNSFRM.TRNSFRM_LOAD_LOG_KEY = TLL_LOAD.LOAD_LOG_KEY
AND TRNSFRM.EGR_GRP_NBR='UNK';
/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/
/*
CREATE VOLATILE TABLE VT_ENCNTR_REPLCD
(
   CMS_CNTRCT_NBR CHAR ( 5 ) NOT NULL , 
   CMS_RUN_DT_TXT CHAR ( 8 ) NOT NULL , 
   CMS_RUN_DT DATE NOT NULL,
   CMS_MBR_HIC_NBR_ID VARCHAR ( 20 ) NOT NULL ,
   ENCNTR_ICN_ID VARCHAR ( 44 ) NOT NULL ,
   ENCNTR_TYPE_SWCH_CD CHAR(3) ,
   ICN_LNK_TO_ID  VARCHAR ( 44 ),
   TRNSFRM_LOAD_LOG_KEY BIGINT
)
PRIMARY INDEX (CMS_CNTRCT_NBR , CMS_RUN_DT_TXT , CMS_MBR_HIC_NBR_ID , ENCNTR_ICN_ID)
ON COMMIT PRESERVE ROWS;
*/
/****************************************************************************************************************/
/*.IF ERRORCODE <> 0 THEN .GOTO ERRORS */
/****************************************************************************************************************/

INSERT INTO WORK_ENCNTR_REPLCD
(
    CMS_CNTRCT_NBR  
   ,CMS_RUN_DT_TXT
   ,CMS_RUN_DT
   ,CMS_MBR_HIC_NBR_ID
   ,ENCNTR_ICN_ID
   ,ENCNTR_TYPE_SWCH_CD
   ,ICN_LNK_TO_ID
   ,TRNSFRM_LOAD_LOG_KEY
 )
 SELECT
    TRNSFRM.CMS_CNTRCT_NBR  
   ,TRNSFRM.CMS_RUN_DT_TXT
   ,TRNSFRM.CMS_RUN_DT
   ,TRNSFRM.CMS_MBR_HIC_NBR_ID
   ,TRNSFRM.ENCNTR_ICN_ID
   ,TRNSFRM.ENCNTR_TYPE_SWCH_CD
   ,TRNSFRM.ICN_LNK_TO_ID 
   ,TRNSFRM.TRNSFRM_LOAD_LOG_KEY
FROM $MAO_004_DTL_TRNSFRM TRNSFRM
INNER JOIN $SR_RADJ_QA.LOAD_LOG TLL
ON TRNSFRM.TRNSFRM_LOAD_LOG_KEY = TLL.LOAD_LOG_KEY
AND    TLL.SUBJ_AREA_NM = '$TRFRM_SUBJ_AREA_NM'
AND    TLL.PBLSH_IND= 'N'
AND    TLL.WORK_FLOW_NM = '$TRFRM_WORK_FLOW_NM'
WHERE (TRNSFRM.ENCNTR_TYPE_SWCH_CD NOT IN ('1','4') OR TRIM (TRNSFRM.ICN_LNK_TO_ID) <> '')

/* ADDED AS A PART OF MRDM- 19925 BY SOLAR TEAM */

QUALIFY ROW_NUMBER() OVER ( PARTITION BY TRNSFRM.CMS_CNTRCT_NBR,TRNSFRM.CMS_MBR_HIC_NBR_ID,TRNSFRM.ICN_LNK_TO_ID,TRNSFRM.ENCNTR_TYPE_SWCH_CD
 ORDER BY TRNSFRM.ENCNTR_ICN_ID DESC) =1;
 

 /***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$ETL_TEMP_SR_RISKADJ','WORK_ENCNTR_REPLCD','N',RTRN_CD,RTRN_CNT,MSG);
/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/
UPDATE TRNSFRM
FROM $MAO_004_DTL_TRNSFRM TRNSFRM
	,WORK_ENCNTR_REPLCD SML_RPLCD
SET REPLCD_IND = 'Y'
,REPLCD_BY_ENCNTR_ICN_ID = SML_RPLCD.ENCNTR_ICN_ID
,REPLCD_RPT_DT_TXT = SML_RPLCD.CMS_RUN_DT_TXT
,REPLCD_RPT_DT =SML_RPLCD.CMS_RUN_DT
,UPDTD_LOAD_LOG_KEY =SML_RPLCD.TRNSFRM_LOAD_LOG_KEY
WHERE TRNSFRM.ENCNTR_ICN_ID = SML_RPLCD.ICN_LNK_TO_ID
AND TRNSFRM.CMS_CNTRCT_NBR=SML_RPLCD.CMS_CNTRCT_NBR
AND TRNSFRM.CMS_MBR_HIC_NBR_ID=SML_RPLCD.CMS_MBR_HIC_NBR_ID
AND SML_RPLCD.ENCNTR_TYPE_SWCH_CD = '3'
AND (TRNSFRM.ENCNTR_TYPE_SWCH_CD='1' OR TRNSFRM.ENCNTR_TYPE_SWCH_CD='3');
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','REPLCD_IND','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','REPLCD_BY_ENCNTR_ICN_ID','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','REPLCD_RPT_DT_TXT','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','REPLCD_RPT_DT','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','UPDTD_LOAD_LOG_KEY','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
UPDATE TRNSFRM
FROM $MAO_004_DTL_TRNSFRM TRNSFRM
	,WORK_ENCNTR_REPLCD SML_RPLCD
SET REPLCD_IND = 'Y'
,REPLCD_BY_ENCNTR_ICN_ID = SML_RPLCD.ENCNTR_ICN_ID
,REPLCD_RPT_DT_TXT = SML_RPLCD.CMS_RUN_DT_TXT
,REPLCD_RPT_DT =SML_RPLCD.CMS_RUN_DT
,UPDTD_LOAD_LOG_KEY =SML_RPLCD.TRNSFRM_LOAD_LOG_KEY
WHERE TRNSFRM.ENCNTR_ICN_ID = SML_RPLCD.ICN_LNK_TO_ID
AND TRNSFRM.CMS_CNTRCT_NBR=SML_RPLCD.CMS_CNTRCT_NBR
AND TRNSFRM.CMS_MBR_HIC_NBR_ID=SML_RPLCD.CMS_MBR_HIC_NBR_ID
AND SML_RPLCD.ENCNTR_TYPE_SWCH_CD = '6'
AND TRNSFRM.ENCNTR_TYPE_SWCH_CD='4';
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','REPLCD_IND','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','REPLCD_BY_ENCNTR_ICN_ID','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','REPLCD_RPT_DT_TXT','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','REPLCD_RPT_DT','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','UPDTD_LOAD_LOG_KEY','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
UPDATE TRNSFRM
FROM $MAO_004_DTL_TRNSFRM TRNSFRM
	,WORK_ENCNTR_REPLCD SML_RPLCD
SET REPLCD_IND = 'Y'
,REPLCD_BY_ENCNTR_ICN_ID = SML_RPLCD.ENCNTR_ICN_ID
,REPLCD_RPT_DT_TXT = SML_RPLCD.CMS_RUN_DT_TXT
,REPLCD_RPT_DT =SML_RPLCD.CMS_RUN_DT
,UPDTD_LOAD_LOG_KEY =SML_RPLCD.TRNSFRM_LOAD_LOG_KEY
WHERE TRNSFRM.ENCNTR_ICN_ID = SML_RPLCD.ICN_LNK_TO_ID
AND TRNSFRM.CMS_CNTRCT_NBR=SML_RPLCD.CMS_CNTRCT_NBR
AND TRNSFRM.CMS_MBR_HIC_NBR_ID=SML_RPLCD.CMS_MBR_HIC_NBR_ID
AND SML_RPLCD.ENCNTR_TYPE_SWCH_CD = '9'
AND TRNSFRM.ENCNTR_TYPE_SWCH_CD IN ('7');
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','REPLCD_IND','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','REPLCD_BY_ENCNTR_ICN_ID','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','REPLCD_RPT_DT_TXT','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','REPLCD_RPT_DT','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','UPDTD_LOAD_LOG_KEY','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
/* updates type 7 records linking back to 1,3 and 4 */

UPDATE TRNSFRM
FROM $MAO_004_DTL_TRNSFRM TRNSFRM
	,WORK_ENCNTR_REPLCD SML_RPLCD
SET REPLCD_IND = 'Y'
,REPLCD_BY_ENCNTR_ICN_ID = SML_RPLCD.ENCNTR_ICN_ID
,REPLCD_RPT_DT_TXT = SML_RPLCD.CMS_RUN_DT_TXT
,REPLCD_RPT_DT =SML_RPLCD.CMS_RUN_DT
,UPDTD_LOAD_LOG_KEY =SML_RPLCD.TRNSFRM_LOAD_LOG_KEY
WHERE TRNSFRM.ENCNTR_ICN_ID = SML_RPLCD.ICN_LNK_TO_ID
AND TRNSFRM.CMS_CNTRCT_NBR=SML_RPLCD.CMS_CNTRCT_NBR
AND TRNSFRM.CMS_MBR_HIC_NBR_ID=SML_RPLCD.CMS_MBR_HIC_NBR_ID
AND SML_RPLCD.ENCNTR_TYPE_SWCH_CD = '7'
/* ADDED AS A PART OF MRDM- 19925 BY SOLAR TEAM */
AND (TRNSFRM.ENCNTR_TYPE_SWCH_CD='1' OR TRNSFRM.ENCNTR_TYPE_SWCH_CD='3' OR TRNSFRM.ENCNTR_TYPE_SWCH_CD='4');

/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','REPLCD_IND','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','REPLCD_BY_ENCNTR_ICN_ID','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','REPLCD_RPT_DT_TXT','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','REPLCD_RPT_DT','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','UPDTD_LOAD_LOG_KEY','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/

UPDATE TRNSFRM
FROM $MAO_004_DTL_TRNSFRM TRNSFRM
	,WORK_ENCNTR_REPLCD SML_RPLCD
SET REPLCD_IND = 'Y'
,REPLCD_BY_ENCNTR_ICN_ID = SML_RPLCD.ENCNTR_ICN_ID
,REPLCD_RPT_DT_TXT = SML_RPLCD.CMS_RUN_DT_TXT
,REPLCD_RPT_DT =SML_RPLCD.CMS_RUN_DT
,UPDTD_LOAD_LOG_KEY =SML_RPLCD.TRNSFRM_LOAD_LOG_KEY
WHERE TRNSFRM.ENCNTR_ICN_ID = SML_RPLCD.ICN_LNK_TO_ID
AND TRNSFRM.CMS_CNTRCT_NBR=SML_RPLCD.CMS_CNTRCT_NBR
AND TRNSFRM.CMS_MBR_HIC_NBR_ID=SML_RPLCD.CMS_MBR_HIC_NBR_ID
AND SML_RPLCD.ENCNTR_TYPE_SWCH_CD IN ('2','5','8');
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','REPLCD_IND','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','REPLCD_BY_ENCNTR_ICN_ID','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','REPLCD_RPT_DT_TXT','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','REPLCD_RPT_DT','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','UPDTD_LOAD_LOG_KEY','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
/*
CREATE VOLATILE TABLE VT_ORGNL_ENCNTR_NOT_FND
(
   CMS_CNTRCT_NBR CHAR ( 5 ) NOT NULL , 
   CMS_RUN_DT_TXT CHAR ( 8 ) NOT NULL , 
   CMS_MBR_HIC_NBR_ID VARCHAR ( 20 ) NOT NULL ,
   ENCNTR_ICN_ID VARCHAR ( 44 ) NOT NULL,
   TRNSFRM_LOAD_LOG_KEY BIGINT 

)
PRIMARY INDEX (CMS_CNTRCT_NBR , CMS_RUN_DT_TXT , CMS_MBR_HIC_NBR_ID , ENCNTR_ICN_ID)
ON COMMIT PRESERVE ROWS;
*/
/****************************************************************************************************************/
/*.IF ERRORCODE <> 0 THEN .GOTO ERRORS */
/****************************************************************************************************************/
INSERT INTO WORK_ORGNL_ENCNTR_NOT_FND
(
	  CMS_CNTRCT_NBR  
   ,CMS_RUN_DT_TXT
   ,CMS_MBR_HIC_NBR_ID
   ,ENCNTR_ICN_ID
   ,TRNSFRM_LOAD_LOG_KEY
)
SELECT
    TRNSFRM.CMS_CNTRCT_NBR  
   ,TRNSFRM.CMS_RUN_DT_TXT
   ,TRNSFRM.CMS_MBR_HIC_NBR_ID
   ,TRNSFRM.ENCNTR_ICN_ID
   ,SML_RPLCD.TRNSFRM_LOAD_LOG_KEY
FROM $MAO_004_DTL_TRNSFRM TRNSFRM
INNER JOIN WORK_ENCNTR_REPLCD SML_RPLCD
ON SML_RPLCD.CMS_CNTRCT_NBR = TRNSFRM.CMS_CNTRCT_NBR
AND SML_RPLCD.CMS_MBR_HIC_NBR_ID=TRNSFRM.CMS_MBR_HIC_NBR_ID
AND SML_RPLCD.ENCNTR_ICN_ID=TRNSFRM.ENCNTR_ICN_ID
AND SML_RPLCD.ENCNTR_TYPE_SWCH_CD ='3'
WHERE SML_RPLCD.ICN_LNK_TO_ID NOT IN (SELECT DISTINCT ENCNTR_ICN_ID FROM $MAO_004_DTL_TRNSFRM TRNSFRM
WHERE ENCNTR_TYPE_SWCH_CD ='1' OR ENCNTR_TYPE_SWCH_CD ='3');
   
 /***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$ETL_TEMP_SR_RISKADJ','WORK_ORGNL_ENCNTR_NOT_FND','N',RTRN_CD,RTRN_CNT,MSG);
/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/

INSERT INTO WORK_ORGNL_ENCNTR_NOT_FND
(
	  CMS_CNTRCT_NBR  
   ,CMS_RUN_DT_TXT
   ,CMS_MBR_HIC_NBR_ID
   ,ENCNTR_ICN_ID
   ,TRNSFRM_LOAD_LOG_KEY
)
SELECT
    TRNSFRM.CMS_CNTRCT_NBR  
   ,TRNSFRM.CMS_RUN_DT_TXT
   ,TRNSFRM.CMS_MBR_HIC_NBR_ID
   ,TRNSFRM.ENCNTR_ICN_ID
   ,SML_RPLCD.TRNSFRM_LOAD_LOG_KEY
FROM $MAO_004_DTL_TRNSFRM TRNSFRM
INNER JOIN WORK_ENCNTR_REPLCD SML_RPLCD
ON SML_RPLCD.CMS_CNTRCT_NBR = TRNSFRM.CMS_CNTRCT_NBR
AND SML_RPLCD.CMS_MBR_HIC_NBR_ID=TRNSFRM.CMS_MBR_HIC_NBR_ID
AND SML_RPLCD.ENCNTR_ICN_ID=TRNSFRM.ENCNTR_ICN_ID
AND SML_RPLCD.ENCNTR_TYPE_SWCH_CD ='4'
WHERE SML_RPLCD.ICN_LNK_TO_ID NOT IN (SELECT DISTINCT ENCNTR_ICN_ID FROM $MAO_004_DTL_TRNSFRM TRNSFRM
WHERE ENCNTR_TYPE_SWCH_CD IN ('6'));
   
 /***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$ETL_TEMP_SR_RISKADJ','WORK_ORGNL_ENCNTR_NOT_FND','N',RTRN_CD,RTRN_CNT,MSG);
/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/

INSERT INTO WORK_ORGNL_ENCNTR_NOT_FND
(
	  CMS_CNTRCT_NBR  
   ,CMS_RUN_DT_TXT
   ,CMS_MBR_HIC_NBR_ID
   ,ENCNTR_ICN_ID
   ,TRNSFRM_LOAD_LOG_KEY
)
SELECT
	TRNSFRM.CMS_CNTRCT_NBR  
   ,TRNSFRM.CMS_RUN_DT_TXT
   ,TRNSFRM.CMS_MBR_HIC_NBR_ID
   ,TRNSFRM.ENCNTR_ICN_ID
   ,SML_RPLCD.TRNSFRM_LOAD_LOG_KEY
FROM $MAO_004_DTL_TRNSFRM TRNSFRM
INNER JOIN WORK_ENCNTR_REPLCD SML_RPLCD
ON SML_RPLCD.CMS_CNTRCT_NBR = TRNSFRM.CMS_CNTRCT_NBR
AND SML_RPLCD.CMS_MBR_HIC_NBR_ID=TRNSFRM.CMS_MBR_HIC_NBR_ID
AND SML_RPLCD.ENCNTR_ICN_ID=TRNSFRM.ENCNTR_ICN_ID
AND SML_RPLCD.ENCNTR_TYPE_SWCH_CD ='7'

/* ADDED AS A PART OF MRDM- 19925 BY SOLAR TEAM */

WHERE SML_RPLCD.ICN_LNK_TO_ID NOT IN (SELECT DISTINCT ENCNTR_ICN_ID FROM $MAO_004_DTL_TRNSFRM TRNSFRM
WHERE ENCNTR_TYPE_SWCH_CD = '1' OR  ENCNTR_TYPE_SWCH_CD = '3' OR TRNSFRM.ENCNTR_TYPE_SWCH_CD='4');
   
 /***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$ETL_TEMP_SR_RISKADJ','WORK_ORGNL_ENCNTR_NOT_FND','N',RTRN_CD,RTRN_CNT,MSG);
/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/

INSERT INTO WORK_ORGNL_ENCNTR_NOT_FND
(
	  CMS_CNTRCT_NBR  
   ,CMS_RUN_DT_TXT
   ,CMS_MBR_HIC_NBR_ID
   ,ENCNTR_ICN_ID
   ,TRNSFRM_LOAD_LOG_KEY
)
SELECT
	TRNSFRM.CMS_CNTRCT_NBR  
   ,TRNSFRM.CMS_RUN_DT_TXT
   ,TRNSFRM.CMS_MBR_HIC_NBR_ID
   ,TRNSFRM.ENCNTR_ICN_ID
   ,SML_RPLCD.TRNSFRM_LOAD_LOG_KEY
FROM $MAO_004_DTL_TRNSFRM TRNSFRM
INNER JOIN WORK_ENCNTR_REPLCD SML_RPLCD
ON SML_RPLCD.CMS_CNTRCT_NBR = TRNSFRM.CMS_CNTRCT_NBR
AND SML_RPLCD.CMS_MBR_HIC_NBR_ID=TRNSFRM.CMS_MBR_HIC_NBR_ID
AND SML_RPLCD.ENCNTR_ICN_ID=TRNSFRM.ENCNTR_ICN_ID
AND SML_RPLCD.ENCNTR_TYPE_SWCH_CD ='9'
WHERE SML_RPLCD.ICN_LNK_TO_ID NOT IN (SELECT DISTINCT ENCNTR_ICN_ID FROM $MAO_004_DTL_TRNSFRM TRNSFRM
WHERE ENCNTR_TYPE_SWCH_CD = '7');
   
 /***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$ETL_TEMP_SR_RISKADJ','WORK_ORGNL_ENCNTR_NOT_FND','N',RTRN_CD,RTRN_CNT,MSG);
/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/
INSERT INTO WORK_ORGNL_ENCNTR_NOT_FND
(
	  CMS_CNTRCT_NBR  
   ,CMS_RUN_DT_TXT
   ,CMS_MBR_HIC_NBR_ID
   ,ENCNTR_ICN_ID
   ,TRNSFRM_LOAD_LOG_KEY
)
SELECT
	TRNSFRM.CMS_CNTRCT_NBR  
   ,TRNSFRM.CMS_RUN_DT_TXT
   ,TRNSFRM.CMS_MBR_HIC_NBR_ID
   ,TRNSFRM.ENCNTR_ICN_ID
   ,SML_RPLCD.TRNSFRM_LOAD_LOG_KEY
FROM $MAO_004_DTL_TRNSFRM TRNSFRM
INNER JOIN WORK_ENCNTR_REPLCD SML_RPLCD
ON SML_RPLCD.CMS_CNTRCT_NBR = TRNSFRM.CMS_CNTRCT_NBR
AND SML_RPLCD.CMS_MBR_HIC_NBR_ID=TRNSFRM.CMS_MBR_HIC_NBR_ID
AND SML_RPLCD.ENCNTR_ICN_ID=TRNSFRM.ENCNTR_ICN_ID
AND SML_RPLCD.ENCNTR_TYPE_SWCH_CD IN ('2','5','8')
WHERE SML_RPLCD.ICN_LNK_TO_ID NOT IN (SELECT DISTINCT ENCNTR_ICN_ID FROM $MAO_004_DTL_TRNSFRM TRNSFRM );
   
 /***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$ETL_TEMP_SR_RISKADJ','WORK_ORGNL_ENCNTR_NOT_FND','N',RTRN_CD,RTRN_CNT,MSG);
/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/
/* Commenting due to out of scope
INSERT INTO WORK_ORGNL_ENCNTR_NOT_FND
(
	  CMS_CNTRCT_NBR  
   ,CMS_RUN_DT_TXT
   ,CMS_MBR_HIC_NBR_ID
   ,ENCNTR_ICN_ID
   ,TRNSFRM_LOAD_LOG_KEY
)
SELECT
	TRNSFRM.CMS_CNTRCT_NBR  
   ,TRNSFRM.CMS_RUN_DT_TXT
   ,TRNSFRM.CMS_MBR_HIC_NBR_ID
   ,TRNSFRM.ENCNTR_ICN_ID
   ,SML_RPLCD.TRNSFRM_LOAD_LOG_KEY
FROM $MAO_004_DTL_TRNSFRM TRNSFRM
INNER JOIN WORK_ENCNTR_REPLCD SML_RPLCD
ON SML_RPLCD.CMS_CNTRCT_NBR = TRNSFRM.CMS_CNTRCT_NBR
AND SML_RPLCD.CMS_MBR_HIC_NBR_ID=TRNSFRM.CMS_MBR_HIC_NBR_ID
AND SML_RPLCD.ENCNTR_ICN_ID=TRNSFRM.ENCNTR_ICN_ID
AND SML_RPLCD.ENCNTR_TYPE_SWCH_CD ='6'
WHERE SML_RPLCD.ICN_LNK_TO_ID NOT IN (SELECT DISTINCT ENCNTR_ICN_ID FROM $MAO_004_DTL_TRNSFRM TRNSFRM
WHERE ENCNTR_TYPE_SWCH_CD = '4');
 */  
/****************************************************************************************************************/
/*.IF ERRORCODE <> 0 THEN .GOTO ERRORS */
/****************************************************************************************************************/
/*COLLECT STATS ON WORK_ORGNL_ENCNTR_NOT_FND INDEX(CMS_CNTRCT_NBR , CMS_RUN_DT_TXT , CMS_MBR_HIC_NBR_ID , ENCNTR_ICN_ID); */
/****************************************************************************************************************/
/*.IF ERRORCODE <> 0 THEN .GOTO ERRORS */
/****************************************************************************************************************/

UPDATE TRNSFRM
FROM $MAO_004_DTL_TRNSFRM TRNSFRM
	,WORK_ORGNL_ENCNTR_NOT_FND ENCNTR_NOT_FND
SET ENCNTR_LNK_TO_NOT_FND_IND ='Y'
,UPDTD_LOAD_LOG_KEY =ENCNTR_NOT_FND.TRNSFRM_LOAD_LOG_KEY
WHERE TRNSFRM.CMS_CNTRCT_NBR = ENCNTR_NOT_FND.CMS_CNTRCT_NBR
AND TRNSFRM.CMS_MBR_HIC_NBR_ID=ENCNTR_NOT_FND.CMS_MBR_HIC_NBR_ID
AND TRNSFRM.ENCNTR_ICN_ID =ENCNTR_NOT_FND.ENCNTR_ICN_ID;
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','ENCNTR_LNK_TO_NOT_FND_IND','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','UPDTD_LOAD_LOG_KEY','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/

/* below codes ADDED AS A PART OF MRDM- 19925 BY SOLAR TEAM */
/* BEGIN */
/*
CREATE VOLATILE TABLE VT_VOID_ORIGINAL_ENCNTR
(
   ORIG_ENCNTR_ICN_ID VARCHAR ( 44 ) NOT NULL,
   CMS_CNTRCT_NBR CHAR ( 5 ) NOT NULL, 
   CMS_MBR_HIC_NBR_ID VARCHAR ( 20 ) NOT NULL,
   DIAG_COUNT INTEGER NOT NULL,
   TRNSFRM_LOAD_LOG_KEY BIGINT
)
PRIMARY INDEX (CMS_CNTRCT_NBR , ORIG_ENCNTR_ICN_ID , CMS_MBR_HIC_NBR_ID , DIAG_COUNT)
ON COMMIT PRESERVE ROWS;
*/
/****************************************************************************************************************/
/*.IF ERRORCODE <> 0 THEN .GOTO ERRORS */
/****************************************************************************************************************/
INSERT INTO  WORK_VOID_ORIGINAL_ENCNTR 

(
ORIG_ENCNTR_ICN_ID,
CMS_CNTRCT_NBR,
CMS_MBR_HIC_NBR_ID,
DIAG_COUNT,
TRNSFRM_LOAD_LOG_KEY
)

SELECT 
 ENCNTR_ICN_ID AS ORIG_ENCNTR_ICN_ID
,CMS_CNTRCT_NBR
,CMS_MBR_HIC_NBR_ID
,SUM 
(
CASE WHEN  ADD_DEL_CD    <> 'D' AND DIAG_CD    <> '' THEN 1 ELSE 0 END +  
CASE WHEN  ADD_DEL_1_CD  <> 'D' AND DIAG_1_CD  <> '' THEN 1 ELSE 0 END +  
CASE WHEN  ADD_DEL_2_CD  <> 'D' AND DIAG_2_CD  <> '' THEN 1 ELSE 0 END +                     
CASE WHEN  ADD_DEL_3_CD  <> 'D' AND DIAG_3_CD  <> '' THEN 1 ELSE 0 END +                    
CASE WHEN  ADD_DEL_4_CD  <> 'D' AND DIAG_4_CD  <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_5_CD  <> 'D' AND DIAG_5_CD  <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_6_CD  <> 'D' AND DIAG_6_CD  <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_7_CD  <> 'D' AND DIAG_7_CD  <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_8_CD  <> 'D' AND DIAG_8_CD  <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_9_CD  <> 'D' AND DIAG_9_CD  <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_10_CD <> 'D' AND DIAG_10_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_11_CD <> 'D' AND DIAG_11_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_12_CD <> 'D' AND DIAG_12_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_13_CD <> 'D' AND DIAG_13_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_14_CD <> 'D' AND DIAG_14_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_15_CD <> 'D' AND DIAG_15_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_16_CD <> 'D' AND DIAG_16_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_17_CD <> 'D' AND DIAG_17_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_18_CD <> 'D' AND DIAG_18_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_19_CD <> 'D' AND DIAG_19_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_20_CD <> 'D' AND DIAG_20_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_21_CD <> 'D' AND DIAG_21_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_22_CD <> 'D' AND DIAG_22_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_23_CD <> 'D' AND DIAG_23_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_24_CD <> 'D' AND DIAG_24_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_25_CD <> 'D' AND DIAG_25_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_26_CD <> 'D' AND DIAG_26_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_27_CD <> 'D' AND DIAG_27_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_28_CD <> 'D' AND DIAG_28_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_29_CD <> 'D' AND DIAG_29_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_30_CD <> 'D' AND DIAG_30_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_31_CD <> 'D' AND DIAG_31_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_32_CD <> 'D' AND DIAG_32_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_33_CD <> 'D' AND DIAG_33_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_34_CD <> 'D' AND DIAG_34_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_35_CD <> 'D' AND DIAG_35_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_36_CD <> 'D' AND DIAG_36_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN  ADD_DEL_37_CD <> 'D' AND DIAG_37_CD <> '' THEN 1 ELSE 0 END 
)DIAG_COUNT
,LL.LOAD_LOG_KEY
FROM $CMS_MAO_DTL_TBL DTL


CROSS JOIN WORK_TRNSFRM_LOAD_LOG LL

WHERE ENCNTR_TYPE_SWCH_CD IN ('1','3','4') 
  AND ENCNTR_ICN_ID IN ( SELECT ICN_LNK_TO_ID FROM $CMS_MAO_DTL_TBL WHERE ENCNTR_TYPE_SWCH_CD = '7')
GROUP BY 1,2,3,5
;


 /***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$ETL_TEMP_SR_RISKADJ','WORK_VOID_ORIGINAL_ENCNTR','N',RTRN_CD,RTRN_CNT,MSG);
/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/
/*
CREATE VOLATILE TABLE VT_VOID_RPLCING_ENCNTR
(
   ORIG_ENCNTR_ICN_ID VARCHAR ( 44 ) NOT NULL,
   CMS_CNTRCT_NBR CHAR ( 5 ) NOT NULL , 
   CMS_MBR_HIC_NBR_ID VARCHAR ( 20 ) NOT NULL ,
   REPLCING_ENCNTR_ICN_ID VARCHAR ( 44 ) NOT NULL,
   DIAG_COUNT INTEGER NOT NULL,
   TRNSFRM_LOAD_LOG_KEY BIGINT
)
PRIMARY INDEX (CMS_CNTRCT_NBR , ORIG_ENCNTR_ICN_ID , CMS_MBR_HIC_NBR_ID ,REPLCING_ENCNTR_ICN_ID, DIAG_COUNT)
ON COMMIT PRESERVE ROWS;
*/
/****************************************************************************************************************/
/*.IF ERRORCODE <> 0 THEN .GOTO ERRORS */
/****************************************************************************************************************/

INSERT INTO  WORK_VOID_RPLCING_ENCNTR 

(
ORIG_ENCNTR_ICN_ID,
CMS_CNTRCT_NBR,
CMS_MBR_HIC_NBR_ID,
REPLCING_ENCNTR_ICN_ID,
DIAG_COUNT,
TRNSFRM_LOAD_LOG_KEY
)

SELECT
 ICN_LNK_TO_ID AS ORIG_ENCNTR_ICN_ID
,CMS_CNTRCT_NBR
,CMS_MBR_HIC_NBR_ID 
,MAX(ENCNTR_ICN_ID) AS REPLCING_ENCNTR_ICN_ID
,SUM(DIAG_COUNT)  AS DIAG_COUNT
,LL.LOAD_LOG_KEY
FROM 
(
SELECT 
 ENCNTR_ICN_ID
,ICN_LNK_TO_ID
,CMS_CNTRCT_NBR
,CMS_MBR_HIC_NBR_ID
,SUM 
(
CASE WHEN DIAG_CD    <> '' THEN 1 ELSE 0 END +  
CASE WHEN DIAG_1_CD  <> '' THEN 1 ELSE 0 END +  
CASE WHEN DIAG_2_CD  <> '' THEN 1 ELSE 0 END +                     
CASE WHEN DIAG_3_CD  <> '' THEN 1 ELSE 0 END +                    
CASE WHEN DIAG_4_CD  <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_5_CD  <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_6_CD  <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_7_CD  <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_8_CD  <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_9_CD  <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_10_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_11_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_12_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_13_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_14_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_15_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_16_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_17_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_18_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_19_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_20_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_21_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_22_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_23_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_24_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_25_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_26_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_27_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_28_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_29_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_30_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_31_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_32_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_33_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_34_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_35_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_36_CD <> '' THEN 1 ELSE 0 END +                   
CASE WHEN DIAG_37_CD <> '' THEN 1 ELSE 0 END 
)DIAG_COUNT
FROM $CMS_MAO_DTL_TBL

 WHERE ENCNTR_TYPE_SWCH_CD IN ('7') 
  AND  ICN_LNK_TO_ID IN ( SELECT ENCNTR_ICN_ID FROM $CMS_MAO_DTL_TBL WHERE ENCNTR_TYPE_SWCH_CD IN ('1','3','4') ) GROUP BY 1,2,3,4
) SML_TYPE_7_DAIG_COUNT  

CROSS JOIN WORK_TRNSFRM_LOAD_LOG LL
GROUP BY 1,2,3,6;

 /***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$ETL_TEMP_SR_RISKADJ','WORK_VOID_RPLCING_ENCNTR','N',RTRN_CD,RTRN_CNT,MSG);
/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/
/*
CREATE VOLATILE TABLE VT_VOID_REPLCING_IND
(
   ORIG_ENCNTR_ICN_ID VARCHAR ( 44 ) NOT NULL,
   CMS_CNTRCT_NBR CHAR ( 5 ) NOT NULL , 
   CMS_MBR_HIC_NBR_ID VARCHAR ( 20 ) NOT NULL ,
   REPLCING_ENCNTR_ICN_ID VARCHAR ( 44 ) NOT NULL,
   REPLACING_FLG CHAR(1) NOT NULL,
   TRNSFRM_LOAD_LOG_KEY BIGINT
)
PRIMARY INDEX (CMS_CNTRCT_NBR , ORIG_ENCNTR_ICN_ID , CMS_MBR_HIC_NBR_ID ,REPLCING_ENCNTR_ICN_ID, REPLACING_FLG)
ON COMMIT PRESERVE ROWS;
*/
/****************************************************************************************************************/
/*.IF ERRORCODE <> 0 THEN .GOTO ERRORS */
/****************************************************************************************************************/

/* IDENTIFICATION OF VOID RECORDS */

INSERT INTO WORK_VOID_REPLCING_IND
(
ORIG_ENCNTR_ICN_ID,
REPLCING_ENCNTR_ICN_ID,
CMS_CNTRCT_NBR,
CMS_MBR_HIC_NBR_ID,
REPLACING_FLG,
TRNSFRM_LOAD_LOG_KEY
)
SELECT 
        ORIG.ORIG_ENCNTR_ICN_ID, 
        RPLCING.REPLCING_ENCNTR_ICN_ID,
        ORIG.CMS_CNTRCT_NBR,
        ORIG.CMS_MBR_HIC_NBR_ID,        
        CASE WHEN ORIG.DIAG_COUNT  = RPLCING.DIAG_COUNT 
             THEN 'Y' 
             ELSE 'N' 
           END AS REPLACING_FLG,
        ORIG.TRNSFRM_LOAD_LOG_KEY 
             FROM WORK_VOID_ORIGINAL_ENCNTR ORIG 
       INNER JOIN WORK_VOID_RPLCING_ENCNTR RPLCING 
               ON ORIG.ORIG_ENCNTR_ICN_ID = RPLCING.ORIG_ENCNTR_ICN_ID
              AND ORIG.CMS_CNTRCT_NBR = RPLCING.CMS_CNTRCT_NBR
              AND ORIG.CMS_MBR_HIC_NBR_ID = RPLCING.CMS_MBR_HIC_NBR_ID
;


 /***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$ETL_TEMP_SR_RISKADJ','WORK_VOID_REPLCING_IND','N',RTRN_CD,RTRN_CNT,MSG);
/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/

/* updates target table CMS_MAO_004_TRNSFRM, if there are multiple Type-7 encounters matching to an original encounter, will update only those Type-7 records except the maximum */
 
UPDATE TRNSFRM
  FROM $MAO_004_DTL_TRNSFRM TRNSFRM,  
        (SELECT 
            TYPE_7.ORIG_ENCNTR_ICN_ID,    
            TYPE_7.REPLCING_ENCNTR_ICN_ID,
            TYPE_7.CMS_CNTRCT_NBR,
            TYPE_7.CMS_MBR_HIC_NBR_ID,
            DTL.CMS_RUN_DT_TXT,
            CASE WHEN TRIM(DTL.CMS_RUN_DT_TXT) IS NULL
                      THEN CAST ('1111-01-01' AS DATE FORMAT 'YYYY-MM-DD') 
                 WHEN TRIM(DTL.CMS_RUN_DT_TXT) = ''
                      THEN CAST('11110101' AS DATE FORMAT 'YYYYMMDD')
                 WHEN (TRIM(DTL.CMS_RUN_DT_TXT) IS NOT NULL AND WORK_CAL_TMP_RUN_DT.YEAR_MNTH_DAY_NBR IS NULL)
                      THEN CAST('11110101' AS DATE FORMAT 'YYYYMMDD')
                 ELSE CAST (DTL.CMS_RUN_DT_TXT AS DATE FORMAT 'YYYYMMDD')
                 END AS CMS_RUN_DT,
            TYPE_7.TRNSFRM_LOAD_LOG_KEY
           FROM WORK_VOID_REPLCING_IND TYPE_7 
				   INNER JOIN $CMS_MAO_DTL_TBL DTL
                   ON TYPE_7.REPLCING_ENCNTR_ICN_ID = DTL.ENCNTR_ICN_ID
                  AND TYPE_7.CMS_CNTRCT_NBR = DTL.CMS_CNTRCT_NBR
                  AND TYPE_7.CMS_MBR_HIC_NBR_ID = DTL.CMS_MBR_HIC_NBR_ID
            LEFT JOIN WORK_CAL_TMP  WORK_CAL_TMP_RUN_DT 
                  ON  CMS_RUN_DT_TXT = WORK_CAL_TMP_RUN_DT.YEAR_MNTH_DAY_NBR    
          ) SML_RPLCD        
 SET REPLCD_IND = 'Y'
,REPLCD_BY_ENCNTR_ICN_ID = SML_RPLCD.REPLCING_ENCNTR_ICN_ID
,REPLCD_RPT_DT_TXT = SML_RPLCD.CMS_RUN_DT_TXT
,REPLCD_RPT_DT =SML_RPLCD.CMS_RUN_DT
,UPDTD_LOAD_LOG_KEY = SML_RPLCD.TRNSFRM_LOAD_LOG_KEY

WHERE TRNSFRM.ICN_LNK_TO_ID = SML_RPLCD.ORIG_ENCNTR_ICN_ID
AND TRNSFRM.ENCNTR_ICN_ID <> SML_RPLCD.REPLCING_ENCNTR_ICN_ID
AND TRNSFRM.CMS_CNTRCT_NBR = SML_RPLCD.CMS_CNTRCT_NBR
AND TRNSFRM.CMS_MBR_HIC_NBR_ID = SML_RPLCD.CMS_MBR_HIC_NBR_ID
AND TRNSFRM.ENCNTR_TYPE_SWCH_CD= '7';


/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','REPLCD_BY_ENCNTR_ICN_ID','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','REPLCD_RPT_DT_TXT','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','REPLCD_RPT_DT','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','UPDTD_LOAD_LOG_KEY','N',RTRN_CD,RTRN_CNT,MSG);
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/

/* update the target table, CMS_MAO_004_TRNSFRM, will update Type-7 records that have fully voided orig-inal encounters (Type-1, 3, 4),*/
/* based on diagnosis-code-count match of the Volatile table, WORK_VOID_REPLCING_IND.That will include both single Type-7 encounter, and multiple Type-7 encounters that are used to void an original encounter.*/
UPDATE TRNSFRM
  FROM $MAO_004_DTL_TRNSFRM TRNSFRM,
        (SELECT 
            ORIG_ENCNTR_ICN_ID,    
            REPLCING_ENCNTR_ICN_ID,
            CMS_CNTRCT_NBR,
            CMS_MBR_HIC_NBR_ID,
            TRNSFRM_LOAD_LOG_KEY             
            FROM WORK_VOID_REPLCING_IND TYPE_7  WHERE REPLACING_FLG = 'Y' ) SML_RPLCD        
  SET REPLCD_IND = 'Y'
     ,UPDTD_LOAD_LOG_KEY =SML_RPLCD.TRNSFRM_LOAD_LOG_KEY
WHERE TRNSFRM.ICN_LNK_TO_ID = SML_RPLCD.ORIG_ENCNTR_ICN_ID
      AND TRNSFRM.ENCNTR_ICN_ID = SML_RPLCD.REPLCING_ENCNTR_ICN_ID
      AND TRNSFRM.CMS_CNTRCT_NBR= SML_RPLCD.CMS_CNTRCT_NBR
      AND TRNSFRM.CMS_MBR_HIC_NBR_ID=SML_RPLCD.CMS_MBR_HIC_NBR_ID
      AND TRNSFRM.ENCNTR_TYPE_SWCH_CD= '7';

/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/

CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','UPDTD_LOAD_LOG_KEY','N',RTRN_CD,RTRN_CNT,MSG);

/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/

/* target table, CMS_MAO_004_TRNSFRM is updated for those Type-7 encounters that partially voided origi-nal encounters (1, 3, and 4)*/

UPDATE TRNSFRM 
FROM $MAO_004_DTL_TRNSFRM TRNSFRM,
    ( SELECT 
        SML_RPLCD.ENCNTR_ICN_ID,
        SML_RPLCD.CMS_CNTRCT_NBR,
        SML_RPLCD.CMS_MBR_HIC_NBR_ID,
        SRC.ALW_DISALW_IND_CD AS ORIG_ALW_DISALW_IND_CD,
        LL.LOAD_LOG_KEY
         FROM $CMS_MAO_DTL_TBL SRC
                INNER JOIN $CMS_MAO_DTL_TBL SML_RPLCD 
                        ON SRC.ENCNTR_ICN_ID = SML_RPLCD.ICN_LNK_TO_ID
                       AND SRC.CMS_CNTRCT_NBR  = SML_RPLCD.CMS_CNTRCT_NBR
                       AND SRC.CMS_MBR_HIC_NBR_ID = SML_RPLCD.CMS_MBR_HIC_NBR_ID
                       AND SRC.ENCNTR_TYPE_SWCH_CD IN ( '1','3','4')
                       AND SML_RPLCD.ENCNTR_TYPE_SWCH_CD IN ('7')
                       
							 CROSS JOIN WORK_TRNSFRM_LOAD_LOG LL
     )SML_LINK_ENCNTR 
  SET ALW_DISALW_IND_CD = SML_LINK_ENCNTR.ORIG_ALW_DISALW_IND_CD,
      UPDTD_LOAD_LOG_KEY = SML_LINK_ENCNTR.LOAD_LOG_KEY
WHERE TRNSFRM.ENCNTR_ICN_ID = SML_LINK_ENCNTR.ENCNTR_ICN_ID
	AND  TRNSFRM.CMS_CNTRCT_NBR  = SML_LINK_ENCNTR.CMS_CNTRCT_NBR
	AND  TRNSFRM.CMS_MBR_HIC_NBR_ID = SML_LINK_ENCNTR.CMS_MBR_HIC_NBR_ID
	AND  TRNSFRM.ENCNTR_TYPE_SWCH_CD IN ( '7' );


/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/

CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','ALW_DISALW_IND_CD','N',RTRN_CD,RTRN_CNT,MSG);

/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/

CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','UPDTD_LOAD_LOG_KEY','N',RTRN_CD,RTRN_CNT,MSG);

/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/
/* CMS_MAO_004_TRNSFRM is updated for those Type-7 encounters whose ICN_LNK_TO_ID  matches  orig-inal encounters (1, 3, and 4) but not match CMS_MBR_HIC_NBR_ID with original encounters (1, 3, and 4)*/

UPDATE TRNSFRM 
    FROM $MAO_004_DTL_TRNSFRM TRNSFRM,  
 
    ( SELECT 
        SML_RPLCD.ENCNTR_ICN_ID,
        SML_RPLCD.CMS_CNTRCT_NBR,
        SML_RPLCD.CMS_MBR_HIC_NBR_ID,
        SML_RPLCD.CMS_RUN_DT_TXT,
        LL.LOAD_LOG_KEY
        FROM $CMS_MAO_DTL_TBL SRC
        INNER JOIN $CMS_MAO_DTL_TBL SML_RPLCD 
		            ON SRC.ENCNTR_ICN_ID = SML_RPLCD.ICN_LNK_TO_ID
		           AND SRC.CMS_CNTRCT_NBR  = SML_RPLCD.CMS_CNTRCT_NBR
		           AND SRC.CMS_MBR_HIC_NBR_ID <> SML_RPLCD.CMS_MBR_HIC_NBR_ID
		           AND SRC.ENCNTR_TYPE_SWCH_CD IN ( '1','3','4')
		           AND SML_RPLCD.ENCNTR_TYPE_SWCH_CD IN ('7')
		           
				CROSS JOIN WORK_TRNSFRM_LOAD_LOG LL
     )SML_NO_LINK 
    SET ENCNTR_LNK_TO_NOT_FND_IND = 'Y',
        UPDTD_LOAD_LOG_KEY = SML_NO_LINK.LOAD_LOG_KEY
  WHERE TRNSFRM.ENCNTR_ICN_ID = SML_NO_LINK.ENCNTR_ICN_ID
		AND TRNSFRM.CMS_CNTRCT_NBR  = SML_NO_LINK.CMS_CNTRCT_NBR
		AND TRNSFRM.CMS_MBR_HIC_NBR_ID = SML_NO_LINK.CMS_MBR_HIC_NBR_ID
		AND TRNSFRM.ENCNTR_TYPE_SWCH_CD IN ( '7' );
		
	/* END */
/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/

CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','ENCNTR_LNK_TO_NOT_FND_IND','N',RTRN_CD,RTRN_CNT,MSG);

/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/

CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','UPDTD_LOAD_LOG_KEY','N',RTRN_CD,RTRN_CNT,MSG);

/****************************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/****************************************************************************************************************/


/* MRDM 27814 - ADD PCN INFORMATION TO MAO-004  */


/***** Join MAO 004 and MAO002 based on Encounter ICN ID. Identify Encounter type  *********/

INSERT INTO WORK_MAO_004_TOTL
(
CMS_CNTRCT_NBR
,ENCNTR_ICN_ID
,CMS_MBR_HIC_NBR_ID
,THRU_SRVC_DT
,THRU_SRVC_DT_TXT
, THRU_SRVC_MNTH_YEAR_NBR
,DOS_YEAR_NBR
,CMS_PROCESSING_YEAR
,PLAN_ID
,MAO2_VNDR_ID
,LNGTH_PLAN_ID
,SBMTR_002_ID
,SBMSN_INT_NBR
,CMS_RUN_DT_IND
,ENCNTR_TYPE_SWCH_CD
,SCRTY_LVL_CD
)
SELECT
 MAO4T.CMS_CNTRCT_NBR
,MAO4T.ENCNTR_ICN_ID
,MAO4T.CMS_MBR_HIC_NBR_ID
,MAO4T.THRU_SRVC_DT
,MAO4T.THRU_SRVC_DT_TXT
,SUBSTR(MAO4T.THRU_SRVC_DT_TXT,1,6) AS  THRU_SRVC_MNTH_YEAR_NBR
, EXTRACT(YEAR FROM MAO4T.THRU_SRVC_DT)  AS DOS_YEAR_NBR
, EXTRACT(YEAR FROM MAO4T.CMS_RUN_DT) AS CMS_PROCESSING_YEAR
, MAO2.PLAN_ID AS PLAN_ID
,TRIM(STRTOK(MAO2.PLAN_ID, '_', 1)) AS MAO2_VNDR_ID
,LENGTH(TRIM(STRTOK(MAO2.PLAN_ID, '_', 1))) AS LNGTH_PLAN_ID
, CASE  WHEN SUBSTR(MAO2.SBMSN_INTRCHNG_NBR_TXT, 1, 1) = 'D' THEN SUBSTR(MAO2.SBMSN_INTRCHNG_NBR_TXT, 1, 6) 
        WHEN SUBSTR(MAO2.SBMSN_INTRCHNG_NBR_TXT, 1, 1) = 'E' THEN SUBSTR(MAO2.SBMSN_INTRCHNG_NBR_TXT, 1, 7) 
        ELSE '' 
  END   AS SBMTR_002_ID
, CASE  WHEN SUBSTR(MAO2.SBMSN_INTRCHNG_NBR_TXT, 1, 1) = 'D' THEN SUBSTR(MAO2.SBMSN_INTRCHNG_NBR_TXT, 7, 9) 
        WHEN SUBSTR(MAO2.SBMSN_INTRCHNG_NBR_TXT, 1, 1) = 'E' THEN SUBSTR(MAO2.SBMSN_INTRCHNG_NBR_TXT, 8, 9) 
        ELSE '' 
  END AS  SBMSN_INT_NBR  /* used to identify caremore pass through files */
, CASE  WHEN MAO2.CMS_RUN_DT_TXT > '20150611' THEN 'Y'
        ELSE 'N'
  END   AS CMS_RUN_DT_IND   /* Used to identify CareMore pass through files */
, CASE  WHEN MAO4T.ENCNTR_TYPE_SWCH_CD = '1' THEN '1_ENCNTR'   /* Encounter */
        WHEN MAO4T.ENCNTR_TYPE_SWCH_CD = '2' THEN '2_VOID_TO_ENCNTR'
        WHEN MAO4T.ENCNTR_TYPE_SWCH_CD = '3' THEN '3_RPLCMNT_TO_ENCNTR'
        WHEN MAO4T.ENCNTR_TYPE_SWCH_CD = '4' THEN '4_CR_ADD' /* Chart review */
        WHEN MAO4T.ENCNTR_TYPE_SWCH_CD = '5' THEN '5_VOID_TO_CR_ADD'
        WHEN MAO4T.ENCNTR_TYPE_SWCH_CD = '6' THEN '6_RPLCMNT_TO_CR_ADD'
        WHEN MAO4T.ENCNTR_TYPE_SWCH_CD = '7' THEN '7_CR_DLT'
        WHEN MAO4T.ENCNTR_TYPE_SWCH_CD = '8' THEN '8_VOID_TO_CR_DLT'
        WHEN MAO4T.ENCNTR_TYPE_SWCH_CD = '9' THEN '9_RPLCMNT_TO_CR_DLT'
        ELSE ''
    END    AS ENCNTR_TYPE_SWCH_CD
,MAO4T.SCRTY_LVL_CD AS SCRTY_LVL_CD
FROM  CMS_MAO_004_TRNSFRM MAO4T
INNER JOIN WORK_TRNSFRM_LOAD_LOG LLK
ON MAO4T.TRNSFRM_LOAD_LOG_KEY = LLK.LOAD_LOG_KEY
LEFT JOIN SRC_CMS_MAO_002_DTL MAO2 
ON  MAO2.ENCNTR_ICN_ID = MAO4T.ENCNTR_ICN_ID
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16;

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_MAO_004_TOTL','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***********************************************************************************************************/

/************** Categorize  records ****************/

INSERT INTO WORK_MAO_004_PCN_CTGRY
(
 ENCNTR_ICN_ID
,ENCNTR_TYPE_SWCH_CD
,PCN_CTGRY_CD
)
SELECT
 ENCNTR_ICN_ID
,ENCNTR_TYPE_SWCH_CD
,CASE WHEN CMS_CNTRCT_NBR IN ('H3421', 'H4738', 'H5427', 'H5594', 'H8170')  THEN '1_AFC'
      WHEN CMS_CNTRCT_NBR = 'H5431'  THEN '2_HS'  
      WHEN SBMTR_002_ID = 'ENH0544'  THEN '3_CAREMORE'
      WHEN SBMTR_002_ID = 'ENH0540' AND CMS_RUN_DT_IND = 'Y' AND SUBSTR(SBMSN_INT_NBR,6,1) = '2'  
      		 THEN  '3_CAREMORE' /* PASS-THRU FILES */ 
      WHEN SBMTR_002_ID = 'ENH5471' 
           THEN '4_SMPLY_SUBMISSION'
      WHEN SBMTR_002_ID IN ( 'ENH0540', 'ENH5817' )
        THEN '5_ENCCARE/EDIFECS'
      WHEN SBMTR_002_ID = 'ENH3655'
        THEN '6_SNR_RISK'
      WHEN SBMTR_002_ID  LIKE 'D%'
        THEN '7_DUALS'
      WHEN PLAN_ID IS NULL
        THEN '8_TBD_NoMatching002'
      ELSE SBMTR_002_ID
        END AS PCN_CTGRY_CD
FROM WORK_MAO_004_TOTL
GROUP BY 1,2,3;

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_MAO_004_PCN_CTGRY','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***********************************************************************************************************/

 /* Extract records from PCN_SRC_CTGRY_XWALK */
 
INSERT INTO WORK_PCN_CTGRY_XWALK
(
PCN_GRPG_ID
,DS_CD
,DS_NM
,DS_CTGRY_1_TXT
,DS_CTGRY_2_TXT
)
SELECT
PCN_GRPG_ID
,DS_CD
,DS_NM
,DS_CTGRY_1_TXT
,DS_CTGRY_2_TXT
FROM PCN_SRC_CTGRY_XWALK
GROUP BY 1,2,3,4,5;

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_PCN_CTGRY_XWALK','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***********************************************************************************************************/
/* Assign PCN_GRPG_ID for Category 1,2,3,4  */
	
INSERT INTO WORK_MAO_004_CTGRY_1TO4
(
ENCNTR_ICN_ID
,ENCNTR_TYPE_SWCH_CD
,PCN_CTGRY_CD
,PCN_GRPG_ID
)
SELECT 
ENCNTR_ICN_ID
,ENCNTR_TYPE_SWCH_CD
,PCN_CTGRY_CD
, CASE WHEN  PCN_CTGRY_CD= '1_AFC' THEN 'UNK'
       WHEN PCN_CTGRY_CD='2_HS' THEN 'HV'
       WHEN PCN_CTGRY_CD='3_CAREMORE' THEN 'EE'
       WHEN PCN_CTGRY_CD='4_SMPLY_SUBMISSION' THEN 'FV' 
       ELSE 'UNK'
END AS PCN_GRPG_ID
FROM WORK_MAO_004_PCN_CTGRY
WHERE PCN_CTGRY_CD IN ( '1_AFC' ,'2_HS' ,'3_CAREMORE','4_SMPLY_SUBMISSION' ) ;

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_MAO_004_CTGRY_1TO4','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***********************************************************************************************************/
 /* Category 1,2,3,4 : Join above work table with WORK_PCN_CTGRY_XWALK and extract all PCN values */
 	
INSERT INTO WORK_MAO_004_PCN_FINL 
(
ENCNTR_ICN_ID
,PCN_CTGRY_CD
,ENCNTR_TYPE_SWCH_CD
,DS_NM
,DS_CTGRY_1_TXT
,DS_CTGRY_2_TXT
,DS_CD
,PCN_KEY
,VNDR_NM
)
SELECT
 MAO.ENCNTR_ICN_ID
,MAO.PCN_CTGRY_CD
,MAO.ENCNTR_TYPE_SWCH_CD
,COALESCE(XWALK.DS_NM,'UNK' ) AS DS_NM
,COALESCE(XWALK.DS_CTGRY_1_TXT,'UNK' ) AS DS_CTGRY_1_TXT
,COALESCE(XWALK.DS_CTGRY_2_TXT,'UNK' ) AS DS_CTGRY_2_TXT
,COALESCE(XWALK.DS_CD,'UNK' ) AS DS_CD
,COALESCE(XWALK.PCN_GRPG_ID,'UNK' )  AS PCN_KEY
,'NA' AS VNDR_NM
FROM WORK_MAO_004_CTGRY_1TO4 MAO
LEFT OUTER JOIN WORK_PCN_CTGRY_XWALK XWALK
ON MAO.PCN_GRPG_ID = XWALK.PCN_GRPG_ID
GROUP BY 1,2,3,4,5,6,7,8,9 ;

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_MAO_004_PCN_FINL','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***********************************************************************************************************/

/******** UPDATE TARGET TABLE  FOR CATEGORY 1,2,3 ,4 **********/

UPDATE TGT
FROM CMS_MAO_004_TRNSFRM TGT, WORK_MAO_004_PCN_FINL SRC , WORK_TRNSFRM_LOAD_LOG LLK
SET
 DS_NM= SRC.DS_NM
,DS_CTGRY_1_TXT  = SRC.DS_CTGRY_1_TXT
,DS_CTGRY_2_TXT  = SRC.DS_CTGRY_2_TXT
,DS_CD= SRC.DS_CD
,PCN_KEY= SRC.PCN_KEY
,VNDR_NM= SRC.VNDR_NM
WHERE TGT.ENCNTR_ICN_ID  = SRC.ENCNTR_ICN_ID
AND LLK.LOAD_LOG_KEY = TGT.TRNSFRM_LOAD_LOG_KEY
;

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','DS_NM','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','DS_CTGRY_1_TXT','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','DS_CTGRY_2_TXT','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','DS_CD','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','PCN_KEY','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','VNDR_NM','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/

/** CATEGORY 5,Encounter Type 1,2 and 3: join with EDPS_SBMSN_SKNY_CLM and identify CLM_SOR_CD 
    and assign PCN_GRPG_ID based on CLM_SOR_CD  **********/
	
INSERT WORK_MAO_004_CTGR5_123_CLMSRCD
(
 ENCNTR_ICN_ID
,PLAN_ID
,PCN_CTGRY_CD
,ENCNTR_TYPE_SWCH_CD
,CLM_SOR_CD
,PCN_GRPG_ID
) 
SELECT    
M.ENCNTR_ICN_ID,
M.PLAN_ID,
C.PCN_CTGRY_CD ,
M.ENCNTR_TYPE_SWCH_CD,
 SKNY.CLM_SOR_CD,
CASE WHEN SKNY.CLM_SOR_CD ='1104' THEN 'RSN' 
			WHEN SKNY.CLM_SOR_CD LIKE 'ODW_%' THEN 'DFL'
			WHEN SKNY.CLM_SOR_CD= 'VLM' THEN 'DFL'
			ELSE 'DCU'
END AS PCN_GRPG_ID
FROM $ETL_TEMP_SR_RISKADJ.WORK_MAO_004_TOTL M
INNER JOIN $ETL_TEMP_SR_RISKADJ.WORK_MAO_004_PCN_CTGRY C 
	ON C.ENCNTR_ICN_ID = M.ENCNTR_ICN_ID
INNER JOIN EDPS_SBMSN_SKNY_CLM SKNY 
	ON SKNY.EDPS_CLM_ID = M.PLAN_ID
WHERE C.PCN_CTGRY_CD = '5_ENCCARE/EDIFECS'
  AND SKNY.EDPS_CD IN ( 'TRZT_ENCC' , 'EDIFECS')
  AND M.ENCNTR_TYPE_SWCH_CD IN ('1_ENCNTR','2_VOID_TO_ENCNTR','3_RPLCMNT_TO_ENCNTR')
GROUP BY 1,2,3,4,5,6;

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_MAO_004_CTGR5_123_CLMSRCD','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***********************************************************************************************************/

/** For all other records where the CLM_SOR_CD not in 1104, odw_% and VLM , assign 'DCU' AS PCN_GRPG_ID  **/
	
INSERT WORK_MAO_004_CTGR5_123_CLMSRCD
(
 ENCNTR_ICN_ID
,PLAN_ID
,PCN_CTGRY_CD
,ENCNTR_TYPE_SWCH_CD
,CLM_SOR_CD
,PCN_GRPG_ID
) 
SELECT 
M.ENCNTR_ICN_ID,
M.PLAN_ID,
C.PCN_CTGRY_CD,
M.ENCNTR_TYPE_SWCH_CD,
COALESCE(SKNY.CLM_SOR_CD,'UNK') AS CLM_SOR_CD,
'DCU' AS PCN_GRPG_ID 
FROM $ETL_TEMP_SR_RISKADJ.WORK_MAO_004_TOTL M
INNER JOIN $ETL_TEMP_SR_RISKADJ.WORK_MAO_004_PCN_CTGRY C 
ON C.ENCNTR_ICN_ID = M.ENCNTR_ICN_ID
LEFT JOIN EDPS_SBMSN_SKNY_CLM SKNY 
ON SKNY.EDPS_CLM_ID = M.PLAN_ID
WHERE C.PCN_CTGRY_CD = '5_ENCCARE/EDIFECS'
  AND M.ENCNTR_TYPE_SWCH_CD IN ('1_ENCNTR','2_VOID_TO_ENCNTR','3_RPLCMNT_TO_ENCNTR')
  AND SKNY.EDPS_CLM_ID IS NULL /* To get unmatched records */
GROUP BY 1,2,3,4,5,6;
/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_MAO_004_CTGR5_123_CLMSRCD','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***********************************************************************************************************/

DELETE FROM WORK_MAO_004_PCN_FINL;

/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***************** Error Handling ********************************/

/* Category 5, Encounter type 1,2 and 3: Join above work table with WORK_PCN_CTGRY_XWALK and extract all PCN values */
 
INSERT INTO WORK_MAO_004_PCN_FINL 
(
ENCNTR_ICN_ID
,PCN_CTGRY_CD
,ENCNTR_TYPE_SWCH_CD
,DS_NM
,DS_CTGRY_1_TXT
,DS_CTGRY_2_TXT
,DS_CD
,PCN_KEY
,VNDR_NM
)
SELECT
 MAO.ENCNTR_ICN_ID
,MAO.PCN_CTGRY_CD
,MAO.ENCNTR_TYPE_SWCH_CD
,COALESCE(XWALK.DS_NM,'UNK' ) AS DS_NM
,COALESCE(XWALK.DS_CTGRY_1_TXT,'UNK' ) AS DS_CTGRY_1_TXT
,COALESCE(XWALK.DS_CTGRY_2_TXT,'UNK' ) AS DS_CTGRY_2_TXT
,COALESCE(XWALK.DS_CD,'UNK' ) AS DS_CD
,COALESCE(XWALK.PCN_GRPG_ID,'UNK' )  AS PCN_KEY
,'NA' AS VNDR_NM
FROM WORK_MAO_004_CTGR5_123_CLMSRCD MAO
LEFT OUTER JOIN WORK_PCN_CTGRY_XWALK XWALK
ON MAO.PCN_GRPG_ID = XWALK.PCN_GRPG_ID
GROUP BY 1,2,3,4,5,6,7,8,9 ;

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_MAO_004_PCN_FINL','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***********************************************************************************************************/

/******** UPDATE TARGET TABLE  FOR CATEGORY 5 SWITCHES 1,2 AND 3  **********/

UPDATE TGT
FROM CMS_MAO_004_TRNSFRM TGT, WORK_MAO_004_PCN_FINL SRC , WORK_TRNSFRM_LOAD_LOG LLK
SET
 DS_NM= SRC.DS_NM
,DS_CTGRY_1_TXT  = SRC.DS_CTGRY_1_TXT
,DS_CTGRY_2_TXT  = SRC.DS_CTGRY_2_TXT
,DS_CD= SRC.DS_CD
,PCN_KEY= SRC.PCN_KEY
,VNDR_NM= SRC.VNDR_NM
WHERE TGT.ENCNTR_ICN_ID  = SRC.ENCNTR_ICN_ID
AND LLK.LOAD_LOG_KEY = TGT.TRNSFRM_LOAD_LOG_KEY
;

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','DS_NM','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','DS_CTGRY_1_TXT','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','DS_CTGRY_2_TXT','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','DS_CD','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','PCN_KEY','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','VNDR_NM','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/

/* Extract required data from BOT_PCN_LIST */
/*
CREATE  MULTISET VOLATILE TABLE  VT_BOT_PCN_LIST_MAO 
(
 EDPS_VNDR_ID VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
 PCN_SRC_ID  DECIMAL(5,2) ,
 PCN_PRFX_TXT VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC NOT NULL,
 RPTG_NM VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC)
PRIMARY INDEX ( PCN_PRFX_TXT )
ON COMMIT PRESERVE ROWS;
*/
/***********************************************************************************************************/
/*.IF ERRORCODE <> 0 THEN .GOTO ERRORS*/
/***********************************************************************************************************/

INSERT INTO WORK_BOT_PCN_LIST_MAO
(
EDPS_VNDR_ID ,
PCN_SRC_ID ,
PCN_PRFX_TXT , 
RPTG_NM 
) 
SELECT
EDPS_VNDR_ID ,
PCN_SRC_ID,
PCN_PRFX_TXT , 
RPTG_NM  
FROM BOT_PCN_LIST
/*WHERE PCN_PRFX_TXT NOT LIKE 'A%'
AND PCN_PRFX_TXT NOT IN ( 'RPBA', 'RPBB', 'RRB', 'RRGA', 'RRGB', 'RPSW', 'RROS', 'RRQ', 'GLD', 'FRQ
', 'GLV', 'GMV', 'GNV')
AND RPTG_NM NOT IN ('Advance Health', 'ComplexCare Solutions') */ /*Commented as part of MRDM-35778*/
GROUP BY 1,2,3,4;
 
/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_BOT_PCN_LIST_MAO','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***********************************************************************************************************/

/*
CREATE MULTISET VOLATILE TABLE VT_PCN_SRC_CTGRY_XWALK_new
     (
      PCN_PRFX_TXT VARCHAR(20) ,
      PCN_GRPG_ID CHAR(10),
      DS_CD_New  DECIMAL(5,2) ,
      DS_CD  CHAR(10) , 
      DS_NM VARCHAR(100) ,
      DS_CTGRY_1_TXT VARCHAR(50) ,
      DS_CTGRY_2_TXT VARCHAR(50)  )
PRIMARY INDEX ( PCN_PRFX_TXT  )
ON COMMIT PRESERVE ROWS;
*/

/***********************************************************************************************************/
/*.IF ERRORCODE <> 0 THEN .GOTO ERRORS */
/***********************************************************************************************************/

INSERT INTO WORK_PCN_SRC_CTGRY_XWALK_new
(PCN_PRFX_TXT,  PCN_GRPG_ID ,
     DS_CD_New,
      DS_CD,
      DS_NM,
      DS_CTGRY_1_TXT,
      DS_CTGRY_2_TXT )
SELECT
PCN_PRFX_TXT,  PCN_GRPG_ID ,
      CAST(DS_CD AS DECIMAL(5,2)) AS DS_CD_New,
      DS_CD,
      DS_NM,
      DS_CTGRY_1_TXT,
      DS_CTGRY_2_TXT 
      FROM  PCN_SRC_CTGRY_XWALK GROUP BY 1,2,3,4,5,6,7;
      
/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_PCN_SRC_CTGRY_XWALK_new','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***********************************************************************************************************/
INSERT INTO WORK_PCN_FIX_MAO02_VLM
(
EDPS_CD
,CLM_SOR_CD
,EDPS_CLM_NBR
,EDPS_CLM_ID
,ENCNTR_ICN_ID
,SEQ_NBR
,VNDR_ID
,PCN_KEY
)
SEL EDPS.EDPS_CD
,EDPS.CLM_SOR_CD
,EDPS.EDPS_CLM_NBR
,EDPS.EDPS_CLM_ID
,EDPS.ENCNTR_ICN_ID
,EX.SEQ_NBR
,EX.VNDR_ID
,EX.PCN_KEY


FROM CMS_MAO_002_TRNSFRM EDPS
INNER JOIN EDPS_VLM_CHRT_PCN_XWALK EX
ON EDPS.EDPS_CLM_ID = EX.EDPS_CLM_ID
WHERE EDPS.EDPS_CD IN ('TRZT_ENCC', 'EDIFECS') 
  AND EDPS.CLM_SOR_CD = 'CHART' 
GROUP BY 1,2,3,4,5,6,7,8;
 
 /***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_PCN_FIX_MAO02_VLM','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***********************************************************************************************************/ 
 
 /* Extract PCN values for Category 5 encounter type 5,6,7,8,9 records */
 
  
INSERT INTO WORK_PCN_FIX_MAO_004
(
 EDPS_CD , 
CLM_SOR_CD ,  
EDPS_CLM_NBR ,   
EDPS_CLM_ID ,  
ENCNTR_ICN_ID ,
SEQ_NBR ,
ENCNTR_TYPE_SWCH_CD ,
PCN_KEY , 
VNDR_ID , 
VNDR_NM ,
DS_CD , 
DS_NM , 
DS_CTGRY_1_TXT , 
DS_CTGRY_2_TXT 
)
SELECT  
EDPS.EDPS_CD
,EDPS.CLM_SOR_CD
,EDPS.EDPS_CLM_NBR
,EDPS.EDPS_CLM_ID
,MAO4.ENCNTR_ICN_ID
,EDPS.SEQ_NBR
,MAO4.ENCNTR_TYPE_SWCH_CD
,EDPS.PCN_KEY 
,EDPS.VNDR_ID
,PX1.RPTG_NM AS VNDR_NM
,PX2.DS_CD
,PX2.DS_NM
,PX2.DS_CTGRY_1_TXT
,PX2.DS_CTGRY_2_TXT

FROM WORK_PCN_FIX_MAO02_VLM EDPS
INNER JOIN CMS_MAO_004_TRNSFRM MAO4
  ON EDPS.ENCNTR_ICN_ID = MAO4.ENCNTR_ICN_ID
  AND MAO4.ENCNTR_TYPE_SWCH_CD IN ('4', '5', '6', '7', '8', '9')  
  AND MAO4.PCN_KEY <> 'EE'  
  AND MAO4.PCN_KEY <> 'FV'  
  
  INNER JOIN WORK_TRNSFRM_LOAD_LOG LLK
ON MAO4.TRNSFRM_LOAD_LOG_KEY = LLK.LOAD_LOG_KEY


INNER JOIN WORK_BOT_PCN_LIST_MAO PX1  
  ON EDPS.VNDR_ID = PX1.EDPS_VNDR_ID
  AND EDPS.PCN_KEY = PX1.PCN_PRFX_TXT 

INNER JOIN WORK_PCN_SRC_CTGRY_XWALK_NEW PX2 
  ON PX1.PCN_SRC_ID = PX2.DS_CD_NEW
  
  
  WHERE  MAO4.PCN_KEY <> EDPS.PCN_KEY 

     QUALIFY ROW_NUMBER () OVER (PARTITION BY   EDPS.CLM_SOR_CD, EDPS.EDPS_CLM_NBR, EDPS.EDPS_CLM_ID, EDPS.SEQ_NBR
       , MAO4.CMS_CNTRCT_NBR, MAO4.ENCNTR_TYPE_SWCH_CD
      , EDPS.VNDR_ID, MAO4.ENCNTR_ICN_ID, EDPS.PCN_KEY
       
      , MAO4.CMS_RUN_DT, MAO4.THRU_SRVC_DT ORDER BY  MAO4.THRU_SRVC_DT  DESC) =1 
;

 /***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_PCN_FIX_MAO_004','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***********************************************************************************************************/ 
/*Commented as part of MRDM-35778*/
/* Extract PCN values for Category 5 encounter type 5,6,7,8,9 records */

/*	
INSERT INTO WORK_MAO_004_CTGR_5_SWTCH_4TO9
(
 MAO2_VNDR_ID
,ENCNTR_ICN_ID
,PCN_CTGRY_CD
,ENCNTR_TYPE_SWCH_CD
,DS_NM
,DS_CTGRY_1_TXT
,DS_CTGRY_2_TXT
,DS_CD
,PCN_KEY
,VNDR_NM
) 
SELECT  
 M.MAO2_VNDR_ID 
,M.ENCNTR_ICN_ID AS ENCNTR_ICN_ID
,C.PCN_CTGRY_CD
,M.ENCNTR_TYPE_SWCH_CD
, CASE  WHEN MAO2_VNDR_ID IN ('86', '87') THEN 'Deletes'
        WHEN EDPS_VNDR_ID = '21' THEN 'Central Region Programs'
        WHEN EDPS_VNDR_ID = '24' THEN 'West Region Programs'
        WHEN EDPS_VNDR_ID = '80' THEN 'Verscend - Corporate and Regional Programs'
        WHEN EDPS_VNDR_ID IN ('9', '81') THEN 'Verscend'
        ELSE COALESCE(XWALK.DS_NM,'UNK')
    END AS DS_NM
, CASE  WHEN MAO2_VNDR_ID IN ('86', '87') THEN 'NA'
        ELSE COALESCE(XWALK.DS_CTGRY_1_TXT,'UNK')
    END AS DS_CTGRY_1_TXT  
, CASE  WHEN MAO2_VNDR_ID IN ('86', '87') THEN 'NA'
        ELSE COALESCE(XWALK.DS_CTGRY_2_TXT,'UNK')
    END AS DS_CTGRY_2_TXT  
, CASE  WHEN MAO2_VNDR_ID IN ('86', '87') THEN 'NA'
        ELSE COALESCE(XWALK.DS_CD,'UNK')  
    END AS DS_CD  
, CASE  WHEN MAO2_VNDR_ID IN ('86', '87') THEN 'NA'
        ELSE COALESCE(BOT.PCN_PRFX_TXT,'UNK')
    END AS PCN_KEY      
, CASE  WHEN MAO2_VNDR_ID IN ('86', '87') THEN 'NA'
        ELSE COALESCE(BOT.RPTG_NM,'UNK') 
    END AS VNDR_NM

FROM WORK_MAO_004_TOTL M

INNER JOIN WORK_MAO_004_PCN_CTGRY C 
 ON C.ENCNTR_ICN_ID = M.ENCNTR_ICN_ID
 
LEFT JOIN WORK_BOT_PCN_LIST_MAO BOT 
 ON BOT.EDPS_VNDR_ID = M.MAO2_VNDR_ID

LEFT JOIN WORK_PCN_SRC_CTGRY_XWALK_new  XWALK 
ON XWALK.DS_CD_New = BOT.PCN_SRC_ID 

WHERE M.ENCNTR_TYPE_SWCH_CD IN ( '4_CR_ADD','5_VOID_TO_CR_ADD','6_RPLCMNT_TO_CR_ADD','7_CR_DLT','8_VOID_TO_CR_DLT','9_RPLCMNT_TO_CR_DLT' )
  AND C.PCN_CTGRY_CD = '5_ENCCARE/EDIFECS'
  AND M.LNGTH_PLAN_ID  <= '3' 
GROUP BY 1,2,3,4,5,6,7,8,9,10;
*/
/***********************************************************************************************************/
/*.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_MAO_004_CTGR_5_SWTCH_4TO9','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS */
/***********************************************************************************************************/

/******** UPDATE TARGET TABLE  FOR CATEGORY 5 SWITCHES 4,5,6,7,8 AND 9 **********/
UPDATE TGT
FROM CMS_MAO_004_TRNSFRM TGT, WORK_PCN_FIX_MAO_004 SRC , WORK_TRNSFRM_LOAD_LOG LLK
SET
 DS_NM= SRC.DS_NM
,DS_CTGRY_1_TXT  = SRC.DS_CTGRY_1_TXT
,DS_CTGRY_2_TXT  = SRC.DS_CTGRY_2_TXT
,DS_CD= SRC.DS_CD
,PCN_KEY= SRC.PCN_KEY
,VNDR_NM= SRC.VNDR_NM
WHERE TGT.ENCNTR_ICN_ID  = SRC.ENCNTR_ICN_ID
AND LLK.LOAD_LOG_KEY = TGT.TRNSFRM_LOAD_LOG_KEY
;

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','DS_NM','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','DS_CTGRY_1_TXT','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','DS_CTGRY_2_TXT','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','DS_CD','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','PCN_KEY','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','VNDR_NM','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/
/* Category 6: Identify CLM_SOR_CD and assign PCN_GRPG_ID */

INSERT INTO WORK_MAO_004_CTGR_6_CLM_SRCD
(
ENCNTR_ICN_ID
,PLAN_ID
,PCN_CTGRY_CD
,ENCNTR_TYPE_SWCH_CD
,CLM_SOR_CD
,PCN_GRPG_ID
)
SELECT   
M.ENCNTR_ICN_ID,
M.PLAN_ID,
C.PCN_CTGRY_CD ,
M.ENCNTR_TYPE_SWCH_CD,
 SKNY.CLM_SOR_CD,
CASE WHEN SKNY.CLM_SOR_CD ='808' THEN 'RSI' 
			WHEN SKNY.CLM_SOR_CD = '809' THEN 'RSK'
			WHEN SKNY.CLM_SOR_CD= '823' THEN 'RSJ'
			ELSE 'DCU'
END AS PCN_GRPG_ID
FROM $ETL_TEMP_SR_RISKADJ.WORK_MAO_004_TOTL M
INNER JOIN $ETL_TEMP_SR_RISKADJ.WORK_MAO_004_PCN_CTGRY C 
 ON C.ENCNTR_ICN_ID = M.ENCNTR_ICN_ID
INNER JOIN EDPS_SBMSN_SKNY_CLM SKNY 
 ON SKNY.EDPS_CLM_ID = M.PLAN_ID
WHERE C.PCN_CTGRY_CD = '6_SNR_RISK'
  AND SKNY.EDPS_CD = 'SNR_RSK' 
GROUP BY 1,2,3,4,5,6;

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_MAO_004_CTGR_6_CLM_SRCD','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***********************************************************************************************************/
/* For all unmatched records, assign 'DCU' AS PCN_GRPG_ID */
	
INSERT INTO WORK_MAO_004_CTGR_6_CLM_SRCD
(
ENCNTR_ICN_ID
,PLAN_ID
,PCN_CTGRY_CD
,ENCNTR_TYPE_SWCH_CD
,CLM_SOR_CD
,PCN_GRPG_ID
)
SELECT    
M.ENCNTR_ICN_ID,
M.PLAN_ID,
C.PCN_CTGRY_CD ,
M.ENCNTR_TYPE_SWCH_CD,
COALESCE(SKNY.CLM_SOR_CD,'UNK') AS CLM_SOR_CD ,
'DCU' AS PCN_GRPG_ID
FROM $ETL_TEMP_SR_RISKADJ.WORK_MAO_004_TOTL M
INNER JOIN $ETL_TEMP_SR_RISKADJ.WORK_MAO_004_PCN_CTGRY C
 ON C.ENCNTR_ICN_ID = M.ENCNTR_ICN_ID
LEFT  JOIN EDPS_SBMSN_SKNY_CLM SKNY
 ON SKNY.EDPS_CLM_ID = M.PLAN_ID
WHERE C.PCN_CTGRY_CD = '6_SNR_RISK'
 AND SKNY.EDPS_CLM_ID IS NULL
GROUP BY 1,2,3,4,5,6 ;

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_MAO_004_CTGR_6_CLM_SRCD','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***********************************************************************************************************/

DELETE FROM WORK_MAO_004_PCN_FINL;

/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***************** Error Handling ********************************/

/* Category 6: Join above work table with WORK_PCN_CTGRY_XWALK and extract all PCN values */
 
 
INSERT INTO WORK_MAO_004_PCN_FINL 
(
ENCNTR_ICN_ID
,PCN_CTGRY_CD
,ENCNTR_TYPE_SWCH_CD
,DS_NM
,DS_CTGRY_1_TXT
,DS_CTGRY_2_TXT
,DS_CD
,PCN_KEY
,VNDR_NM
)
SELECT
 MAO.ENCNTR_ICN_ID
,MAO.PCN_CTGRY_CD
,MAO.ENCNTR_TYPE_SWCH_CD
,COALESCE(XWALK.DS_NM,'UNK' ) AS DS_NM
,COALESCE(XWALK.DS_CTGRY_1_TXT,'UNK' ) AS DS_CTGRY_1_TXT
,COALESCE(XWALK.DS_CTGRY_2_TXT,'UNK' ) AS DS_CTGRY_2_TXT
,COALESCE(XWALK.DS_CD,'UNK' ) AS DS_CD
,COALESCE(XWALK.PCN_GRPG_ID,'UNK' )  AS PCN_KEY
,'NA' AS VNDR_NM
FROM WORK_MAO_004_CTGR_6_CLM_SRCD MAO
LEFT OUTER JOIN WORK_PCN_CTGRY_XWALK XWALK
ON MAO.PCN_GRPG_ID = XWALK.PCN_GRPG_ID
GROUP BY 1,2,3,4,5,6,7,8,9 ;

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_MAO_004_PCN_FINL','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***********************************************************************************************************/

/******** UPDATE TARGET TABLE  FOR CATEGORY 6 **********/
	
UPDATE TGT
FROM CMS_MAO_004_TRNSFRM TGT, WORK_MAO_004_PCN_FINL SRC , WORK_TRNSFRM_LOAD_LOG LLK
SET
 DS_NM= SRC.DS_NM
,DS_CTGRY_1_TXT  = SRC.DS_CTGRY_1_TXT
,DS_CTGRY_2_TXT  = SRC.DS_CTGRY_2_TXT
,DS_CD= SRC.DS_CD
,PCN_KEY= SRC.PCN_KEY
,VNDR_NM= SRC.VNDR_NM
WHERE TGT.ENCNTR_ICN_ID  = SRC.ENCNTR_ICN_ID
AND LLK.LOAD_LOG_KEY = TGT.TRNSFRM_LOAD_LOG_KEY
;

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','DS_NM','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','DS_CTGRY_1_TXT','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','DS_CTGRY_2_TXT','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','DS_CD','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','PCN_KEY','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','VNDR_NM','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/
/* Category 7, Encounter type 1,2,3 : Identify CLM_SOR_CD and assign PCN_GRPG_ID */


INSERT INTO WORK_EDPS_SBMSN_CNT
(
EDPS_CD  ,  
EDPS_CLM_ID, 
CLM_SOR_CD_CNT
)
SELECT 
 EDPS_CD  ,  
 EDPS_CLM_ID, 
 COUNT(DISTINCT CLM_SOR_CD)  AS CLM_SOR_CD_CNT
 FROM  EDPS_SBMSN_SKNY_CLM skny
 WHERE  EDPS_CD = 'TRZT_DUALS' 
 GROUP BY 1,2;

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_EDPS_SBMSN_CNT','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***********************************************************************************************************/

INSERT INTO WORK_EDPS_SBMSN_MAO004
 (
 EDPS_CD  , 
 CLM_SOR_CD, 
 EDPS_CLM_ID,
 EDPS_SUBSTR_CLM_ID
 )
SELECT
SKNY.EDPS_CD  , 
SKNY.CLM_SOR_CD, 
SKNY.EDPS_CLM_ID,
SUBSTR(skny.EDPS_CLM_ID,4,LENGTH(skny.EDPS_CLM_ID)) AS EDPS_SUBSTR_CLM_ID
FROM EDPS_SBMSN_SKNY_CLM skny
INNER JOIN WORK_EDPS_SBMSN_CNT CN
ON CN.EDPS_CD = skny.EDPS_CD
AND CN.EDPS_CLM_ID = skny.EDPS_CLM_ID
AND CLM_SOR_CD_CNT=1
WHERE  skny.EDPS_CD = 'TRZT_DUALS'
GROUP BY 1,2,3,4
;

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_EDPS_SBMSN_MAO004','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/

INSERT INTO WORK_MAO_004_CTGR7
(
CLM_SOR_CD
,ENCNTR_ICN_ID
,PCN_CTGRY_CD
,ENCNTR_TYPE_SWCH_CD
)

SELECT skny.CLM_SOR_CD,  m.ENCNTR_ICN_ID ,c.PCN_CTGRY_CD ,m.ENCNTR_TYPE_SWCH_CD
FROM WORK_MAO_004_TOTL m
INNER JOIN  WORK_MAO_004_PCN_CTGRY c ON c.ENCNTR_ICN_ID = m.ENCNTR_ICN_ID
INNER JOIN WORK_EDPS_SBMSN_MAO004 skny  ON skny.EDPS_SUBSTR_CLM_ID = m.PLAN_ID
WHERE c.PCN_CTGRY_CD = '7_DUALS'
  AND skny.EDPS_CD = 'TRZT_DUALS'
  AND skny.CLM_SOR_CD IN ('ASH', 'Beacon', 'LCare', 'Vision') 
  AND m.ENCNTR_TYPE_SWCH_CD IN ('1_ENCNTR', '2_VOID_TO_ENCNTR', '3_RPLCMNT_TO_ENCNTR')
GROUP BY 1,2,3,4

UNION

SELECT skny.CLM_SOR_CD, m.ENCNTR_ICN_ID ,c.PCN_CTGRY_CD ,m.ENCNTR_TYPE_SWCH_CD
FROM WORK_MAO_004_TOTL m
INNER JOIN  WORK_MAO_004_PCN_CTGRY c ON c.ENCNTR_ICN_ID = m.ENCNTR_ICN_ID
INNER JOIN WORK_EDPS_SBMSN_MAO004 skny  ON skny.EDPS_CLM_ID = m.PLAN_ID
WHERE c.PCN_CTGRY_CD = '7_DUALS'
  AND skny.EDPS_CD = 'TRZT_DUALS'
  AND m.ENCNTR_TYPE_SWCH_CD IN ('1_ENCNTR', '2_VOID_TO_ENCNTR', '3_RPLCMNT_TO_ENCNTR')
GROUP BY 1,2,3,4;

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_MAO_004_CTGR7','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/
/*
CREATE VOLATILE TABLE  VT_DISNT_SOR_CD_CNT   
( ENCNTR_ICN_ID VARCHAR(44) ,
	SOR_CD_CNT INTEGER
)PRIMARY INDEX (ENCNTR_ICN_ID)
ON COMMIT PRESERVE ROWS;
*/
/***********************************************************************************************************/
/*.IF ERRORCODE <> 0 THEN .GOTO ERRORS*/
/***********************************************************************************************************/
INSERT INTO WORK_DISNT_SOR_CD_CNT
(ENCNTR_ICN_ID
,SOR_CD_CNT
)
SEL 
ENCNTR_ICN_ID,
COUNT(DISTINCT CLM_SOR_CD ) AS SOR_CD_CNT 
FROM WORK_MAO_004_CTGR7 GROUP BY 1;

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_DISNT_SOR_CD_CNT','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/

INSERT INTO WORK_MAO_004_CTGR7_CLM_SRCD
(
CLM_SOR_CD
,ENCNTR_ICN_ID
,PCN_CTGRY_CD
,ENCNTR_TYPE_SWCH_CD
,PCN_GRPG_ID
)
SELECT 
WRK.CLM_SOR_CD,  
WRK.ENCNTR_ICN_ID ,
WRK.PCN_CTGRY_CD ,
WRK.ENCNTR_TYPE_SWCH_CD,
CASE WHEN  CLM_SOR_CD=  '1104' THEN 'RSN'
			WHEN  CLM_SOR_CD IN ('ASH', 'Aspire', 'Dental', 'LCare', 'Pharmacy','PROF', 'Vision') THEN 'DFL'
			WHEN  CLM_SOR_CD IN ('DoC', 'NCPN', 'PMG','Beacon','Caremore') THEN 'CFL'
			ELSE 'DCU'
		END AS PCN_GRPG_ID
FROM WORK_MAO_004_CTGR7 WRK
INNER JOIN WORK_DISNT_SOR_CD_CNT VT
ON VT.ENCNTR_ICN_ID = WRK.ENCNTR_ICN_ID
AND SOR_CD_CNT=1
GROUP BY 1,2,3,4,5;


/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_MAO_004_CTGR7_CLM_SRCD','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***********************************************************************************************************/
/* For all unmatched records, assign 'DCU'  AS PCN_GRPG_ID */
INSERT INTO WORK_MAO_004_CTGR7_CLM_SRCD
(
CLM_SOR_CD
,ENCNTR_ICN_ID
,PCN_CTGRY_CD
,ENCNTR_TYPE_SWCH_CD
,PCN_GRPG_ID
)
SELECT 
'UNK' AS CLM_SOR_CD,  
M.ENCNTR_ICN_ID ,
C.PCN_CTGRY_CD ,
M.ENCNTR_TYPE_SWCH_CD,
'DCU'  AS PCN_GRPG_ID
FROM WORK_MAO_004_TOTL M
INNER JOIN  WORK_MAO_004_PCN_CTGRY C 
ON C.ENCNTR_ICN_ID = M.ENCNTR_ICN_ID
LEFT JOIN WORK_MAO_004_CTGR7_CLM_SRCD WRK
ON WRK.ENCNTR_ICN_ID = M.ENCNTR_ICN_ID
WHERE C.PCN_CTGRY_CD = '7_DUALS'
AND M.ENCNTR_TYPE_SWCH_CD IN ('1_ENCNTR', '2_VOID_TO_ENCNTR', '3_RPLCMNT_TO_ENCNTR')
AND WRK.ENCNTR_ICN_ID IS NULL
;
/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_MAO_004_CTGR7_CLM_SRCD','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***********************************************************************************************************/

/* Category 7  Switches 4,5,6,7,8,9 : Assign 'DYZ'  AS PCN_GRPG_ID    */

INSERT INTO WORK_MAO_004_CTGR7_CLM_SRCD
(
CLM_SOR_CD
,ENCNTR_ICN_ID
,PCN_CTGRY_CD
,ENCNTR_TYPE_SWCH_CD
,PCN_GRPG_ID
)
SELECT 
'UNK' as CLM_SOR_CD,  
M.ENCNTR_ICN_ID ,
C.PCN_CTGRY_CD ,
M.ENCNTR_TYPE_SWCH_CD,
'DYZ'  AS PCN_GRPG_ID 
FROM WORK_MAO_004_TOTL M
INNER JOIN  WORK_MAO_004_PCN_CTGRY C 
ON C.ENCNTR_ICN_ID = M.ENCNTR_ICN_ID
WHERE M.ENCNTR_TYPE_SWCH_CD IN ( '4_CR_ADD', '5_VOID_TO_CR_ADD', '6_RPLCMNT_TO_CR_ADD', '7_CR_DLT', '8_VOID_TO_CR_DLT', '9_RPLCMNT_TO_CR_DLT')
  AND C.PCN_CTGRY_CD = '7_DUALS'
;

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_MAO_004_CTGR7_CLM_SRCD','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***********************************************************************************************************/

DELETE FROM WORK_MAO_004_PCN_FINL;

/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***************** Error Handling ********************************/

/* Category 7: Join above work table with WORK_PCN_CTGRY_XWALK and extract all PCN values */
 
INSERT INTO WORK_MAO_004_PCN_FINL 
(
ENCNTR_ICN_ID
,PCN_CTGRY_CD
,ENCNTR_TYPE_SWCH_CD
,DS_NM
,DS_CTGRY_1_TXT
,DS_CTGRY_2_TXT
,DS_CD
,PCN_KEY
,VNDR_NM
)
SELECT
 MAO.ENCNTR_ICN_ID
,MAO.PCN_CTGRY_CD
,MAO.ENCNTR_TYPE_SWCH_CD
,COALESCE(XWALK.DS_NM,'UNK' ) AS DS_NM
,COALESCE(XWALK.DS_CTGRY_1_TXT,'UNK' ) AS DS_CTGRY_1_TXT
,COALESCE(XWALK.DS_CTGRY_2_TXT,'UNK' ) AS DS_CTGRY_2_TXT
,COALESCE(XWALK.DS_CD,'UNK' ) AS DS_CD
,COALESCE(XWALK.PCN_GRPG_ID,'UNK' )  AS PCN_KEY
,'NA' AS VNDR_NM
FROM WORK_MAO_004_CTGR7_CLM_SRCD MAO
LEFT OUTER JOIN WORK_PCN_CTGRY_XWALK XWALK
ON MAO.PCN_GRPG_ID = XWALK.PCN_GRPG_ID
GROUP BY 1,2,3,4,5,6,7,8,9 ;

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_MAO_004_PCN_FINL','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***********************************************************************************************************/
UPDATE TGT
FROM CMS_MAO_004_TRNSFRM TGT, WORK_MAO_004_PCN_FINL SRC , WORK_TRNSFRM_LOAD_LOG LLK
SET
 DS_NM= SRC.DS_NM
,DS_CTGRY_1_TXT  = SRC.DS_CTGRY_1_TXT
,DS_CTGRY_2_TXT  = SRC.DS_CTGRY_2_TXT
,DS_CD= SRC.DS_CD
,PCN_KEY= SRC.PCN_KEY
,VNDR_NM= SRC.VNDR_NM
WHERE TGT.ENCNTR_ICN_ID  = SRC.ENCNTR_ICN_ID
AND LLK.LOAD_LOG_KEY = TGT.TRNSFRM_LOAD_LOG_KEY
;

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','DS_NM','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','DS_CTGRY_1_TXT','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','DS_CTGRY_2_TXT','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','DS_CD','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','PCN_KEY','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','VNDR_NM','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/
INSERT INTO WORK_PCN_FIX_VLM_TEMP
(
VNDR_ID
,PCN_KEY
,SEQ_NBR
)
SEL VNDR_ID
,PCN_KEY
,CAST(TRIM(SEQ_NBR) AS VARCHAR(50)) AS   SEQ_NBR
FROM EDPS_VLM_CHRT_PCN_XWALK
GROUP BY 1,2,3
;

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_PCN_FIX_VLM_TEMP','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***********************************************************************************************************/
DELETE FROM WORK_PCN_FIX_MAO02_VLM;
/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***********************************************************************************************************/
INSERT INTO WORK_PCN_FIX_MAO02_VLM 
(
EDPS_CD
,CLM_SOR_CD
,EDPS_CLM_NBR
,EDPS_CLM_ID
,ENCNTR_ICN_ID
,SEQ_NBR
,VNDR_ID
,PCN_KEY
)

SEL  EDPS.EDPS_CD
,EDPS.CLM_SOR_CD
,EDPS.EDPS_CLM_NBR
,EDPS.EDPS_CLM_ID
,EDPS.ENCNTR_ICN_ID
,CAST(EX.SEQ_NBR AS INTEGER) AS SEQ_NBR
,EX.VNDR_ID
,EX.PCN_KEY


FROM CMS_MAO_002_TRNSFRM EDPS
INNER JOIN WORK_PCN_FIX_VLM_TEMP EX
ON EDPS.EDPS_CLM_ID = EX.SEQ_NBR
WHERE EDPS.EDPS_CD = 'TRZT_DUALS'  
  AND EDPS.CLM_SOR_CD = 'CHART'  
  GROUP BY 1,2,3,4,5,6,7,8
;


/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_PCN_FIX_MAO02_VLM','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***********************************************************************************************************/
DELETE FROM WORK_PCN_FIX_MAO_004;
/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***********************************************************************************************************/
INSERT INTO WORK_PCN_FIX_MAO_004
(
 EDPS_CD , 
CLM_SOR_CD ,  
EDPS_CLM_NBR ,   
EDPS_CLM_ID ,  
ENCNTR_ICN_ID ,
SEQ_NBR ,
ENCNTR_TYPE_SWCH_CD ,
PCN_KEY , 
VNDR_ID , 
VNDR_NM ,
DS_CD , 
DS_NM , 
DS_CTGRY_1_TXT , 
DS_CTGRY_2_TXT 
)
SELECT  
EDPS.EDPS_CD
,EDPS.CLM_SOR_CD
,EDPS.EDPS_CLM_NBR
,EDPS.EDPS_CLM_ID
,MAO4.ENCNTR_ICN_ID
,EDPS.SEQ_NBR
,MAO4.ENCNTR_TYPE_SWCH_CD
,EDPS.PCN_KEY 
,EDPS.VNDR_ID
,PX1.RPTG_NM AS VNDR_NM
,PX2.DS_CD
,PX2.DS_NM
,PX2.DS_CTGRY_1_TXT
,PX2.DS_CTGRY_2_TXT

FROM WORK_PCN_FIX_MAO02_VLM EDPS

INNER JOIN CMS_MAO_004_TRNSFRM MAO4
  ON EDPS.ENCNTR_ICN_ID = MAO4.ENCNTR_ICN_ID
  AND MAO4.DS_NM IN ('EDPS ONLY PROGRAM DATA DUALS')

INNER JOIN WORK_TRNSFRM_LOAD_LOG LLK
ON MAO4.TRNSFRM_LOAD_LOG_KEY = LLK.LOAD_LOG_KEY


INNER JOIN WORK_BOT_PCN_LIST_MAO PX1  
  ON EDPS.VNDR_ID = PX1.EDPS_VNDR_ID
  AND EDPS.PCN_KEY = PX1.PCN_PRFX_TXT 

INNER JOIN WORK_PCN_SRC_CTGRY_XWALK_NEW PX2 
  ON PX1.PCN_SRC_ID = PX2.DS_CD_NEW
 

QUALIFY ROW_NUMBER () OVER (PARTITION BY  EDPS.EDPS_CD, EDPS.CLM_SOR_CD, EDPS.EDPS_CLM_NBR, EDPS.EDPS_CLM_ID,  EDPS.SEQ_NBR
       , MAO4.CMS_CNTRCT_NBR, MAO4.ENCNTR_TYPE_SWCH_CD
      , EDPS.VNDR_ID, MAO4.ENCNTR_ICN_ID, EDPS.PCN_KEY
       
      , MAO4.CMS_RUN_DT, MAO4.THRU_SRVC_DT ORDER BY  MAO4.THRU_SRVC_DT  DESC) =1
 ;
/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_PCN_FIX_MAO_004','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***********************************************************************************************************/
/******** UPDATE TARGET TABLE  FOR CATEGORY 7 **********/
UPDATE TGT
FROM CMS_MAO_004_TRNSFRM TGT, WORK_PCN_FIX_MAO_004 SRC , WORK_TRNSFRM_LOAD_LOG LLK
SET
 DS_NM= SRC.DS_NM
,DS_CTGRY_1_TXT  = SRC.DS_CTGRY_1_TXT
,DS_CTGRY_2_TXT  = SRC.DS_CTGRY_2_TXT
,DS_CD= SRC.DS_CD
,PCN_KEY= SRC.PCN_KEY
,VNDR_NM= SRC.VNDR_NM
WHERE TGT.ENCNTR_ICN_ID  = SRC.ENCNTR_ICN_ID
AND LLK.LOAD_LOG_KEY = TGT.TRNSFRM_LOAD_LOG_KEY
;

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','DS_NM','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','DS_CTGRY_1_TXT','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','DS_CTGRY_2_TXT','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','DS_CD','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','PCN_KEY','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','VNDR_NM','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/
/* Extract records from SRC_CMS_MBR_RSTTD_MNTHLY and identify Current HICN */
INSERT INTO WORK_MBR_RSTTD_MNTHLY_DTL
(
 CMS_CNTRCT_NBR
,RSTTD_ADJSTD_MNTH_YEAR_NBR
,SRC_CMS_PLAN_BNFT_PKG_ID
,CMS_MBR_HIC_NBR_ID
,CURNT_CMS_MBR_HIC_NBR_ID
,RSTTD_ENRLMNT_STTS_CD
,SCRTY_LVL_CD 
) 
SELECT
 MMR.CMS_CNTRCT_NBR
,CAST(SUBSTR(MMR.RSTTD_ADJSTD_MNTH_YEAR_NBR, 6, 4) || SUBSTR(MMR.RSTTD_ADJSTD_MNTH_YEAR_NBR, 10, 2) AS CHAR(6)) AS RSTTD_ADJSTD_MNTH_YEAR_NBR
,MMR.SRC_CMS_PLAN_BNFT_PKG_ID
,MMR.CMS_MBR_HIC_NBR_ID
,COALESCE(CRNT.CURNT_CMS_MBR_HIC_NBR_ID,'UNK') AS CURNT_CMS_MBR_HIC_NBR_ID 
,MMR.RSTTD_ENRLMNT_STTS_CD
,MMR.SCRTY_LVL_CD 
FROM SRC_CMS_MBR_RSTTD_MNTHLY MMR
LEFT JOIN CMS_MBR_CURNT_HIC_NBR_XREF CRNT
ON CRNT.CMS_MBR_HIC_NBR_ID = MMR.CMS_MBR_HIC_NBR_ID
WHERE MMR.RSTTD_ENRLMNT_STTS_CD IN ('E' ,'D')
GROUP BY 1,2,3,4,5,6,7
;

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_MBR_RSTTD_MNTHLY_DTL','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***********************************************************************************************************/
/* Identify PBP for category 8 records */
	
INSERT INTO WORK_MAO_004_CTGR_8_MBR_DTL
(
CMS_CNTRCT_NBR
,SRC_CMS_PLAN_BNFT_PKG_ID
,DOS_YEAR_NBR
,CURNT_CMS_MBR_HIC_NBR_ID
,ENCNTR_ICN_ID
,SCRTY_LVL_CD
)
SELECT
  M.CMS_CNTRCT_NBR
, COALESCE(MMR.SRC_CMS_PLAN_BNFT_PKG_ID, MMRD.SRC_CMS_PLAN_BNFT_PKG_ID) AS SRC_CMS_PLAN_BNFT_PKG_ID
, M.DOS_YEAR_NBR
,CRNT.CURNT_CMS_MBR_HIC_NBR_ID AS CURNT_CMS_MBR_HIC_NBR_ID
,  M.ENCNTR_ICN_ID 
, COALESCE(MMR.SCRTY_LVL_CD, MMRD.SCRTY_LVL_CD) AS SCRTY_LVL_CD

FROM WORK_MAO_004_TOTL M
INNER JOIN WORK_MAO_004_PCN_CTGRY C ON C.ENCNTR_ICN_ID = M.ENCNTR_ICN_ID
  AND C.PCN_CTGRY_CD = '8_TBD_NOMATCHING002'
  
LEFT JOIN CMS_MBR_CURNT_HIC_NBR_XREF CRNT 
ON CRNT.CMS_MBR_HIC_NBR_ID = M.CMS_MBR_HIC_NBR_ID

LEFT JOIN WORK_MBR_RSTTD_MNTHLY_DTL MMR 
ON MMR.CURNT_CMS_MBR_HIC_NBR_ID = CRNT.CURNT_CMS_MBR_HIC_NBR_ID
  AND MMR.RSTTD_ENRLMNT_STTS_CD = 'E' 
  AND MMR.CMS_CNTRCT_NBR = M.CMS_CNTRCT_NBR
  AND  THRU_SRVC_MNTH_YEAR_NBR = MMR.RSTTD_ADJSTD_MNTH_YEAR_NBR

LEFT JOIN WORK_MBR_RSTTD_MNTHLY_DTL MMRD
  ON MMRD.CURNT_CMS_MBR_HIC_NBR_ID = CRNT.CURNT_CMS_MBR_HIC_NBR_ID
  AND MMRD.RSTTD_ENRLMNT_STTS_CD = 'D' 
  AND MMRD.CMS_CNTRCT_NBR = M.CMS_CNTRCT_NBR
  AND  THRU_SRVC_MNTH_YEAR_NBR = MMRD.RSTTD_ADJSTD_MNTH_YEAR_NBR
GROUP BY 1,2,3,4,5,6;

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_MAO_004_CTGR_8_MBR_DTL','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***********************************************************************************************************/
/* Identify Caremore records */

INSERT INTO WORK_MAO_004_CTGR_8_CRMORE
(
CMS_CNTRCT_NBR
,SRC_CMS_PLAN_BNFT_PKG_ID
,DOS_YEAR_NBR
,ENCNTR_ICN_ID
,CAREMORE_PLAN_IND
)
SELECT
 M.CMS_CNTRCT_NBR
,M.SRC_CMS_PLAN_BNFT_PKG_ID
,M.DOS_YEAR_NBR
,M.ENCNTR_ICN_ID 
,CASE WHEN bot.CMS_CNTRCT_NM LIKE '%CareMore%' THEN 'Y'
     WHEN bot.CMPNY_RGN_NM ='CareMore' THEN 'Y'
     WHEN m.CMS_CNTRCT_NBR = 'H0544' AND m.DOS_YEAR_NBR < '2018' THEN 'Y' /* CareMore owned this contract 100% prior to 2017 and its not in the BOT prior to 2017.
     																																		In 2018 they owned all individual membership (62,494) and Anthem owns Group (170 members)) */
     WHEN m.CMS_CNTRCT_NBR = 'H4346' AND m.DOS_YEAR_NBR < '2018' THEN 'Y' /* CareMore owned this contract 100% prior to 2018 and its not in the BOT prior to 2017 */
     WHEN m.CMS_CNTRCT_NBR = 'H4346' AND m.DOS_YEAR_NBR = '2018' AND M.SRC_CMS_PLAN_BNFT_PKG_ID NOT IN ('012', '013', '014') 
     			THEN 'Y' /* Anthem owned just 3 PBPs of this contract in 2018, and the rest must be CareMore */
     WHEN m.CMS_CNTRCT_NBR IN ('H2593') THEN 'Y' /* CareMore owns this contract 100% and its in the BOT starting in 2018 */
          ELSE 'N'
END AS CAREMORE_PLAN_IND
FROM WORK_MAO_004_CTGR_8_MBR_DTL M
 
LEFT JOIN BOT_CMS_CNTRCT BOT 
ON BOT.CMS_CNTRCT_NBR = M.CMS_CNTRCT_NBR
AND BOT.SRC_CMS_PBP_ID = M.SRC_CMS_PLAN_BNFT_PKG_ID
AND BOT.CMS_CNTRCT_PBP_SGMNT_YEAR_NBR = M.DOS_YEAR_NBR
GROUP BY 1,2,3,4,5
;

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_MAO_004_CTGR_8_CRMORE','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/*************
/***********************************************************************************************/

/* Assign PCN_GRPG_ID */

INSERT INTO WORK_MAO_004_CTGRY_8_PCN
(
ENCNTR_ICN_ID
,CMS_CNTRCT_NBR
,PCN_GRPG_ID
) 
SELECT
ENCNTR_ICN_ID
,CMS_CNTRCT_NBR
,CASE 
 WHEN CMS_CNTRCT_NBR = 'H5471' THEN 'FV'
 WHEN CAREMORE_PLAN_IND='Y' THEN   'EE'
 ELSE 'UNK'
END AS PCN_GRPG_ID
FROM  WORK_MAO_004_CTGR_8_CRMORE
GROUP BY 1,2,3;

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_MAO_004_CTGRY_8_PCN','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***********************************************************************************************************/

DELETE FROM WORK_MAO_004_PCN_FINL;

/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***************** Error Handling ********************************/

/* Category 8: Join above work table with WORK_PCN_CTGRY_XWALK and extract all PCN values */
 
INSERT INTO WORK_MAO_004_PCN_FINL 
(
ENCNTR_ICN_ID
,PCN_CTGRY_CD
,ENCNTR_TYPE_SWCH_CD
,DS_NM
,DS_CTGRY_1_TXT
,DS_CTGRY_2_TXT
,DS_CD
,PCN_KEY
,VNDR_NM
)
SELECT
 MAO.ENCNTR_ICN_ID
,'NA' AS PCN_CTGRY_CD
,'NA' AS ENCNTR_TYPE_SWCH_CD
,CASE WHEN MAO.PCN_GRPG_ID= 'UNK' THEN 'UNK' ELSE XWALK.DS_NM  END AS DS_NM
,CASE WHEN MAO.PCN_GRPG_ID= 'UNK' THEN 'UNK' ELSE XWALK.DS_CTGRY_1_TXT END AS DS_CTGRY_1_TXT
,CASE WHEN MAO.PCN_GRPG_ID= 'UNK' THEN 'UNK' ELSE XWALK.DS_CTGRY_2_TXT END AS DS_CTGRY_2_TXT
,CASE WHEN MAO.PCN_GRPG_ID= 'UNK' THEN 'UNK' ELSE XWALK.DS_CD END AS DS_CD
,CASE WHEN MAO.PCN_GRPG_ID= 'UNK' THEN 'UNK' ELSE XWALK.PCN_GRPG_ID  END AS PCN_KEY
,'NA' AS VNDR_NM
FROM WORK_MAO_004_CTGRY_8_PCN MAO
LEFT OUTER JOIN WORK_PCN_CTGRY_XWALK XWALK
ON MAO.PCN_GRPG_ID = XWALK.PCN_GRPG_ID
GROUP BY 1,2,3,4,5,6,7,8,9 ;

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_TBL('$CSA_DB','WORK_MAO_004_PCN_FINL','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***********************************************************************************************************/

/******** UPDATE TARGET TABLE  FOR CATEGORY 8 **********/
UPDATE TGT
FROM CMS_MAO_004_TRNSFRM TGT, WORK_MAO_004_PCN_FINL SRC , WORK_TRNSFRM_LOAD_LOG LLK
SET
 DS_NM= SRC.DS_NM
,DS_CTGRY_1_TXT  = SRC.DS_CTGRY_1_TXT
,DS_CTGRY_2_TXT  = SRC.DS_CTGRY_2_TXT
,DS_CD= SRC.DS_CD
,PCN_KEY= SRC.PCN_KEY
,VNDR_NM= SRC.VNDR_NM
WHERE TGT.ENCNTR_ICN_ID  = SRC.ENCNTR_ICN_ID
AND LLK.LOAD_LOG_KEY = TGT.TRNSFRM_LOAD_LOG_KEY
;

/***********************************************************************************************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','DS_NM','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','DS_CTGRY_1_TXT','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','DS_CTGRY_2_TXT','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','DS_CD','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','PCN_KEY','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
CALL APPLPROC_NOPHI_ENT.REFRESH_STTSTCS_CLMN('$CMS_DB','$MAO_004_DTL_TRNSFRM','VNDR_NM','N',RTRN_CD,RTRN_CNT,MSG);
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***********************************************************************************************************/



.QUIT 0

.LABEL ERRORS

.QUIT ERRORCODE

EOF

#============================================================================
# show AIX return code and exit with it
#============================================================================

RETURN_CODE=$?
echo "script return code= " $RETURN_CODE
if [[ $RETURN_CODE = 0 ]] ; then
sh $CODE/sr_riskadj/scripts/mailalert.sh "bteq_load_success_MAO004_TRNSFRM.mail"
else
sh $CODE/sr_riskadj/scripts/mailalert.sh "bteq_load_fail_MAO004_TRNSFRM.mail"
fi
exit $RETURN_CODE
