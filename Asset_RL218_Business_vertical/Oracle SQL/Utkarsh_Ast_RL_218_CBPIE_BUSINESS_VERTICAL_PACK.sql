SET SERVEROUTPUT ON;

-- Package Specification
CREATE OR REPLACE PACKAGE CUSTOM.BUSSINESSVERTICALPACK AS
    PROCEDURE BUSSINESSVERTICALPROC(
        inp_str IN VARCHAR2,     
        out_retCode OUT NUMBER,
        out_rec OUT VARCHAR2
    );
END BUSSINESSVERTICALPACK;
/

-- Package Body
CREATE OR REPLACE PACKAGE BODY CUSTOM.BUSSINESSVERTICALPACK AS

    outArr TBAADM.basp0099.ArrayType;  

    PROCEDURE BUSSINESSVERTICALPROC(
        inp_str IN VARCHAR2,     
        out_retCode OUT NUMBER,
        out_rec OUT VARCHAR2
    ) IS

        p_input_date DATE;

        CURSOR c_business_vertical IS
        SELECT REF_CODE AS business_vertical
        FROM TBAADM.RCT
        WHERE REF_REC_TYPE = 'AG'
        AND DEL_FLG = 'N'
        AND BANK_ID = '01';

        v_total_portfolio       NUMBER;
        v_npa_portfolio         NUMBER;
        v_write_off_portfolio   NUMBER;
        v_processing_fee        NUMBER;

    BEGIN
        -- Parse input string to get date
        tbaadm.basp0099.formInputArr(inp_str, outArr);      
        p_input_date := TO_DATE(outArr(0), 'DD-MM-YYYY');

        -- Loop through business verticals
        FOR rec IN c_business_vertical LOOP

            -- 1. Outstanding
            SELECT NVL(SUM(outstanding),0)
            INTO v_total_portfolio
            FROM (
                SELECT SUM(l.dmd_amt - l.tot_adj_amt) AS outstanding
                FROM tbaadm.ldt l, tbaadm.gac c, tbaadm.gam g
                WHERE l.acid = c.acid
                  AND g.acid = c.acid
                  AND g.schm_type = 'LAA'
                  AND l.dmd_date <= p_input_date
                  AND c.free_code_6 = rec.business_vertical

                UNION ALL

                SELECT SUM(g.sanct_lim - g.clr_bal_amt) AS outstanding
                FROM tbaadm.gam g, tbaadm.gac c
                WHERE g.acid = c.acid
                  AND g.schm_type = 'ODA'
                  AND g.last_any_tran_date <= p_input_date
                  AND c.free_code_6 = rec.business_vertical
            );

            -- 2. NPA Count
            SELECT COUNT(*)
            INTO v_npa_portfolio
            FROM tbaadm.gac gc, tbaadm.acd ac, tbaadm.aip ap, tbaadm.gam gm
            WHERE ac.b2k_id = gm.acid
              AND gm.acid = gc.acid
              AND gm.schm_type = 'LAA'
              AND ap.main_asset_class = ac.main_classification_system
              AND ap.sub_asset_class = ac.sub_classification_system
              AND ap.past_due_flg = 'Y'
              AND ap.rcre_time <= p_input_date
              AND gc.free_code_6 = rec.business_vertical;

            -- 3. Write-off Accounts
            SELECT COUNT(DISTINCT c.acid)
            INTO v_write_off_portfolio
            FROM tbaadm.cot c, tbaadm.gac gc, tbaadm.gam gm
            WHERE c.acid = gm.acid
              AND gm.acid = gc.acid
              AND gm.schm_type IN ('LAA','ODA')
              AND c.chrge_off_date <= p_input_date
              AND gc.free_code_6 = rec.business_vertical;

            -- 4. Processing Fee
            SELECT NVL(SUM(chat.chrge_amt_collected),0)
            INTO v_processing_fee
            FROM tbaadm.chat chat, tbaadm.cxl cxl, tbaadm.gac gc, tbaadm.gam gm
            WHERE chat.acid = gm.acid
              AND gc.acid = gm.acid
              AND gm.schm_type IN ('LAA','ODA')
              AND cxl.target_acid = chat.acid
              AND cxl.chrg_tran_date <= p_input_date
              AND chat.charge_type = 'PROSF'
              AND chat.pttm_event_id = 'PROSF'
              AND gc.free_code_6 = rec.business_vertical;

            -- 5. Insert into custom table
            INSERT INTO CUSTOM.BUSSINESS_VERT_DTLS_MAIN 
                (BUSINESS_VERTICAL, TOTAL_PORTFOLIO, NPA_PORTFOLIO, WRITE_OFF_PORTFOLIO, PROCESSING_FEE,
                 LOGIN_FEE, STAMP_DUTY_CHRG, CHEQUE_BOUNCING_CHRG, LEGAL_VALUATION_CHRG, LEGAL_TECHNICAL_CHRG,
                 LATE_PAYMENT_CHRG, PART_PAYMENT_CHRG, PRE_CLOSE_CHRG, PENAL_CHRG, MONITOR_DOC_CHRG_,
                 OTH_INC_DIR_TO_LAN, DSA_EXP, LEGAL_FILING_EXPENSES, LEGAL_PROFF_CHRG_CONS_FEES_EXP,
                 LEGAL_PROFF_CHRG_STAMP_DUTY_CT_FEE, LEGAL_TECH_FEES_BUSINESS, LEGAL_PROF_EXP_CONSUMP_BASED,
                 ADVOC_FEES_COLLECTION, ADVOC_FEES_ADMIN, ADVOC_FEES_BUSINESS, CREDIT_BUREAU_EXPENSES,
                 ANY_OTH_EXP_DIR_TO_LAN, BOD_DATE, LCHG_USER_ID, LCHG_TIME, RCRE_USER_ID, RCRE_TIME, BANK_ID)
            VALUES
                (rec.business_vertical, v_total_portfolio, v_npa_portfolio, v_write_off_portfolio, v_processing_fee,
                 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, p_input_date, 'OCT1', SYSDATE, 'OCT1', SYSDATE, '01');

            -- 6. Print confirmation message
            DBMS_OUTPUT.PUT_LINE('Inserted successfully for business vertical: ' || rec.business_vertical);

        END LOOP;

        COMMIT;

        -- Set output parameters
        out_retCode := 1;  -- success
        out_rec := 'All business verticals processed successfully.';

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            out_retCode := -1;
            out_rec := SQLERRM;
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END BUSSINESSVERTICALPROC;

END BUSSINESSVERTICALPACK;
/
show error;
