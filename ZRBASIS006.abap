*&---------------------------------------------------------------------*
* Module         : BASIS
* Type           : Report
* Name           : ZRBASIS006
* Transaction    : ZBASIS006
* Author         : RODRIGO DOS REIS SILVA
* Architect      : RODRIGO DOS REIS SILVA
* No. Jira       : SBD-8
* Date           : 10/02/2020
* Objetivo       : Release request MW0, E6D, RBS, ALV and NAT
*&---------------------------------------------------------------------*

REPORT  zrbasis006.


DATA: ls_requests002 TYPE ztrequests002,
      it_requests002 TYPE STANDARD TABLE OF ztrequests002,
      ls_tr_per_product1 TYPE ztr_per_product1.

DATA: task TYPE ztrequests002-task,
      v_request TYPE ztrequests002,
      return LIKE bapiret2,
      return2 LIKE bapiret2.


DATA: lv_string_en TYPE string,
      lv_string_pt TYPE string.

SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE v_name.
SELECTION-SCREEN: SKIP.

SELECTION-SCREEN BEGIN OF BLOCK frame1 WITH FRAME TITLE text-001.

PARAMETERS: p_task TYPE ztrequests002-task OBLIGATORY.

SELECTION-SCREEN END OF BLOCK frame1.

SELECTION-SCREEN BEGIN OF BLOCK frame2 WITH FRAME TITLE text-002.
PARAMETERS : p_1_en(20) TYPE c OBLIGATORY.
PARAMETERS : p_2_en(20) TYPE c OBLIGATORY.
PARAMETERS : p_3_en(20) TYPE c.
PARAMETERS : p_4_en(20) TYPE c.
PARAMETERS : p_5_en(20) TYPE c.
SELECTION-SCREEN END OF BLOCK frame2.

SELECTION-SCREEN BEGIN OF BLOCK frame3 WITH FRAME TITLE text-003.
PARAMETERS : p_1_pt(20) TYPE c OBLIGATORY.
PARAMETERS : p_2_pt(20) TYPE c OBLIGATORY.
PARAMETERS : p_3_pt(20) TYPE c.
PARAMETERS : p_4_pt(20) TYPE c.
PARAMETERS : p_5_pt(20) TYPE c.
SELECTION-SCREEN END OF BLOCK frame3.


SELECTION-SCREEN BEGIN OF BLOCK frame4 WITH FRAME TITLE text-004.
PARAMETERS : p_1_sfn(20) TYPE c OBLIGATORY.
SELECTION-SCREEN END OF BLOCK frame4.

SELECTION-SCREEN BEGIN OF BLOCK frame5 WITH FRAME TITLE text-005.
PARAMETERS : p_1_ecc(20) TYPE c OBLIGATORY.
SELECTION-SCREEN END OF BLOCK frame5.

SELECTION-SCREEN BEGIN OF BLOCK frame6 WITH FRAME TITLE text-006.
PARAMETERS : p_1_mob(20) TYPE c OBLIGATORY.
SELECTION-SCREEN END OF BLOCK frame6.

SELECTION-SCREEN: END OF BLOCK b1.

CONCATENATE p_1_en p_2_en p_3_en p_4_en p_5_en INTO lv_string_en SEPARATED BY space.
CONCATENATE p_1_pt p_2_pt p_3_pt p_4_pt p_5_pt INTO lv_string_pt SEPARATED BY space.

SELECT SINGLE * FROM ztrequests002 INTO v_request
  WHERE task EQ p_task.

SELECT SINGLE * FROM ztr_per_product1
 INTO ls_tr_per_product1 WHERE zrequest = v_request-request.

IF sy-subrc = 0.
*                                                       INICIO SIGGA_S30
  IF ls_tr_per_product1-zdestination IS NOT INITIAL.
       DATA: v_dest  TYPE ztr_per_product1-zdestination,
            v_acao TYPE string,
            v_fuction TYPE string,
            v_system TYPE  ztr_per_product1-zsystem.

      v_acao = 'R'.
      v_dest = ls_tr_per_product1-zdestination.
      v_fuction = ls_tr_per_product1-zfuction.

    CALL FUNCTION v_fuction
      DESTINATION v_dest
      EXPORTING
        acao    = v_acao
        request = v_request-request
        task    = v_request-task
      IMPORTING
        return  = return2
      EXCEPTIONS
        OTHERS  = 1.

  ELSE.
*                                                               FIM SIGGA_S30
    CALL FUNCTION 'BAPI_CTREQUEST_RELEASE'
      EXPORTING
        requestid = v_request-request
        taskid    = p_task
      IMPORTING
        return    = return2
      EXCEPTIONS
        OTHERS    = 1.

  ENDIF.

ENDIF.


IF return2-id IS NOT INITIAL.

  WRITE: /.
  WRITE: / 'Basis Team - Task release information'.
  WRITE: /.
  WRITE: / 'ERROR! Please contact Basis team ASAP.'.
  WRITE: /.
  WRITE: / 'NOTE:', 8 return2-message. "Retorna pendência da request (SIGGA_S30)

ELSE.

  v_request-keywords_en = lv_string_en.
  v_request-keywords_pt = lv_string_pt.
  v_request-sfn_tr      = p_1_sfn.
  v_request-ecc_tr      = p_1_ecc.
  v_request-mobile_version = p_1_mob.

  MODIFY ztrequests002 FROM v_request.

  MESSAGE s781(tr) WITH p_task v_request-request.

ENDIF.
