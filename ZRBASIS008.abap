*&---------------------------------------------------------------------*
* Module         : BASIS
* Type           : Report
* Name           : ZRBASIS008
* Transaction    : ZBASIS008
* Author         : RODRIGO DOS REIS SILVA
* Architect      : RODRIGO DOS REIS SILVA
* No. Jira       : SBD-8
* Date           : 10/02/2020
* Objetivo       : Internal Transport Management
*&---------------------------------------------------------------------*

REPORT  ZRBASIS008.

TABLES: sscrfields.
DATA: g_ucomm TYPE syucomm.



SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-200.
SELECTION-SCREEN PUSHBUTTON /1(35) p_but1 USER-COMMAND but1.
SELECTION-SCREEN: SKIP.
SELECTION-SCREEN PUSHBUTTON /1(35) p_but2 USER-COMMAND but2.
SELECTION-SCREEN: SKIP.
SELECTION-SCREEN PUSHBUTTON /1(35) p_but3 USER-COMMAND but3.
SELECTION-SCREEN: SKIP.
SELECTION-SCREEN PUSHBUTTON /1(35) p_but4 USER-COMMAND but4.

SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  p_but1 = '@0Y@Create Task'(001).
  p_but2 = '@4A@ Release'(002).
  p_but3 = '@4G@ Trace'(003).
  p_but4 = '@4G@ Task objects'(004).


AT SELECTION-SCREEN.
* Se se carregou num dos botões, guarda o seu código e continua
  IF sscrfields-ucomm EQ 'BUT1' OR
      sscrfields-ucomm EQ 'BUT2' OR
      sscrfields-ucomm EQ 'BUT3' OR
      sscrfields-ucomm EQ 'BUT4'.
    g_ucomm = sscrfields-ucomm.
    sscrfields-ucomm = 'ONLI'. "carregou em F8.

  ENDIF.

  START-OF-SELECTION.
  CASE g_ucomm.
    WHEN 'BUT1'.
      call transaction 'ZBASIS005'.
    WHEN 'BUT2'.
      call transaction 'ZBASIS006'.
    WHEN 'BUT3'..
      call transaction 'ZBASIS007'.
    WHEN 'BUT4'..
      call transaction 'ZBASIS009'.
ENDCASE.
