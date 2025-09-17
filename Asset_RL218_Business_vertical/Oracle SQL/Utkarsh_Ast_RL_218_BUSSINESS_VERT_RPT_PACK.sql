-- Package Specification
CREATE OR REPLACE PACKAGE CUSTOM.FIN_BUSSINESS_VERT_RPT_PACK AS
    PROCEDURE FIN_BUSSINESS_VERT_RPT_PROC(
        inp_str     IN  VARCHAR2,     
        out_retCode OUT NUMBER,
        out_rec     OUT VARCHAR2
    );
END FIN_BUSSINESS_VERT_RPT_PACK;
/

-- Package Body
CREATE OR REPLACE PACKAGE BODY CUSTOM.FIN_BUSSINESS_VERT_RPT_PACK 
AS
			outArr        		TBAADM.basp0099.ArrayType;
			input_date      	DATE;
            V_PARTICULAR  		VARCHAR2(200);
            V_BC_RETAIL 		NUMBER;
            V_MSME  			NUMBER;
            V_HL    			NUMBER;
            V_WHEELS    		NUMBER;
            V_MICRO_LAP 		NUMBER;
            V_PERSONAL_LOAN     NUMBER;
            V_STRATEGIC_LAP     NUMBER;
            V_WSL_NBFC      	NUMBER;
            V_BBG           	NUMBER;
            V_GOLD_LOAN         NUMBER;
            V_CREDIT_CARD       NUMBER;
            V_ODFD              NUMBER;
            V_STAFF_LOANS       NUMBER;

 CURSOR C1(input_date DATE) IS
