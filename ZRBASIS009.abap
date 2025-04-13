
*&---------------------------------------------------------------------*
* Module         : BASIS
* Type           : Report
* Name           : ZRBASIS009
* Transaction    : ZBASIS009
* Author         : RODRIGO DOS REIS SILVA
* Architect      : RODRIGO DOS REIS SILVA
* No. Jira       : SBD-8
* Date           : 10/02/2020
* Objetivo       : Request or task objects
*&---------------------------------------------------------------------*

REPORT  zrbasis009.

TABLES: e071.

DATA: it_objects TYPE TABLE OF e071,
      ls_e071 TYPE e071,
      ls_tr_per_product1 TYPE ztr_per_product1,
      ls_ztrequests002 TYPE ztrequests002,
      v_request TYPE ztrequests002-request,
      v_dest  TYPE ztr_per_product1-zdestination,
      v_acao TYPE string,
      v_fuction TYPE ztr_per_product1-zfuction,
      v_system TYPE  ztr_per_product1-zsystem.

SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE v_name.
SELECTION-SCREEN: SKIP.

SELECTION-SCREEN BEGIN OF BLOCK frame1 WITH FRAME TITLE text-001.
PARAMETERS: p_task TYPE e071-trkorr OBLIGATORY.
SELECTION-SCREEN END OF BLOCK frame1.

SELECTION-SCREEN: END OF BLOCK b1.


START-OF-SELECTION.

  "Buscar os Dados
  PERFORM busca_dados.
  "Mostrar os Dados
  PERFORM mostra_dados.


*&---------------------------------------------------------------------*
*&      Form  busca_dados
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM busca_dados.

  SELECT request
   FROM ztrequests002
   INTO v_request
   WHERE task EQ p_task OR
      request EQ p_task.
  ENDSELECT.

  SELECT *
   FROM ztr_per_product1
   INTO ls_tr_per_product1
   WHERE zrequest EQ v_request.
  ENDSELECT.

  v_dest = ls_tr_per_product1-zdestination.

  IF v_dest IS NOT INITIAL.

      v_acao = 'O'.
      v_fuction = ls_tr_per_product1-zfuction.

      CALL FUNCTION v_fuction
        DESTINATION v_dest
        EXPORTING
          acao     = v_acao
          task     = p_task
        IMPORTING
          we_e071  = ls_e071
        TABLES
          zobjects = it_objects.
    ELSE.

      SELECT *
         FROM e071
         INTO TABLE  it_objects
         WHERE trkorr EQ p_task OR
         trkorr EQ p_task.

    ENDIF.

    ENDFORM.                    "busca_dados

*&---------------------------------------------------------------------*
*&      Form  mostra_dados
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM mostra_dados.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_structure_name = 'e071'
    TABLES
      t_outtab         = it_objects.
  .
  IF sy-subrc <> 0.
    WRITE: /.
    WRITE: / 'Basis Team - Task creation information'.
    WRITE: /.
    WRITE: / 'ERROR! Please contact Basis team ASAP.'.
    WRITE: /.
  ENDIF.
ENDFORM.                    "mostra_dados
