*&---------------------------------------------------------------------*
*& Report  ZRBASIS002
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zrbasis002.

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
      jira TYPE ztrequests001-jira,
      cliente TYPE ztrequests001-cliente.


DATA: ls_requests001 TYPE ztrequests001,
      it_requests001 TYPE STANDARD TABLE OF ztrequests001,
      ls_tr_per_product TYPE ztr_per_product.


PARAMETERS:
            "p_trkorr type trkorr obligatory,
            p_jira TYPE ztrequests001-jira OBLIGATORY,
            p_client TYPE ztrequests001-cliente OBLIGATORY,
            p_produt TYPE i OBLIGATORY AS LISTBOX VISIBLE LENGTH 30
*            p_trkorr type i obligatory as listbox visible length 20
            "p_produt type ztrequests001-produto obligatory,

   USER-COMMAND dummy.

INITIALIZATION.

  DATA: id TYPE vrm_id,
        lt_values TYPE vrm_values,
        ls_value LIKE LINE OF lt_values,
        lt_values_aux TYPE vrm_values,
        ls_value_aux LIKE LINE OF lt_values.

  DATA: lt_tr_per_product TYPE TABLE OF ztr_per_product-zproduct_name,
        lt_zrequest       TYPE TABLE OF ztr_per_product-zrequest.

  FIELD-SYMBOLS: <fs_tr_per_product> TYPE ztr_per_product-zproduct_name,
                 <fs_zrequest>       TYPE ztr_per_product-zrequest.

  REFRESH lt_values.

  SELECT zproduct_name FROM ztr_per_product
    INTO TABLE lt_tr_per_product.

  LOOP AT lt_tr_per_product ASSIGNING <fs_tr_per_product>.

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
        lv_ticket_number TYPE ztrequests001-ticket.

  jira = p_jira.
  cliente = p_client.

  CONCATENATE  jira cliente sy-uname sy-datum  INTO lv_text SEPARATED BY space.

  SELECT SINGLE MAX( ticket ) FROM ztrequests001
            INTO lv_ticket_number.

  SELECT SINGLE * FROM ztr_per_product
    INTO ls_tr_per_product WHERE id = p_produt.

  IF ls_tr_per_product IS NOT INITIAL.
*                                                         INICIO SIGGA_S30
    IF ls_tr_per_product-zdestination IS NOT INITIAL.
      DATA: v_dest  TYPE ztr_per_product-zdestination,
            v_acao TYPE string,
            v_usuario TYPE sy-uname.
      v_acao = 'C'.
      v_dest = ls_tr_per_product-zdestination.
      CALL FUNCTION 'Z_FUNCAO_REQUEST_E6D'
           DESTINATION v_dest
           EXPORTING
             acao            = v_acao
             request         = ls_tr_per_product-zrequest
*                TASK            =
             descricao       = lv_text
             tprequest       = 'X'
             usuario         = sy-uname
             mandante        = '800'
           IMPORTING
             we_e070         = ls_e070
             we_e07t         = ls_e07t
             we_e070c        = ls_e070c.
*                                                           FIM SIGGA_S30
    ELSE.
      CALL FUNCTION 'TRINT_INSERT_NEW_COMM'
        EXPORTING
          wi_kurztext   = lv_text
          wi_trfunction = 'X'
          iv_username   = sy-uname
          wi_strkorr    = ls_tr_per_product-zrequest
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

    ls_requests001-client = ls_e070c-client.
    lv_ticket_number = lv_ticket_number + 1.
    ls_requests001-ticket = lv_ticket_number.
    ls_requests001-request = ls_tr_per_product-zrequest.
    ls_requests001-task = ls_e070-trkorr.
    ls_requests001-jira = p_jira.
    ls_requests001-cliente =  p_client.
    ls_requests001-produto = ls_tr_per_product-zproduct_name.
    ls_requests001-type_request = ls_e070-trfunction.
    ls_requests001-data = ls_e070-as4date.
    ls_requests001-time = ls_e070-as4time.
    ls_requests001-created_by = sy-uname .

    MODIFY ztrequests001 FROM ls_requests001.

    WRITE: /.
    WRITE: / 'Basis Team - Task information'.
    WRITE: /.
    WRITE: / 'Your task has been created. See the information.'.
    WRITE: /.
    WRITE: / 'Task number:',     20 ls_e070-trkorr.
    WRITE: / 'Task owner:',      20 ls_requests001-created_by.
    WRITE: / 'Internal ticket:', 20 lv_ticket_number.
    WRITE: /.

  ENDIF.