WITH ValidVerticals AS (
    SELECT ref_code AS business_vertical
    FROM tbaadm.rct
    WHERE REF_REC_TYPE = 'AG' AND del_flg = 'N' AND rcre_user_id = 'OCT1'
),
BaseData AS (
    -- Portfolio Data
    SELECT business_vertical, 'Total Portfolio' AS Particular, TO_NUMBER(NVL(TOTAL_PORTFOLIO, 0)) AS value
    FROM CUSTOM.BUSSINESS_VERT_DTLS_MAIN
    WHERE BOD_DATE <= input_date AND BANK_ID = '01'
      AND business_vertical IN (SELECT business_vertical FROM ValidVerticals)
    
    UNION ALL
    SELECT business_vertical, 'NPA Portfolio', TO_NUMBER(NVL(NPA_PORTFOLIO, 0))
    FROM CUSTOM.BUSSINESS_VERT_DTLS_MAIN
    WHERE BOD_DATE <= input_date AND BANK_ID = '01'
      AND business_vertical IN (SELECT business_vertical FROM ValidVerticals)
    
    UNION ALL
    SELECT business_vertical, 'Write-off Portfolio', TO_NUMBER(NVL(WRITE_OFF_PORTFOLIO, 0))
    FROM CUSTOM.BUSSINESS_VERT_DTLS_MAIN
    WHERE BOD_DATE <= input_date AND BANK_ID = '01'
      AND business_vertical IN (SELECT business_vertical FROM ValidVerticals)
    
    UNION ALL
    SELECT NULL, 'Total Income', NULL FROM dual
    
    UNION ALL
    -- Interest Income
    SELECT c.free_code_6 AS business_vertical, 'Interest Income' AS Particular, 
           TO_NUMBER(NVL(SUM(
               CASE 
                   WHEN g.schm_type = 'LAA' 
                        AND l.dmd_flow_id = 'INDEM' 
                        AND l.dmd_date <= input_date
                   THEN l.TOT_ADJ_AMT
                   WHEN g.schm_type = 'ODA' 
                        AND l.dmd_date <= input_date
                        AND EXISTS (
                            SELECT 1 
                            FROM tbaadm.dtd d
                            WHERE d.acid = g.acid
                              AND d.tran_type = 'T'
                              AND d.tran_sub_type = 'IC'
                        )
                   THEN l.TOT_ADJ_AMT
               END
           ), 0)) AS value
    FROM tbaadm.ldt l
    JOIN tbaadm.gam g ON l.acid = g.acid
    JOIN tbaadm.gac c ON c.acid = g.acid
    WHERE c.free_code_6 IN (SELECT business_vertical FROM ValidVerticals)
    GROUP BY c.free_code_6
    
    UNION ALL
    -- Interest Reversal
    SELECT c.free_code_6, '(-) Interest Reversal on Account of NPA', 
           NVL(TO_NUMBER(SUM(e.NRML_INT_SUSPENSE_AMT_DR)), 0)
    FROM tbaadm.eit e
    JOIN tbaadm.gam g ON e.entity_id = g.acid
    JOIN tbaadm.gac c ON c.acid = g.acid
    WHERE g.schm_type = 'LAA'
      AND c.free_code_6 IN (SELECT business_vertical FROM ValidVerticals)
    GROUP BY c.free_code_6
    
    UNION ALL
    -- Charges and Fees
    SELECT business_vertical, Particular, TO_NUMBER(NVL(value, 0)) AS value
    FROM CUSTOM.BUSSINESS_VERT_DTLS_MAIN
    UNPIVOT (
        value FOR Particular IN (
            PROCESSING_FEE AS 'Processing Fee',
            LOGIN_FEE AS 'Login Fee',
            STAMP_DUTY_CHRG AS 'Stamp Duty Charges',
            CHEQUE_BOUNCING_CHRG AS 'Cheque Bouncing Charges',
            LEGAL_VALUATION_CHRG AS 'Legal Valuation Charges',
            LEGAL_TECHNICAL_CHRG AS 'Legal Technical Charges',
            LATE_PAYMENT_CHRG AS 'Late Payment Charges',
            PART_PAYMENT_CHRG AS 'Part-payment Charges',
            PRE_CLOSE_CHRG AS 'Pre Close Charges',
            PENAL_CHRG AS 'Penal Charges',
            MONITOR_DOC_CHRG_ AS 'Monitoring and Documentation Charges',
            OTH_INC_DIR_TO_LAN AS 'Any Other Income directly traced to LAN',
            DSA_EXP AS 'DSA Exp',
            LEGAL_FILING_EXPENSES AS 'Legal and Filing Expenses',
            LEGAL_PROFF_CHRG_CONS_FEES_EXP AS 'Legal and Proff Chrg - Consultant Fees and Exp',
            LEGAL_PROFF_CHRG_STAMP_DUTY_CT_FEE AS 'Legal and Proff Charges-Stamp duty / court fee',
            LEGAL_TECH_FEES_BUSINESS AS 'Legal and Technical Fees Business',
            LEGAL_PROF_EXP_CONSUMP_BASED AS 'Legal and Professional Exp- Consumption based',
            ADVOC_FEES_COLLECTION AS 'Advocate Fees - Collection',
            ADVOC_FEES_ADMIN AS 'Advocate Fees Administrative',
            ADVOC_FEES_BUSINESS AS 'Advocate Fees Business',
            CREDIT_BUREAU_EXPENSES AS 'Credit Bureau Expenses',
            ANY_OTH_EXP_DIR_TO_LAN AS 'Any Other Exp. directly traced to LAN'
        )
    )
    WHERE BOD_DATE <= input_date AND BANK_ID = '01'
      AND business_vertical IN (SELECT business_vertical FROM ValidVerticals)
    
    UNION ALL
    -- Total1 (Fees + Interest Income + Interest Reversal)
    SELECT bv.business_vertical, 
           'Total' AS Particular,
           NVL(TO_NUMBER(bv.PROCESSING_FEE), 0) +
           NVL(TO_NUMBER(bv.LOGIN_FEE), 0) +
           NVL(TO_NUMBER(bv.STAMP_DUTY_CHRG), 0) +
           NVL(TO_NUMBER(bv.CHEQUE_BOUNCING_CHRG), 0) +
           NVL(TO_NUMBER(bv.LEGAL_VALUATION_CHRG), 0) +
           NVL(TO_NUMBER(bv.LEGAL_TECHNICAL_CHRG), 0) +
           NVL(TO_NUMBER(bv.LATE_PAYMENT_CHRG), 0) +
           NVL(TO_NUMBER(bv.PART_PAYMENT_CHRG), 0) +
           NVL(TO_NUMBER(bv.PRE_CLOSE_CHRG), 0) +
           NVL(TO_NUMBER(bv.PENAL_CHRG), 0) +
           NVL(TO_NUMBER(bv.MONITOR_DOC_CHRG_), 0) +
           NVL(TO_NUMBER(bv.OTH_INC_DIR_TO_LAN), 0) +
           NVL((
               SELECT SUM(
                   CASE 
                       WHEN g2.schm_type = 'LAA' 
                            AND l.dmd_flow_id = 'INDEM' 
                            AND l.dmd_date <= input_date
                       THEN l.TOT_ADJ_AMT
                       WHEN g2.schm_type = 'ODA' 
                            AND l.dmd_date <= input_date
                            AND EXISTS (
                                SELECT 1 
                                FROM tbaadm.dtd d
                                WHERE d.acid = g2.acid
                                  AND d.tran_type = 'T'
                                  AND d.tran_sub_type = 'IC'
                            )
                       THEN l.TOT_ADJ_AMT
                   END
               )
               FROM tbaadm.ldt l
               JOIN tbaadm.gam g2 ON l.acid = g2.acid
               JOIN tbaadm.gac c2 ON c2.acid = g2.acid
               WHERE c2.free_code_6 = bv.business_vertical
           ), 0) +
           NVL((
               SELECT SUM(e.NRML_INT_SUSPENSE_AMT_DR)
               FROM tbaadm.eit e
               JOIN tbaadm.gam g2 ON e.entity_id = g2.acid
               JOIN tbaadm.gac c2 ON c2.acid = g2.acid
               WHERE g2.schm_type = 'LAA'
                 AND c2.free_code_6 = bv.business_vertical
           ), 0) AS value
    FROM CUSTOM.BUSSINESS_VERT_DTLS_MAIN bv
    WHERE bv.bod_date <= input_date
      AND bv.bank_id = '01'
      AND bv.business_vertical IN (SELECT business_vertical FROM ValidVerticals)
    
    UNION ALL
    SELECT NULL, 'Total Expenses', NULL FROM dual
    
    UNION ALL
    -- Total2 (Expenses)
    SELECT 
        bv.business_vertical,
        'Total ' AS Particular,
        SUM(
            NVL(TO_NUMBER(bv.DSA_EXP), 0) +
            NVL(TO_NUMBER(bv.LEGAL_FILING_EXPENSES), 0) +
            NVL(TO_NUMBER(bv.LEGAL_PROFF_CHRG_CONS_FEES_EXP), 0) +
            NVL(TO_NUMBER(bv.LEGAL_PROFF_CHRG_STAMP_DUTY_CT_FEE), 0) +
            NVL(TO_NUMBER(bv.LEGAL_TECH_FEES_BUSINESS), 0) +
            NVL(TO_NUMBER(bv.LEGAL_PROF_EXP_CONSUMP_BASED), 0) +
            NVL(TO_NUMBER(bv.ADVOC_FEES_COLLECTION), 0) +
            NVL(TO_NUMBER(bv.ADVOC_FEES_ADMIN), 0) +
            NVL(TO_NUMBER(bv.ADVOC_FEES_BUSINESS), 0) +
            NVL(TO_NUMBER(bv.CREDIT_BUREAU_EXPENSES), 0) +
            NVL(TO_NUMBER(bv.ANY_OTH_EXP_DIR_TO_LAN), 0)
        ) AS value
    FROM CUSTOM.BUSSINESS_VERT_DTLS_MAIN bv
    WHERE BOD_DATE <= input_date AND BANK_ID = '01'
      AND business_vertical IN (SELECT business_vertical FROM ValidVerticals)
    GROUP BY bv.business_vertical
),
AllParticulars AS (
    SELECT Particular
    FROM (
        SELECT 'Total Portfolio' AS Particular FROM dual UNION ALL
        SELECT 'NPA Portfolio' FROM dual UNION ALL
        SELECT 'Write-off Portfolio' FROM dual UNION ALL
        SELECT 'Total Income' FROM dual UNION ALL
        SELECT 'Interest Income' FROM dual UNION ALL
        SELECT '(-) Interest Reversal on Account of NPA' FROM dual UNION ALL
        SELECT 'Processing Fee' FROM dual UNION ALL
        SELECT 'Login Fee' FROM dual UNION ALL
        SELECT 'Stamp Duty Charges' FROM dual UNION ALL
        SELECT 'Cheque Bouncing Charges' FROM dual UNION ALL
        SELECT 'Legal Valuation Charges' FROM dual UNION ALL
        SELECT 'Legal Technical Charges' FROM dual UNION ALL
        SELECT 'Late Payment Charges' FROM dual UNION ALL
        SELECT 'Part-payment Charges' FROM dual UNION ALL
        SELECT 'Pre Close Charges' FROM dual UNION ALL
        SELECT 'Penal Charges' FROM dual UNION ALL
        SELECT 'Monitoring and Documentation Charges' FROM dual UNION ALL
        SELECT 'Any Other Income directly traced to LAN' FROM dual UNION ALL
        SELECT 'Total' FROM dual UNION ALL
        SELECT 'Total Expenses' FROM dual UNION ALL
        SELECT 'DSA Exp' FROM dual UNION ALL
        SELECT 'Legal and Filing Expenses' FROM dual UNION ALL
        SELECT 'Legal and Proff Chrg - Consultant Fees and Exp' FROM dual UNION ALL
        SELECT 'Legal and Proff Charges-Stamp duty / court fee' FROM dual UNION ALL
        SELECT 'Legal and Technical Fees Business' FROM dual UNION ALL
        SELECT 'Legal and Professional Exp- Consumption based' FROM dual UNION ALL
        SELECT 'Advocate Fees - Collection' FROM dual UNION ALL
        SELECT 'Advocate Fees Administrative' FROM dual UNION ALL
        SELECT 'Advocate Fees Business' FROM dual UNION ALL
        SELECT 'Credit Bureau Expenses' FROM dual UNION ALL
        SELECT 'Any Other Exp. directly traced to LAN' FROM dual UNION ALL
        SELECT 'Total ' FROM dual
    )
)
SELECT 
    ap.Particular,
    MAX(CASE WHEN bd.business_vertical = 'BC' THEN bd.value END) AS BC_RETAIL,
    MAX(CASE WHEN bd.business_vertical = 'MSME' THEN bd.value END) AS MSME,
    MAX(CASE WHEN bd.business_vertical = 'HL' THEN bd.value END) AS HL,
    MAX(CASE WHEN bd.business_vertical = 'WHEEL' THEN bd.value END) AS WHEELS,
    MAX(CASE WHEN bd.business_vertical = 'LAP' THEN bd.value END) AS MICRO_LAP,
    MAX(CASE WHEN bd.business_vertical = 'PL' THEN bd.value END) AS PERSONAL_LOAN,
    MAX(CASE WHEN bd.business_vertical = 'SLAP' THEN bd.value END) AS STRATEGIC_LAP,
    MAX(CASE WHEN bd.business_vertical = 'WSL' THEN bd.value END) AS WSL_NBFC,
    MAX(CASE WHEN bd.business_vertical = 'BBG' THEN bd.value END) AS BBG,
    MAX(CASE WHEN bd.business_vertical = 'GOLD' THEN bd.value END) AS GOLD_LOAN,
    MAX(CASE WHEN bd.business_vertical = 'CARD' THEN bd.value END) AS CREDIT_CARD,
    MAX(CASE WHEN bd.business_vertical = 'ODFD' THEN bd.value END) AS ODFD,
    MAX(CASE WHEN bd.business_vertical = 'STAFF' THEN bd.value END) AS STAFF_LOANS
