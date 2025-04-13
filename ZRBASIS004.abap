*&---------------------------------------------------------------------*
*& Report  ZRBASIS004
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zrbasis004.


DATA: ls_requests001 TYPE ztrequests001,
      it_requests001 TYPE STANDARD TABLE OF ztrequests001,
      ls_tr_per_product TYPE ztr_per_product.

DATA: task TYPE ztrequests001-task,
      v_request TYPE ztrequests001,
      return LIKE bapiret2,
      return2 LIKE bapiret2.


DATA: lv_string_en TYPE string,
      lv_string_pt TYPE string.

SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE v_name.
SELECTION-SCREEN: SKIP.

SELECTION-SCREEN BEGIN OF BLOCK frame1 WITH FRAME TITLE text-001.

PARAMETERS: p_task TYPE ztrequests001-task OBLIGATORY.

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

SELECT SINGLE * FROM ztrequests001 INTO v_request
  WHERE task EQ p_task.

SELECT SINGLE * FROM ztr_per_product
 INTO ls_tr_per_product WHERE zrequest = v_request-request.

IF sy-subrc = 0.
                                                       "INICIO SIGGA_S30
  IF ls_tr_per_product-zdestination IS NOT INITIAL.
    DATA: v_dest  TYPE ztr_per_product-zdestination,
          v_acao TYPE string,
          v_usuario TYPE sy-uname.
    v_acao = 'R'.
    v_dest = ls_tr_per_product-zdestination.
    CALL FUNCTION 'Z_FUNCAO_REQUEST_E6D'
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

  MODIFY ztrequests001 FROM v_request.

  MESSAGE s781(tr) WITH p_task v_request-request.

ENDIF.
