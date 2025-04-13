*&---------------------------------------------------------------------*
* Module         : BASIS
* Type           : Report
* Name           : ZRBASIS005
* Transaction    : ZBASIS005
* Author         : RODRIGO DOS REIS SILVA
* Architect      : RODRIGO DOS REIS SILVA
* No. Jira       : SBD-8
* Date           : 10/02/2020
* Objetivo       : Create request MW0, E6D, RBS, ALV and NAT
*&---------------------------------------------------------------------*

REPORT  zrbasis005.

TYPE-POOLS: vrm.

TABLES:e070,
       e07t,
       e070c,
       e070v,
       e071.

DATA:
      ls_e070 TYPE e070,
      ls_e07t TYPE e07t,
      ls_e070c TYPE e070c,
      jira TYPE ztrequests002-jira,
      cliente TYPE ztrequests002-cliente.


DATA: ls_requests002 TYPE ztrequests002,
      it_requests002 TYPE STANDARD TABLE OF ztrequests002,
      ls_tr_per_product1 TYPE ztr_per_product1.


PARAMETERS:
            "p_trkorr type trkorr obligatory,
            p_jira TYPE ztrequests002-jira OBLIGATORY,
            p_client TYPE ztrequests002-cliente OBLIGATORY,
            p_produt TYPE i OBLIGATORY AS LISTBOX VISIBLE LENGTH 30


   USER-COMMAND dummy.

INITIALIZATION.

  DATA: id TYPE vrm_id,
        lt_values TYPE vrm_values,
        ls_value LIKE LINE OF lt_values,
        lt_values_aux TYPE vrm_values,
        ls_value_aux LIKE LINE OF lt_values.

  DATA: lt_tr_per_product1 TYPE TABLE OF ztr_per_product1-zproduct_name,
        lt_zrequest1       TYPE TABLE OF ztr_per_product1-zrequest.

  FIELD-SYMBOLS: <fs_tr_per_product> TYPE ztr_per_product1-zproduct_name,
                 <fs_zrequest>       TYPE ztr_per_product1-zrequest.

  REFRESH lt_values.

  SELECT zproduct_name FROM ztr_per_product1
    INTO TABLE lt_tr_per_product1.

  LOOP AT lt_tr_per_product1 ASSIGNING <fs_tr_per_product>.

    ls_value-key = sy-tabix.
    ls_value-text = <fs_tr_per_product>.

    APPEND ls_value TO lt_values.

  ENDLOOP.

  id = 'P_PRODUT'.
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = id
      values = lt_values.

*--------------------------------------------------------------------*
START-OF-SELECTION.
*--------------------------------------------------------------------*

  DATA: lv_text TYPE e07t-as4text,
        lv_ticket_number TYPE ztrequests002-ticket.

  jira = p_jira.
  cliente = p_client.

  CONCATENATE  jira cliente sy-uname sy-datum  INTO lv_text SEPARATED BY space.

  SELECT SINGLE MAX( ticket ) FROM ztrequests002
            INTO lv_ticket_number.

  SELECT SINGLE * FROM ztr_per_product1
    INTO ls_tr_per_product1 WHERE id = p_produt.

  IF ls_tr_per_product1 IS NOT INITIAL.

    IF ls_tr_per_product1-zdestination IS NOT INITIAL.
      DATA: v_dest  TYPE ztr_per_product1-zdestination,
            v_acao TYPE string,
            v_fuction TYPE string.

      v_acao = 'C'.
      v_dest = ls_tr_per_product1-zdestination.
      v_fuction = ls_tr_per_product1-zfuction.

      CALL FUNCTION v_fuction
        DESTINATION v_dest
        EXPORTING
          acao      = v_acao
          request   = ls_tr_per_product1-zrequest
          descricao = lv_text
          tprequest = 'X'
          usuario   = sy-uname
          mandante  = sy-mandt
        IMPORTING
          we_e070   = ls_e070
          we_e07t   = ls_e07t
          we_e070c  = ls_e070c.

    ELSE.

      CALL FUNCTION 'TRINT_INSERT_NEW_COMM'
        EXPORTING
          wi_kurztext   = lv_text
          wi_trfunction = 'X'
          iv_username   = sy-uname
          wi_strkorr    = ls_tr_per_product1-zrequest
          wi_client     = sy-mandt
        IMPORTING
          we_e070       = ls_e070
          we_e07t       = ls_e07t
          we_e070c      = ls_e070c
        EXCEPTIONS
          OTHERS        = 1.
    ENDIF.

  ELSE.


    WRITE: /.
    WRITE: / 'Basis Team - Task creation information'.
    WRITE: /.
    WRITE: / 'ERROR! Please contact Basis team ASAP.'.
    WRITE: /.

  ENDIF.

  IF sy-subrc <> 0.

    WRITE: /.
    WRITE: / 'Basis Team - Task creation information'.
    WRITE: /.
    WRITE: / 'ERROR! Please contact Basis team ASAP.'.
    WRITE: /.

  ELSE.

    ls_requests002-client = ls_e070c-client.
    lv_ticket_number = lv_ticket_number + 1.
    ls_requests002-ticket = lv_ticket_number.
    ls_requests002-request = ls_tr_per_product1-zrequest.
    ls_requests002-task = ls_e070-trkorr.
    ls_requests002-jira = p_jira.
    ls_requests002-cliente =  p_client.
    ls_requests002-produto = ls_tr_per_product1-zproduct_name.
    ls_requests002-type_request = ls_e070-trfunction.
    ls_requests002-data = ls_e070-as4date.
    ls_requests002-time = ls_e070-as4time.
    ls_requests002-created_by = sy-uname .

    MODIFY ztrequests002 FROM ls_requests002.

    WRITE: /.
    WRITE: / 'Basis Team - Task information'.
    WRITE: /.
    WRITE: / 'Your task has been created. See the information.'.
    WRITE: /.
    WRITE: / 'Task number:',     20 ls_e070-trkorr.
    WRITE: / 'Task owner:',      20 ls_requests002-created_by.
    WRITE: / 'Internal ticket:', 20 lv_ticket_number.
    WRITE: /.

  ENDIF.
