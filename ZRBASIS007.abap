*&---------------------------------------------------------------------*
* Module         : BASIS
* Type           : Report
* Name           : ZRBASIS007
* Transaction    : ZBASIS007
* Author         : RODRIGO DOS REIS SILVA
* Architect      : RODRIGO DOS REIS SILVA
* No. Jira       : SBD-8
* Date           : 10/02/2020
* Objetivo       : Trace request MW0, E6D, RBS, ALV and NAT
*&---------------------------------------------------------------------*

report  zrbasis007.


data: it_ztrequests002 type table of ztrequests002,
      ls_ztrequests002 like it_ztrequests002.



* Inicio dos Paramentros de filtros para saida do relatório

parameters: p_jira type ztrequests002-jira,            "nº jira
            p_client type ztrequests002-cliente,      "nome do cliente
            p_produt type ztrequests002-produto,      "nome do produto
            p_reques type ztrequests002-request,      "id da request
            p_task type ztrequests002-task,           "id da tarefa"
            p_creat type ztrequests002-created_by.    "titular da tarefa"

select-options p_data for   sy-datum.                 "dta. criação da tarefa".

* Fim dos Paramentros de filtros para saida do relatório

* Inicio da Declaração das variaveis do Range

data: r_jira like range of p_jira,
      s_jira like line of  r_jira,

      r_client like range of p_client,
      s_client like line of  r_client,

      r_produt like range of p_produt,
      s_produt like line of  r_produt,

      r_reques like range of p_reques,
      s_reques like line of  r_reques,

      r_task like range of p_task,
      s_task like line of  r_task,

      r_creat like range of p_creat,
      s_creat like line of  r_creat.

* Fim da Declaração das variaveis do Range
*Inicio da atribuição dos valores para o Range

if p_jira is not initial.
  s_jira-option = 'EQ'.
  s_jira-sign = 'I'.
  s_jira-low = p_jira.
  append s_jira to r_jira.

endif.

if p_client is not initial.
  s_client-option = 'EQ'.
  s_client-sign = 'I'.
  s_client-low = p_client.
  append s_client to r_client.
endif.

if p_produt is not initial.
  s_produt-option = 'EQ'.
  s_produt-sign = 'I'.
  s_produt-low = p_produt.
  append s_produt to r_produt.
endif.

if p_reques is not initial.
  s_reques-option = 'EQ'.
  s_reques-sign = 'I'.
  s_reques-low = p_reques.
  append s_reques to r_reques.
endif.

if p_task is not initial.
  s_task-option = 'EQ'.
  s_task-sign = 'I'.
  s_task-low = p_task.
  append s_task to r_task.
endif.

if p_creat is not initial.
  s_creat-option = 'EQ'.
  s_creat-sign = 'I'.
  s_creat-low = p_creat.
  append s_creat to r_creat.
endif.

"Declarando os campos da estrutura interna
types: begin of ty_request,
  jira type ztrequests002-jira,                 "nº jira
  cliente type ztrequests002-cliente,           "nome do cliente
  produto type ztrequests002-produto,           "nome do produto
  request type ztrequests002-request,           "id da request
  task type ztrequests002-task,                 "id da tarefa"
  data type ztrequests002-data,                 "dta. criação da tarefa"
  created_by type ztrequests002-created_by,     "titular da tarefa"
  keywords_en type string,
  keywords_pt type string,
  sfn_tr type ztrequests002-sfn_tr,
  ecc_tr type ztrequests002-ecc_tr,
  mobile_version type ztrequests002-mobile_version,
end of ty_request.

data: it_request type table of ty_request,
      ls_request like it_request.

"buscar os dados
perform busca_dados.

"mostrar os dados
perform  mostra_dados.


*&---------------------------------------------------------------------*
*&      form  busca_dados
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form busca_dados.

  if p_data-low is initial.
    p_data-low = '19000101'.
  endif.

  if p_data-high is initial.
    p_data-high = sy-datum.
  endif.

  select
  ztrequests002~jira
  ztrequests002~cliente
  ztrequests002~produto
  ztrequests002~request
  ztrequests002~task
  ztrequests002~data
  ztrequests002~created_by
  keywords_en
  keywords_pt
  sfn_tr
  ecc_tr
  mobile_version
        into table it_request from ztrequests002
        where jira in r_jira
        and cliente in r_client
        and produto in r_produt
        and request in r_reques
        and task in r_task
        and ( data ge p_data-low and data le p_data-high )
        and created_by in r_creat.


endform.                    "busca_dados

*&---------------------------------------------------------------------*
*&      form  mostra_dados
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form mostra_dados.

  type-pools: slis.

  data:
        it_fieldcat  type slis_t_fieldcat_alv,
        wa_fieldcat  type slis_fieldcat_alv.

  wa_fieldcat-fieldname  = 'JIRA'.
  wa_fieldcat-seltext_m  = 'Jira number'.
  append wa_fieldcat to it_fieldcat.

  wa_fieldcat-fieldname  = 'CLIENTE'.
  wa_fieldcat-seltext_m  = 'Customer'.
  append wa_fieldcat to it_fieldcat.

  wa_fieldcat-fieldname  = 'PRODUTO'.
  wa_fieldcat-seltext_m  = 'Product'.
  append wa_fieldcat to it_fieldcat.

  wa_fieldcat-fieldname  = 'REQUEST'.
  wa_fieldcat-seltext_m  = 'Request'.
  append wa_fieldcat to it_fieldcat.

  wa_fieldcat-fieldname  = 'TASK'.
  wa_fieldcat-seltext_m  = 'Task'.
  append wa_fieldcat to it_fieldcat.

  wa_fieldcat-fieldname  = 'DATA'.
  wa_fieldcat-seltext_m  = 'Creation Date'.
  append wa_fieldcat to it_fieldcat.

  wa_fieldcat-fieldname  = 'CREATED_BY'.
  wa_fieldcat-seltext_m  = 'Created by'.
  append wa_fieldcat to it_fieldcat.

  wa_fieldcat-fieldname  = 'KEYWORDS_EN'.
  wa_fieldcat-seltext_m  = 'KeyWords EN'.
  append wa_fieldcat to it_fieldcat.

  wa_fieldcat-fieldname  = 'KEYWORDS_PT'.
  wa_fieldcat-seltext_m  = 'KeyWords PT'.
  append wa_fieldcat to it_fieldcat.

  wa_fieldcat-fieldname  = 'SFN_TR'.
  wa_fieldcat-seltext_m  = 'SFN dependency'.
  append wa_fieldcat to it_fieldcat.

  wa_fieldcat-fieldname  = 'ECC_TR'.
  wa_fieldcat-seltext_m  = 'ECC dependency'.
  append wa_fieldcat to it_fieldcat.

  wa_fieldcat-fieldname  = 'MOBILE_VERSION'.
  wa_fieldcat-seltext_m  = 'Mobile dependency'.
  append wa_fieldcat to it_fieldcat.

*Emitindo o relatório ALV com utilizando a função REUSE_ALV_GRID_DISPLAY.

  call function 'REUSE_ALV_GRID_DISPLAY'
    exporting
      it_fieldcat = it_fieldcat
    tables
      t_outtab    = it_request.
*   EXCEPTIONS
*     PROGRAM_ERROR                     = 1
*     OTHERS                            = 2
  .
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
  .
endform.                    "mostra_dados
