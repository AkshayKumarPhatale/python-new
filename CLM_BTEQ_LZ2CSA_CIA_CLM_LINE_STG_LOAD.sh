exec 1> $CODE/edlr2/logs/`echo $0 | cut -d '/' -f8 | sed 's/\.sh//g'`_$(date +"%Y%m%d_%H%M%S").log 2>&1
######################################################################################################################################################
# RULER --- no line of code or comments should extend beyond column 150 (Unix code may be an exception).
#--------*---------*---------*---------*---------*---------*---------*---------*---------*---------*---------*---------*---------*---------*---------*
#        0         0         0         0         0         0         0         0         0         1         1         1         1         1         1
#        1         2         3         4         5         6         7         8         9         0         1         2         3         4         5
#        0         0         0         0         0         0         0         0         0         0         0         0         0         0         0
#--------*---------*---------*---------*---------*---------*---------*---------*---------*---------*---------*---------*---------*---------*---------*
######################################################################################################################################################
#=====================================================================================================================================================

#===========================================================================================================================
# Title		: CLM_BTEQ_LZ2CSA_AFC_CLM_LINE_STG_LOAD.sh
# Filename	: CLM_BTEQ_LZ2CSA_AFC_CLM_LINE_STG_LOAD.sh
# Description	: This script inserts records from CLM_LINE_STG table to CLM_LINE_STG(AFC)
# Source Tables	: CLM_LINE_STG,
# Target Tables	: CLM_LINE_STG
# Key Columns	: CLM_ADJSTMNT_KEY,CLM_LINE_NBR
# Developer	: LEGATO
# Prod Impl on	: 11-07-2019
# Location	: BANGALORE, INDIA
# Parameters	: Parameter file name
# Return codes	: Zero represents successful execution of script. Non-Zero represents failure of the script.
# Parameters	: Parameter file name, TBL_NM, CLMN, SOR_CD, SUBJ_AREA_NM, LZ_WORK_FLOW_NM
# Return codes  : Zero represents successful execution of script. Non-Zero represents failure of the script.

# Date			Ver#			Modified By(Name)				Change and Reason for Change
# ------		-----			-----------------------------		--------------------------------------
# 11-07-2019  	          1.0                     LEGATO - BLR 		                       Initial Version
# 
#===========================================================================================================================

echo "script file =" $0

PARM_FILE=$1
echo "parm file= "$PARM_FILE.parm
. $CODE/edlr2/scripts/$PARM_FILE.parm

#===========================================================================================================================================
#BTEQ Script
#===========================================================================================================================================

bteq<<EOF

.SET WIDTH 150;

/* ************************************* Error Handling ****************************************** */
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/* ************************************* Error Handling ****************************************** */

/* *****************************************************************************************************
Put BTEQ in Transaction mode 
***************************************************************************************************** */

.SET SESSION TRANSACTION BTET;

/* ************************************* Error Handling ****************************************** */
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/* ************************************* Error Handling ****************************************** */

/* *************************************************************************************************
Extract username and password and logon to database.
************************************************************************************************* */

.run file $LOGON/$LOGON_ID;

/* ************************************* Error Handling ****************************************** */
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/* ************************************* Error Handling ****************************************** */

SELECT SESSION;

/* ************************************* Error Handling ****************************************** */
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/* ************************************* Error Handling ****************************************** */

SET QUERY_BAND = 'ApplicationName=$0;Frequency=Daily;' FOR SESSION;

/* ******************* Error Handling ************************ */
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/* ******************* Error Handling ************************ */

DATABASE $AFC_ETL_VIEWS_DB;

/* ******************* Error Handling ************************ */
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/* ******************* Error Handling ************************ */

