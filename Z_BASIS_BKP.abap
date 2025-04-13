*&---------------------------------------------------------------------*
*& Report  Z_BASIS_BKP
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

report  z_basis_bkp.

data: ztable type table of ztrequests001.

select * from ztrequests001
  into table ztable.

if sy-subrc = 0.

  call function 'Z_BASIS_BKP' destination 'MW0_TO_E6D'
    IMPORTING
      zcontent = ztable.

endif.
