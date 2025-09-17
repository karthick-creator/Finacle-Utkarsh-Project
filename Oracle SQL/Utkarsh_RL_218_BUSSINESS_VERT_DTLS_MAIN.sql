------------------------------------------------------------------------------------------------
--File Name                     :       Utkarsh_RL_218_BUSSINESS_VERT_DTLS_MAIN.sql
--Author                        :       KARTHICK G
--Requirement id                :       RL_218
--Description                   :       CUSTOM.BUSSINESS_VERT_DTLS_MAIN TABLE CREATION FOR CUSTOM MENU - CBPIER
--Modification History
------------------------------------------------------------------------------------------------
--S.No. |       Date            |       Name                   |       Description
-------         ----------              ----------------------  ------------------------------------
-- 1    |       22-08-2025      |       KARTHICK G             |       Original Version
------------------------------------------------------------------------------------------------

BEGIN
EXECUTE IMMEDIATE 'DROP TABLE CUSTOM.BUSSINESS_VERT_DTLS_MAIN TABLE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
CREATE TABLE CUSTOM.BUSSINESS_VERT_DTLS_MAIN(
			BUSINESS_VERTICAL                                                   VARCHAR(5),
			TOTAL_PORTFOLIO                                                     VARCHAR2(16),
			NPA_PORTFOLIO                                                       NUMBER(20,4),
			WRITE_OFF_PORTFOLIO                                                 NUMBER(20,4),
			PROCESSING_FEE                                                      NUMBER(20,4),
			LOGIN_FEE                                                           NUMBER(20,4),
			STAMP_DUTY_CHRG                                                     NUMBER(20,4),
			CHEQUE_BOUNCING_CHRG                                                NUMBER(20,4),
			LEGAL_VALUATION_CHRG                                                NUMBER(20,4),
			LEGAL_TECHNICAL_CHRG                                                NUMBER(20,4),
			LATE_PAYMENT_CHRG                                                   NUMBER(20,4),
			PART_PAYMENT_CHRG                                                   NUMBER(20,4),
			PRE_CLOSE_CHRG                                                      NUMBER(20,4),
			PENAL_CHRG                                                          NUMBER(20,4),
			MONITOR_DOC_CHRG_                                                   NUMBER(20,4),
			OTH_INC_DIR_TO_LAN                                                  NUMBER(20,4),
			DSA_EXP                                                             NUMBER(20,4),
			LEGAL_FILING_EXPENSES                                               NUMBER(20,4),
			LEGAL_PROFF_CHRG_CONS_FEES_EXP                                      NUMBER(20,4),
			LEGAL_PROFF_CHRG_STAMP_DUTY_CT_FEE                                  NUMBER(20,4),
			LEGAL_TECH_FEES_BUSINESS                                           NUMBER(20,4),
			LEGAL_PROF_EXP_CONSUMP_BASED                                        NUMBER(20,4),
			ADVOC_FEES_COLLECTION                                               NUMBER(20,4),
			ADVOC_FEES_ADMIN                                                    NUMBER(20,4),
			ADVOC_FEES_BUSINESS                                                 NUMBER(20,4),
			CREDIT_BUREAU_EXPENSES                                              NUMBER(20,4),
			ANY_OTH_EXP_DIR_TO_LAN                                              NUMBER(20,4),
			BOD_DATE                                                            DATE,
			LCHG_USER_ID                                                        VARCHAR2(15 CHAR),
			LCHG_TIME                                                           DATE,
			RCRE_USER_ID                                                        VARCHAR2(15 CHAR),
			RCRE_TIME                                                           DATE,
			BANK_ID                                                             VARCHAR2(8 CHAR)
)
/
GRANT SELECT, INSERT, UPDATE, DELETE ON CUSTOM.BUSSINESS_VERT_DTLS_MAIN TO TBAGEN
/
GRANT SELECT, INSERT, UPDATE, DELETE ON CUSTOM.BUSSINESS_VERT_DTLS_MAIN TO TBAADM
/
GRANT SELECT ON CUSTOM.BUSSINESS_VERT_DTLS_MAIN TO TBAUTIL
/