FROM AllParticulars ap
LEFT JOIN BaseData bd ON ap.Particular = bd.Particular
GROUP BY ap.Particular
ORDER BY DECODE(ap.Particular,
                'Total Portfolio', 1,
                'NPA Portfolio', 2,
                'Write-off Portfolio', 3,
                'Total Income', 4,
                'Interest Income', 5,
                '(-) Interest Reversal on Account of NPA', 6,
                'Processing Fee', 7,
                'Login Fee', 8,
                'Stamp Duty Charges', 9,
                'Cheque Bouncing Charges', 10,
                'Legal Valuation Charges', 11,
                'Legal Technical Charges', 12,
                'Late Payment Charges', 13,
                'Part-payment Charges', 14,
                'Pre Close Charges', 15,
                'Penal Charges', 16,
                'Monitoring and Documentation Charges', 17,
                'Any Other Income directly traced to LAN', 18,
                'Total', 19,
                'Total Expenses', 20,
                'DSA Exp', 21,
                'Legal and Filing Expenses', 22,
                'Legal and Proff Chrg - Consultant Fees and Exp', 23,
                'Legal and Proff Charges-Stamp duty / court fee', 24,
                'Legal and Technical Fees Business', 25,
                'Legal and Professional Exp- Consumption based', 26,
                'Advocate Fees - Collection', 27,
                'Advocate Fees Administrative', 28,
                'Advocate Fees Business', 29,
                'Credit Bureau Expenses', 30,
                'Any Other Exp. directly traced to LAN', 31,
                'Total ', 32,
                999);

    PROCEDURE FIN_BUSSINESS_VERT_RPT_PROC(
        inp_str IN VARCHAR2,     
        out_retCode OUT NUMBER,
        out_rec OUT VARCHAR2    
    ) AS

    BEGIN
        OUT_RETCODE := 0;
        OUT_REC := NULL;

        -- Split input string
        TBAADM.basp0099.formInputArr(inp_str, outArr);
         --input_date := TO_CHAR(TO_DATE(outArr(0),'DD-MM-YYYY'),'DD-MON-YYYY');
		input_date := TO_DATE(outArr(0),'DD-MM-YYYY');		
	 
       	IF NOT C1%ISOPEN THEN
		--{
			OPEN C1(input_date);
		--}
		END IF;
        
        IF C1%ISOPEN THEN
        --{ 
            FETCH C1 INTO 
            V_PARTICULAR,
            V_BC_RETAIL,
            V_MSME,
            V_HL,
            V_WHEELS,
            V_MICRO_LAP,
            V_PERSONAL_LOAN,
            V_STRATEGIC_LAP,
            V_WSL_NBFC,
            V_BBG,
            V_GOLD_LOAN,
            V_CREDIT_CARD,
            V_ODFD,
            V_STAFF_LOANS;
        --}
            END IF;
  
             IF C1%FOUND THEN
		--{      
            -- Concatenate each row (metric) into OUT_REC with '|' separator and newline
            OUT_REC := OUT_REC ||
                       V_PARTICULAR || '|' ||
                       V_BC_RETAIL || '|' ||
                       V_MSME || '|' ||
                       V_HL || '|' ||
                       V_WHEELS || '|' ||
                       V_MICRO_LAP || '|' ||
                       V_PERSONAL_LOAN || '|' ||
                       V_STRATEGIC_LAP || '|' ||
                       V_WSL_NBFC || '|' ||
                       V_BBG || '|' ||
                       V_GOLD_LOAN || '|' ||
                       V_CREDIT_CARD || '|' ||
                       V_ODFD || '|' ||
                       V_STAFF_LOANS; 
        		--}
        ELSE
		--{
            CLOSE C1;
			OUT_RETCODE := 1;
            RETURN;
		--}
		END IF;
    END FIN_BUSSINESS_VERT_RPT_PROC;

END FIN_BUSSINESS_VERT_RPT_PACK;
/