/*REFRESH THE STAGE TABLE FOR CURRENT DATA LOAD */
DELETE
FROM $AFC_ETL_VIEWS_DB.CLM_LINE_STG
WHERE LOAD_LOG_KEY IN
  (SELECT LOAD_LOG_KEY FROM $ETL_VIEWS_DB.CSA_LOAD_LOG
           WHERE PBLSH_IND='N'
                        AND LOAD_END_DTM ='$AFC_CSA2EDW_CLM_HIGH_DTM'
                        AND PBLSH_DTM ='$AFC_CSA2EDW_CLM_HIGH_DTM'
                        AND SUBJ_AREA_NM     ='$LZ2CSA_CLM_SUBJ_AREA_NM'
                        AND WORK_FLOW_NM IN ($LZ2CSA_AFC_CLM_WORK_FLOW_NM)
           
 )
			AND CLM_SOR_CD in ('$LZ2CSA_AFC_CLM_SOR_CD');

/* ************************************* Error Handling ****************************************** */
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/* ************************************* Error Handling ****************************************** */

INSERT INTO $AFC_ETL_VIEWS_DB.CLM_LINE_STG
(
     CLM_ADJSTMNT_KEY
    ,CLM_LINE_NBR
    ,CLM_SOR_CD
    ,SRC_GRP_NBR
    ,SRC_SUBGRP_NBR
    ,PRCHSR_ORG_NBR
    ,PRCHSR_ORG_TYPE_CD
    ,RLTD_PRCHSR_ORG_NBR
    ,RLTD_PRCHSR_ORG_TYPE_CD
    ,MBRSHP_SRC_SYS_PROD_ID
    ,PROD_ID
    ,PKG_NBR
    ,BNFT_PKG_ID
    ,PROV_SOR_CD
    ,RNDRG_PROV_ID
    ,RNDRG_PROV_ID_TYPE_CD
    ,SRC_INN_CD
    ,INN_CD
    ,SRC_CLM_NASCO_PAR_CD
    ,CLM_NASCO_PAR_CD
    ,SRC_CLM_LINE_ENCNTR_CD
    ,CLM_LINE_ENCNTR_CD
    ,SRC_CLM_LINE_STTS_CD
    ,CLM_LINE_STTS_CD
    ,CLM_LINE_SRVC_STRT_DT
    ,CLM_LINE_SRVC_END_DT
    ,SRC_CLM_LINE_SRVC_DT_MTHD_CD
    ,CLM_LINE_SRVC_DT_MTHD_CD
    ,ADJDCTN_DT
    ,PROC_MDFR_1_CD
    ,PROC_MDFR_2_CD
    ,SCNDRY_HLTH_SRVC_CD
    ,RVNU_CD
    ,HLTH_SRVC_CD
    ,HLTH_SRVC_TYPE_CD
    ,CLM_LINE_NDC
    ,BILLD_SRVC_UNIT_CNT
    ,PAID_SRVC_UNIT_CNT
    ,SRC_INPAT_CD
    ,INPAT_CD
    ,SRC_PLACE_OF_SRVC_CD
    ,PLACE_OF_SRVC_CD
    ,SRC_CLM_ADJDCTN_LVL_CD
    ,CLM_ADJDCTN_LVL_CD
    ,BED_TYPE_CD
    ,SRC_BED_TYPE_CD
    ,PN_ID
    ,FEE_SCHED_ID
    ,FFS_EQVLNT_AMT
    ,SRC_PRCP_ID
    ,SRC_SRVC_DNL_RSN_CD
    ,BILLD_CHRG_AMT
    ,NON_CVRD_AMT
    ,CVRD_EXPNS_AMT
    ,DSCNT_AMT
    ,ALWD_AMT
    ,CPAY_AMT
    ,COINSRN_AMT
    ,COB_SVNGS_AMT
    ,DDCTBL_AMT
    ,ENRLMNT_PRTCTN_AMT
    ,EPO_WTHLD_AMT
    ,MBR_SNCTNS_PNLTYS_AMT
    ,OTHR_RDCTN_AMT
    ,PAT_PAID_DFRNTL_AMT
    ,PAID_AMT
    ,BAD_DEBT_CHRTY_ALWNC_AMT
    ,INTRST_AMT
    ,ITS_TRNSCTN_FEE_AMT
    ,ITS_SURCHRG_AMT
    ,ITS_CENTRL_FNCL_AGNCY_FEE_AMT
    ,ITS_ADMNSTRN_FEE_AMT
    ,ITS_ACS_FEE_AMT
    ,ST_SURCHRG_AMT
    ,TAX_AMT
    ,PGYBK_CD
    ,SRC_DERIVD_IND_CD
    ,DERIVD_IND_CD
    ,SRC_PHRMCTL_PRCG_SRC_SYS_CD
    ,PHRMCTL_PRCG_SRC_SYS_CD
    ,MBR_PROV_NTWK_ID
    ,HOUS_ACCT_CD
    ,SRC_CPAY_CTGRY_CD
    ,CPAY_CTGRY_CD
    ,SRC_BNFT_PAYMNT_STTS_CD
    ,BNFT_PAYMNT_STTS_CD
    ,OTHR_INSRNC_PLAN_NM
    ,PAT_ACCT_NBR
    ,VNDR_INVC_NBR
    ,CLM_PRCSR_ID
    ,SRC_ADJSTMNT_RSN_CD
    ,ADJSTMNT_RSN_CD
    ,SRC_CLM_REIMBMNT_TYPE_CD
    ,CLM_REIMBMNT_TYPE_CD
    ,LOINC_CD
    ,SRC_ENCNTR_SRC_CD
    ,ENCNTR_SRC_CD
    ,ENCNTR_VNDR_ID
    ,PRNCPL_DIAG_CD
    ,OTHR_DIAG_1_CD
    ,OTHR_DIAG_2_CD
    ,OTHR_DIAG_3_CD
    ,PRC_SHIP_CD
    ,LOAD_LOG_KEY
    ,SOR_DTM
    ,CRCTD_LOAD_LOG_KEY
    ,UPDTD_LOAD_LOG_KEY
    ,TRNSCTN_CD
    ,TRNSCTN_DTM
    ,CLM_LINE_ADJSTMNT_CD
    ,SRC_CLM_LINE_ADJSTMNT_CD
    ,CLM_LINE_CASE_ID
    ,CLM_LINE_PA_SOR_CD
    ,CLM_LINE_PA_NBR
    ,SRC_CLM_LINE_PA_TYPE_CD
    ,CLM_LINE_PA_TYPE_CD
    ,CNTRL_PLAN_CD
    ,CLM_ADJSTMNT_NBR
    ,SRC_CLM_LINE_ADJSTMNT_NBR
    ,SRC_BNB_CLM_LINE_NBR
    ,CLM_LINE_RPTG_BILLD_DAYS_CNT
    ,CLM_LINE_RPTG_PAID_DAYS_CNT
    ,SRC_CLM_LINE_PRCG_DISALW_CD
    ,CLM_LINE_PRCG_DISALW_CD
    ,SRC_CLM_LINE_NDC
    ,CLM_LINE_BILLD_DAYS_CNT
    ,CLM_LINE_PAID_DAYS_CNT
    ,MULTIPLAN_FEE_AMT
    ,PARG_STTS_CD
    ,SRC_PARG_STTS_CD
    ,CLM_LINE_CDHP_PAYOUT_AMT
    ,ITS_DFLT_CLMS_RSLTN_PNLTY_AMT
    ,BILLD_HLTH_SRVC_CD
    ,BILLD_HLTH_SRVC_TYPE_CD
    ,WLP_COB_SVNGS_AMT
    ,WLP_PNLTY_AMT
    ,CLM_AGE_NBR
    ,EXTRNL_LOAD_CD
    ,ITS_ACS_FEE_CD
    ,SRC_ITS_ACS_FEE_CD
    ,MRKT_RGN_CD
    ,SRC_MRKT_RGN_CD
    ,SRC_INSTNL_NGTTD_SRVC_TERM_ID
    ,SRC_INSTNL_REIMBMNT_TERM_ID
    ,CLM_LINE_COB_OC_PAID_AMT
    ,CLM_LINE_COB_OC_NON_CVRD_AMT
    ,CLM_LINE_COB_OC_APRVD_AMT
    ,HMO_LINE_CD
    ,SRC_HMO_LINE_CD
    ,MBR_CVRG_TRMNTN_DT
    ,CLM_DIAG_ID
    ,SRC_ICD_VRSN_CD
    ,ICD_VRSN_CD
    ,RPTG_CLM_LINE_ADJDCTN_STTS_CD
    ,CLM_LINE_PKG_UOM_CD
    ,SRC_CLM_LINE_PKG_UOM_CD
    ,CLM_LINE_PKG_SIZE_NBR
    ,SBMTD_CLM_LINE_NBR
    ,PRCHSR_ORG_BNFT_CLS_ID
    ,CLM_LINE_PAYMNT_PCT
    ,SBSDZD_AMT
    ,UNSBSDZD_FFS_EQVLNT_AMT
    ,UNSBSDZD_DDCTBL_AMT
    ,UNSBSDZD_COINSRN_AMT
    ,UNSBSDZD_CPAY_AMT
    ,UNSBSDZD_MBR_SNCTNS_PNLTY_AMT
    ,UNSBSDZD_PAT_PAID_DFRNTL_AMT
    ,UNSBSDZD_ENRLPRTN_AMT
    ,UNSBSDZD_EPO_WTHLD_AMT
    ,UNSBSDZD_PAID_AMT
    ,EHB_CD
    ,SRC_EHB_CD
    ,PARNT_BNFT_PKG_ID
    ,CLM_LINE_REIMB_MTHD_CD
    ,SRC_CLM_LINE_REIMB_MTHD_CD
    ,CLM_LINE_OVRD_ADJSTMNT_CD
    ,SRC_CLM_LINE_OVRD_ADJSTMNT_CD
    ,SRC_RT_CTGRY_CD
    ,CLM_LINE_WCRE_IND_CD
    ,SRC_CLM_LINE_WCRE_IND_CD
    ,CLM_LINE_RBB_NCCT_ID
    ,CLM_LINE_RBB_MAX_AMT
    ,CLM_LINE_RBB_OVRG_AMT
    ,CLM_LINE_RBB_ACCUMR_BNFT_AMT
    ,CLM_LINE_RBB_BNDLD_IND_CD
    ,SRC_CLM_LINE_RBB_BNDLD_IND_CD
    ,HIX_CD
    ,SRC_HIX_CD
    ,CLM_LINE_RBB_HRA_AMT
    ,SRC_CLM_LINE_SPRT_CD
    ,PROV_RISK_WTHLD_AMT
    ,COB_DDCTBL_ACCUMR_AMT
    ,COB_CPAY_ACCUMR_AMT
    ,COB_COINSRN_ACCUMR_AMT
    ,PAYMNT_APC_NBR
    ,DTL_APC_WT_FCTR
    ,DTL_CLM_OCE_EDIT_CD
    ,OUT_ITEM_STTS_IND_CD
    ,MEDCR_SQSTRTN_RDCTN_AMT
    ,MBRSHP_SOR_CD
    ,MBR_SURCHRG_AMT
    ,MEDCRA_DDCTBL_AMT
    ,MEDCRA_COINSRN_CPAY_AMT
    ,MEDCRA_DDCTBL_WVR_AMT
    ,MEDCRA_DDCTBL_PAID_AMT
    ,CLM_LINE_RBB_CD
    ,SRC_CLM_LINE_RBB_CD
    ,UNSBSDZD_MBR_SURCHRG_AMT
    ,CLM_LINE_COB_OC_DDCTBL_AMT
    ,SCNDRY_POOL_AMT
    ,LOAD_SOR_CD
    ,ITS_SPLMNTL_AMT
    ,SRC_WRTOFF_TYPE_CD
    ,SRC_DDCTBL_TYPE_CD
    ,SRC_OTHR_TYPE_CD
    ,SRC_CPAY_TYPE_CD
    ,SRC_REJ_TYPE_CD
    ,SRC_PAY_TYPE_CD
    ,MEDCR_OC_SQSTRTN_AMT
    ,MEDCRB_OC_COINSRN_CPAY_AMT
    ,CLM_LINE_COB_SCNDRY_OC_DDCTBL_AMT
    ,CLM_LINE_COB_OC_COINSRN_AMT
    ,CLM_LINE_COB_SCNDRY_OC_COINSRN_AMT
    ,MEDCR_OC_APRVD_AMT
    ,MEDCRB_OC_DDCTBL_AMT
    ,MEDCR_OC_NON_CVRD_AMT
    ,MEDCR_OC_PAID_AMT
    ,PRPY_RVW_ALWD_AMT
    ,PRPY_RVW_VNDR_DISALWD_AMT
    ,RPTG_HOTT_MH_CTGRY_CD
    ,EMRGNCY_IND_CD
    ,PROV_SRVC_PA_PASS_IND_CD
    ,SRC_SITE_OF_SRVC_BNFT_CD
)
SELECT 
          STG.CLM_ADJSTMNT_KEY
    ,STG.CLM_LINE_NBR
    ,STG.CLM_SOR_CD
    ,STG.SRC_GRP_NBR
    ,STG.SRC_SUBGRP_NBR
    ,STG.PRCHSR_ORG_NBR
    ,STG.PRCHSR_ORG_TYPE_CD
    ,STG.RLTD_PRCHSR_ORG_NBR
    ,STG.RLTD_PRCHSR_ORG_TYPE_CD
    ,STG.MBRSHP_SRC_SYS_PROD_ID
    ,STG.PROD_ID
    ,STG.PKG_NBR
    ,STG.BNFT_PKG_ID
    ,STG.PROV_SOR_CD
    ,STG.RNDRG_PROV_ID
    ,STG.RNDRG_PROV_ID_TYPE_CD
    ,STG.SRC_INN_CD
    ,STG.INN_CD
    ,STG.SRC_CLM_NASCO_PAR_CD
    ,STG.CLM_NASCO_PAR_CD
    ,STG.SRC_CLM_LINE_ENCNTR_CD
    ,STG.CLM_LINE_ENCNTR_CD
    ,STG.SRC_CLM_LINE_STTS_CD
    ,STG.CLM_LINE_STTS_CD
    ,STG.CLM_LINE_SRVC_STRT_DT
    ,STG.CLM_LINE_SRVC_END_DT
    ,STG.SRC_CLM_LINE_SRVC_DT_MTHD_CD
    ,STG.CLM_LINE_SRVC_DT_MTHD_CD
    ,STG.ADJDCTN_DT
    ,STG.PROC_MDFR_1_CD
    ,STG.PROC_MDFR_2_CD
    ,STG.SCNDRY_HLTH_SRVC_CD
    ,STG.RVNU_CD
    ,STG.HLTH_SRVC_CD
    ,STG.HLTH_SRVC_TYPE_CD
    ,STG.CLM_LINE_NDC
    ,STG.BILLD_SRVC_UNIT_CNT
    ,STG.PAID_SRVC_UNIT_CNT
    ,STG.SRC_INPAT_CD
    ,STG.INPAT_CD
    ,STG.SRC_PLACE_OF_SRVC_CD
    ,STG.PLACE_OF_SRVC_CD
    ,STG.SRC_CLM_ADJDCTN_LVL_CD
    ,STG.CLM_ADJDCTN_LVL_CD
    ,STG.BED_TYPE_CD
    ,STG.SRC_BED_TYPE_CD
    ,STG.PN_ID
    ,STG.FEE_SCHED_ID
    ,STG.FFS_EQVLNT_AMT
    ,STG.SRC_PRCP_ID
    ,STG.SRC_SRVC_DNL_RSN_CD
    ,STG.BILLD_CHRG_AMT
    ,STG.NON_CVRD_AMT
    ,STG.CVRD_EXPNS_AMT
    ,STG.DSCNT_AMT
    ,STG.ALWD_AMT
    ,STG.CPAY_AMT
    ,STG.COINSRN_AMT
    ,STG.COB_SVNGS_AMT
    ,STG.DDCTBL_AMT
    ,STG.ENRLMNT_PRTCTN_AMT
    ,STG.EPO_WTHLD_AMT
    ,STG.MBR_SNCTNS_PNLTYS_AMT
    ,STG.OTHR_RDCTN_AMT
    ,STG.PAT_PAID_DFRNTL_AMT
    ,STG.PAID_AMT
    ,STG.BAD_DEBT_CHRTY_ALWNC_AMT
    ,STG.INTRST_AMT
    ,STG.ITS_TRNSCTN_FEE_AMT
    ,STG.ITS_SURCHRG_AMT
    ,STG.ITS_CENTRL_FNCL_AGNCY_FEE_AMT
    ,STG.ITS_ADMNSTRN_FEE_AMT
    ,STG.ITS_ACS_FEE_AMT
    ,STG.ST_SURCHRG_AMT
    ,STG.TAX_AMT
    ,STG.PGYBK_CD
    ,STG.SRC_DERIVD_IND_CD
    ,STG.DERIVD_IND_CD
    ,STG.SRC_PHRMCTL_PRCG_SRC_SYS_CD
    ,STG.PHRMCTL_PRCG_SRC_SYS_CD
    ,STG.MBR_PROV_NTWK_ID
    ,STG.HOUS_ACCT_CD
    ,STG.SRC_CPAY_CTGRY_CD
    ,STG.CPAY_CTGRY_CD
    ,STG.SRC_BNFT_PAYMNT_STTS_CD
    ,STG.BNFT_PAYMNT_STTS_CD
    ,STG.OTHR_INSRNC_PLAN_NM
    ,STG.PAT_ACCT_NBR
    ,STG.VNDR_INVC_NBR
    ,STG.CLM_PRCSR_ID
    ,STG.SRC_ADJSTMNT_RSN_CD
    ,STG.ADJSTMNT_RSN_CD
    ,STG.SRC_CLM_REIMBMNT_TYPE_CD
    ,STG.CLM_REIMBMNT_TYPE_CD
    ,STG.LOINC_CD
    ,STG.SRC_ENCNTR_SRC_CD
    ,STG.ENCNTR_SRC_CD
    ,STG.ENCNTR_VNDR_ID
    ,STG.PRNCPL_DIAG_CD
    ,STG.OTHR_DIAG_1_CD
    ,STG.OTHR_DIAG_2_CD
    ,STG.OTHR_DIAG_3_CD
    ,STG.PRC_SHIP_CD
    ,STG.LOAD_LOG_KEY
    ,STG.SOR_DTM
    ,STG.CRCTD_LOAD_LOG_KEY
    ,STG.UPDTD_LOAD_LOG_KEY
    ,STG.TRNSCTN_CD
    ,STG.TRNSCTN_DTM
    ,STG.CLM_LINE_ADJSTMNT_CD
    ,STG.SRC_CLM_LINE_ADJSTMNT_CD
    ,STG.CLM_LINE_CASE_ID
    ,STG.CLM_LINE_PA_SOR_CD
    ,STG.CLM_LINE_PA_NBR
    ,STG.SRC_CLM_LINE_PA_TYPE_CD
    ,STG.CLM_LINE_PA_TYPE_CD
    ,STG.CNTRL_PLAN_CD
    ,STG.CLM_ADJSTMNT_NBR
    ,STG.SRC_CLM_LINE_ADJSTMNT_NBR
    ,STG.SRC_BNB_CLM_LINE_NBR
    ,STG.CLM_LINE_RPTG_BILLD_DAYS_CNT
    ,STG.CLM_LINE_RPTG_PAID_DAYS_CNT
    ,STG.SRC_CLM_LINE_PRCG_DISALW_CD
    ,STG.CLM_LINE_PRCG_DISALW_CD
    ,STG.SRC_CLM_LINE_NDC
    ,STG.CLM_LINE_BILLD_DAYS_CNT
    ,STG.CLM_LINE_PAID_DAYS_CNT
    ,STG.MULTIPLAN_FEE_AMT
    ,STG.PARG_STTS_CD
    ,STG.SRC_PARG_STTS_CD
    ,STG.CLM_LINE_CDHP_PAYOUT_AMT
    ,STG.ITS_DFLT_CLMS_RSLTN_PNLTY_AMT
    ,STG.BILLD_HLTH_SRVC_CD
    ,STG.BILLD_HLTH_SRVC_TYPE_CD
    ,STG.WLP_COB_SVNGS_AMT
    ,STG.WLP_PNLTY_AMT
    ,STG.CLM_AGE_NBR
    ,STG.EXTRNL_LOAD_CD
    ,STG.ITS_ACS_FEE_CD
    ,STG.SRC_ITS_ACS_FEE_CD
    ,STG.MRKT_RGN_CD
    ,STG.SRC_MRKT_RGN_CD
    ,STG.SRC_INSTNL_NGTTD_SRVC_TERM_ID
    ,STG.SRC_INSTNL_REIMBMNT_TERM_ID
    ,STG.CLM_LINE_COB_OC_PAID_AMT
    ,STG.CLM_LINE_COB_OC_NON_CVRD_AMT
    ,STG.CLM_LINE_COB_OC_APRVD_AMT
    ,STG.HMO_LINE_CD
    ,STG.SRC_HMO_LINE_CD
    ,STG.MBR_CVRG_TRMNTN_DT
    ,STG.CLM_DIAG_ID
    ,STG.SRC_ICD_VRSN_CD
    ,STG.ICD_VRSN_CD
    ,STG.RPTG_CLM_LINE_ADJDCTN_STTS_CD
    ,STG.CLM_LINE_PKG_UOM_CD
    ,STG.SRC_CLM_LINE_PKG_UOM_CD
    ,STG.CLM_LINE_PKG_SIZE_NBR
    ,STG.SBMTD_CLM_LINE_NBR
    ,STG.PRCHSR_ORG_BNFT_CLS_ID
    ,STG.CLM_LINE_PAYMNT_PCT
    ,STG.SBSDZD_AMT
    ,STG.UNSBSDZD_FFS_EQVLNT_AMT
    ,STG.UNSBSDZD_DDCTBL_AMT
    ,STG.UNSBSDZD_COINSRN_AMT
    ,STG.UNSBSDZD_CPAY_AMT
    ,STG.UNSBSDZD_MBR_SNCTNS_PNLTY_AMT
    ,STG.UNSBSDZD_PAT_PAID_DFRNTL_AMT
    ,STG.UNSBSDZD_ENRLPRTN_AMT
    ,STG.UNSBSDZD_EPO_WTHLD_AMT
    ,STG.UNSBSDZD_PAID_AMT
    ,STG.EHB_CD
    ,STG.SRC_EHB_CD
    ,STG.PARNT_BNFT_PKG_ID
    ,STG.CLM_LINE_REIMB_MTHD_CD
    ,STG.SRC_CLM_LINE_REIMB_MTHD_CD
    ,STG.CLM_LINE_OVRD_ADJSTMNT_CD
    ,STG.SRC_CLM_LINE_OVRD_ADJSTMNT_CD
    ,STG.SRC_RT_CTGRY_CD
    ,STG.CLM_LINE_WCRE_IND_CD
    ,STG.SRC_CLM_LINE_WCRE_IND_CD
    ,STG.CLM_LINE_RBB_NCCT_ID
    ,STG.CLM_LINE_RBB_MAX_AMT
    ,STG.CLM_LINE_RBB_OVRG_AMT
    ,STG.CLM_LINE_RBB_ACCUMR_BNFT_AMT
    ,STG.CLM_LINE_RBB_BNDLD_IND_CD
    ,STG.SRC_CLM_LINE_RBB_BNDLD_IND_CD
    ,STG.HIX_CD
    ,STG.SRC_HIX_CD
    ,STG.CLM_LINE_RBB_HRA_AMT
    ,STG.SRC_CLM_LINE_SPRT_CD
    ,STG.PROV_RISK_WTHLD_AMT
    ,STG.COB_DDCTBL_ACCUMR_AMT
    ,STG.COB_CPAY_ACCUMR_AMT
    ,STG.COB_COINSRN_ACCUMR_AMT
    ,STG.PAYMNT_APC_NBR
    ,STG.DTL_APC_WT_FCTR
    ,STG.DTL_CLM_OCE_EDIT_CD
    ,STG.OUT_ITEM_STTS_IND_CD
    ,STG.MEDCR_SQSTRTN_RDCTN_AMT
    ,STG.MBRSHP_SOR_CD
    ,STG.MBR_SURCHRG_AMT
    ,STG.MEDCRA_DDCTBL_AMT
    ,STG.MEDCRA_COINSRN_CPAY_AMT
    ,STG.MEDCRA_DDCTBL_WVR_AMT
    ,STG.MEDCRA_DDCTBL_PAID_AMT
    ,STG.CLM_LINE_RBB_CD
    ,STG.SRC_CLM_LINE_RBB_CD
    ,STG.UNSBSDZD_MBR_SURCHRG_AMT
    ,STG.CLM_LINE_COB_OC_DDCTBL_AMT
    ,STG.SCNDRY_POOL_AMT
    ,STG.LOAD_SOR_CD
    ,STG.ITS_SPLMNTL_AMT
    ,STG.SRC_WRTOFF_TYPE_CD
    ,STG.SRC_DDCTBL_TYPE_CD
    ,STG.SRC_OTHR_TYPE_CD
    ,STG.SRC_CPAY_TYPE_CD
    ,STG.SRC_REJ_TYPE_CD
    ,STG.SRC_PAY_TYPE_CD
    ,STG.MEDCR_OC_SQSTRTN_AMT
    ,STG.MEDCRB_OC_COINSRN_CPAY_AMT
    ,STG.CLM_LINE_COB_SCNDRY_OC_DDCTBL_AMT
    ,STG.CLM_LINE_COB_OC_COINSRN_AMT
    ,STG.CLM_LINE_COB_SCNDRY_OC_COINSRN_AMT
    ,STG.MEDCR_OC_APRVD_AMT
    ,STG.MEDCRB_OC_DDCTBL_AMT
    ,STG.MEDCR_OC_NON_CVRD_AMT
    ,STG.MEDCR_OC_PAID_AMT
    ,STG.PRPY_RVW_ALWD_AMT
    ,STG.PRPY_RVW_VNDR_DISALWD_AMT
    ,STG.RPTG_HOTT_MH_CTGRY_CD
    ,STG.EMRGNCY_IND_CD
    ,STG.PROV_SRVC_PA_PASS_IND_CD
    ,STG.SRC_SITE_OF_SRVC_BNFT_CD
      FROM  $ETL_VIEWS_DB.CLM_LINE_STG STG
	  INNER JOIN $ETL_VIEWS_DB.CLM_STG CLM_STG
						ON STG.CLM_ADJSTMNT_KEY = CLM_STG.CLM_ADJSTMNT_KEY
INNER JOIN  $ETL_VIEWS_DB.CSA_LOAD_LOG CLL
			ON CLL.LOAD_LOG_KEY=STG.LOAD_LOG_KEY
						AND CLL.LOAD_LOG_KEY=CLM_STG.LOAD_LOG_KEY
                        AND PBLSH_IND='N'
                        AND CLL.LOAD_END_DTM ='$AFC_CSA2EDW_CLM_HIGH_DTM'
                        AND CLL.PBLSH_DTM ='$AFC_CSA2EDW_CLM_HIGH_DTM'
                        AND CLL.SUBJ_AREA_NM     ='$LZ2CSA_CLM_SUBJ_AREA_NM'
                       AND CLL.WORK_FLOW_NM IN ($LZ2CSA_AFC_CLM_WORK_FLOW_NM)
           		where STG.CLM_SOR_CD in ('$LZ2CSA_AFC_CLM_SOR_CD') AND CLM_STG.MBRSHP_SOR_CD IN ('$LZ2CSA_AFC_MBRSHP_SOR_CD');


 /* ************************************* Error Handling ****************************************** */
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/* ************************************* Error Handling ****************************************** */

CALL $DB_RFRSH_STAT_PROC.REFRESH_STTSTCS_TBL('$AFC_ETL_TEMP_DB','CLM_LINE_STG','N',RTRN_CD,RTRN_CNT,MSG);

/* ************************************* Error Handling ****************************************** */
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/* ************************************* Error Handling ****************************************** */

/* ********************* If the query succeeds Zero will be the return value ********************** */
.QUIT 0
/* ***************** If the query fails the error code value will be returned ********************* */

.LABEL ERRORS

.QUIT ERRORCODE
EOF
# show AIX return code and exit with it
RETURN_CODE=$?
echo "script return code = " $RETURN_CODE
exit $RETURN_CODE
